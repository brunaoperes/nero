import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/config/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../features/tasks/presentation/providers/task_providers.dart';

/// Widget de tarefas rápidas do dia
class QuickTasksWidget extends ConsumerWidget {
  const QuickTasksWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final todayTasksAsync = ref.watch(todayTasksProvider);

    return todayTasksAsync.when(
      data: (tasks) {
        if (tasks.isEmpty) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.darkBorder.withOpacity(0.1),
              ),
            ),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.task_alt,
                    size: 48,
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Nenhuma tarefa para hoje',
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Limitar a 4 tarefas
        final limitedTasks = tasks.take(4).toList();

        return Column(
          children: limitedTasks.map((task) {
            return TaskItemWidget(
              taskId: task.id,
              title: task.title,
              isCompleted: task.isCompleted,
              origin: task.origin,
              onToggle: () async {
                await ref.read(tasksListProvider.notifier).toggleTaskCompletion(
                  task.id,
                  !task.isCompleted,
                );
                ref.invalidate(todayTasksProvider);
                ref.invalidate(taskStatsProvider);
              },
              onTap: () {
                context.go('${AppConstants.routeTasks}/${task.id}');
              },
            );
          }).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, stack) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          'Erro ao carregar tarefas',
          style: TextStyle(
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class TaskItemWidget extends StatelessWidget {
  final String taskId;
  final String title;
  final bool isCompleted;
  final String origin;
  final VoidCallback? onToggle;
  final VoidCallback? onTap;

  const TaskItemWidget({
    super.key,
    required this.taskId,
    required this.title,
    required this.isCompleted,
    required this.origin,
    this.onToggle,
    this.onTap,
  });

  Color _getOriginColor() {
    switch (origin) {
      case 'personal':
        return AppColors.primary;
      case 'company':
        return AppColors.warning;
      case 'ai':
        return AppColors.aiAccent;
      case 'recurring':
        return AppColors.secondary;
      default:
        return AppColors.grey500;
    }
  }

  IconData _getOriginIcon() {
    switch (origin) {
      case 'personal':
        return Icons.person;
      case 'company':
        return Icons.business;
      case 'ai':
        return Icons.auto_awesome;
      case 'recurring':
        return Icons.repeat;
      default:
        return Icons.task;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Checkbox
              InkWell(
                onTap: onToggle,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isCompleted
                          ? AppColors.success
                          : AppColors.grey400,
                      width: 2,
                    ),
                    color: isCompleted
                        ? AppColors.success
                        : Colors.transparent,
                  ),
                  child: isCompleted
                      ? const Icon(
                          Icons.check,
                          size: 16,
                          color: Colors.white,
                        )
                      : null,
                ),
              ),
              const SizedBox(width: 12),

              // Conteúdo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        decoration: isCompleted
                            ? TextDecoration.lineThrough
                            : null,
                        color: isCompleted
                            ? theme.textTheme.bodySmall?.color
                            : null,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Badge de origem
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _getOriginColor().withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getOriginIcon(),
                      size: 12,
                      color: _getOriginColor(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
