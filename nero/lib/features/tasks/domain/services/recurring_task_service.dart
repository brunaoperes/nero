import '../../../../shared/models/task_model.dart';
import '../repositories/task_repository.dart';

/// Serviço para gerenciar tarefas recorrentes
class RecurringTaskService {
  final TaskRepository _taskRepository;

  RecurringTaskService(this._taskRepository);

  /// Gera a próxima data de vencimento baseado no tipo de recorrência
  DateTime? getNextDueDate(DateTime? currentDueDate, String? recurrenceType) {
    if (currentDueDate == null || recurrenceType == null) {
      return null;
    }

    switch (recurrenceType) {
      case 'daily':
        return currentDueDate.add(const Duration(days: 1));

      case 'weekly':
        return currentDueDate.add(const Duration(days: 7));

      case 'monthly':
        // Adiciona 1 mês, mantendo o mesmo dia (ou último dia do mês se não existir)
        int year = currentDueDate.year;
        int month = currentDueDate.month + 1;

        if (month > 12) {
          month = 1;
          year++;
        }

        // Verifica o último dia do mês de destino
        int lastDayOfMonth = DateTime(year, month + 1, 0).day;
        int day = currentDueDate.day > lastDayOfMonth
            ? lastDayOfMonth
            : currentDueDate.day;

        return DateTime(
          year,
          month,
          day,
          currentDueDate.hour,
          currentDueDate.minute,
        );

      default:
        return null;
    }
  }

  /// Cria uma nova instância de tarefa recorrente quando a atual é concluída
  Future<TaskModel?> createNextRecurringTask(TaskModel completedTask) async {
    // Verifica se é uma tarefa recorrente
    if (completedTask.recurrenceType == null) {
      return null;
    }

    // Calcula a próxima data de vencimento
    final nextDueDate = getNextDueDate(
      completedTask.dueDate ?? DateTime.now(),
      completedTask.recurrenceType,
    );

    if (nextDueDate == null) {
      return null;
    }

    // Cria nova tarefa com os mesmos dados, mas nova data
    final newTask = TaskModel(
      id: '', // Será gerado pelo backend
      userId: completedTask.userId,
      title: completedTask.title,
      description: completedTask.description,
      origin: completedTask.origin,
      priority: completedTask.priority,
      dueDate: nextDueDate,
      isCompleted: false, // Nova tarefa começa não concluída
      completedAt: null,
      recurrenceType: completedTask.recurrenceType, // Mantém recorrência
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    try {
      await _taskRepository.createTask(newTask);
      return newTask;
    } catch (e) {
      // Log error (pode adicionar logger aqui)
      return null;
    }
  }

  /// Processa uma tarefa quando é marcada como concluída
  /// Se for recorrente, cria a próxima instância
  Future<void> onTaskCompleted(TaskModel task) async {
    if (task.recurrenceType != null && task.origin == 'recurring') {
      await createNextRecurringTask(task);
    }
  }

  /// Verifica e cria tarefas recorrentes pendentes
  /// Pode ser chamado periodicamente (ex: ao abrir o app)
  Future<void> checkAndCreatePendingRecurringTasks() async {
    try {
      // Busca todas as tarefas recorrentes concluídas
      final completedRecurringTasks = await _taskRepository.getTasks(
        status: 'completed',
        origin: 'recurring',
      );

      final now = DateTime.now();

      for (final task in completedRecurringTasks) {
        if (task.recurrenceType == null || task.completedAt == null) continue;

        // Verifica se já passou o tempo de criar a próxima instância
        final nextDueDate = getNextDueDate(
          task.dueDate ?? task.completedAt!,
          task.recurrenceType,
        );

        if (nextDueDate != null && nextDueDate.isBefore(now)) {
          // Verifica se já existe uma tarefa futura com mesmo título
          final futureTasks = await _taskRepository.getTasks(
            searchQuery: task.title,
          );

          final hasNextInstance = futureTasks.any((t) =>
            t.title == task.title &&
            !t.isCompleted &&
            t.dueDate != null &&
            t.dueDate!.isAfter(task.dueDate ?? task.completedAt!)
          );

          // Se não existe próxima instância, cria
          if (!hasNextInstance) {
            await createNextRecurringTask(task);
          }
        }
      }
    } catch (e) {
      // Log error
    }
  }
}
