import '../../../../shared/models/task_model.dart';
import '../repositories/task_repository.dart';

/// UseCase para atualizar tarefa
class UpdateTask {
  final TaskRepository _repository;

  UpdateTask(this._repository);

  Future<TaskModel> call(TaskModel task) async {
    return await _repository.updateTask(task);
  }
}
