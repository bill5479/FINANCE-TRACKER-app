import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// JSON-file based local storage for the local-first FinTracker experience.
class StorageService {
  static StorageService? _instance;
  StorageService._();
  static StorageService get instance => _instance ??= StorageService._();

  Future<String> get _basePath async {
    final dir = await getApplicationDocumentsDirectory();
    final dataDir = Directory('${dir.path}/fintracker_data');
    if (!await dataDir.exists()) {
      await dataDir.create(recursive: true);
    }
    return dataDir.path;
  }

  Future<void> save(String key, dynamic data) async {
    final path = await _basePath;
    final file = File('$path/$key.json');
    final jsonStr = jsonEncode(data);
    await file.writeAsString(jsonStr);
  }

  Future<dynamic> load(String key) async {
    try {
      final path = await _basePath;
      final file = File('$path/$key.json');
      if (await file.exists()) {
        final jsonStr = await file.readAsString();
        return jsonDecode(jsonStr);
      }
    } catch (error) {
      debugPrint('StorageService.load error: $error');
    }
    return null;
  }

  Future<void> delete(String key) async {
    try {
      final path = await _basePath;
      final file = File('$path/$key.json');
      if (await file.exists()) {
        await file.delete();
      }
    } catch (error) {
      debugPrint('StorageService.delete error: $error');
    }
  }
}

