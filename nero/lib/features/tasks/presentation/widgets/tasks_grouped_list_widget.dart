import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/task_model.dart';
import 'task_card_v2.dart';
import 'animated_task_item.dart';

/// Widget de lista de tarefas agrupadas por seção
class TasksGroupedListWidget extends StatefulWidget {
  final List<TaskModel> tasks;
  final Function(TaskModel) onTaskTap;
  final Function(TaskModel) onTaskToggle;
  final Function(TaskModel) onTaskEdit;
  final Function(TaskModel)? onTaskPostpone;
  final Function(TaskModel) onTaskDelete;
  final bool isDark;

  const TasksGroupedListWidget({
    super.key,
    required this.tasks,
    required this.onTaskTap,
    required this.onTaskToggle,
    required this.onTaskEdit,
    this.onTaskPostpone,
    required this.onTaskDelete,
    this.isDark = true,
  });

  @override
  State<TasksGroupedListWidget> createState() => _TasksGroupedListWidgetState();
}

class _TasksGroupedListWidgetState extends State<TasksGroupedListWidget> {
  bool _showCompleted = false;

  // Conjunto de IDs de tarefas sendo removidas (para animação)
  final Set<String> _removingTaskIds = {};

  // Cache de tarefas sendo removidas (para continuar mostrando durante animação)
  final Map<String, TaskModel> _removingTasksCache = {};

  Map<String, List<TaskModel>> _groupTasks() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final groups = <String, List<TaskModel>>{
      'overdue': [],
      'today': [],
      'tomorrow': [],
      'future': [],
      'completed': [],
    };

    // Combinar tarefas atuais com tarefas sendo removidas (para manter durante animação)
    final allTasks = <TaskModel>[
      ...widget.tasks,
      ..._removingTasksCache.values.where((cached) {
        // Só adiciona se não estiver mais na lista widget.tasks
        return !widget.tasks.any((t) => t.id == cached.id);
      }),
    ];

    for (final task in allTasks) {
      if (task.isCompleted) {
        groups['completed']!.add(task);
        continue;
      }

      if (task.dueDate == null) {
        groups['future']!.add(task);
        continue;
      }

      final taskDate = DateTime(
        task.dueDate!.year,
        task.dueDate!.month,
        task.dueDate!.day,
      );

      if (taskDate.isBefore(today)) {
        groups['overdue']!.add(task);
      } else if (taskDate == today) {
        groups['today']!.add(task);
      } else if (taskDate == tomorrow) {
        groups['tomorrow']!.add(task);
      } else {
        groups['future']!.add(task);
      }
    }

    // Ordenar por prioridade dentro de cada grupo
    for (final key in groups.keys) {
      groups[key]!.sort((a, b) {
        final priorityOrder = {'high': 0, 'medium': 1, 'low': 2};
        final aPriority = priorityOrder[a.priority?.toLowerCase()] ?? 3;
        final bPriority = priorityOrder[b.priority?.toLowerCase()] ?? 3;
        return aPriority.compareTo(bPriority);
      });
    }

    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groupTasks();

    if (widget.tasks.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ATRASADAS
        if (groups['overdue']!.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Atrasadas',
            count: groups['overdue']!.length,
            color: AppColors.priorityHigh,
            icon: Icons.warning_amber_rounded,
          ),
          ...groups['overdue']!.map((task) => _buildTaskCard(task)),
          const SizedBox(height: 16),
        ],

        // HOJE
        if (groups['today']!.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Hoje',
            count: groups['today']!.length,
            color: AppColors.primary,
            icon: Icons.today,
          ),
          ...groups['today']!.map((task) => _buildTaskCard(task)),
          const SizedBox(height: 16),
        ],

        // AMANHÃ
        if (groups['tomorrow']!.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Amanhã',
            count: groups['tomorrow']!.length,
            color: AppColors.info,
            icon: Icons.event,
          ),
          ...groups['tomorrow']!.map((task) => _buildTaskCard(task)),
          const SizedBox(height: 16),
        ],

        // FUTURAS
        if (groups['future']!.isNotEmpty) ...[
          _buildSectionHeader(
            title: 'Próximas',
            count: groups['future']!.length,
            color: AppColors.textSecondary,
            icon: Icons.calendar_month,
          ),
          ...groups['future']!.map((task) => _buildTaskCard(task)),
          const SizedBox(height: 16),
        ],

        // CONCLUÍDAS (colapsável)
        if (groups['completed']!.isNotEmpty) ...[
          _buildCollapsibleSectionHeader(
            title: 'Concluídas',
            count: groups['completed']!.length,
            color: AppColors.success,
            icon: Icons.check_circle,
            isExpanded: _showCompleted,
            onToggle: () => setState(() => _showCompleted = !_showCompleted),
          ),
          if (_showCompleted)
            ...groups['completed']!.map((task) => _buildTaskCard(task)),
        ],
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: widget.isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSectionHeader({
    required String title,
    required int count,
    required Color color,
    required IconData icon,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return InkWell(
      onTap: onToggle,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: widget.isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: color,
                  fontFamily: 'Inter',
                ),
              ),
            ),
            const Spacer(),
            Icon(
              isExpanded ? Icons.expand_less : Icons.expand_more,
              color: widget.isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskCard(TaskModel task) {
    final isRemoving = _removingTaskIds.contains(task.id);

    return AnimatedTaskItem(
      key: ValueKey(task.id),
      isRemoving: isRemoving,
      child: TaskCardV2(
        task: task,
        isDark: widget.isDark,
        onTap: () => widget.onTaskTap(task),
        onToggle: () => widget.onTaskToggle(task),
        onEdit: () => widget.onTaskEdit(task),
        onPostpone: widget.onTaskPostpone != null
            ? () => widget.onTaskPostpone!(task)
            : null,
        onDelete: () => _handleDelete(task),
      ),
    );
  }

  /// Inicia animação de remoção
  void _handleDelete(TaskModel task) {
    // Salva tarefa no cache para continuar renderizando durante animação
    _removingTasksCache[task.id] = task;

    // Marca tarefa como "sendo removida" para iniciar animação
    setState(() {
      _removingTaskIds.add(task.id);
    });

    // Chama callback de deleção IMEDIATAMENTE (remoção otimista)
    widget.onTaskDelete(task);

    // Aguarda animação terminar (250ms) antes de limpar cache
    Future.delayed(const Duration(milliseconds: 250), () {
      if (mounted) {
        setState(() {
          _removingTaskIds.remove(task.id);
          _removingTasksCache.remove(task.id);
        });
      }
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.task_alt,
              size: 80,
              color: widget.isDark
                  ? AppColors.textSecondary.withOpacity(0.3)
                  : const Color(0xFFBDBDBD),
            ),
            const SizedBox(height: 24),
            Text(
              'Nenhuma tarefa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: widget.isDark
                    ? AppColors.textPrimary
                    : const Color(0xFF1C1C1C),
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Crie sua primeira tarefa\ntocando no botão abaixo',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: widget.isDark
                    ? AppColors.textSecondary.withOpacity(0.7)
                    : AppColors.textSecondary,
                fontFamily: 'Inter',
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
