import '../entities/notification_entity.dart';

/// Interface do repositório de notificações
abstract class NotificationRepository {
  /// Busca todas as notificações do usuário
  Future<List<NotificationEntity>> getNotifications(String userId);

  /// Busca apenas notificações não lidas
  Future<List<NotificationEntity>> getUnreadNotifications(String userId);

  /// Marca uma notificação como lida
  Future<void> markAsRead(String notificationId);

  /// Marca todas as notificações como lidas
  Future<void> markAllAsRead(String userId);

  /// Deleta uma notificação
  Future<void> deleteNotification(String notificationId);

  /// Deleta todas as notificações lidas
  Future<void> deleteAllRead(String userId);

  /// Cria uma nova notificação
  Future<NotificationEntity> createNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? payload,
    String? actionUrl,
    DateTime? scheduledFor,
  });

  /// Conta notificações não lidas
  Future<int> getUnreadCount(String userId);

  /// Busca notificações por tipo
  Future<List<NotificationEntity>> getNotificationsByType({
    required String userId,
    required NotificationType type,
  });
}
