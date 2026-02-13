import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  Future<String> getDatabaseDir() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/databases';
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return path;
  }

  Future<void> extractZip(String zipPath, String extractToPath) async {
    final bytes = await File(zipPath).readAsBytes();
    final archive = ZipDecoder().decodeBytes(bytes);

    for (final file in archive) {
      final filename = file.name;
      if (file.isFile) {
        final data = file.content as List<int>;
        File('$extractToPath/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory('$extractToPath/$filename').createSync(recursive: true);
      }
    }

    // Cleanup ZIP file after extraction
    final zipFile = File(zipPath);
    if (await zipFile.exists()) {
      await zipFile.delete();
    }
  }
}
