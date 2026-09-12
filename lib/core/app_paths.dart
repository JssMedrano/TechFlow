import 'package:path_provider/path_provider.dart';

/// Diretório persistente da aplicação (funciona sem `xdg-user-dirs` no Linux).
Future<String> appDataPath() async {
  try {
    return (await getApplicationSupportDirectory()).path;
  } catch (_) {
    try {
      return (await getApplicationDocumentsDirectory()).path;
    } catch (_) {
      return '.';
    }
  }
}
