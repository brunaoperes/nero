import '../../../../shared/models/transaction_model.dart';

/// Interface do repositório de transações financeiras
abstract class TransactionRepository {
  /// Busca todas as transações com filtros opcionais
  Future<List<TransactionModel>> getTransactions({
    String? type, // income, expense
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
    String? source,
    String? searchQuery,
    String? sortBy,
    bool ascending = false, // mais recentes primeiro por padrão
  });

  /// Busca transação por ID
  Future<TransactionModel> getTransactionById(String id);

  /// Cria nova transação
  Future<TransactionModel> createTransaction(TransactionModel transaction);

  /// Atualiza transação existente
  Future<TransactionModel> updateTransaction(TransactionModel transaction);

  /// Deleta transação
  Future<void> deleteTransaction(String id);

  /// Confirma categoria sugerida pela IA
  Future<TransactionModel> confirmCategory(String id, String category);

  /// Busca transações do mês atual
  Future<List<TransactionModel>> getCurrentMonthTransactions();

  /// Busca estatísticas de transações
  Future<Map<String, dynamic>> getTransactionStats({
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
  });

  /// Busca total de receitas e despesas
  Future<Map<String, double>> getIncomeExpenseSummary({
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
  });

  /// Busca transações por categoria
  Future<Map<String, double>> getTransactionsByCategory({
    String? type, // income ou expense
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
  });
}
