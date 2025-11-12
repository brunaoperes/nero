// lib/features/company/data/models/project_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/project_entity.dart';

part 'project_model.freezed.dart';
part 'project_model.g.dart';

@freezed
class ProjectModel with _$ProjectModel {
  const factory ProjectModel({
    required String id,
    required String userId,
    required String companyId,
    required String clientId,
    String? contractId,
    required String name,
    String? description,
    required String status,
    required String priority,
    required DateTime startDate,
    DateTime? endDate,
    DateTime? deadline,
    double? budget,
    double? actualCost,
    int? progress,
    String? tags,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ProjectModel;

  factory ProjectModel.fromJson(Map<String, dynamic> json) =>
      _$ProjectModelFromJson(json);

  factory ProjectModel.fromEntity(ProjectEntity entity) {
    return ProjectModel(
      id: entity.id,
      userId: entity.userId,
      companyId: entity.companyId,
      clientId: entity.clientId,
      contractId: entity.contractId,
      name: entity.name,
      description: entity.description,
      status: entity.status.toJson(),
      priority: entity.priority.toJson(),
      startDate: entity.startDate,
      endDate: entity.endDate,
      deadline: entity.deadline,
      budget: entity.budget,
      actualCost: entity.actualCost,
      progress: entity.progress,
      tags: entity.tags,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

extension ProjectModelExtension on ProjectModel {
  ProjectEntity toEntity() {
    return ProjectEntity(
      id: id,
      userId: userId,
      companyId: companyId,
      clientId: clientId,
      contractId: contractId,
      name: name,
      description: description,
      status: ProjectStatusExtension.fromJson(status),
      priority: ProjectPriorityExtension.fromJson(priority),
      startDate: startDate,
      endDate: endDate,
      deadline: deadline,
      budget: budget,
      actualCost: actualCost,
      progress: progress,
      tags: tags,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
