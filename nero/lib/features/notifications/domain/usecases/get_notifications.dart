import '../entities/notification_entity.dart';
import '../repositories/notification_repository.dart';

/// Use case para buscar notificações do usuário
class GetNotifications {
  final NotificationRepository _repository;

  GetNotifications(this._repository);

  Future<List<NotificationEntity>> call(String userId) async {
    return await _repository.getNotifications(userId);
  }
}
