import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';
import 'notification_service.dart';

/// Handler para mensagens FCM em background (top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final logger = Logger();
  logger.d('Mensagem FCM recebida em background: ${message.messageId}');
  logger.d('Título: ${message.notification?.title}');
  logger.d('Corpo: ${message.notification?.body}');
  logger.d('Data: ${message.data}');
}

/// Serviço responsável por gerenciar Firebase Cloud Messaging (FCM)
/// Usado para receber e processar push notifications remotas
class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final NotificationService _notificationService = NotificationService();
  final Logger _logger = Logger();

  bool _initialized = false;
  String? _fcmToken;

  // StreamSubscriptions para gerenciar listeners
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _onMessageSubscription;
  StreamSubscription<RemoteMessage>? _onMessageOpenedAppSubscription;

  String? get fcmToken => _fcmToken;

  /// Inicializa o serviço FCM
  Future<void> initialize() async {
    if (_initialized) {
      _logger.d('FCMService já inicializado');
      return;
    }

    try {
      // Registrar handler para mensagens em background
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

      // Solicitar permissão de notificação
      await _requestPermission();

      // Obter o token FCM
      await _getToken();

      // Configurar listeners
      _setupMessageHandlers();

      // Configurar auto-inicialização
      await _firebaseMessaging.setAutoInitEnabled(true);

      _initialized = true;
      _logger.i('FCMService inicializado com sucesso');
      _logger.i('FCM Token: $_fcmToken');
    } catch (e, stack) {
      _logger.e('Erro ao inicializar FCMService', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Solicita permissão para receber notificações push
  Future<void> _requestPermission() async {
    try {
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        _logger.i('Permissão de notificação concedida');
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        _logger.i('Permissão provisória de notificação concedida');
      } else {
        _logger.w('Permissão de notificação negada');
      }
    } catch (e, stack) {
      _logger.e('Erro ao solicitar permissão', error: e, stackTrace: stack);
    }
  }

  /// Obtém o token FCM do dispositivo
  Future<String?> _getToken() async {
    try {
      _fcmToken = await _firebaseMessaging.getToken();
      _logger.i('Token FCM obtido: $_fcmToken');

      // TODO: Enviar token para o backend/Supabase para poder enviar notificações
      await _saveTokenToDatabase(_fcmToken);

      // Cancelar listener anterior se existir
      await _tokenRefreshSubscription?.cancel();

      // Listener para refresh do token
      _tokenRefreshSubscription = _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _logger.i('Token FCM atualizado: $newToken');
        _fcmToken = newToken;
        _saveTokenToDatabase(newToken);
      });

      return _fcmToken;
    } catch (e, stack) {
      _logger.e('Erro ao obter token FCM', error: e, stackTrace: stack);
      return null;
    }
  }

  /// Salva o token FCM no Supabase
  Future<void> _saveTokenToDatabase(String? token) async {
    if (token == null) return;

    try {
      // TODO: Implementar salvamento no Supabase
      // Exemplo:
      // await supabase.from('user_devices').upsert({
      //   'user_id': currentUserId,
      //   'fcm_token': token,
      //   'device_type': Platform.isAndroid ? 'android' : 'ios',
      //   'updated_at': DateTime.now().toIso8601String(),
      // });

      _logger.d('Token FCM salvo no database (TODO: implementar)');
    } catch (e, stack) {
      _logger.e('Erro ao salvar token no database', error: e, stackTrace: stack);
    }
  }

  /// Configura os handlers para diferentes estados de mensagens
  void _setupMessageHandlers() {
    // Cancelar listeners anteriores se existirem
    _onMessageSubscription?.cancel();
    _onMessageOpenedAppSubscription?.cancel();

    // Mensagens quando o app está em FOREGROUND (aberto)
    _onMessageSubscription = FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Mensagens quando o app está em BACKGROUND (minimizado)
    // O handler global _firebaseMessagingBackgroundHandler já cuida disso

    // Quando o usuário toca na notificação e o app abre
    _onMessageOpenedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Verificar se o app foi aberto por uma notificação
    _checkInitialMessage();
  }

  /// Handler para mensagens quando o app está em foreground
  void _handleForegroundMessage(RemoteMessage message) {
    _logger.d('Mensagem FCM recebida em foreground: ${message.messageId}');

    final notification = message.notification;
    final data = message.data;

    if (notification != null) {
      _logger.d('Título: ${notification.title}');
      _logger.d('Corpo: ${notification.body}');

      // Exibir notificação local quando o app está aberto
      _notificationService.showNotification(
        id: message.hashCode,
        title: notification.title ?? 'Nero',
        body: notification.body ?? '',
        payload: _encodePayload(data),
        priority: _getPriorityFromData(data),
      );
    }

    // Processar dados customizados
    if (data.isNotEmpty) {
      _logger.d('Data: $data');
      _processNotificationData(data);
    }
  }

  /// Handler para quando o usuário toca na notificação
  void _handleMessageOpenedApp(RemoteMessage message) {
    _logger.d('Notificação tocada, app aberto: ${message.messageId}');

    final data = message.data;
    if (data.isNotEmpty) {
      _processNotificationData(data);
      // TODO: Navegar para tela específica baseado no tipo de notificação
      // Exemplo: Se data['type'] == 'task', navegar para tela de tarefas
    }
  }

  /// Verifica se o app foi aberto por uma notificação
  Future<void> _checkInitialMessage() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();

    if (initialMessage != null) {
      _logger.d('App aberto por notificação: ${initialMessage.messageId}');
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Processa os dados customizados da notificação
  void _processNotificationData(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'task_reminder':
        _logger.d('Processar lembrete de tarefa: ${data['task_id']}');
        // TODO: Implementar lógica específica
        break;

      case 'finance_alert':
        _logger.d('Processar alerta financeiro: ${data['alert_type']}');
        // TODO: Implementar lógica específica
        break;

      case 'meeting_reminder':
        _logger.d('Processar lembrete de reunião: ${data['meeting_id']}');
        // TODO: Implementar lógica específica
        break;

      case 'ai_recommendation':
        _logger.d('Processar recomendação da IA');
        // TODO: Implementar lógica específica
        break;

      default:
        _logger.d('Tipo de notificação desconhecido: $type');
    }
  }

  /// Se inscreve em um tópico FCM
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      _logger.i('Inscrito no tópico: $topic');
    } catch (e, stack) {
      _logger.e('Erro ao se inscrever no tópico', error: e, stackTrace: stack);
    }
  }

  /// Remove inscrição de um tópico FCM
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logger.i('Desinscrito do tópico: $topic');
    } catch (e, stack) {
      _logger.e('Erro ao desinscrever do tópico', error: e, stackTrace: stack);
    }
  }

  /// Deleta o token FCM (útil para logout)
  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      _logger.i('Token FCM deletado');
    } catch (e, stack) {
      _logger.e('Erro ao deletar token FCM', error: e, stackTrace: stack);
    }
  }

  // Métodos auxiliares

  /// Codifica o payload em String
  String _encodePayload(Map<String, dynamic> data) {
    // Simplificado: retorna o tipo de notificação
    return data['type']?.toString() ?? '';
  }

  /// Determina a prioridade baseado nos dados
  NotificationPriority _getPriorityFromData(Map<String, dynamic> data) {
    final priority = data['priority'] as String?;

    switch (priority) {
      case 'high':
        return NotificationPriority.high;
      case 'low':
        return NotificationPriority.low;
      default:
        return NotificationPriority.normal;
    }
  }

  /// Limpa recursos e cancela todos os listeners
  Future<void> dispose() async {
    _logger.d('Disposing FCMService...');

    await _tokenRefreshSubscription?.cancel();
    await _onMessageSubscription?.cancel();
    await _onMessageOpenedAppSubscription?.cancel();

    _tokenRefreshSubscription = null;
    _onMessageSubscription = null;
    _onMessageOpenedAppSubscription = null;

    _initialized = false;
    _logger.i('FCMService disposed');
  }
}
