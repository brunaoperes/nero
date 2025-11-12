import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/task_model.dart';

class TaskCard extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  const TaskCard({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    required this.onDelete,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isHovered = false;

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

  Widget _buildPriorityBadge(String? priority) {
    if (priority == null) return const SizedBox.shrink();

    final color = _getPriorityColor(priority);
    final label = _getPriorityLabel(priority);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.4),
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
    );
  }

  bool _isOverdue() {
    if (widget.task.dueDate == null || widget.task.isCompleted) return false;
    return widget.task.dueDate!.isBefore(DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = _isOverdue();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isOverdue
                ? Colors.red.withOpacity(0.3)
                : isDark
                    ? AppColors.darkBorder.withOpacity(0.1)
                    : const Color(0xFFE0E0E0),
            width: 1,
          ),
          boxShadow: _isHovered
              ? [BoxShadow(
                  color: AppColors.primary.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )]
              : [BoxShadow(
                  color: isDark
                      ? Colors.black.withOpacity(0.15)
                      : Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                // Checkbox
                GestureDetector(
                  onTap: widget.onToggle,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: widget.task.isCompleted
                            ? AppColors.primary
                            : AppColors.textSecondary.withOpacity(0.3),
                        width: 2,
                      ),
                      color: widget.task.isCompleted ? AppColors.primary : Colors.transparent,
                    ),
                    child: widget.task.isCompleted
                        ? const Icon(Icons.check, size: 16, color: Colors.white)
                        : null,
                  ),
                ),
                const SizedBox(width: 12),

                // Conteúdo
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        widget.task.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: widget.task.isCompleted
                              ? AppColors.textSecondary
                              : isDark
                                  ? AppColors.textPrimary
                                  : const Color(0xFF1C1C1C),
                          decoration: widget.task.isCompleted
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                        ),
                      ),

                      // Descrição
                      if (widget.task.description != null && widget.task.description!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.task.description!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary.withOpacity(0.7),
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),

                      // Tags e informações
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          // Origem
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getOriginColor(widget.task.origin).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _getOriginColor(widget.task.origin).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              _getOriginLabel(widget.task.origin),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getOriginColor(widget.task.origin),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),

                          // Prioridade
                          if (widget.task.priority != null)
                            _buildPriorityBadge(widget.task.priority),

                          // Data de vencimento
                          if (widget.task.dueDate != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isOverdue
                                    ? Colors.red.withOpacity(0.1)
                                    : AppColors.textSecondary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isOverdue
                                      ? Colors.red.withOpacity(0.3)
                                      : AppColors.textSecondary.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 12,
                                    color: isOverdue ? Colors.red : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(widget.task.dueDate!),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isOverdue ? Colors.red : AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Botão de deletar
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  iconSize: 20,
                  color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }
}
