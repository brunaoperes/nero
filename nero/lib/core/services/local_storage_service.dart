import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Serviço de armazenamento local com Hive
///
/// Gerencia dados offline para:
/// - Tarefas
/// - Transações financeiras
/// - Empresas
/// - Fila de operações pendentes
class LocalStorageService {
  // Boxes do Hive
  static const String _tasksBoxName = 'tasks';
  static const String _transactionsBoxName = 'transactions';
  static const String _companiesBoxName = 'companies';
  static const String _queueBoxName = 'offline_queue';
  static const String _syncBoxName = 'sync_metadata';

  /// Inicializa o Hive
  static Future<void> initialize() async {
    await Hive.initFlutter();

    // Abrir boxes
    await Hive.openBox(_tasksBoxName);
    await Hive.openBox(_transactionsBoxName);
    await Hive.openBox(_companiesBoxName);
    await Hive.openBox(_queueBoxName);
    await Hive.openBox(_syncBoxName);
  }

  // ==================== TAREFAS ====================

  /// Salva uma tarefa localmente
  Future<void> saveTask(String id, Map<String, dynamic> taskData) async {
    final box = Hive.box(_tasksBoxName);
    await box.put(id, taskData);
  }

  /// Obtém uma tarefa local
  Map<String, dynamic>? getTask(String id) {
    final box = Hive.box(_tasksBoxName);
    final data = box.get(id);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Obtém todas as tarefas locais
  List<Map<String, dynamic>> getAllTasks() {
    final box = Hive.box(_tasksBoxName);
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Deleta uma tarefa local
  Future<void> deleteTask(String id) async {
    final box = Hive.box(_tasksBoxName);
    await box.delete(id);
  }

  /// Limpa todas as tarefas locais
  Future<void> clearTasks() async {
    final box = Hive.box(_tasksBoxName);
    await box.clear();
  }

  // ==================== TRANSAÇÕES ====================

  /// Salva uma transação localmente
  Future<void> saveTransaction(String id, Map<String, dynamic> transactionData) async {
    final box = Hive.box(_transactionsBoxName);
    await box.put(id, transactionData);
  }

  /// Obtém uma transação local
  Map<String, dynamic>? getTransaction(String id) {
    final box = Hive.box(_transactionsBoxName);
    final data = box.get(id);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Obtém todas as transações locais
  List<Map<String, dynamic>> getAllTransactions() {
    final box = Hive.box(_transactionsBoxName);
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Deleta uma transação local
  Future<void> deleteTransaction(String id) async {
    final box = Hive.box(_transactionsBoxName);
    await box.delete(id);
  }

  /// Limpa todas as transações locais
  Future<void> clearTransactions() async {
    final box = Hive.box(_transactionsBoxName);
    await box.clear();
  }

  // ==================== EMPRESAS ====================

  /// Salva uma empresa localmente
  Future<void> saveCompany(String id, Map<String, dynamic> companyData) async {
    final box = Hive.box(_companiesBoxName);
    await box.put(id, companyData);
  }

  /// Obtém uma empresa local
  Map<String, dynamic>? getCompany(String id) {
    final box = Hive.box(_companiesBoxName);
    final data = box.get(id);
    return data != null ? Map<String, dynamic>.from(data) : null;
  }

  /// Obtém todas as empresas locais
  List<Map<String, dynamic>> getAllCompanies() {
    final box = Hive.box(_companiesBoxName);
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Deleta uma empresa local
  Future<void> deleteCompany(String id) async {
    final box = Hive.box(_companiesBoxName);
    await box.delete(id);
  }

  // ==================== FILA DE OPERAÇÕES ====================

  /// Adiciona uma operação à fila offline
  Future<void> enqueueOperation(Map<String, dynamic> operation) async {
    final box = Hive.box(_queueBoxName);
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    await box.put(timestamp, operation);
  }

  /// Obtém todas as operações na fila
  List<Map<String, dynamic>> getAllQueuedOperations() {
    final box = Hive.box(_queueBoxName);
    return box.values
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  /// Remove uma operação da fila
  Future<void> dequeueOperation(int key) async {
    final box = Hive.box(_queueBoxName);
    await box.delete(key);
  }

  /// Limpa toda a fila
  Future<void> clearQueue() async {
    final box = Hive.box(_queueBoxName);
    await box.clear();
  }

  /// Retorna quantidade de operações na fila
  int getQueueSize() {
    final box = Hive.box(_queueBoxName);
    return box.length;
  }

  // ==================== METADADOS DE SINCRONIZAÇÃO ====================

  /// Salva timestamp da última sincronização
  Future<void> setLastSyncTime(DateTime timestamp) async {
    final box = Hive.box(_syncBoxName);
    await box.put('last_sync', timestamp.toIso8601String());
  }

  /// Obtém timestamp da última sincronização
  DateTime? getLastSyncTime() {
    final box = Hive.box(_syncBoxName);
    final timestamp = box.get('last_sync');
    return timestamp != null ? DateTime.parse(timestamp) : null;
  }

  /// Salva status da última sincronização
  Future<void> setSyncStatus(String status) async {
    final box = Hive.box(_syncBoxName);
    await box.put('sync_status', status);
  }

  /// Obtém status da última sincronização
  String? getSyncStatus() {
    final box = Hive.box(_syncBoxName);
    return box.get('sync_status');
  }

  // ==================== UTILITÁRIOS ====================

  /// Limpa todos os dados locais
  Future<void> clearAll() async {
    await clearTasks();
    await clearTransactions();
    await clearQueue();

    final syncBox = Hive.box(_syncBoxName);
    await syncBox.clear();
  }

  /// Fecha todas as boxes
  static Future<void> close() async {
    await Hive.close();
  }
}

/// Provider do serviço de armazenamento local
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});
