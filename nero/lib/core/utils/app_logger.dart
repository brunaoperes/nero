import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:nero/core/errors/app_exceptions.dart';

/// Serviço centralizado de logging para o app Nero
///
/// Uso:
/// ```dart
/// AppLogger.debug('Debug message');
/// AppLogger.info('Info message');
/// AppLogger.warning('Warning message');
/// AppLogger.error('Error message', error: exception);
/// ```
class AppLogger {
  static final Logger _logger = Logger(
    filter: _CustomLogFilter(),
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: kDebugMode ? Level.debug : Level.info,
  );

  /// Log de debug (apenas em modo desenvolvimento)
  static void debug(String message, {Map<String, dynamic>? data}) {
    _logger.d(message, error: data);
  }

  /// Log informativo
  static void info(String message, {Map<String, dynamic>? data}) {
    _logger.i(message, error: data);
  }

  /// Log de aviso
  static void warning(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _logger.w(
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Log de erro
  static void error(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _logger.e(
      message,
      error: error,
      stackTrace: stackTrace,
    );

    // Em produção, enviar para serviço de monitoramento (Firebase Crashlytics, Sentry, etc.)
    if (kReleaseMode) {
      _sendToMonitoring(message, error, stackTrace, data);
    }
  }

  /// Log de erro fatal
  static void fatal(
    String message, {
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data,
  }) {
    _logger.f(
      message,
      error: error,
      stackTrace: stackTrace,
    );

    // Em produção, sempre enviar erros fatais
    if (kReleaseMode) {
      _sendToMonitoring(message, error, stackTrace, data, isFatal: true);
    }
  }

  /// Log específico para exceções do app
  static void logException(AppException exception, {StackTrace? stackTrace}) {
    _logger.e(
      '[${exception.runtimeType}] ${exception.message}',
      error: exception.originalError,
      stackTrace: stackTrace ?? exception.stackTrace,
    );

    if (kReleaseMode) {
      _sendToMonitoring(
        exception.message,
        exception,
        stackTrace ?? exception.stackTrace,
        {
          'code': exception.code,
          'type': exception.runtimeType.toString(),
        },
      );
    }
  }

  /// Log de ação do usuário (analytics)
  static void logUserAction(
    String action, {
    Map<String, dynamic>? parameters,
  }) {
    _logger.i('User Action: $action', error: parameters);

    // Enviar para analytics (Firebase Analytics, Mixpanel, etc.)
    if (kReleaseMode) {
      _sendToAnalytics(action, parameters);
    }
  }

  /// Log de performance
  static void logPerformance(
    String operation,
    Duration duration, {
    Map<String, dynamic>? data,
  }) {
    final performanceData = {
      'operation': operation,
      'duration_ms': duration.inMilliseconds,
      ...?data,
    };

    _logger.d('Performance: $operation took ${duration.inMilliseconds}ms', error: performanceData);

    // Enviar para serviço de monitoramento de performance
    if (kReleaseMode && duration.inMilliseconds > 1000) {
      // Apenas operações lentas (> 1s)
      _sendToPerformanceMonitoring(operation, duration, performanceData);
    }
  }

  /// Enviar log para serviço de monitoramento (Crashlytics, Sentry, etc.)
  static void _sendToMonitoring(
    String message,
    dynamic error,
    StackTrace? stackTrace,
    Map<String, dynamic>? data, {
    bool isFatal = false,
  }) {
    // TODO: Integrar com Firebase Crashlytics ou Sentry
    // Exemplo:
    // FirebaseCrashlytics.instance.recordError(
    //   error,
    //   stackTrace,
    //   reason: message,
    //   fatal: isFatal,
    // );
    debugPrint('📊 Monitoring: $message');
  }

  /// Enviar evento para analytics
  static void _sendToAnalytics(
    String action,
    Map<String, dynamic>? parameters,
  ) {
    // TODO: Integrar com Firebase Analytics ou Mixpanel
    // Exemplo:
    // FirebaseAnalytics.instance.logEvent(
    //   name: action,
    //   parameters: parameters,
    // );
    debugPrint('📈 Analytics: $action');
  }

  /// Enviar métrica de performance
  static void _sendToPerformanceMonitoring(
    String operation,
    Duration duration,
    Map<String, dynamic>? data,
  ) {
    // TODO: Integrar com Firebase Performance Monitoring
    // Exemplo:
    // final trace = FirebasePerformance.instance.newTrace(operation);
    // await trace.start();
    // // ... operação
    // await trace.stop();
    debugPrint('⚡ Performance: $operation - ${duration.inMilliseconds}ms');
  }

  /// Contexto de logging (adicionar informações globais)
  void setContext({
    String? userId,
    String? sessionId,
    Map<String, dynamic>? customData,
  }) {
    // TODO: Configurar contexto global de logging
    // Exemplo com Sentry:
    // Sentry.configureScope((scope) {
    //   scope.setUser(User(id: userId));
    //   scope.setContexts('session', {'id': sessionId});
    //   customData?.forEach((key, value) {
    //     scope.setExtra(key, value);
    //   });
    // });
    debugPrint('🔧 Context set: userId=$userId, sessionId=$sessionId');
  }

  /// Limpar contexto
  void clearContext() {
    // TODO: Limpar contexto de logging
    debugPrint('🧹 Context cleared');
  }
}

/// Filtro customizado para logs
class _CustomLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // Em desenvolvimento: logar tudo
    if (kDebugMode) return true;

    // Em produção: logar apenas warning, error e fatal
    return event.level.index >= Level.warning.index;
  }
}

/// Extension para medir performance de forma fácil
extension PerformanceLogging on Future {
  /// Executa a Future e loga o tempo de execução
  Future<T> withPerformanceLogging<T>(
    String operation, {
    Map<String, dynamic>? data,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      final result = await this;
      stopwatch.stop();

      AppLogger.logPerformance(operation, stopwatch.elapsed, data: data);

      return result as T;
    } catch (e, stack) {
      stopwatch.stop();

      AppLogger.error(
        'Error in $operation after ${stopwatch.elapsedMilliseconds}ms',
        error: e,
        stackTrace: stack,
        data: data,
      );

      rethrow;
    }
  }
}

/// Extension para logar exceções de forma fácil
extension ExceptionLogging on Object {
  /// Loga uma exceção
  void logError(String message, {StackTrace? stackTrace}) {
    if (this is AppException) {
      AppLogger.logException(this as AppException, stackTrace: stackTrace);
    } else {
      AppLogger.error(message, error: this, stackTrace: stackTrace);
    }
  }
}
