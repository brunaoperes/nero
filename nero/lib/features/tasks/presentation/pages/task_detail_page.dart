import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/task_model.dart';
import '../providers/task_providers.dart';
import 'task_form_page_v2.dart';

class TaskDetailPage extends ConsumerWidget {
  final String taskId;

  const TaskDetailPage({super.key, required this.taskId});

  Color _getOriginColor(String origin) {
    switch (origin) {
      case 'personal':
        return AppColors.primary;
      case 'company':
        return AppColors.secondary;
      case 'ai':
        return AppColors.aiAccent;
      case 'recurring':
        return Colors.purple;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getOriginLabel(String origin) {
    switch (origin) {
      case 'personal':
        return 'Pessoal';
      case 'company':
        return 'Empresa';
      case 'ai':
        return 'IA';
      case 'recurring':
        return 'Recorrente';
      default:
        return origin;
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority) {
      case 'high':
        return AppColors.priorityHigh;
      case 'medium':
        return AppColors.priorityMedium;
      case 'low':
        return AppColors.priorityLow;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getPriorityLabel(String? priority) {
    switch (priority) {
      case 'high':
        return 'Alta';
      case 'medium':
        return 'Média';
      case 'low':
        return 'Baixa';
      default:
        return '';
    }
  }

  Future<void> _editTask(BuildContext context, WidgetRef ref, TaskModel task) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => TaskFormPageV2(task: task),
      ),
    );

    if (result == true) {
      // Invalidar providers para atualizar o dashboard automaticamente
      ref.invalidate(todayTasksProvider);
      ref.invalidate(tasksListProvider);

      // Voltar após editar
      if (context.mounted) {
        Navigator.of(context).pop(true);
      }
    }
  }

  Future<void> _deleteTask(BuildContext context, WidgetRef ref, TaskModel task) async {
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

    if (confirmed == true) {
      final success = await ref.read(tasksListProvider.notifier).deleteTask(task.id);
      if (context.mounted) {
        if (success) {
          // Invalidar providers para atualizar o dashboard automaticamente
          ref.invalidate(todayTasksProvider);
          ref.invalidate(tasksListProvider);

          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tarefa deletada!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao deletar tarefa'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleTask(WidgetRef ref, TaskModel task) async {
    await ref.read(tasksListProvider.notifier).toggleTaskCompletion(
      task.id,
      !task.isCompleted,
    );

    // Invalidar providers para atualizar o dashboard automaticamente
    ref.invalidate(todayTasksProvider);
    ref.invalidate(tasksListProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<TaskModel>(
      future: ref.read(taskRepositoryProvider).getTaskById(taskId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Erro'),
            ),
            body: const Center(
              child: Text(
                'Erro ao carregar tarefa',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        final task = snapshot.data!;
        final isOverdue = task.dueDate != null &&
            !task.isCompleted &&
            task.dueDate!.isBefore(DateTime.now());

        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            title: const Text(
              'Detalhes da Tarefa',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.textPrimary),
                onPressed: () => _editTask(context, ref, task),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () => _deleteTask(context, ref, task),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status checkbox e título
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GestureDetector(
                      onTap: () => _toggleTask(ref, task),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: task.isCompleted
                                ? AppColors.primary
                                : AppColors.textSecondary.withOpacity(0.3),
                            width: 2,
                          ),
                          color: task.isCompleted ? AppColors.primary : Colors.transparent,
                        ),
                        child: task.isCompleted
                            ? const Icon(Icons.check, size: 20, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: task.isCompleted
                              ? AppColors.textSecondary
                              : AppColors.textPrimary,
                          decoration: task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Descrição
                if (task.description != null && task.description!.isNotEmpty) ...[
                  const _SectionTitle(title: 'Descrição'),
                  const SizedBox(height: 8),
                  Text(
                    task.description!,
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.textSecondary.withOpacity(0.9),
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Tags
                const _SectionTitle(title: 'Informações'),
                const SizedBox(height: 12),

                // Origem
                _InfoRow(
                  icon: Icons.label,
                  label: 'Origem',
                  value: _getOriginLabel(task.origin),
                  valueColor: _getOriginColor(task.origin),
                ),

                // Prioridade
                if (task.priority != null)
                  _InfoRow(
                    icon: Icons.flag,
                    label: 'Prioridade',
                    value: _getPriorityLabel(task.priority),
                    valueColor: _getPriorityColor(task.priority),
                  ),

                // Data de vencimento
                if (task.dueDate != null)
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Vencimento',
                    value: DateFormat('dd/MM/yyyy HH:mm').format(task.dueDate!),
                    valueColor: isOverdue ? Colors.red : AppColors.textPrimary,
                  ),

                // Recorrência
                if (task.recurrenceType != null)
                  _InfoRow(
                    icon: Icons.repeat,
                    label: 'Recorrência',
                    value: task.recurrenceType == 'daily'
                        ? 'Diária'
                        : task.recurrenceType == 'weekly'
                            ? 'Semanal'
                            : 'Mensal',
                  ),

                const SizedBox(height: 24),

                // Datas
                const _SectionTitle(title: 'Histórico'),
                const SizedBox(height: 12),

                _InfoRow(
                  icon: Icons.add_circle_outline,
                  label: 'Criada em',
                  value: DateFormat('dd/MM/yyyy HH:mm').format(task.createdAt),
                ),

                if (task.completedAt != null)
                  _InfoRow(
                    icon: Icons.check_circle_outline,
                    label: 'Concluída em',
                    value: DateFormat('dd/MM/yyyy HH:mm').format(task.completedAt!),
                    valueColor: Colors.green,
                  ),

                _InfoRow(
                  icon: Icons.update,
                  label: 'Atualizada em',
                  value: DateFormat('dd/MM/yyyy HH:mm').format(task.updatedAt),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.textSecondary.withOpacity(0.7),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary.withOpacity(0.7),
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
