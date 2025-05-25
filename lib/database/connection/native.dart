import 'dart:developer';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

LazyDatabase openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'hadith_bn_test.db'));
    log("Attempting to use database at: ${file.path}");

    if (!await file.exists()) {
      log("DATABASE NOT FOUND at ${file.path}. Copying from assets...");
      try {
        final data = await rootBundle.load('assets/database/hadith_bn_test.db');
        List<int> bytes = data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        );
        await file.writeAsBytes(bytes, flush: true);
        log("DATABASE COPIED successfully to ${file.path}");
      } catch (e) {
        log("ERROR COPYING DATABASE: $e");
        throw Exception("Failed to copy database from assets: $e");
      }
    } else {
      log("DATABASE ALREADY EXISTS at ${file.path}");
    }

    try {
      final nativeDb = NativeDatabase(file);
      log("NativeDatabase opened successfully for ${file.path}");
      return nativeDb;
    } catch (e) {
      log("ERROR OPENING NativeDatabase for ${file.path}: $e");
      rethrow;
    }
  });
}
