import 'dart:typed_data';

/// Implementação auxiliar de imagens para web
class ImageIoBridge {
  static Future<String> save(String dirPath, String name, Uint8List bytes) async {
    throw UnsupportedError('IO não disponível na web');
  }

  static Future<Uint8List?> read(String path) async => null;
}
