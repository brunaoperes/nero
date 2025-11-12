import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_entity.freezed.dart';

/// Entidade que representa uma transação financeira
@freezed
class TransactionEntity with _$TransactionEntity {
  const factory TransactionEntity({
    required String id,
    required String userId,
    required String title,
    required double amount,
    required TransactionType type,
    required String categoryId,
    required DateTime date,
    String? description,
    String? account, // Conta / Banco
    String? companyId,
    bool? isRecurring,
    String? recurrencePattern, // daily, weekly, monthly, yearly
    DateTime? nextRecurrenceDate,
    String? aiCategorySuggestion,
    bool? aiCategoryConfirmed,
    String? attachmentUrl,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TransactionEntity;
}

/// Tipo de transação
enum TransactionType {
  income,   // Receita
  expense,  // Despesa
}

/// Extensão para TransactionType
extension TransactionTypeExtension on TransactionType {
  String toJson() {
    switch (this) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
    }
  }

  static TransactionType fromJson(String json) {
    switch (json) {
      case 'income':
        return TransactionType.income;
      case 'expense':
        return TransactionType.expense;
      default:
        return TransactionType.expense;
    }
  }

  String get displayName {
    switch (this) {
      case TransactionType.income:
        return 'Receita';
      case TransactionType.expense:
        return 'Despesa';
    }
  }

  String get icon {
    switch (this) {
      case TransactionType.income:
        return '💰';
      case TransactionType.expense:
        return '💸';
    }
  }
}
