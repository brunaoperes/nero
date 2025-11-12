import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/financial_goal_entity.dart';

part 'financial_goal_model.freezed.dart';
part 'financial_goal_model.g.dart';

/// Model que representa uma meta financeira vinda do Supabase
@freezed
class FinancialGoalModel with _$FinancialGoalModel {
  const FinancialGoalModel._();

  const factory FinancialGoalModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    @JsonKey(name: 'target_amount') required double targetAmount,
    @JsonKey(name: 'current_amount') required double currentAmount,
    @JsonKey(name: 'target_date') required String targetDate,
    String? description,
    String? icon,
    String? color,
    required String status,
    @JsonKey(name: 'achieved_date') String? achievedDate,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _FinancialGoalModel;

  /// Cria um FinancialGoalModel a partir de JSON
  factory FinancialGoalModel.fromJson(Map<String, dynamic> json) =>
      _$FinancialGoalModelFromJson(json);

  /// Converte para Entity
  FinancialGoalEntity toEntity() {
    return FinancialGoalEntity(
      id: id,
      userId: userId,
      name: name,
      targetAmount: targetAmount,
      currentAmount: currentAmount,
      targetDate: DateTime.parse(targetDate),
      description: description,
      icon: icon,
      color: color,
      status: GoalStatusExtension.fromJson(status),
      achievedDate:
          achievedDate != null ? DateTime.parse(achievedDate!) : null,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Converte Entity para Model
  factory FinancialGoalModel.fromEntity(FinancialGoalEntity entity) {
    return FinancialGoalModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      targetAmount: entity.targetAmount,
      currentAmount: entity.currentAmount,
      targetDate: entity.targetDate.toIso8601String(),
      description: entity.description,
      icon: entity.icon,
      color: entity.color,
      status: entity.status.toJson(),
      achievedDate: entity.achievedDate?.toIso8601String(),
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}
