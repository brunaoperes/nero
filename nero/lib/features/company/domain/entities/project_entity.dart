// lib/features/company/domain/entities/project_entity.dart

/// Entidade que representa um projeto
class ProjectEntity {
  final String id;
  final String userId;
  final String companyId;
  final String clientId;
  final String? contractId; // Contrato associado (opcional)
  final String name;
  final String? description;
  final ProjectStatus status;
  final ProjectPriority priority;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime? deadline;
  final double? budget;
  final double? actualCost;
  final int? progress; // Progresso em % (0-100)
  final String? tags; // Tags separadas por vírgula
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProjectEntity({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.clientId,
    this.contractId,
    required this.name,
    this.description,
    required this.status,
    required this.priority,
    required this.startDate,
    this.endDate,
    this.deadline,
    this.budget,
    this.actualCost,
    this.progress,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Verifica se o projeto está atrasado
  bool get isOverdue {
    if (deadline == null || status == ProjectStatus.completed) return false;
    return DateTime.now().isAfter(deadline!);
  }

  /// Verifica se está próximo do deadline (7 dias)
  bool get isNearDeadline {
    if (deadline == null || status == ProjectStatus.completed) return false;
    final daysUntilDeadline = deadline!.difference(DateTime.now()).inDays;
    return daysUntilDeadline > 0 && daysUntilDeadline <= 7;
  }

  /// Verifica se está acima do orçamento
  bool get isOverBudget {
    if (budget == null || actualCost == null) return false;
    return actualCost! > budget!;
  }

  ProjectEntity copyWith({
    String? id,
    String? userId,
    String? companyId,
    String? clientId,
    String? contractId,
    String? name,
    String? description,
    ProjectStatus? status,
    ProjectPriority? priority,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? deadline,
    double? budget,
    double? actualCost,
    int? progress,
    String? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProjectEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      clientId: clientId ?? this.clientId,
      contractId: contractId ?? this.contractId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      deadline: deadline ?? this.deadline,
      budget: budget ?? this.budget,
      actualCost: actualCost ?? this.actualCost,
      progress: progress ?? this.progress,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Status do projeto
enum ProjectStatus {
  planning,    // Planejamento
  inProgress,  // Em andamento
  onHold,      // Pausado
  completed,   // Concluído
  cancelled,   // Cancelado
}

extension ProjectStatusExtension on ProjectStatus {
  String get displayName {
    switch (this) {
      case ProjectStatus.planning:
        return 'Planejamento';
      case ProjectStatus.inProgress:
        return 'Em Andamento';
      case ProjectStatus.onHold:
        return 'Pausado';
      case ProjectStatus.completed:
        return 'Concluído';
      case ProjectStatus.cancelled:
        return 'Cancelado';
    }
  }

  String toJson() {
    return toString().split('.').last;
  }

  static ProjectStatus fromJson(String json) {
    return ProjectStatus.values.firstWhere(
      (e) => e.toJson() == json,
      orElse: () => ProjectStatus.planning,
    );
  }
}

/// Prioridade do projeto
enum ProjectPriority {
  low,
  medium,
  high,
  urgent,
}

extension ProjectPriorityExtension on ProjectPriority {
  String get displayName {
    switch (this) {
      case ProjectPriority.low:
        return 'Baixa';
      case ProjectPriority.medium:
        return 'Média';
      case ProjectPriority.high:
        return 'Alta';
      case ProjectPriority.urgent:
        return 'Urgente';
    }
  }

  String toJson() {
    return toString().split('.').last;
  }

  static ProjectPriority fromJson(String json) {
    return ProjectPriority.values.firstWhere(
      (e) => e.toJson() == json,
      orElse: () => ProjectPriority.medium,
    );
  }
}
