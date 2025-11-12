import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/transaction_model.dart';

/// Provider de lista de transações
/// TODO: Integrar com repository real quando estiver disponível
final transactionsProvider = StateProvider<List<TransactionModel>>((ref) {
  // Por enquanto retorna lista vazia
  // Depois você pode integrar com o repository/usecase real
  return [];
});

/// Provider de transações filtradas
final filteredTransactionsProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  // TODO: Aplicar filtros quando implementado
  return transactions;
});

/// Provider de receitas (income)
final incomesProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return transactions.where((t) => t.type == 'income').toList();
});

/// Provider de despesas (expense)
final expensesProvider = Provider<List<TransactionModel>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  return transactions.where((t) => t.type == 'expense').toList();
});

/// Provider para estatísticas financeiras
final financeStatsProvider = Provider<Map<String, double>>((ref) {
  final transactions = ref.watch(transactionsProvider);

  final totalIncome = transactions
      .where((t) => t.type == 'income')
      .fold(0.0, (sum, t) => sum + t.amount);

  final totalExpenses = transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, t) => sum + t.amount);

  return {
    'totalIncome': totalIncome,
    'totalExpenses': totalExpenses,
    'balance': totalIncome - totalExpenses,
  };
});

/// Provider de transações por categoria
final transactionsByCategoryProvider =
    Provider<Map<String, List<TransactionModel>>>((ref) {
  final transactions = ref.watch(transactionsProvider);
  final Map<String, List<TransactionModel>> byCategory = {};

  for (final transaction in transactions) {
    final category = transaction.category ?? 'Sem Categoria';
    byCategory.putIfAbsent(category, () => []);
    byCategory[category]!.add(transaction);
  }

  return byCategory;
});
