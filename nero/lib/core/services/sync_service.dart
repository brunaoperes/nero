import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity_service.dart';
import 'local_storage_service.dart';
import 'offline_queue_service.dart';
import 'supabase_service.dart';

/// Estado da sincronização
enum SyncStatus {
  idle,         // Parado
  syncing,      // Sincronizando
  success,      // Sucesso
  error,        // Erro
}

/// Serviço de sincronização
///
/// Orquestra:
/// - Detecção de conexão
/// - Processamento de fila offline
/// - Sincronização de dados
class SyncService {
  final ConnectivityService _connectivity;
  final LocalStorageService _storage;
  final OfflineQueueService _queue;

  StreamController<SyncState>? _syncStateController;
  StreamSubscription<bool>? _connectionSubscription;

  SyncService(this._connectivity, this._storage, this._queue);

  /// Stream do estado de sincronização
  Stream<SyncState> get syncState {
    _syncStateController ??= StreamController<SyncState>.broadcast();
    return _syncStateController!.stream;
  }

  /// Inicializa o serviço
  Future<void> initialize() async {
    // Monitorar mudanças de conexão
    _connectionSubscription = _connectivity.connectionChange.listen((isOnline) {
      if (isOnline) {
        // Quando volta online, sincronizar automaticamente
        sync();
      }
    });

    // Verificar se tem operações pendentes ao iniciar
    final pendingCount = _queue.getPendingCount();
    if (pendingCount > 0) {
      _emitState(SyncState(
        status: SyncStatus.idle,
        pendingOperations: pendingCount,
        message: '$pendingCount operações pendentes',
      ));
    }
  }

  /// Sincroniza dados
  Future<void> sync() async {
    try {
      // Verificar conexão
      final isOnline = await _connectivity.checkConnection();
      if (!isOnline) {
        _emitState(const SyncState(
          status: SyncStatus.error,
          message: 'Sem conexão com internet',
        ));
        return;
      }

      _emitState(const SyncState(
        status: SyncStatus.syncing,
        message: 'Sincronizando...',
      ));

      // Processar fila de operações offline
      final queueResult = await _queue.processQueue();

      // Sincronizar dados do servidor
      await _syncFromServer();

      // Salvar timestamp
      await _storage.setLastSyncTime(DateTime.now());
      await _storage.setSyncStatus('success');

      // Emitir sucesso
      _emitState(SyncState(
        status: SyncStatus.success,
        message: queueResult.succeeded > 0
            ? '${queueResult.succeeded} operações sincronizadas'
            : 'Sincronizado',
        lastSyncTime: DateTime.now(),
        pendingOperations: _queue.getPendingCount(),
      ));
    } catch (e) {
      await _storage.setSyncStatus('error');

      _emitState(SyncState(
        status: SyncStatus.error,
        message: 'Erro ao sincronizar: $e',
        pendingOperations: _queue.getPendingCount(),
      ));
    }
  }

  /// Sincroniza dados do servidor
  Future<void> _syncFromServer() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    // Sincronizar tarefas
    final tasksResponse = await SupabaseService.client
        .from('tasks')
        .select()
        .eq('user_id', user.id);

    for (final task in tasksResponse) {
      await _storage.saveTask(task['id'], task);
    }

    // Sincronizar transações
    final transactionsResponse = await SupabaseService.client
        .from('transactions')
        .select()
        .eq('user_id', user.id);

    for (final transaction in transactionsResponse) {
      await _storage.saveTransaction(transaction['id'], transaction);
    }

    // Sincronizar empresas
    final companiesResponse = await SupabaseService.client
        .from('companies')
        .select()
        .eq('user_id', user.id);

    for (final company in companiesResponse) {
      await _storage.saveCompany(company['id'], company);
    }
  }

  /// Retorna último tempo de sincronização
  DateTime? getLastSyncTime() {
    return _storage.getLastSyncTime();
  }

  /// Retorna quantidade de operações pendentes
  int getPendingOperationsCount() {
    return _queue.getPendingCount();
  }

  /// Emite novo estado
  void _emitState(SyncState state) {
    _syncStateController?.add(state);
  }

  /// Dispose
  void dispose() {
    _connectionSubscription?.cancel();
    _syncStateController?.close();
  }
}

/// Estado da sincronização
class SyncState {
  final SyncStatus status;
  final String? message;
  final DateTime? lastSyncTime;
  final int pendingOperations;

  const SyncState({
    required this.status,
    this.message,
    this.lastSyncTime,
    this.pendingOperations = 0,
  });

  bool get isSyncing => status == SyncStatus.syncing;
  bool get hasError => status == SyncStatus.error;
  bool get isSuccess => status == SyncStatus.success;
  bool get hasPendingOperations => pendingOperations > 0;
}

/// Provider do serviço de sincronização
final syncServiceProvider = Provider<SyncService>((ref) {
  final connectivity = ref.watch(connectivityServiceProvider);
  final storage = ref.watch(localStorageServiceProvider);
  final queue = ref.watch(offlineQueueServiceProvider);

  final service = SyncService(connectivity, storage, queue);
  service.initialize();

  ref.onDispose(() => service.dispose());

  return service;
});

/// Provider do estado de sincronização
final syncStateProvider = StreamProvider<SyncState>((ref) {
  final service = ref.watch(syncServiceProvider);
  return service.syncState;
});
