import '../repositories/task_repository.dart';

/// UseCase para deletar tarefa
class DeleteTask {
  final TaskRepository _repository;

  DeleteTask(this._repository);

  Future<void> call(String id) async {
    return await _repository.deleteTask(id);
  }
}
