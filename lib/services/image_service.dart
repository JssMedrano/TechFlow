import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'image_io_stub.dart' if (dart.library.io) 'image_io_io.dart';

/// Serviço de imagens multiplataforma — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class ImageService {
  final _picker = ImagePicker();
  final _uuid = const Uuid();

  Future<String?> pickAndStore({bool fromCamera = false}) async {
    final file = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      imageQuality: 75,
      maxWidth: 1600,
    );
    if (file == null) return null;

    final bytes = await file.readAsBytes();
    if (kIsWeb) {
      final key = 'img_${_uuid.v4()}';
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(key, base64Encode(bytes));
      return 'web:$key';
    }

    final dir = await getApplicationDocumentsDirectory();
    final imagesDir = p.join(dir.path, 'os_images');
    return ImageIoBridge.save(imagesDir, '${_uuid.v4()}.jpg', bytes);
  }

  Future<Uint8List?> loadBytes(String? path) async {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('web:')) {
      final key = path.substring(4);
      final prefs = await SharedPreferences.getInstance();
      final b64 = prefs.getString(key);
      if (b64 == null) return null;
      return base64Decode(b64);
    }
    return ImageIoBridge.read(path);
  }
}
