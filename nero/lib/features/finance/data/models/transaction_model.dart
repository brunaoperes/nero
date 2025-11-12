import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/transaction_entity.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

/// Model que representa uma transação vinda do Supabase
@freezed
class TransactionModel with _$TransactionModel {
  const TransactionModel._();

  const factory TransactionModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String title,
    required double amount,
    required String type,
    @JsonKey(name: 'category_id') required String categoryId,
    required String date,
    String? description,
    @JsonKey(name: 'company_id') String? companyId,
    @JsonKey(name: 'is_recurring') bool? isRecurring,
    @JsonKey(name: 'recurrence_pattern') String? recurrencePattern,
    @JsonKey(name: 'next_recurrence_date') String? nextRecurrenceDate,
    @JsonKey(name: 'ai_category_suggestion') String? aiCategorySuggestion,
    @JsonKey(name: 'ai_category_confirmed') bool? aiCategoryConfirmed,
    @JsonKey(name: 'attachment_url') String? attachmentUrl,
    Map<String, dynamic>? metadata,
    @JsonKey(name: 'created_at') required String createdAt,
    @JsonKey(name: 'updated_at') required String updatedAt,
  }) = _TransactionModel;

  /// Cria um TransactionModel a partir de JSON
  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);

  /// Converte para Entity
  TransactionEntity toEntity() {
    return TransactionEntity(
      id: id,
      userId: userId,
      title: title,
      amount: amount,
      type: TransactionTypeExtension.fromJson(type),
      categoryId: categoryId,
      date: DateTime.parse(date),
      description: description,
      companyId: companyId,
      isRecurring: isRecurring,
      recurrencePattern: recurrencePattern,
      nextRecurrenceDate: nextRecurrenceDate != null
          ? DateTime.parse(nextRecurrenceDate!)
          : null,
      aiCategorySuggestion: aiCategorySuggestion,
      aiCategoryConfirmed: aiCategoryConfirmed,
      attachmentUrl: attachmentUrl,
      metadata: metadata,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Converte Entity para Model
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      amount: entity.amount,
      type: entity.type.toJson(),
      categoryId: entity.categoryId,
      date: entity.date.toIso8601String(),
      description: entity.description,
      companyId: entity.companyId,
      isRecurring: entity.isRecurring,
      recurrencePattern: entity.recurrencePattern,
      nextRecurrenceDate: entity.nextRecurrenceDate?.toIso8601String(),
      aiCategorySuggestion: entity.aiCategorySuggestion,
      aiCategoryConfirmed: entity.aiCategoryConfirmed,
      attachmentUrl: entity.attachmentUrl,
      metadata: entity.metadata,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}
