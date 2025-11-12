import '../../../../shared/models/task_model.dart';
import '../repositories/task_repository.dart';

/// UseCase para buscar tarefas
class GetTasks {
  final TaskRepository _repository;

  GetTasks(this._repository);

  Future<List<TaskModel>> call({
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
    return await _repository.getTasks(
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
}
