import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/task_model.dart';

/// Provider de lista de tarefas
/// TODO: Integrar com repository real quando estiver disponível
final tasksProvider = StateProvider<List<TaskModel>>((ref) {
  // Por enquanto retorna lista vazia
  // Depois você pode integrar com o repository/usecase real
  return [];
});

/// Provider de tarefas filtradas
final filteredTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksProvider);
  // TODO: Aplicar filtros quando implementado
  return tasks;
});

/// Provider de tarefas completadas
final completedTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks.where((task) => task.isCompleted).toList();
});

/// Provider de tarefas pendentes
final pendingTasksProvider = Provider<List<TaskModel>>((ref) {
  final tasks = ref.watch(tasksProvider);
  return tasks.where((task) => !task.isCompleted).toList();
});

/// Provider para estatísticas de tarefas
final taskStatsProvider = Provider<Map<String, int>>((ref) {
  final tasks = ref.watch(tasksProvider);

  return {
    'total': tasks.length,
    'completed': tasks.where((t) => t.isCompleted).length,
    'pending': tasks.where((t) => !t.isCompleted).length,
    'highPriority': tasks.where((t) => t.priority == 'high').length,
    'mediumPriority': tasks.where((t) => t.priority == 'medium').length,
    'lowPriority': tasks.where((t) => t.priority == 'low').length,
  };
});
