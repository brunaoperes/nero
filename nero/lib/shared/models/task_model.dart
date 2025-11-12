import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_model.freezed.dart';
part 'task_model.g.dart';

/// Modelo de tarefa do Nero
@freezed
class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String userId,
    required String title,
    String? description,
    @Default(false) bool isCompleted,
    DateTime? dueDate,
    DateTime? completedAt,
    String? companyId,
    @Default('personal') String origin, // personal, company, ai, recurring
    String? priority, // 'low', 'medium', 'high'
    String? recurrenceType, // null, 'daily', 'weekly', 'monthly'
    List<String>? tags,
    Map<String, dynamic>? metadata,
    // Campos de localização
    String? locationName,
    double? latitude,
    double? longitude,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, dynamic> json) =>
      _$TaskModelFromJson(json);
}
