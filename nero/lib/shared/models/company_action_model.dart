import 'package:freezed_annotation/freezed_annotation.dart';

part 'company_action_model.freezed.dart';
part 'company_action_model.g.dart';

@freezed
class CompanyActionModel with _$CompanyActionModel {
  const factory CompanyActionModel({
    required String id,
    required String companyId,
    required String userId,
    required String actionType, // task_created, meeting_scheduled, checklist_completed
    required String title,
    String? description,
    String? relatedId,
    String? relatedType, // task, meeting, checklist, transaction
    Map<String, dynamic>? metadata,
    required DateTime createdAt,
  }) = _CompanyActionModel;

  factory CompanyActionModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyActionModelFromJson(json);
}
