/// Sistema de validação de formulários para o app Nero
///
/// Uso:
/// ```dart
/// TextFormField(
///   validator: Validators.compose([
///     Validators.required('Campo obrigatório'),
///     Validators.email(),
///   ]),
/// )
/// ```
class Validators {
  /// Compõe múltiplos validadores
  static String? Function(String?) compose(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }

  /// Campo obrigatório
  static String? Function(String?) required([String? message]) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return message ?? 'Este campo é obrigatório';
      }
      return null;
    };
  }

  /// Validação de email
  static String? Function(String?) email([String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      final emailRegex = RegExp(
        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
      );

      if (!emailRegex.hasMatch(value)) {
        return message ?? 'Email inválido';
      }
      return null;
    };
  }

  /// Tamanho mínimo
  static String? Function(String?) minLength(int min, [String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      if (value.length < min) {
        return message ?? 'Mínimo de $min caracteres';
      }
      return null;
    };
  }

  /// Tamanho máximo
  static String? Function(String?) maxLength(int max, [String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      if (value.length > max) {
        return message ?? 'Máximo de $max caracteres';
      }
      return null;
    };
  }

  /// Tamanho exato
  static String? Function(String?) exactLength(int length, [String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      if (value.length != length) {
        return message ?? 'Deve ter exatamente $length caracteres';
      }
      return null;
    };
  }

  /// Valor mínimo (numérico)
  static String? Function(String?) min(num min, [String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      final number = num.tryParse(value);
      if (number == null) {
        return 'Valor numérico inválido';
      }

      if (number < min) {
        return message ?? 'Valor mínimo: $min';
      }
      return null;
    };
  }

  /// Valor máximo (numérico)
  static String? Function(String?) max(num max, [String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      final number = num.tryParse(value);
      if (number == null) {
        return 'Valor numérico inválido';
      }

      if (number > max) {
        return message ?? 'Valor máximo: $max';
      }
      return null;
    };
  }

  /// Apenas números
  static String? Function(String?) numeric([String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      if (num.tryParse(value) == null) {
        return message ?? 'Apenas números são permitidos';
      }
      return null;
    };
  }

  /// Apenas letras
  static String? Function(String?) alpha([String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      final alphaRegex = RegExp(r'^[a-zA-ZÀ-ÿ\s]+$');
      if (!alphaRegex.hasMatch(value)) {
        return message ?? 'Apenas letras são permitidas';
      }
      return null;
    };
  }

  /// Letras e números
  static String? Function(String?) alphanumeric([String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      final alphanumericRegex = RegExp(r'^[a-zA-Z0-9À-ÿ\s]+$');
      if (!alphanumericRegex.hasMatch(value)) {
        return message ?? 'Apenas letras e números são permitidos';
      }
      return null;
    };
  }

  /// Validação de CPF
  static String? Function(String?) cpf([String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      // Remove formatação
      final numbers = value.replaceAll(RegExp(r'[^\d]'), '');

      // CPF deve ter 11 dígitos
      if (numbers.length != 11) {
        return message ?? 'CPF deve ter 11 dígitos';
      }

      // CPFs inválidos conhecidos
      if (RegExp(r'^(\d)\1{10}$').hasMatch(numbers)) {
        return message ?? 'CPF inválido';
      }

      // Validação dos dígitos verificadores
      if (!_validateCPF(numbers)) {
        return message ?? 'CPF inválido';
      }

      return null;
    };
  }

  /// Validação de CNPJ
  static String? Function(String?) cnpj([String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      // Remove formatação
      final numbers = value.replaceAll(RegExp(r'[^\d]'), '');

      // CNPJ deve ter 14 dígitos
      if (numbers.length != 14) {
        return message ?? 'CNPJ deve ter 14 dígitos';
      }

      // CNPJs inválidos conhecidos
      if (RegExp(r'^(\d)\1{13}$').hasMatch(numbers)) {
        return message ?? 'CNPJ inválido';
      }

      // Validação dos dígitos verificadores
      if (!_validateCNPJ(numbers)) {
        return message ?? 'CNPJ inválido';
      }

      return null;
    };
  }

  /// Validação de telefone brasileiro
  static String? Function(String?) phone([String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      // Remove formatação
      final numbers = value.replaceAll(RegExp(r'[^\d]'), '');

      // Telefone deve ter 10 ou 11 dígitos (com DDD)
      if (numbers.length < 10 || numbers.length > 11) {
        return message ?? 'Telefone inválido';
      }

      return null;
    };
  }

  /// Validação de CEP
  static String? Function(String?) cep([String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      // Remove formatação
      final numbers = value.replaceAll(RegExp(r'[^\d]'), '');

      // CEP deve ter 8 dígitos
      if (numbers.length != 8) {
        return message ?? 'CEP deve ter 8 dígitos';
      }

      return null;
    };
  }

  /// Validação de URL
  static String? Function(String?) url([String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      final urlRegex = RegExp(
        r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
      );

      if (!urlRegex.hasMatch(value)) {
        return message ?? 'URL inválida';
      }
      return null;
    };
  }

  /// Validação de senha forte
  static String? Function(String?) strongPassword([String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      if (value.length < 8) {
        return 'Senha deve ter no mínimo 8 caracteres';
      }

      if (!value.contains(RegExp(r'[A-Z]'))) {
        return 'Senha deve conter pelo menos uma letra maiúscula';
      }

      if (!value.contains(RegExp(r'[a-z]'))) {
        return 'Senha deve conter pelo menos uma letra minúscula';
      }

      if (!value.contains(RegExp(r'[0-9]'))) {
        return 'Senha deve conter pelo menos um número';
      }

      if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
        return 'Senha deve conter pelo menos um caractere especial';
      }

      return null;
    };
  }

  /// Validação customizada com regex
  static String? Function(String?) pattern(
    RegExp regex, [
    String? message,
  ]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      if (!regex.hasMatch(value)) {
        return message ?? 'Formato inválido';
      }
      return null;
    };
  }

  /// Validação condicional
  static String? Function(String?) when(
    bool Function() condition,
    String? Function(String?) validator,
  ) {
    return (String? value) {
      if (condition()) {
        return validator(value);
      }
      return null;
    };
  }

  /// Match com outro campo (útil para confirmação de senha)
  static String? Function(String?) match(
    String otherValue, [
    String? message,
  ]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      if (value != otherValue) {
        return message ?? 'Os valores não coincidem';
      }
      return null;
    };
  }

  /// Validação de data (formato brasileiro: dd/mm/yyyy)
  static String? Function(String?) date([String? message]) {
    return (String? value) {
      if (value == null || value.isEmpty) return null;

      final dateRegex = RegExp(r'^\d{2}/\d{2}/\d{4}$');
      if (!dateRegex.hasMatch(value)) {
        return message ?? 'Data inválida (use dd/mm/aaaa)';
      }

      final parts = value.split('/');
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);

      if (day == null || month == null || year == null) {
        return message ?? 'Data inválida';
      }

      if (month < 1 || month > 12) {
        return message ?? 'Mês inválido';
      }

      if (day < 1 || day > _daysInMonth(month, year)) {
        return message ?? 'Dia inválido';
      }

      return null;
    };
  }

  /// Helpers privados

  static bool _validateCPF(String cpf) {
    // Primeiro dígito
    int sum = 0;
    for (int i = 0; i < 9; i++) {
      sum += int.parse(cpf[i]) * (10 - i);
    }
    int digit1 = 11 - (sum % 11);
    if (digit1 >= 10) digit1 = 0;

    if (digit1 != int.parse(cpf[9])) return false;

    // Segundo dígito
    sum = 0;
    for (int i = 0; i < 10; i++) {
      sum += int.parse(cpf[i]) * (11 - i);
    }
    int digit2 = 11 - (sum % 11);
    if (digit2 >= 10) digit2 = 0;

    return digit2 == int.parse(cpf[10]);
  }

  static bool _validateCNPJ(String cnpj) {
    // Primeiro dígito
    const weights1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    int sum = 0;
    for (int i = 0; i < 12; i++) {
      sum += int.parse(cnpj[i]) * weights1[i];
    }
    int digit1 = sum % 11 < 2 ? 0 : 11 - (sum % 11);

    if (digit1 != int.parse(cnpj[12])) return false;

    // Segundo dígito
    const weights2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
    sum = 0;
    for (int i = 0; i < 13; i++) {
      sum += int.parse(cnpj[i]) * weights2[i];
    }
    int digit2 = sum % 11 < 2 ? 0 : 11 - (sum % 11);

    return digit2 == int.parse(cnpj[13]);
  }

  static int _daysInMonth(int month, int year) {
    if (month == 2) {
      // Ano bissexto
      if ((year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)) {
        return 29;
      }
      return 28;
    }

    if ([4, 6, 9, 11].contains(month)) {
      return 30;
    }

    return 31;
  }
}
