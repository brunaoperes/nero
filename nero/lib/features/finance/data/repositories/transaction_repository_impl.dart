import '../../../../shared/models/transaction_model.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_datasource.dart';

/// Implementação do repositório de transações
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDatasource _remoteDatasource;

  TransactionRepositoryImpl({
    required TransactionRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  @override
  Future<List<TransactionModel>> getTransactions({
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
    String? source,
    String? searchQuery,
    String? sortBy,
    bool ascending = false,
  }) async {
    return await _remoteDatasource.getTransactions(
      type: type,
      category: category,
      startDate: startDate,
      endDate: endDate,
      companyId: companyId,
      source: source,
      searchQuery: searchQuery,
      sortBy: sortBy,
      ascending: ascending,
    );
  }

  @override
  Future<TransactionModel> getTransactionById(String id) async {
    return await _remoteDatasource.getTransactionById(id);
  }

  @override
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    return await _remoteDatasource.createTransaction(transaction);
  }

  @override
  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    return await _remoteDatasource.updateTransaction(transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    return await _remoteDatasource.deleteTransaction(id);
  }

  @override
  Future<TransactionModel> confirmCategory(String id, String category) async {
    return await _remoteDatasource.confirmCategory(id, category);
  }

  @override
  Future<List<TransactionModel>> getCurrentMonthTransactions() async {
    return await _remoteDatasource.getCurrentMonthTransactions();
  }

  @override
  Future<Map<String, dynamic>> getTransactionStats({
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
  }) async {
    return await _remoteDatasource.getTransactionStats(
      startDate: startDate,
      endDate: endDate,
      companyId: companyId,
    );
  }

  @override
  Future<Map<String, double>> getIncomeExpenseSummary({
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
  }) async {
    return await _remoteDatasource.getIncomeExpenseSummary(
      startDate: startDate,
      endDate: endDate,
      companyId: companyId,
    );
  }

  @override
  Future<Map<String, double>> getTransactionsByCategory({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
  }) async {
    return await _remoteDatasource.getTransactionsByCategory(
      type: type,
      startDate: startDate,
      endDate: endDate,
      companyId: companyId,
    );
  }
}
