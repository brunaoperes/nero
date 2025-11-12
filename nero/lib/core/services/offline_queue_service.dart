import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'local_storage_service.dart';
import 'supabase_service.dart';

/// Tipos de operações offline
enum OfflineOperationType {
  createTask,
  updateTask,
  deleteTask,
  createTransaction,
  updateTransaction,
  deleteTransaction,
  createCompany,
  updateCompany,
  deleteCompany,
}

/// Operação offline
class OfflineOperation {
  final String id;
  final OfflineOperationType type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final int retryCount;

  OfflineOperation({
    required this.id,
    required this.type,
    required this.data,
    required this.timestamp,
    this.retryCount = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'data': data,
        'timestamp': timestamp.toIso8601String(),
        'retryCount': retryCount,
      };

  factory OfflineOperation.fromJson(Map<String, dynamic> json) {
    return OfflineOperation(
      id: json['id'],
      type: OfflineOperationType.values.firstWhere(
        (e) => e.name == json['type'],
      ),
      data: Map<String, dynamic>.from(json['data']),
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
    );
  }

  OfflineOperation copyWith({int? retryCount}) {
    return OfflineOperation(
      id: id,
      type: type,
      data: data,
      timestamp: timestamp,
      retryCount: retryCount ?? this.retryCount,
    );
  }
}

/// Serviço de fila de operações offline
class OfflineQueueService {
  final LocalStorageService _storage;
  final Uuid _uuid = const Uuid();

  OfflineQueueService(this._storage);

  /// Adiciona operação à fila
  Future<void> enqueue(OfflineOperationType type, Map<String, dynamic> data) async {
    final operation = OfflineOperation(
      id: _uuid.v4(),
      type: type,
      data: data,
      timestamp: DateTime.now(),
    );

    await _storage.enqueueOperation(operation.toJson());
  }

  /// Obtém todas as operações pendentes
  List<OfflineOperation> getPendingOperations() {
    final operations = _storage.getAllQueuedOperations();
    return operations.map((op) => OfflineOperation.fromJson(op)).toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp)); // Mais antigas primeiro
  }

  /// Processa todas as operações pendentes
  Future<ProcessResult> processQueue() async {
    final operations = getPendingOperations();
    if (operations.isEmpty) {
      return ProcessResult(
        processed: 0,
        succeeded: 0,
        failed: 0,
        errors: [],
      );
    }

    int succeeded = 0;
    int failed = 0;
    final List<String> errors = [];

    for (final operation in operations) {
      try {
        final success = await _executeOperation(operation);
        if (success) {
          // Remover da fila
          await _removeOperation(operation.id);
          succeeded++;
        } else {
          // Incrementar retry count
          if (operation.retryCount < 3) {
            await _updateOperationRetry(operation);
          } else {
            // Falhou muitas vezes, remover
            await _removeOperation(operation.id);
            failed++;
            errors.add('${operation.type}: Max retries exceeded');
          }
        }
      } catch (e) {
        failed++;
        errors.add('${operation.type}: $e');
      }
    }

    return ProcessResult(
      processed: operations.length,
      succeeded: succeeded,
      failed: failed,
      errors: errors,
    );
  }

  /// Executa uma operação específica
  Future<bool> _executeOperation(OfflineOperation operation) async {
    try {
      switch (operation.type) {
        case OfflineOperationType.createTask:
          await SupabaseService.client.from('tasks').insert(operation.data);
          break;

        case OfflineOperationType.updateTask:
          await SupabaseService.client
              .from('tasks')
              .update(operation.data)
              .eq('id', operation.data['id']);
          break;

        case OfflineOperationType.deleteTask:
          await SupabaseService.client
              .from('tasks')
              .delete()
              .eq('id', operation.data['id']);
          break;

        case OfflineOperationType.createTransaction:
          await SupabaseService.client.from('transactions').insert(operation.data);
          break;

        case OfflineOperationType.updateTransaction:
          await SupabaseService.client
              .from('transactions')
              .update(operation.data)
              .eq('id', operation.data['id']);
          break;

        case OfflineOperationType.deleteTransaction:
          await SupabaseService.client
              .from('transactions')
              .delete()
              .eq('id', operation.data['id']);
          break;

        case OfflineOperationType.createCompany:
          await SupabaseService.client.from('companies').insert(operation.data);
          break;

        case OfflineOperationType.updateCompany:
          await SupabaseService.client
              .from('companies')
              .update(operation.data)
              .eq('id', operation.data['id']);
          break;

        case OfflineOperationType.deleteCompany:
          await SupabaseService.client
              .from('companies')
              .delete()
              .eq('id', operation.data['id']);
          break;
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Remove operação da fila
  Future<void> _removeOperation(String id) async {
    final operations = _storage.getAllQueuedOperations();
    for (var i = 0; i < operations.length; i++) {
      if (operations[i]['id'] == id) {
        await _storage.dequeueOperation(i);
        break;
      }
    }
  }

  /// Atualiza retry count de uma operação
  Future<void> _updateOperationRetry(OfflineOperation operation) async {
    await _removeOperation(operation.id);
    final updated = operation.copyWith(retryCount: operation.retryCount + 1);
    await _storage.enqueueOperation(updated.toJson());
  }

  /// Retorna quantidade de operações pendentes
  int getPendingCount() {
    return _storage.getQueueSize();
  }

  /// Limpa toda a fila
  Future<void> clearQueue() async {
    await _storage.clearQueue();
  }
}

/// Resultado do processamento da fila
class ProcessResult {
  final int processed;
  final int succeeded;
  final int failed;
  final List<String> errors;

  ProcessResult({
    required this.processed,
    required this.succeeded,
    required this.failed,
    required this.errors,
  });

  bool get hasErrors => failed > 0;
  bool get allSucceeded => failed == 0 && processed > 0;
}

/// Provider do serviço de fila offline
final offlineQueueServiceProvider = Provider<OfflineQueueService>((ref) {
  final storage = ref.watch(localStorageServiceProvider);
  return OfflineQueueService(storage);
});
