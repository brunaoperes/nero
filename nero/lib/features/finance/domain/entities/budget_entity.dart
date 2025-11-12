import 'package:freezed_annotation/freezed_annotation.dart';

part 'budget_entity.freezed.dart';

/// Entidade que representa um orçamento por categoria
@freezed
class BudgetEntity with _$BudgetEntity {
  const factory BudgetEntity({
    required String id,
    required String userId,
    required String categoryId,
    required double limitAmount,
    required BudgetPeriod period,
    required DateTime startDate,
    DateTime? endDate,
    required bool isActive,
    double? currentAmount, // Calculado, não armazenado
    double? alertThreshold, // % para alertar (ex: 0.8 = 80%)
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _BudgetEntity;
}

/// Período do orçamento
enum BudgetPeriod {
  daily,
  weekly,
  monthly,
  yearly,
}

/// Extensão para BudgetPeriod
extension BudgetPeriodExtension on BudgetPeriod {
  String toJson() {
    switch (this) {
      case BudgetPeriod.daily:
        return 'daily';
      case BudgetPeriod.weekly:
        return 'weekly';
      case BudgetPeriod.monthly:
        return 'monthly';
      case BudgetPeriod.yearly:
        return 'yearly';
    }
  }

  static BudgetPeriod fromJson(String json) {
    switch (json) {
      case 'daily':
        return BudgetPeriod.daily;
      case 'weekly':
        return BudgetPeriod.weekly;
      case 'monthly':
        return BudgetPeriod.monthly;
      case 'yearly':
        return BudgetPeriod.yearly;
      default:
        return BudgetPeriod.monthly;
    }
  }

  String get displayName {
    switch (this) {
      case BudgetPeriod.daily:
        return 'Diário';
      case BudgetPeriod.weekly:
        return 'Semanal';
      case BudgetPeriod.monthly:
        return 'Mensal';
      case BudgetPeriod.yearly:
        return 'Anual';
    }
  }
}
