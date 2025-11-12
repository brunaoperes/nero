import '../../../../shared/models/task_model.dart';

/// Interface do repositório de tarefas
abstract class TaskRepository {
  /// Busca todas as tarefas com filtros opcionais
  Future<List<TaskModel>> getTasks({
    String? status,
    String? origin,
    String? priority,
    String? companyId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? sortBy,
    bool ascending = true,
  });

  /// Busca tarefa por ID
  Future<TaskModel> getTaskById(String id);

  /// Cria nova tarefa
  Future<TaskModel> createTask(TaskModel task);

  /// Atualiza tarefa existente
  Future<TaskModel> updateTask(TaskModel task);

  /// Deleta tarefa
  Future<void> deleteTask(String id);

  /// Marca tarefa como concluída ou não concluída
  Future<TaskModel> toggleTaskCompletion(String id, bool isCompleted);

  /// Busca tarefas de hoje
  Future<List<TaskModel>> getTodayTasks();

  /// Busca tarefas atrasadas
  Future<List<TaskModel>> getOverdueTasks();

  /// Cria tarefa recorrente
  Future<TaskModel> createRecurringTask(TaskModel task);

  /// Busca estatísticas de tarefas
  Future<Map<String, dynamic>> getTaskStats();
}
