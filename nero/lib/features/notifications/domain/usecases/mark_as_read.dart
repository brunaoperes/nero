import '../repositories/notification_repository.dart';

/// Use case para marcar notificação como lida
class MarkAsRead {
  final NotificationRepository _repository;

  MarkAsRead(this._repository);

  Future<void> call(String notificationId) async {
    await _repository.markAsRead(notificationId);
  }
}
