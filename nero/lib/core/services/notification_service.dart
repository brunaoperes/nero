import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:logger/logger.dart';

/// Serviço responsável por gerenciar notificações locais
/// Usado para lembretes, alertas e notificações agendadas
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();

  bool _initialized = false;

  /// Inicializa o serviço de notificações
  Future<void> initialize() async {
    if (_initialized) {
      _logger.d('NotificationService já inicializado');
      return;
    }

    try {
      // Inicializar timezone
      tz.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation('America/Sao_Paulo'));

      // Configurações Android
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

      // Configurações iOS
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      // Configurações gerais
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // Inicializar
      await _notifications.initialize(
        initSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );

      // Criar canais de notificação (Android)
      await _createNotificationChannels();

      _initialized = true;
      _logger.i('NotificationService inicializado com sucesso');
    } catch (e, stack) {
      _logger.e('Erro ao inicializar NotificationService', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Cria os canais de notificação para Android
  Future<void> _createNotificationChannels() async {
    // Canal de alta importância (para tarefas urgentes)
    const highImportanceChannel = AndroidNotificationChannel(
      'high_importance_channel',
      'Notificações Importantes',
      description: 'Canal para notificações de alta prioridade',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    // Canal de importância padrão (para lembretes normais)
    const defaultChannel = AndroidNotificationChannel(
      'default_channel',
      'Notificações Gerais',
      description: 'Canal para notificações normais',
      importance: Importance.defaultImportance,
      playSound: true,
    );

    // Canal de baixa importância (para alertas sutis)
    const lowImportanceChannel = AndroidNotificationChannel(
      'low_importance_channel',
      'Alertas Sutis',
      description: 'Canal para notificações de baixa prioridade',
      importance: Importance.low,
      playSound: false,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(highImportanceChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(defaultChannel);

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(lowImportanceChannel);

    _logger.d('Canais de notificação criados');
  }

  /// Callback quando a notificação é tocada
  void _onNotificationTapped(NotificationResponse response) {
    _logger.d('Notificação tocada: ${response.payload}');
    // TODO: Implementar navegação baseada no payload
    // Ex: Se payload = "task_123", navegar para tela de detalhes da tarefa
  }

  /// Solicita permissão para enviar notificações
  Future<bool> requestPermission() async {
    // Android 13+ requer permissão explícita
    final androidPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      _logger.d('Permissão de notificação Android: $granted');
      return granted ?? false;
    }

    // iOS sempre solicita na inicialização
    final iosPlugin = _notifications
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosPlugin != null) {
      final granted = await iosPlugin.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      _logger.d('Permissão de notificação iOS: $granted');
      return granted ?? false;
    }

    return false;
  }

  /// Exibe uma notificação imediata
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    if (!_initialized) {
      _logger.w('NotificationService não inicializado');
      return;
    }

    try {
      final channelId = _getChannelId(priority);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(priority),
        channelDescription: _getChannelDescription(priority),
        importance: _getImportance(priority),
        priority: _getPriority(priority),
        playSound: priority != NotificationPriority.low,
        enableVibration: priority == NotificationPriority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.show(id, title, body, details, payload: payload);
      _logger.d('Notificação exibida: $title');
    } catch (e, stack) {
      _logger.e('Erro ao exibir notificação', error: e, stackTrace: stack);
    }
  }

  /// Agenda uma notificação para uma data/hora específica
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    if (!_initialized) {
      _logger.w('NotificationService não inicializado');
      return;
    }

    try {
      final channelId = _getChannelId(priority);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(priority),
        channelDescription: _getChannelDescription(priority),
        importance: _getImportance(priority),
        priority: _getPriority(priority),
        playSound: priority != NotificationPriority.low,
        enableVibration: priority == NotificationPriority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(scheduledDate, tz.local),
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      _logger.d('Notificação agendada para: $scheduledDate - $title');
    } catch (e, stack) {
      _logger.e('Erro ao agendar notificação', error: e, stackTrace: stack);
    }
  }

  /// Agenda uma notificação periódica (diária, semanal, etc)
  Future<void> schedulePeriodicNotification({
    required int id,
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    String? payload,
    NotificationPriority priority = NotificationPriority.normal,
  }) async {
    if (!_initialized) {
      _logger.w('NotificationService não inicializado');
      return;
    }

    try {
      final channelId = _getChannelId(priority);

      final androidDetails = AndroidNotificationDetails(
        channelId,
        _getChannelName(priority),
        channelDescription: _getChannelDescription(priority),
        importance: _getImportance(priority),
        priority: _getPriority(priority),
        playSound: priority != NotificationPriority.low,
        enableVibration: priority == NotificationPriority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notifications.periodicallyShow(
        id,
        title,
        body,
        repeatInterval,
        details,
        payload: payload,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );

      _logger.d('Notificação periódica agendada: $title');
    } catch (e, stack) {
      _logger.e('Erro ao agendar notificação periódica', error: e, stackTrace: stack);
    }
  }

  /// Cancela uma notificação específica
  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
    _logger.d('Notificação cancelada: $id');
  }

  /// Cancela todas as notificações
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    _logger.d('Todas as notificações canceladas');
  }

  /// Retorna todas as notificações pendentes
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }

  // Métodos auxiliares para mapear prioridade

  String _getChannelId(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return 'high_importance_channel';
      case NotificationPriority.low:
        return 'low_importance_channel';
      case NotificationPriority.normal:
        return 'default_channel';
    }
  }

  String _getChannelName(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return 'Notificações Importantes';
      case NotificationPriority.low:
        return 'Alertas Sutis';
      case NotificationPriority.normal:
        return 'Notificações Gerais';
    }
  }

  String _getChannelDescription(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return 'Canal para notificações de alta prioridade';
      case NotificationPriority.low:
        return 'Canal para notificações de baixa prioridade';
      case NotificationPriority.normal:
        return 'Canal para notificações normais';
    }
  }

  Importance _getImportance(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Importance.high;
      case NotificationPriority.low:
        return Importance.low;
      case NotificationPriority.normal:
        return Importance.defaultImportance;
    }
  }

  Priority _getPriority(NotificationPriority priority) {
    switch (priority) {
      case NotificationPriority.high:
        return Priority.high;
      case NotificationPriority.low:
        return Priority.low;
      case NotificationPriority.normal:
        return Priority.defaultPriority;
    }
  }
}

/// Enum para prioridade de notificações
enum NotificationPriority {
  low,
  normal,
  high,
}
