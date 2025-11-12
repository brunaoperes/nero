import '../../../../shared/models/task_model.dart';
import '../../domain/repositories/task_repository.dart';
import '../datasources/task_remote_datasource.dart';

/// Implementação do repositório de tarefas
class TaskRepositoryImpl implements TaskRepository {
  final TaskRemoteDatasource _remoteDatasource;

  TaskRepositoryImpl({
    required TaskRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  @override
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
  }) async {
    return await _remoteDatasource.getTasks(
      status: status,
      origin: origin,
      priority: priority,
      companyId: companyId,
      startDate: startDate,
      endDate: endDate,
      searchQuery: searchQuery,
      sortBy: sortBy,
      ascending: ascending,
    );
  }

  @override
  Future<TaskModel> getTaskById(String id) async {
    return await _remoteDatasource.getTaskById(id);
  }

  @override
  Future<TaskModel> createTask(TaskModel task) async {
    return await _remoteDatasource.createTask(task);
  }

  @override
  Future<TaskModel> updateTask(TaskModel task) async {
    return await _remoteDatasource.updateTask(task);
  }

  @override
  Future<void> deleteTask(String id) async {
    return await _remoteDatasource.deleteTask(id);
  }

  @override
  Future<TaskModel> toggleTaskCompletion(String id, bool isCompleted) async {
    return await _remoteDatasource.toggleTaskCompletion(id, isCompleted);
  }

  @override
  Future<List<TaskModel>> getTodayTasks() async {
    return await _remoteDatasource.getTodayTasks();
  }

  @override
  Future<List<TaskModel>> getOverdueTasks() async {
    return await _remoteDatasource.getOverdueTasks();
  }

  @override
  Future<TaskModel> createRecurringTask(TaskModel task) async {
    return await _remoteDatasource.createRecurringTask(task);
  }

  @override
  Future<Map<String, dynamic>> getTaskStats() async {
    return await _remoteDatasource.getTaskStats();
  }
}
