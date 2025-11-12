import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../shared/models/task_model.dart';
import '../../domain/entities/task_entity.dart';

/// Provider que integra notificações com tarefas
/// Automaticamente cria/atualiza/cancela lembretes quando tarefas mudam
class TaskNotificationIntegration {
  final TaskReminderService _reminderService = TaskReminderService();
  final Logger _logger = Logger();

  /// Cria lembretes quando uma tarefa é criada
  Future<void> onTaskCreated(TaskModel task) async {
    try {
      // Verificar se lembretes de tarefas estão habilitados
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('task_reminders_enabled') ?? true;

      if (!enabled) {
        _logger.d('Lembretes de tarefas desabilitados');
        return;
      }

      // Só criar lembrete se a tarefa tem data agendada
      if (task.dueDate == null) {
        _logger.d('Tarefa sem data agendada, não criar lembrete');
        return;
      }

      // Converter TaskModel para TaskEntity
      final entity = _taskModelToEntity(task);

      // Obter tempo de lembrete padrão
      final reminderMinutes = prefs.getInt('default_reminder_minutes') ?? 15;

      // Agendar lembrete
      await _reminderService.scheduleTaskReminder(
        task: entity,
        minutesBefore: reminderMinutes,
      );

      _logger.i('Lembrete criado para tarefa: ${task.title}');
    } catch (e, stack) {
      _logger.e('Erro ao criar lembrete de tarefa', error: e, stackTrace: stack);
    }
  }

  /// Atualiza lembretes quando uma tarefa é editada
  Future<void> onTaskUpdated(TaskModel task) async {
    try {
      // Verificar se lembretes estão habilitados
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('task_reminders_enabled') ?? true;

      if (!enabled) {
        // Se desabilitado, cancelar qualquer lembrete existente
        await _reminderService.cancelTaskReminder(task.id);
        return;
      }

      // Se a tarefa foi concluída, cancelar lembrete
      if (task.isCompleted) {
        await _reminderService.cancelTaskReminder(task.id);
        _logger.i('Lembrete cancelado - tarefa concluída: ${task.title}');
        return;
      }

      // Se não tem mais data agendada, cancelar lembrete
      if (task.dueDate == null) {
        await _reminderService.cancelTaskReminder(task.id);
        _logger.i('Lembrete cancelado - data removida: ${task.title}');
        return;
      }

      // Converter e atualizar lembrete
      final entity = _taskModelToEntity(task);
      final reminderMinutes = prefs.getInt('default_reminder_minutes') ?? 15;

      await _reminderService.updateTaskReminder(
        task: entity,
        minutesBefore: reminderMinutes,
      );

      _logger.i('Lembrete atualizado para tarefa: ${task.title}');
    } catch (e, stack) {
      _logger.e('Erro ao atualizar lembrete de tarefa', error: e, stackTrace: stack);
    }
  }

  /// Cancela lembretes quando uma tarefa é deletada
  Future<void> onTaskDeleted(String taskId) async {
    try {
      await _reminderService.cancelTaskReminder(taskId);
      _logger.i('Lembrete cancelado - tarefa deletada: $taskId');
    } catch (e, stack) {
      _logger.e('Erro ao cancelar lembrete de tarefa', error: e, stackTrace: stack);
    }
  }

  /// Marca tarefa como concluída e cancela lembrete
  Future<void> onTaskCompleted(TaskModel task) async {
    try {
      await _reminderService.cancelTaskReminder(task.id);
      _logger.i('Lembrete cancelado - tarefa concluída: ${task.title}');
    } catch (e, stack) {
      _logger.e('Erro ao cancelar lembrete de tarefa', error: e, stackTrace: stack);
    }
  }

  /// Envia notificação para tarefas atrasadas
  Future<void> checkAndNotifyOverdueTasks(List<TaskModel> tasks) async {
    try {
      final now = DateTime.now();

      for (final task in tasks) {
        if (!task.isCompleted &&
            task.dueDate != null &&
            task.dueDate!.isBefore(now)) {
          final entity = _taskModelToEntity(task);
          await _reminderService.scheduleOverdueTaskNotification(entity);
        }
      }

      _logger.i('Verificação de tarefas atrasadas concluída');
    } catch (e, stack) {
      _logger.e('Erro ao verificar tarefas atrasadas', error: e, stackTrace: stack);
    }
  }

  /// Envia resumo diário de tarefas
  Future<void> sendDailySummary(List<TaskModel> tasks) async {
    try {
      final totalTasks = tasks.length;
      final completedTasks = tasks.where((t) => t.isCompleted).length;
      final pendingTasks = tasks.where((t) => !t.isCompleted).length;

      final now = DateTime.now();
      final overdueTasks = tasks
          .where((t) =>
              !t.isCompleted &&
              t.dueDate != null &&
              t.dueDate!.isBefore(now))
          .length;

      await _reminderService.scheduleDailySummary(
        totalTasks: totalTasks,
        completedTasks: completedTasks,
        pendingTasks: pendingTasks,
        overdueTasks: overdueTasks,
      );

      _logger.i('Resumo diário enviado');
    } catch (e, stack) {
      _logger.e('Erro ao enviar resumo diário', error: e, stackTrace: stack);
    }
  }

  /// Converte TaskModel para TaskEntity
  TaskEntity _taskModelToEntity(TaskModel model) {
    return TaskEntity(
      id: model.id,
      userId: model.userId,
      title: model.title,
      description: model.description,
      origin: _parseOrigin(model.origin),
      priority: _parsePriority(model.priority ?? 'medium'),
      isCompleted: model.isCompleted,
      scheduledDate: model.dueDate,
      completedDate: model.completedAt,
      recurrenceType: model.recurrenceType,
      companyId: null, // TaskModel não tem companyId ainda
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  TaskOrigin _parseOrigin(String origin) {
    switch (origin) {
      case 'personal':
        return TaskOrigin.personal;
      case 'company':
        return TaskOrigin.company;
      case 'ai':
        return TaskOrigin.ai;
      case 'recurring':
        return TaskOrigin.recurring;
      default:
        return TaskOrigin.personal;
    }
  }

  TaskPriority _parsePriority(String priority) {
    switch (priority) {
      case 'high':
        return TaskPriority.high;
      case 'low':
        return TaskPriority.low;
      case 'medium':
      default:
        return TaskPriority.medium;
    }
  }
}

/// Provider para TaskNotificationIntegration
final taskNotificationIntegrationProvider = Provider<TaskNotificationIntegration>((ref) {
  return TaskNotificationIntegration();
});
