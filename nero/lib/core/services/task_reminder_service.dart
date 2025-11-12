// TODO: Este arquivo foi temporariamente desabilitado devido a dependências quebradas
// O import '../../features/tasks/domain/entities/task_entity.dart' não existe
// Será necessário implementar a feature de tasks antes de habilitar este serviço

/*
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/tasks/domain/entities/task_entity.dart';
import 'notification_service.dart';

/// Serviço responsável por gerenciar lembretes de tarefas
/// Cria, atualiza e cancela notificações baseadas nas tarefas do usuário
class TaskReminderService {
  static final TaskReminderService _instance = TaskReminderService._internal();
  factory TaskReminderService() => _instance;
  TaskReminderService._internal();

  final NotificationService _notificationService = NotificationService();
  final Logger _logger = Logger();

  // Prefixos para IDs de notificação (evitar conflitos)
  static const int _taskReminderIdPrefix = 1000000;
  static const int _overdueTeminderIdPrefix = 2000000;

  /// Cria um lembrete para uma tarefa
  Future<void> scheduleTaskReminder({
    required TaskEntity task,
    int minutesBefore = 15, // Padrão: 15 minutos antes
  }) async {
    if (task.scheduledDate == null) {
      _logger.w('Tarefa ${task.id} não tem data agendada');
      return;
    }

    try {
      final reminderTime = task.scheduledDate!.subtract(
        Duration(minutes: minutesBefore),
      );

      // Não agendar se a data já passou
      if (reminderTime.isBefore(DateTime.now())) {
        _logger.w('Data de lembrete já passou: $reminderTime');
        return;
      }

      // Gerar ID único baseado no ID da tarefa
      final notificationId = _generateTaskNotificationId(task.id);

      // Determinar prioridade
      final priority = _getTaskPriority(task);

      // Agendar notificação
      await _notificationService.scheduleNotification(
        id: notificationId,
        title: _getTaskReminderTitle(minutesBefore),
        body: task.title,
        scheduledDate: reminderTime,
        payload: 'task_${task.id}',
        priority: priority,
      );

      _logger.i('Lembrete agendado para tarefa ${task.id} às $reminderTime');

      // Salvar configuração
      await _saveReminderConfig(task.id, minutesBefore);
    } catch (e, stack) {
      _logger.e('Erro ao agendar lembrete de tarefa', error: e, stackTrace: stack);
    }
  }

  /// Cria múltiplos lembretes para uma tarefa (ex: 1 dia antes, 1 hora antes, 15 min antes)
  Future<void> scheduleMultipleReminders({
    required TaskEntity task,
    List<int>? minutesList, // Lista de minutos antes
  }) async {
    final minutes = minutesList ?? [1440, 60, 15]; // 1 dia, 1 hora, 15 min

    for (final min in minutes) {
      await scheduleTaskReminder(task: task, minutesBefore: min);
    }
  }

  /// Atualiza o lembrete de uma tarefa
  Future<void> updateTaskReminder({
    required TaskEntity task,
    int minutesBefore = 15,
  }) async {
    // Cancelar lembrete antigo
    await cancelTaskReminder(task.id);

    // Criar novo lembrete
    await scheduleTaskReminder(task: task, minutesBefore: minutesBefore);
  }

  /// Cancela o lembrete de uma tarefa
  Future<void> cancelTaskReminder(String taskId) async {
    try {
      final notificationId = _generateTaskNotificationId(taskId);
      await _notificationService.cancelNotification(notificationId);
      _logger.i('Lembrete cancelado para tarefa $taskId');

      // Remover configuração salva
      await _removeReminderConfig(taskId);
    } catch (e, stack) {
      _logger.e('Erro ao cancelar lembrete de tarefa', error: e, stackTrace: stack);
    }
  }

  /// Agenda notificação para tarefas atrasadas
  Future<void> scheduleOverdueTaskNotification(TaskEntity task) async {
    try {
      final notificationId = _generateOverdueNotificationId(task.id);

      await _notificationService.showNotification(
        id: notificationId,
        title: '⏰ Tarefa Atrasada!',
        body: task.title,
        payload: 'task_${task.id}',
        priority: NotificationPriority.high,
      );

      _logger.i('Notificação de tarefa atrasada enviada: ${task.id}');
    } catch (e, stack) {
      _logger.e('Erro ao enviar notificação de tarefa atrasada', error: e, stackTrace: stack);
    }
  }

  /// Envia notificação de resumo diário de tarefas
  Future<void> scheduleDailySummary({
    required int totalTasks,
    required int completedTasks,
    required int pendingTasks,
    required int overdueTasks,
  }) async {
    try {
      final body = _buildDailySummaryBody(
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        pendingTasks: pendingTasks,
        overdueTasks: overdueTasks,
      );

      await _notificationService.showNotification(
        id: 999999, // ID fixo para resumo diário
        title: '📊 Resumo do Dia',
        body: body,
        priority: NotificationPriority.normal,
      );

      _logger.i('Resumo diário de tarefas enviado');
    } catch (e, stack) {
      _logger.e('Erro ao enviar resumo diário', error: e, stackTrace: stack);
    }
  }

  /// Agenda notificação recorrente para tarefas recorrentes
  Future<void> scheduleRecurringTaskReminder({
    required TaskEntity task,
    required RepeatInterval interval,
  }) async {
    if (task.recurrenceType == null) {
      _logger.w('Tarefa ${task.id} não é recorrente');
      return;
    }

    try {
      final notificationId = _generateTaskNotificationId(task.id);

      await _notificationService.schedulePeriodicNotification(
        id: notificationId,
        title: '🔄 Tarefa Recorrente',
        body: task.title,
        repeatInterval: interval,
        payload: 'task_${task.id}',
        priority: _getTaskPriority(task),
      );

      _logger.i('Lembrete recorrente agendado para tarefa ${task.id}');
    } catch (e, stack) {
      _logger.e('Erro ao agendar lembrete recorrente', error: e, stackTrace: stack);
    }
  }

  /// Cancela todos os lembretes de tarefas
  Future<void> cancelAllTaskReminders() async {
    try {
      await _notificationService.cancelAllNotifications();
      _logger.i('Todos os lembretes de tarefas cancelados');
    } catch (e, stack) {
      _logger.e('Erro ao cancelar todos os lembretes', error: e, stackTrace: stack);
    }
  }

  // Métodos auxiliares

  /// Gera ID único para notificação de tarefa
  int _generateTaskNotificationId(String taskId) {
    return _taskReminderIdPrefix + taskId.hashCode.abs() % 1000000;
  }

  /// Gera ID único para notificação de tarefa atrasada
  int _generateOverdueNotificationId(String taskId) {
    return _overdueTeminderIdPrefix + taskId.hashCode.abs() % 1000000;
  }

  /// Determina a prioridade da notificação baseado na tarefa
  NotificationPriority _getTaskPriority(TaskEntity task) {
    switch (task.priority) {
      case TaskPriority.high:
        return NotificationPriority.high;
      case TaskPriority.low:
        return NotificationPriority.low;
      case TaskPriority.medium:
        return NotificationPriority.normal;
    }
  }

  /// Gera o título do lembrete baseado no tempo
  String _getTaskReminderTitle(int minutesBefore) {
    if (minutesBefore < 60) {
      return '⏰ Tarefa em $minutesBefore minutos';
    } else if (minutesBefore < 1440) {
      final hours = (minutesBefore / 60).round();
      return '⏰ Tarefa em $hours ${hours == 1 ? "hora" : "horas"}';
    } else {
      final days = (minutesBefore / 1440).round();
      return '⏰ Tarefa em $days ${days == 1 ? "dia" : "dias"}';
    }
  }

  /// Constrói o corpo da notificação de resumo diário
  String _buildDailySummaryBody({
    required int totalTasks,
    required int completedTasks,
    required int pendingTasks,
    required int overdueTasks,
  }) {
    final parts = <String>[];

    if (completedTasks > 0) {
      parts.add('✅ $completedTasks concluída${completedTasks > 1 ? "s" : ""}');
    }

    if (pendingTasks > 0) {
      parts.add('⏳ $pendingTasks pendente${pendingTasks > 1 ? "s" : ""}');
    }

    if (overdueTasks > 0) {
      parts.add('⏰ $overdueTasks atrasada${overdueTasks > 1 ? "s" : ""}');
    }

    return parts.join(' • ');
  }

  /// Salva a configuração de lembrete no SharedPreferences
  Future<void> _saveReminderConfig(String taskId, int minutesBefore) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminder_$taskId', minutesBefore);
    } catch (e) {
      _logger.e('Erro ao salvar config de lembrete', error: e);
    }
  }

  /// Remove a configuração de lembrete do SharedPreferences
  Future<void> _removeReminderConfig(String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('reminder_$taskId');
    } catch (e) {
      _logger.e('Erro ao remover config de lembrete', error: e);
    }
  }

  /// Obtém a configuração de lembrete salva
  Future<int?> getReminderConfig(String taskId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt('reminder_$taskId');
    } catch (e) {
      _logger.e('Erro ao obter config de lembrete', error: e);
      return null;
    }
  }
}
*/
