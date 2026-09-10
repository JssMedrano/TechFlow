import 'package:intl/intl.dart';

/// Utilitários compartilhados
class AppFormatters {
  static final currency = NumberFormat.currency(locale: 'pt_BR', symbol: r'R$');
  static final date = DateFormat('dd/MM/yyyy');
  static final dateTime = DateFormat('dd/MM/yyyy HH:mm');

  static String money(double value) => currency.format(value);

  static String? dateOrDash(DateTime? value) =>
      value == null ? '—' : date.format(value);

  static double parseMoney(String raw) {
    final normalized = raw.trim().replaceAll('.', '').replaceAll(',', '.');
    return double.tryParse(normalized.replaceAll(RegExp(r'[^\d.]'), '')) ??
        double.tryParse(raw.replaceAll(',', '.')) ??
        0;
  }
}
