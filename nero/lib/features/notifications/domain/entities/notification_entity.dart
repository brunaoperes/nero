import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_entity.freezed.dart';

/// Entidade que representa uma notificação no domínio
@freezed
class NotificationEntity with _$NotificationEntity {
  const factory NotificationEntity({
    required String id,
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    required DateTime createdAt,
    required bool isRead,
    String? payload,
    String? actionUrl,
    DateTime? scheduledFor,
  }) = _NotificationEntity;
}

/// Tipos de notificação no sistema
enum NotificationType {
  taskReminder,       // Lembrete de tarefa
  taskOverdue,        // Tarefa atrasada
  financeAlert,       // Alerta financeiro
  budgetWarning,      // Aviso de orçamento
  goalAchieved,       // Meta atingida
  meetingReminder,    // Lembrete de reunião
  aiRecommendation,   // Recomendação da IA
  system,             // Notificação do sistema
  other,              // Outros
}

/// Extensão para converter string em NotificationType
extension NotificationTypeExtension on NotificationType {
  String toJson() {
    switch (this) {
      case NotificationType.taskReminder:
        return 'task_reminder';
      case NotificationType.taskOverdue:
        return 'task_overdue';
      case NotificationType.financeAlert:
        return 'finance_alert';
      case NotificationType.budgetWarning:
        return 'budget_warning';
      case NotificationType.goalAchieved:
        return 'goal_achieved';
      case NotificationType.meetingReminder:
        return 'meeting_reminder';
      case NotificationType.aiRecommendation:
        return 'ai_recommendation';
      case NotificationType.system:
        return 'system';
      case NotificationType.other:
        return 'other';
    }
  }

  static NotificationType fromJson(String json) {
    switch (json) {
      case 'task_reminder':
        return NotificationType.taskReminder;
      case 'task_overdue':
        return NotificationType.taskOverdue;
      case 'finance_alert':
        return NotificationType.financeAlert;
      case 'budget_warning':
        return NotificationType.budgetWarning;
      case 'goal_achieved':
        return NotificationType.goalAchieved;
      case 'meeting_reminder':
        return NotificationType.meetingReminder;
      case 'ai_recommendation':
        return NotificationType.aiRecommendation;
      case 'system':
        return NotificationType.system;
      default:
        return NotificationType.other;
    }
  }

  /// Retorna o ícone para cada tipo de notificação
  String get icon {
    switch (this) {
      case NotificationType.taskReminder:
        return '⏰';
      case NotificationType.taskOverdue:
        return '🔴';
      case NotificationType.financeAlert:
        return '💰';
      case NotificationType.budgetWarning:
        return '⚠️';
      case NotificationType.goalAchieved:
        return '🎉';
      case NotificationType.meetingReminder:
        return '📅';
      case NotificationType.aiRecommendation:
        return '🤖';
      case NotificationType.system:
        return '🔔';
      case NotificationType.other:
        return '📬';
    }
  }
}
