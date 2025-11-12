import 'package:freezed_annotation/freezed_annotation.dart';

part 'financial_goal_entity.freezed.dart';

/// Entidade que representa uma meta financeira
@freezed
class FinancialGoalEntity with _$FinancialGoalEntity {
  const factory FinancialGoalEntity({
    required String id,
    required String userId,
    required String name,
    required double targetAmount,
    required double currentAmount,
    required DateTime targetDate,
    String? description,
    String? icon,
    String? color,
    required GoalStatus status,
    DateTime? achievedDate,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _FinancialGoalEntity;
}

/// Status da meta
enum GoalStatus {
  active,
  achieved,
  cancelled,
}

/// Extensão para GoalStatus
extension GoalStatusExtension on GoalStatus {
  String toJson() {
    switch (this) {
      case GoalStatus.active:
        return 'active';
      case GoalStatus.achieved:
        return 'achieved';
      case GoalStatus.cancelled:
        return 'cancelled';
    }
  }

  static GoalStatus fromJson(String json) {
    switch (json) {
      case 'active':
        return GoalStatus.active;
      case 'achieved':
        return GoalStatus.achieved;
      case 'cancelled':
        return GoalStatus.cancelled;
      default:
        return GoalStatus.active;
    }
  }

  String get displayName {
    switch (this) {
      case GoalStatus.active:
        return 'Ativa';
      case GoalStatus.achieved:
        return 'Concluída';
      case GoalStatus.cancelled:
        return 'Cancelada';
    }
  }

  String get icon {
    switch (this) {
      case GoalStatus.active:
        return '🎯';
      case GoalStatus.achieved:
        return '🎉';
      case GoalStatus.cancelled:
        return '❌';
    }
  }
}
