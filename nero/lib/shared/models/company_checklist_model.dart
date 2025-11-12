import 'package:freezed_annotation/freezed_annotation.dart';

part 'company_checklist_model.freezed.dart';
part 'company_checklist_model.g.dart';

@freezed
class ChecklistItem with _$ChecklistItem {
  const factory ChecklistItem({
    required String id,
    required String title,
    @Default(false) bool completed,
  }) = _ChecklistItem;

  factory ChecklistItem.fromJson(Map<String, dynamic> json) =>
      _$ChecklistItemFromJson(json);
}

@freezed
class CompanyChecklistModel with _$CompanyChecklistModel {
  const factory CompanyChecklistModel({
    required String id,
    required String companyId,
    required String userId,
    required String title,
    String? description,
    required String type, // mei, monthly, annual, custom
    String? frequency, // monthly, annual, once
    DateTime? dueDate,
    @Default(false) bool isCompleted,
    DateTime? completedAt,
    @Default([]) List<ChecklistItem> items,
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CompanyChecklistModel;

  factory CompanyChecklistModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyChecklistModelFromJson(json);
}
