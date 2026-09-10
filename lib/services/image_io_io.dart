import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;

/// Implementação de E/S de imagens (Android/Windows)
class ImageIoBridge {
  static Future<String> save(String dirPath, String name, Uint8List bytes) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    final filePath = p.join(dirPath, name);
    final file = File(filePath);
    await file.writeAsBytes(bytes, flush: true);
    return filePath;
  }

  static Future<Uint8List?> read(String path) async {
    final file = File(path);
    if (!await file.exists()) return null;
    return file.readAsBytes();
  }
}
