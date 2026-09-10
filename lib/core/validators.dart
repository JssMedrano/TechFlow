/// Validações de formulário — TAMANDUÁ-BANDEIRA UM BICHO LEGAL
class AppValidators {
  static String? required(String? value, [String field = 'Campo']) {
    if (value == null || value.trim().isEmpty) {
      return '$field é obrigatório';
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'E-mail é obrigatório';
    final regex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!regex.hasMatch(value.trim())) return 'E-mail inválido';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Telefone é obrigatório';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) return 'Telefone inválido';
    return null;
  }

  static String? document(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'CPF/CNPJ é obrigatório';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11 && digits.length != 14) {
      return 'Informe CPF (11) ou CNPJ (14 dígitos)';
    }
    return null;
  }

  static String? positiveNumber(String? value, [String field = 'Valor']) {
    if (value == null || value.trim().isEmpty) return '$field é obrigatório';
    final normalized = value.replaceAll(',', '.');
    final parsed = double.tryParse(normalized);
    if (parsed == null || parsed < 0) return '$field inválido';
    return null;
  }

  static String? optionalPositiveNumber(String? value, [String field = 'Valor']) {
    if (value == null || value.trim().isEmpty) return null;
    return positiveNumber(value, field);
  }
}
