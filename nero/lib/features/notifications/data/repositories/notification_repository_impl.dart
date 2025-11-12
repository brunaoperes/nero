import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../datasources/notification_remote_datasource.dart';

/// Implementação do repositório de notificações
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDatasource _remoteDatasource;

  NotificationRepositoryImpl(this._remoteDatasource);

  @override
  Future<List<NotificationEntity>> getNotifications(String userId) async {
    final models = await _remoteDatasource.getNotifications(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<NotificationEntity>> getUnreadNotifications(String userId) async {
    final models = await _remoteDatasource.getUnreadNotifications(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _remoteDatasource.markAsRead(notificationId);
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    await _remoteDatasource.markAllAsRead(userId);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _remoteDatasource.deleteNotification(notificationId);
  }

  @override
  Future<void> deleteAllRead(String userId) async {
    await _remoteDatasource.deleteAllRead(userId);
  }

  @override
  Future<NotificationEntity> createNotification({
    required String userId,
    required String title,
    required String body,
    required NotificationType type,
    String? payload,
    String? actionUrl,
    DateTime? scheduledFor,
  }) async {
    final model = await _remoteDatasource.createNotification(
      userId: userId,
      title: title,
      body: body,
      type: type.toJson(),
      payload: payload,
      actionUrl: actionUrl,
      scheduledFor: scheduledFor,
    );

    return model.toEntity();
  }

  @override
  Future<int> getUnreadCount(String userId) async {
    return await _remoteDatasource.getUnreadCount(userId);
  }

  @override
  Future<List<NotificationEntity>> getNotificationsByType({
    required String userId,
    required NotificationType type,
  }) async {
    final models = await _remoteDatasource.getNotificationsByType(
      userId: userId,
      type: type.toJson(),
    );
    return models.map((model) => model.toEntity()).toList();
  }
}
