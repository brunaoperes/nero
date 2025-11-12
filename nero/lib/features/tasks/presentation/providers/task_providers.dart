import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/task_model.dart';
import '../../data/datasources/task_remote_datasource.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../../domain/usecases/create_task.dart';
import '../../domain/usecases/delete_task.dart';
import '../../domain/usecases/get_tasks.dart';
import '../../domain/usecases/toggle_task_completion.dart';
import '../../domain/usecases/update_task.dart';
import '../../domain/services/recurring_task_service.dart';

// ==========================================
// DATASOURCES
// ==========================================

final taskRemoteDatasourceProvider = Provider<TaskRemoteDatasource>((ref) {
  return TaskRemoteDatasource(
    supabaseClient: SupabaseService.client,
  );
});

// ==========================================
// REPOSITORIES
// ==========================================

final taskRepositoryProvider = Provider<TaskRepository>((ref) {
  return TaskRepositoryImpl(
    remoteDatasource: ref.watch(taskRemoteDatasourceProvider),
  );
});

// ==========================================
// USECASES
// ==========================================

final getTasksUseCaseProvider = Provider<GetTasks>((ref) {
  return GetTasks(ref.watch(taskRepositoryProvider));
});

final createTaskUseCaseProvider = Provider<CreateTask>((ref) {
  return CreateTask(ref.watch(taskRepositoryProvider));
});

final updateTaskUseCaseProvider = Provider<UpdateTask>((ref) {
  return UpdateTask(ref.watch(taskRepositoryProvider));
});

final deleteTaskUseCaseProvider = Provider<DeleteTask>((ref) {
  return DeleteTask(ref.watch(taskRepositoryProvider));
});

final toggleTaskCompletionUseCaseProvider = Provider<ToggleTaskCompletion>((ref) {
  return ToggleTaskCompletion(ref.watch(taskRepositoryProvider));
});

// ==========================================
// SERVICES
// ==========================================

final recurringTaskServiceProvider = Provider<RecurringTaskService>((ref) {
  return RecurringTaskService(ref.watch(taskRepositoryProvider));
});

// ==========================================
// STATE PROVIDERS
// ==========================================

/// Provider para lista de tarefas
final tasksListProvider = StateNotifierProvider<TasksListNotifier, AsyncValue<List<TaskModel>>>((ref) {
  return TasksListNotifier(ref);
});

/// Notifier para gerenciar lista de tarefas
class TasksListNotifier extends StateNotifier<AsyncValue<List<TaskModel>>> {
  final Ref _ref;

  TasksListNotifier(this._ref) : super(const AsyncValue.loading()) {
    _initialize();
  }

  /// Inicializa o notifier verificando tarefas recorrentes pendentes
  Future<void> _initialize() async {
    // Verifica e cria tarefas recorrentes pendentes
    try {
      final recurringService = _ref.read(recurringTaskServiceProvider);
      await recurringService.checkAndCreatePendingRecurringTasks();
    } catch (e) {
      // Log error silenciosamente
    }

    // Carrega as tarefas
    await loadTasks();
  }

  /// Carrega todas as tarefas
  Future<void> loadTasks({
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
    state = const AsyncValue.loading();
    try {
      final getTasks = _ref.read(getTasksUseCaseProvider);
      final tasks = await getTasks(
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
      state = AsyncValue.data(tasks);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Cria nova tarefa
  Future<bool> createTask(TaskModel task) async {
    try {
      print('[TasksListNotifier] 🔵 createTask chamado');
      print('[TasksListNotifier] 📝 Task: ${task.toJson()}');

      final createTask = _ref.read(createTaskUseCaseProvider);
      print('[TasksListNotifier] ⏳ Chamando use case...');

      await createTask(task);

      print('[TasksListNotifier] ✅ Use case executado com sucesso!');
      print('[TasksListNotifier] 🔄 Recarregando lista de tarefas...');

      await loadTasks(); // Recarrega a lista

      // Invalida providers do Dashboard para atualização automática
      _ref.invalidate(todayTasksProvider);
      _ref.invalidate(overdueTasksProvider);
      _ref.invalidate(taskStatsProvider);

      print('[TasksListNotifier] ✅ Tarefa criada e lista recarregada com sucesso!');
      return true;
    } catch (e, stack) {
      print('[TasksListNotifier] ❌ ERRO ao criar tarefa: $e');
      print('[TasksListNotifier] 📚 Stack: $stack');
      return false;
    }
  }

  /// Atualiza tarefa
  Future<bool> updateTask(TaskModel task) async {
    try {
      final updateTask = _ref.read(updateTaskUseCaseProvider);
      await updateTask(task);
      await loadTasks(); // Recarrega a lista

      // Invalida providers do Dashboard para atualização automática
      _ref.invalidate(todayTasksProvider);
      _ref.invalidate(overdueTasksProvider);
      _ref.invalidate(taskStatsProvider);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Deleta tarefa (versão antiga - mantida para compatibilidade)
  Future<bool> deleteTask(String id) async {
    try {
      final deleteTask = _ref.read(deleteTaskUseCaseProvider);
      await deleteTask(id);
      await loadTasks(); // Recarrega a lista

      // Invalida providers do Dashboard para atualização automática
      _ref.invalidate(todayTasksProvider);
      _ref.invalidate(overdueTasksProvider);
      _ref.invalidate(taskStatsProvider);

      return true;
    } catch (e) {
      return false;
    }
  }

  /// Deleta tarefa com UI otimista (sem reload, atualização instantânea)
  Future<({bool success, TaskModel? removedTask})> deleteTaskOptimistic(String id) async {
    // 1. Salvar estado atual
    final currentTasks = state.value ?? [];
    final taskIndex = currentTasks.indexWhere((t) => t.id == id);

    if (taskIndex == -1) {
      return (success: false, removedTask: null);
    }

    final removedTask = currentTasks[taskIndex];

    // 2. Remoção otimista - atualiza estado IMEDIATAMENTE
    final updatedTasks = List<TaskModel>.from(currentTasks)..removeAt(taskIndex);
    state = AsyncValue.data(updatedTasks);

    // 3. Invalida providers do Dashboard para atualização instantânea
    _ref.invalidate(todayTasksProvider);
    _ref.invalidate(overdueTasksProvider);
    _ref.invalidate(taskStatsProvider);

    // 4. Chamada ao backend (async, sem bloquear UI)
    try {
      final deleteTask = _ref.read(deleteTaskUseCaseProvider);
      await deleteTask(id);
      return (success: true, removedTask: removedTask);
    } catch (e, stack) {
      // 5. ROLLBACK - restaura a tarefa na mesma posição
      final restoredTasks = List<TaskModel>.from(updatedTasks)
        ..insert(taskIndex, removedTask);
      state = AsyncValue.data(restoredTasks);

      // Invalida novamente para reverter dashboard
      _ref.invalidate(todayTasksProvider);
      _ref.invalidate(overdueTasksProvider);
      _ref.invalidate(taskStatsProvider);

      return (success: false, removedTask: removedTask);
    }
  }

  /// Restaura uma tarefa deletada (undo)
  void undoDelete(TaskModel task, int originalIndex) {
    final currentTasks = state.value ?? [];
    final restoredTasks = List<TaskModel>.from(currentTasks)
      ..insert(originalIndex, task);

    state = AsyncValue.data(restoredTasks);

    // Invalida providers
    _ref.invalidate(todayTasksProvider);
    _ref.invalidate(overdueTasksProvider);
    _ref.invalidate(taskStatsProvider);
  }

  /// Marca/desmarca tarefa como concluída
  Future<bool> toggleTaskCompletion(String id, bool isCompleted) async {
    try {
      final toggleTask = _ref.read(toggleTaskCompletionUseCaseProvider);
      await toggleTask(id, isCompleted);

      // Se está marcando como concluída, processa tarefas recorrentes
      if (isCompleted) {
        // Busca a tarefa para verificar se é recorrente
        final currentTasks = state.value ?? [];
        final task = currentTasks.firstWhere(
          (t) => t.id == id,
          orElse: () => currentTasks.first, // Fallback caso não encontre
        );

        // Se for recorrente, cria a próxima instância
        if (task.recurrenceType != null && task.origin == 'recurring') {
          final recurringService = _ref.read(recurringTaskServiceProvider);
          await recurringService.onTaskCompleted(task);
        }
      }

      await loadTasks(); // Recarrega a lista

      // Invalida providers do Dashboard para atualização automática
      _ref.invalidate(todayTasksProvider);
      _ref.invalidate(overdueTasksProvider);
      _ref.invalidate(taskStatsProvider);

      return true;
    } catch (e) {
      return false;
    }
  }
}

// ==========================================
// FILTROS E BUSCA
// ==========================================

/// Provider para filtro de status
final taskStatusFilterProvider = StateProvider<String?>((ref) => null);

/// Provider para filtro de origem
final taskOriginFilterProvider = StateProvider<String?>((ref) => null);

/// Provider para filtro de prioridade
final taskPriorityFilterProvider = StateProvider<String?>((ref) => null);

/// Provider para busca
final taskSearchQueryProvider = StateProvider<String?>((ref) => null);

/// Provider para ordenação
final taskSortByProvider = StateProvider<String?>((ref) => null);

/// Provider para direção da ordenação
final taskSortAscendingProvider = StateProvider<bool>((ref) => true);

// ==========================================
// TAREFAS DE HOJE
// ==========================================

/// Provider para tarefas de hoje
final todayTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return await repository.getTodayTasks();
});

// ==========================================
// TAREFAS ATRASADAS
// ==========================================

/// Provider para tarefas atrasadas
final overdueTasksProvider = FutureProvider<List<TaskModel>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return await repository.getOverdueTasks();
});

// ==========================================
// ESTATÍSTICAS
// ==========================================

/// Provider para estatísticas de tarefas
final taskStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(taskRepositoryProvider);
  return await repository.getTaskStats();
});
