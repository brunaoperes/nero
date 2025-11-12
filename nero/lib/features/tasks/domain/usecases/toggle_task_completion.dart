import '../../../../shared/models/task_model.dart';
import '../repositories/task_repository.dart';

/// UseCase para marcar/desmarcar tarefa como concluída
class ToggleTaskCompletion {
  final TaskRepository _repository;

  ToggleTaskCompletion(this._repository);

  Future<TaskModel> call(String id, bool isCompleted) async {
    return await _repository.toggleTaskCompletion(id, isCompleted);
  }
}
