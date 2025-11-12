import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/task_model.dart';
import '../providers/task_providers.dart';
import '../widgets/tasks_header_widget.dart';
import '../widgets/tasks_grouped_list_widget.dart';
import '../widgets/task_filter_bottom_sheet.dart';
import '../widgets/task_sort_bottom_sheet.dart';
import 'task_form_page_v2.dart';

class TasksListPage extends ConsumerStatefulWidget {
  final String? companyId;
  final String? companyName;

  const TasksListPage({
    super.key,
    this.companyId,
    this.companyName,
  });

  @override
  ConsumerState<TasksListPage> createState() => _TasksListPageState();
}

class _TasksListPageState extends ConsumerState<TasksListPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Se tiver companyId, carrega as tarefas filtradas
    if (widget.companyId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(tasksListProvider.notifier).loadTasks(companyId: widget.companyId);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TaskFilterBottomSheet(),
    );
  }

  void _showSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TaskSortBottomSheet(),
    );
  }

  Future<void> _createTask() async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const TaskFormPageV2(),
      ),
    );

    if (result == true) {
      ref.read(tasksListProvider.notifier).loadTasks(companyId: widget.companyId);
    }
  }

  Future<void> _editTask(TaskModel task) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskFormPageV2(task: task),
      ),
    );

    if (result == true) {
      ref.read(tasksListProvider.notifier).loadTasks(companyId: widget.companyId);
    }
  }

  Future<void> _deleteTask(TaskModel task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Deletar Tarefa'),
        content: Text('Tem certeza que deseja deletar "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Salvar índice original para possível undo
    final currentTasks = ref.read(tasksListProvider).value ?? [];
    final originalIndex = currentTasks.indexWhere((t) => t.id == task.id);

    // Remoção otimista - não aguarda backend
    final result = await ref.read(tasksListProvider.notifier).deleteTaskOptimistic(task.id);

    if (!mounted) return;

    if (result.success) {

      // Snackbar com ação "Desfazer"
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Tarefa "${task.title}" deletada',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Desfazer',
            textColor: Colors.white,
            onPressed: () {
              ref.read(tasksListProvider.notifier).undoDelete(task, originalIndex);

              // Feedback de restauração
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      const Icon(Icons.restore, color: Colors.white, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Tarefa "${task.title}" restaurada'),
                      ),
                    ],
                  ),
                  backgroundColor: AppColors.info,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ),
      );
    } else {
      // Erro - tarefa já foi revertida automaticamente pelo rollback
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 20),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Erro ao deletar tarefa. Operação revertida.'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _toggleTask(TaskModel task) async {
    await ref.read(tasksListProvider.notifier).toggleTaskCompletion(
      task.id,
      !task.isCompleted,
    );
  }

  Future<void> _postponeTask(TaskModel task) async {
    if (task.dueDate == null) return;

    final newDueDate = task.dueDate!.add(const Duration(days: 1));
    final updatedTask = task.copyWith(dueDate: newDueDate);

    final success = await ref.read(tasksListProvider.notifier).updateTask(updatedTask);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success ? 'Tarefa adiada para amanhã!' : 'Erro ao adiar tarefa'),
          backgroundColor: success ? AppColors.success : Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksAsync = ref.watch(tasksListProvider);
    final statusFilter = ref.watch(taskStatusFilterProvider);
    final originFilter = ref.watch(taskOriginFilterProvider);
    final priorityFilter = ref.watch(taskPriorityFilterProvider);

    // Conta quantos filtros estão ativos
    int activeFiltersCount = 0;
    if (statusFilter != null) activeFiltersCount++;
    if (originFilter != null) activeFiltersCount++;
    if (priorityFilter != null) activeFiltersCount++;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: widget.companyId != null
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tarefas da Empresa',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 18,
                    ),
                  ),
                  if (widget.companyName != null)
                    Text(
                      widget.companyName!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                      ),
                    ),
                ],
              )
            : const Text('Minhas Tarefas'),
        actions: [
          // Botão de ordenação
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSortBottomSheet,
            tooltip: 'Ordenar',
          ),
          // Botão de filtros com badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.filter_list),
                onPressed: _showFilterBottomSheet,
                tooltip: 'Filtrar',
              ),
              if (activeFiltersCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '$activeFiltersCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de busca
          _TaskSearchField(
            controller: _searchController,
            onSearch: (value) {
              ref.read(taskSearchQueryProvider.notifier).state = value.isEmpty ? null : value;
              // Debounce: aguardar 500ms antes de buscar
              Future.delayed(const Duration(milliseconds: 500), () {
                if (value == _searchController.text) {
                  ref.read(tasksListProvider.notifier).loadTasks(
                    searchQuery: value.isEmpty ? null : value,
                    companyId: widget.companyId,
                  );
                }
              });
            },
            onClear: () {
              ref.read(taskSearchQueryProvider.notifier).state = null;
              ref.read(tasksListProvider.notifier).loadTasks(companyId: widget.companyId);
            },
          ),

          // Lista de tarefas
          Expanded(
            child: tasksAsync.when(
              data: (tasks) {
                final isDark = Theme.of(context).brightness == Brightness.dark;

                // Calcular estatísticas
                final completedTasks = tasks.where((t) => t.isCompleted).length;
                final pendingTasks = tasks.where((t) => !t.isCompleted).length;
                final totalTasks = tasks.length;

                if (tasks.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.task_alt,
                          size: 64,
                          color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          activeFiltersCount > 0
                              ? 'Nenhuma tarefa encontrada\ncom os filtros aplicados'
                              : '✅ Você ainda não tem tarefas.\nCrie sua primeira tarefa!',
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontSize: 14,
                            color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    await ref.read(tasksListProvider.notifier).loadTasks(companyId: widget.companyId);
                  },
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Cabeçalho com anel de progresso
                      TasksHeaderWidget(
                        completedTasks: completedTasks,
                        pendingTasks: pendingTasks,
                        totalTasks: totalTasks,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),

                      // Lista agrupada de tarefas
                      TasksGroupedListWidget(
                        tasks: tasks,
                        isDark: isDark,
                        onTaskTap: _editTask,
                        onTaskToggle: _toggleTask,
                        onTaskEdit: _editTask,
                        onTaskPostpone: _postponeTask,
                        onTaskDelete: _deleteTask,
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
              error: (error, stack) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppColors.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro ao carregar tarefas',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontSize: 16,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => ref.read(tasksListProvider.notifier).loadTasks(companyId: widget.companyId),
                      child: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'tasks_list_page_fab',
        onPressed: _createTask,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nova Tarefa',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ==========================================
// WIDGET DE BUSCA (StatefulWidget)
// ==========================================

/// Widget de busca de tarefas que usa tema centralizado
class _TaskSearchField extends StatefulWidget {
  final TextEditingController controller;
  final Function(String) onSearch;
  final VoidCallback onClear;

  const _TaskSearchField({
    required this.controller,
    required this.onSearch,
    required this.onClear,
  });

  @override
  State<_TaskSearchField> createState() => _TaskSearchFieldState();
}

class _TaskSearchFieldState extends State<_TaskSearchField> {
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _showClearButton = widget.controller.text.isNotEmpty;
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_showClearButton != hasText) {
      setState(() {
        _showClearButton = hasText;
      });
    }
  }

  void _clearSearch() {
    widget.controller.clear();
    widget.onClear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: widget.controller,
        cursorColor: theme.colorScheme.primary,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          hintText: 'Buscar tarefas…',
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _showClearButton
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: _clearSearch,
                )
              : null,
        ),
        onChanged: widget.onSearch,
      ),
    );
  }
}
