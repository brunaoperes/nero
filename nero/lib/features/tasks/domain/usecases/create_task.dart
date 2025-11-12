import '../../../../shared/models/task_model.dart';
import '../repositories/task_repository.dart';

/// UseCase para criar tarefa
class CreateTask {
  final TaskRepository _repository;

  CreateTask(this._repository);

  Future<TaskModel> call(TaskModel task) async {
    return await _repository.createTask(task);
  }
}
