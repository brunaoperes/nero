import '../../../../shared/models/transaction_model.dart';

/// Grupo de transações agrupadas por data
class TransactionGroup {
  final DateTime date; // Data do grupo (sem hora)
  final String label; // "Hoje", "Ontem", "12 de novembro"
  final List<TransactionModel> transactions;

  const TransactionGroup({
    required this.date,
    required this.label,
    required this.transactions,
  });

  /// Total de receitas do grupo
  double get totalIncome => transactions
      .where((t) => t.type == 'income')
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Total de despesas do grupo
  double get totalExpense => transactions
      .where((t) => t.type == 'expense')
      .fold(0.0, (sum, t) => sum + t.amount);

  /// Saldo do grupo (receitas - despesas)
  double get balance => totalIncome - totalExpense;
}
