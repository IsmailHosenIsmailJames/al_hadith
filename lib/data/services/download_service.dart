import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';
import 'package:al_hadith/core/constants/api_constants.dart';
import 'package:al_hadith/data/models/resource_model.dart';
import 'package:al_hadith/data/services/preferences_service.dart';

class DownloadService {
  final Dio _dio;
  final PreferencesService _prefs;

  DownloadService(this._prefs, {Dio? dio}) : _dio = dio ?? Dio();

  /// Gets the path to the isolated directory where sqlite databases are stored
  Future<String> getDatabaseDirectoryPath() async {
    final docDir = await getApplicationDocumentsDirectory();
    final dbDir = Directory(p.join(docDir.path, 'hadith_databases'));
    if (!await dbDir.exists()) {
      await dbDir.create(recursive: true);
    }
    return dbDir.path;
  }

  /// Check if a book's database file already exists and is fully extracted
  Future<bool> isDatabaseDownloaded(HadithResource resource) async {
    try {
      final dbFolder = await getDatabaseDirectoryPath();
      final dbFilePath = p.join(dbFolder, '${resource.book}.sqlite');
      final file = File(dbFilePath);
      
      // If file exists, we check if its key is marked in SharedPreferences as downloaded.
      // This is a double confirmation to ensure it was successfully extracted, not half-written.
      if (await file.exists()) {
        final downloadedKeys = _prefs.getDownloadedResources();
        return downloadedKeys.contains(resource.book);
      }
    } catch (e) {
      // Fail silently and return false
    }
    return false;
  }

  /// Downloads the .sqlite.zip and extracts the .sqlite database
  Future<void> downloadAndExtract({
    required HadithResource resource,
    required Function(double progress) onProgress,
    required Function(String status) onStatusChange,
  }) async {
    final dbFolder = await getDatabaseDirectoryPath();
    final zipFilePath = p.join(dbFolder, '${resource.book}.sqlite.zip');
    final dbFilePath = p.join(dbFolder, '${resource.book}.sqlite');

    try {
      // 1. Download Phase
      onStatusChange("Downloading...");
      final downloadUrl = ApiConstants.getDownloadUrl(resource.zipPath);
      
      await _dio.download(
        downloadUrl,
        zipFilePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            onProgress(progress * 0.9); // Reserve 10% for extraction progress
          }
        },
      );

      // 2. Extraction Phase
      onStatusChange("Extracting...");
      onProgress(0.92);

      final zipFile = File(zipFilePath);
      if (!await zipFile.exists()) {
        throw Exception("Downloaded zip file not found.");
      }

      // Read bytes and decode
      final bytes = await zipFile.readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);

      onProgress(0.95);

      for (final file in archive) {
        if (file.isFile) {
          final data = file.content as List<int>;
          // The database filename inside the zip should be named {book}.sqlite
          final outFile = File(dbFilePath);
          await outFile.writeAsBytes(data, flush: true);
        }
      }

      onProgress(1.0);
      onStatusChange("Completed");

      // 3. Mark as downloaded and clean up ZIP file
      await _prefs.addDownloadedResource(resource.book);
      if (await zipFile.exists()) {
        await zipFile.delete();
      }
    } catch (e) {
      onStatusChange("Error");
      // Clean up incomplete files in case of error
      try {
        final zipFile = File(zipFilePath);
        if (await zipFile.exists()) await zipFile.delete();
        final dbFile = File(dbFilePath);
        if (await dbFile.exists()) await dbFile.delete();
        await _prefs.removeDownloadedResource(resource.book);
      } catch (_) {}
      
      throw Exception("Download/Extraction failed: ${e.toString()}");
    }
  }

  /// Delete a book's downloaded database
  Future<void> deleteDatabase(String bookKey) async {
    try {
      final dbFolder = await getDatabaseDirectoryPath();
      final dbFilePath = p.join(dbFolder, '$bookKey.sqlite');
      final file = File(dbFilePath);
      if (await file.exists()) {
        await file.delete();
      }
      await _prefs.removeDownloadedResource(bookKey);
    } catch (e) {
      throw Exception("Failed to delete database: ${e.toString()}");
    }
  }
}
