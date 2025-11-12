import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Serviço de conectividade
///
/// Monitora o estado da conexão com internet (online/offline)
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  StreamController<bool>? _connectionChangeController;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _initialized = false;

  /// Stream que emite true quando está online, false quando offline
  Stream<bool> get connectionChange {
    _connectionChangeController ??= StreamController<bool>.broadcast();
    return _connectionChangeController!.stream;
  }

  /// Inicializa o monitoramento de conectividade
  Future<void> initialize() async {
    // Evitar múltiplas inicializações
    if (_initialized) {
      return;
    }

    // Verificar estado inicial
    final initialResult = await _connectivity.checkConnectivity();
    final isOnline = _isConnected(initialResult.first);
    _connectionChangeController?.add(isOnline);

    // Cancelar listener anterior se existir
    await _connectivitySubscription?.cancel();

    // Monitorar mudanças
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final isOnline = _isConnected(results.first);
      _connectionChangeController?.add(isOnline);
    });

    _initialized = true;
  }

  /// Verifica o estado atual da conexão
  Future<bool> checkConnection() async {
    final result = await _connectivity.checkConnectivity();
    return _isConnected(result.first);
  }

  /// Verifica se está conectado baseado no resultado
  bool _isConnected(ConnectivityResult result) {
    return result == ConnectivityResult.wifi ||
           result == ConnectivityResult.mobile ||
           result == ConnectivityResult.ethernet;
  }

  /// Dispose
  Future<void> dispose() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
    await _connectionChangeController?.close();
    _connectionChangeController = null;
    _initialized = false;
  }
}

/// Provider do serviço de conectividade
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Provider do estado de conexão
final connectionStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectionChange;
});

/// Provider simples para saber se está online (síncrono)
final isOnlineProvider = Provider<bool>((ref) {
  final connectionAsync = ref.watch(connectionStatusProvider);
  return connectionAsync.when(
    data: (isOnline) => isOnline,
    loading: () => true, // Assume online enquanto carrega
    error: (_, __) => true, // Assume online em caso de erro
  );
});
