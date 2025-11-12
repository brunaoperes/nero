import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/budget_entity.dart';

part 'budget_model.freezed.dart';
part 'budget_model.g.dart';

/// Model que representa um orçamento vindo do Supabase
@freezed
class BudgetModel with _$BudgetModel {
  const BudgetModel._();

  const factory BudgetModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'category_id') required String categoryId,
    @JsonKey(name: 'limit_amount') required double limitAmount,
    required String period,
    @JsonKey(name: 'start_date') required String startDate,
    @JsonKey(name: 'end_date') String? endDate,
    @JsonKey(name: 'is_active') required bool isActive,
    @JsonKey(name: 'current_amount') double? currentAmount,
    @JsonKey(name: 'alert_threshold') double? alertThreshold,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _BudgetModel;

  /// Cria um BudgetModel a partir de JSON
  factory BudgetModel.fromJson(Map<String, dynamic> json) =>
      _$BudgetModelFromJson(json);

  /// Converte para Entity
  BudgetEntity toEntity() {
    return BudgetEntity(
      id: id,
      userId: userId,
      categoryId: categoryId,
      limitAmount: limitAmount,
      period: BudgetPeriodExtension.fromJson(period),
      startDate: DateTime.parse(startDate),
      endDate: endDate != null ? DateTime.parse(endDate!) : null,
      isActive: isActive,
      currentAmount: currentAmount,
      alertThreshold: alertThreshold,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Converte Entity para Model
  factory BudgetModel.fromEntity(BudgetEntity entity) {
    return BudgetModel(
      id: entity.id,
      userId: entity.userId,
      categoryId: entity.categoryId,
      limitAmount: entity.limitAmount,
      period: entity.period.toJson(),
      startDate: entity.startDate.toIso8601String(),
      endDate: entity.endDate?.toIso8601String(),
      isActive: entity.isActive,
      currentAmount: entity.currentAmount,
      alertThreshold: entity.alertThreshold,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}
