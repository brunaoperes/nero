import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/fcm_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../data/datasources/notification_remote_datasource.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/get_notifications.dart';
import '../../domain/usecases/mark_as_read.dart';

// ===== SERVIÇOS =====

/// Provider para NotificationService (notificações locais)
final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

/// Provider para FCMService (push notifications)
final fcmServiceProvider = Provider<FCMService>((ref) {
  return FCMService();
});

// ===== DATA LAYER =====

/// Provider para NotificationRemoteDatasource
final notificationRemoteDatasourceProvider =
    Provider<NotificationRemoteDatasource>((ref) {
  final supabase = Supabase.instance.client;
  return NotificationRemoteDatasource(supabase);
});

/// Provider para NotificationRepository
final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  final datasource = ref.read(notificationRemoteDatasourceProvider);
  return NotificationRepositoryImpl(datasource);
});

// ===== USE CASES =====

/// Provider para GetNotifications use case
final getNotificationsUsecaseProvider = Provider<GetNotifications>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return GetNotifications(repository);
});

/// Provider para MarkAsRead use case
final markAsReadUsecaseProvider = Provider<MarkAsRead>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  return MarkAsRead(repository);
});

// ===== STATE PROVIDERS =====

/// Provider para lista de notificações do usuário
final notificationsProvider =
    FutureProvider.autoDispose<List<NotificationEntity>>((ref) async {
  final usecase = ref.read(getNotificationsUsecaseProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    throw Exception('Usuário não autenticado');
  }

  return await usecase(userId);
});

/// Provider para notificações não lidas
final unreadNotificationsProvider =
    FutureProvider.autoDispose<List<NotificationEntity>>((ref) async {
  final repository = ref.read(notificationRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    throw Exception('Usuário não autenticado');
  }

  return await repository.getUnreadNotifications(userId);
});

/// Provider para contagem de notificações não lidas
final unreadCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repository = ref.read(notificationRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    return 0;
  }

  return await repository.getUnreadCount(userId);
});

// ===== CONTROLLERS =====

/// Controller para ações de notificações
class NotificationController extends StateNotifier<AsyncValue<void>> {
  final NotificationRepository _repository;
  final String _userId;

  NotificationController(this._repository, this._userId)
      : super(const AsyncValue.data(null));

  /// Marca notificação como lida
  Future<void> markAsRead(String notificationId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.markAsRead(notificationId);
    });
  }

  /// Marca todas como lidas
  Future<void> markAllAsRead() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.markAllAsRead(_userId);
    });
  }

  /// Deleta notificação
  Future<void> deleteNotification(String notificationId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteNotification(notificationId);
    });
  }

  /// Deleta todas as notificações lidas
  Future<void> deleteAllRead() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteAllRead(_userId);
    });
  }
}

/// Provider para NotificationController
final notificationControllerProvider =
    StateNotifierProvider<NotificationController, AsyncValue<void>>((ref) {
  final repository = ref.read(notificationRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return NotificationController(repository, userId);
});
