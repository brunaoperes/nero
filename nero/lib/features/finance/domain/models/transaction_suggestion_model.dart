import '../../../../shared/models/transaction_model.dart';

/// Modelo para sugestão de transação no autocomplete
class TransactionSuggestion {
  final String description;
  final String? category;
  final String? account;
  final String paymentStatus;
  final double? lastAmount;
  final DateTime lastUsedAt;
  final double matchScore; // 0.0 a 1.0 - quão bem a sugestão combina com a busca

  const TransactionSuggestion({
    required this.description,
    this.category,
    this.account,
    this.paymentStatus = 'paid',
    this.lastAmount,
    required this.lastUsedAt,
    required this.matchScore,
  });

  /// Cria uma sugestão a partir de uma transação
  factory TransactionSuggestion.fromTransaction(
    TransactionModel transaction, {
    required double matchScore,
  }) {
    return TransactionSuggestion(
      description: transaction.description ?? 'Sem descrição',
      category: transaction.category,
      account: transaction.account,
      paymentStatus: transaction.paymentStatus,
      lastAmount: transaction.amount,
      lastUsedAt: transaction.date ?? DateTime.now(),
      matchScore: matchScore,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionSuggestion &&
          runtimeType == other.runtimeType &&
          description == other.description;

  @override
  int get hashCode => description.hashCode;
}
