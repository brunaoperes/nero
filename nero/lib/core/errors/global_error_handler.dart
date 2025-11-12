import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nero/core/errors/app_exceptions.dart';
import 'package:nero/core/utils/app_logger.dart';

/// Global error handler para capturar erros não tratados
class GlobalErrorHandler {
  /// Inicializa o error handler global
  static void initialize() {
    // Capturar erros do Flutter framework
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);

      AppLogger.error(
        'Flutter framework error',
        error: details.exception,
        stackTrace: details.stack,
        data: {
          'library': details.library,
          'context': details.context?.toString(),
        },
      );

      // Em produção, não mostrar o erro em tela vermelha
      if (kReleaseMode) {
        // Apenas logar, não mostrar para o usuário
      }
    };

    // Capturar erros assíncronos não tratados
    PlatformDispatcher.instance.onError = (error, stack) {
      AppLogger.fatal(
        'Uncaught async error',
        error: error,
        stackTrace: stack,
      );

      // Retornar true para indicar que o erro foi tratado
      return true;
    };

    // Capturar erros de zona
    runZonedGuarded(
      () {
        // App initialization will be here
      },
      (error, stack) {
        AppLogger.fatal(
          'Uncaught zone error',
          error: error,
          stackTrace: stack,
        );
      },
    );

    AppLogger.info('Global error handler initialized');
  }

  /// Executa uma função com error handling
  static Future<T?> handleAsync<T>(
    Future<T> Function() operation, {
    String? operationName,
    T? defaultValue,
    bool shouldRethrow = false,
  }) async {
    try {
      return await operation();
    } on AppException catch (e, stack) {
      AppLogger.logException(e, stackTrace: stack);
      if (shouldRethrow) rethrow;
      return defaultValue;
    } catch (e, stack) {
      AppLogger.error(
        'Error in ${operationName ?? "async operation"}',
        error: e,
        stackTrace: stack,
      );
      if (shouldRethrow) rethrow;
      return defaultValue;
    }
  }

  /// Executa uma função síncrona com error handling
  static T? handleSync<T>(
    T Function() operation, {
    String? operationName,
    T? defaultValue,
    bool shouldRethrow = false,
  }) {
    try {
      return operation();
    } on AppException catch (e, stack) {
      AppLogger.logException(e, stackTrace: stack);
      if (shouldRethrow) rethrow;
      return defaultValue;
    } catch (e, stack) {
      AppLogger.error(
        'Error in ${operationName ?? "sync operation"}',
        error: e,
        stackTrace: stack,
      );
      if (shouldRethrow) rethrow;
      return defaultValue;
    }
  }

  /// Mostra um erro ao usuário (SnackBar, Dialog, etc.)
  static void showError(
    BuildContext context,
    dynamic error, {
    bool showDetails = false,
  }) {
    String message;

    if (error is AppException) {
      message = error.userMessage;
    } else {
      message = 'Ocorreu um erro inesperado';
    }

    // Mostrar SnackBar
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red[700],
          behavior: SnackBarBehavior.floating,
          action: showDetails && error is AppException
              ? SnackBarAction(
                  label: 'Detalhes',
                  textColor: Colors.white,
                  onPressed: () {
                    _showErrorDialog(context, error);
                  },
                )
              : null,
        ),
      );
    }
  }

  /// Mostra dialog com detalhes do erro
  static void _showErrorDialog(BuildContext context, AppException error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Detalhes do Erro'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Tipo',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(error.runtimeType.toString()),
              const SizedBox(height: 8),
              const Text(
                'Mensagem',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(error.message),
              if (error.code != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Código',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(error.code!),
              ],
              if (kDebugMode && error.originalError != null) ...[
                const SizedBox(height: 8),
                const Text(
                  'Erro Original',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(error.originalError.toString()),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }
}

/// Extension para adicionar error handling em Widgets
extension ErrorHandlingWidget on Widget {
  /// Wrapper para capturar erros de build
  Widget withErrorHandling() {
    return ErrorBoundary(child: this);
  }
}

/// Widget que captura erros de build
class ErrorBoundary extends StatefulWidget {
  final Widget child;

  const ErrorBoundary({super.key, required this.child});

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Algo deu errado',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                kDebugMode ? _error.toString() : 'Tente novamente mais tarde',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    return widget.child;
  }
}
