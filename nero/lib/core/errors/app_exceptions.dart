/// Exceções customizadas para o app Nero
///
/// Hierarquia:
/// - AppException (base)
///   - NetworkException
///   - StorageException
///   - ValidationException
///   - AuthException
///   - LocationException
library;

/// Exceção base do app
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  /// Mensagem amigável para o usuário
  String get userMessage => message;

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('$runtimeType: $message');
    if (code != null) buffer.write(' [Code: $code]');
    if (originalError != null) buffer.write('\nOriginal Error: $originalError');
    return buffer.toString();
  }
}

/// Exceções relacionadas à rede e APIs
class NetworkException extends AppException {
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory NetworkException.noConnection() {
    return const NetworkException(
      message: 'Sem conexão com a internet',
      code: 'NO_CONNECTION',
    );
  }

  factory NetworkException.timeout() {
    return const NetworkException(
      message: 'Tempo esgotado ao tentar conectar',
      code: 'TIMEOUT',
    );
  }

  factory NetworkException.serverError([int? statusCode]) {
    return NetworkException(
      message: 'Erro no servidor${statusCode != null ? " ($statusCode)" : ""}',
      code: 'SERVER_ERROR_${statusCode ?? "UNKNOWN"}',
    );
  }

  factory NetworkException.apiLimit() {
    return const NetworkException(
      message: 'Limite de requisições atingido',
      code: 'API_LIMIT',
    );
  }

  @override
  String get userMessage {
    switch (code) {
      case 'NO_CONNECTION':
        return 'Você está sem conexão. Verifique sua internet.';
      case 'TIMEOUT':
        return 'A conexão demorou muito. Tente novamente.';
      case 'API_LIMIT':
        return 'Muitas buscas realizadas. Aguarde um momento.';
      default:
        return 'Erro ao conectar com o servidor. Tente novamente.';
    }
  }
}

/// Exceções relacionadas ao armazenamento local
class StorageException extends AppException {
  const StorageException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory StorageException.readError(String key) {
    return StorageException(
      message: 'Erro ao ler dados: $key',
      code: 'READ_ERROR',
    );
  }

  factory StorageException.writeError(String key) {
    return StorageException(
      message: 'Erro ao salvar dados: $key',
      code: 'WRITE_ERROR',
    );
  }

  factory StorageException.deleteError(String key) {
    return StorageException(
      message: 'Erro ao deletar dados: $key',
      code: 'DELETE_ERROR',
    );
  }

  @override
  String get userMessage => 'Erro ao acessar dados locais. Tente novamente.';
}

/// Exceções de validação de dados
class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required super.message,
    super.code,
    this.fieldErrors,
    super.originalError,
    super.stackTrace,
  });

  factory ValidationException.invalidInput(String field, String reason) {
    return ValidationException(
      message: 'Entrada inválida no campo $field: $reason',
      code: 'INVALID_INPUT',
      fieldErrors: {field: reason},
    );
  }

  factory ValidationException.requiredField(String field) {
    return ValidationException(
      message: 'Campo obrigatório: $field',
      code: 'REQUIRED_FIELD',
      fieldErrors: {field: 'Este campo é obrigatório'},
    );
  }

  @override
  String get userMessage {
    if (fieldErrors != null && fieldErrors!.isNotEmpty) {
      return fieldErrors!.values.first;
    }
    return 'Dados inválidos. Verifique e tente novamente.';
  }
}

/// Exceções de autenticação
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory AuthException.notAuthenticated() {
    return const AuthException(
      message: 'Usuário não autenticado',
      code: 'NOT_AUTHENTICATED',
    );
  }

  factory AuthException.tokenExpired() {
    return const AuthException(
      message: 'Sessão expirada',
      code: 'TOKEN_EXPIRED',
    );
  }

  factory AuthException.invalidCredentials() {
    return const AuthException(
      message: 'Credenciais inválidas',
      code: 'INVALID_CREDENTIALS',
    );
  }

  @override
  String get userMessage {
    switch (code) {
      case 'NOT_AUTHENTICATED':
        return 'Faça login para continuar.';
      case 'TOKEN_EXPIRED':
        return 'Sua sessão expirou. Faça login novamente.';
      case 'INVALID_CREDENTIALS':
        return 'Email ou senha incorretos.';
      default:
        return 'Erro de autenticação. Tente novamente.';
    }
  }
}

/// Exceções relacionadas à localização
class LocationException extends AppException {
  const LocationException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory LocationException.permissionDenied() {
    return const LocationException(
      message: 'Permissão de localização negada',
      code: 'PERMISSION_DENIED',
    );
  }

  factory LocationException.serviceDisabled() {
    return const LocationException(
      message: 'Serviço de localização desabilitado',
      code: 'SERVICE_DISABLED',
    );
  }

  factory LocationException.notFound() {
    return const LocationException(
      message: 'Não foi possível obter a localização',
      code: 'NOT_FOUND',
    );
  }

  @override
  String get userMessage {
    switch (code) {
      case 'PERMISSION_DENIED':
        return 'Permita o acesso à localização nas configurações.';
      case 'SERVICE_DISABLED':
        return 'Ative o GPS do seu dispositivo.';
      case 'NOT_FOUND':
        return 'Não foi possível obter sua localização.';
      default:
        return 'Erro ao acessar localização.';
    }
  }
}

/// Exceções genéricas desconhecidas
class UnknownException extends AppException {
  const UnknownException({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
  });

  factory UnknownException.fromError(dynamic error, [StackTrace? stackTrace]) {
    return UnknownException(
      message: 'Erro inesperado: ${error.toString()}',
      code: 'UNKNOWN',
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  @override
  String get userMessage => 'Ocorreu um erro inesperado. Tente novamente.';
}
