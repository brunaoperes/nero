import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/notification_model.dart';

/// Datasource responsável por buscar notificações do Supabase
class NotificationRemoteDatasource {
  final SupabaseClient _supabase;
  final Logger _logger = Logger();

  NotificationRemoteDatasource(this._supabase);

  /// Busca todas as notificações do usuário
  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _logger.d('Notificações obtidas: ${response.length}');

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e('Erro ao buscar notificações', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Busca apenas notificações não lidas
  Future<List<NotificationModel>> getUnreadNotifications(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false)
          .order('created_at', ascending: false);

      _logger.d('Notificações não lidas: ${response.length}');

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e('Erro ao buscar notificações não lidas', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Marca uma notificação como lida
  Future<void> markAsRead(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('id', notificationId);

      _logger.d('Notificação marcada como lida: $notificationId');
    } catch (e, stack) {
      _logger.e('Erro ao marcar notificação como lida', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Marca todas as notificações como lidas
  Future<void> markAllAsRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .update({'is_read': true})
          .eq('user_id', userId)
          .eq('is_read', false);

      _logger.d('Todas as notificações marcadas como lidas');
    } catch (e, stack) {
      _logger.e('Erro ao marcar todas como lidas', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Deleta uma notificação
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('id', notificationId);

      _logger.d('Notificação deletada: $notificationId');
    } catch (e, stack) {
      _logger.e('Erro ao deletar notificação', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Deleta todas as notificações lidas
  Future<void> deleteAllRead(String userId) async {
    try {
      await _supabase
          .from('notifications')
          .delete()
          .eq('user_id', userId)
          .eq('is_read', true);

      _logger.d('Todas as notificações lidas deletadas');
    } catch (e, stack) {
      _logger.e('Erro ao deletar notificações lidas', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Cria uma nova notificação
  Future<NotificationModel> createNotification({
    required String userId,
    required String title,
    required String body,
    required String type,
    String? payload,
    String? actionUrl,
    DateTime? scheduledFor,
  }) async {
    try {
      final response = await _supabase
          .from('notifications')
          .insert({
            'user_id': userId,
            'title': title,
            'body': body,
            'type': type,
            'payload': payload,
            'action_url': actionUrl,
            'scheduled_for': scheduledFor?.toIso8601String(),
            'is_read': false,
          })
          .select()
          .single();

      _logger.d('Notificação criada: ${response['id']}');

      return NotificationModel.fromJson(response);
    } catch (e, stack) {
      _logger.e('Erro ao criar notificação', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Conta notificações não lidas
  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('is_read', false);

      final count = (response as List).length;
      _logger.d('Total de notificações não lidas: $count');

      return count;
    } catch (e, stack) {
      _logger.e('Erro ao contar notificações não lidas', error: e, stackTrace: stack);
      return 0;
    }
  }

  /// Busca notificações por tipo
  Future<List<NotificationModel>> getNotificationsByType({
    required String userId,
    required String type,
  }) async {
    try {
      final response = await _supabase
          .from('notifications')
          .select()
          .eq('user_id', userId)
          .eq('type', type)
          .order('created_at', ascending: false);

      _logger.d('Notificações do tipo $type: ${response.length}');

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e('Erro ao buscar notificações por tipo', error: e, stackTrace: stack);
      rethrow;
    }
  }
}
