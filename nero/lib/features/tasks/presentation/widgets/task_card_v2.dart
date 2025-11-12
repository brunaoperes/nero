import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/task_model.dart';

/// Card moderno de tarefa com swipe gestures e animações
class TaskCardV2 extends StatefulWidget {
  final TaskModel task;
  final VoidCallback onTap;
  final VoidCallback onToggle;
  final VoidCallback? onEdit;
  final VoidCallback? onPostpone;
  final VoidCallback? onDelete;
  final bool isDark;

  const TaskCardV2({
    super.key,
    required this.task,
    required this.onTap,
    required this.onToggle,
    this.onEdit,
    this.onPostpone,
    this.onDelete,
    this.isDark = true,
  });

  @override
  State<TaskCardV2> createState() => _TaskCardV2State();
}

class _TaskCardV2State extends State<TaskCardV2> with SingleTickerProviderStateMixin {
  late AnimationController _checkAnimationController;
  late Animation<double> _scaleAnimation;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _checkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _checkAnimationController, curve: Curves.easeOutCubic),
    );
    if (widget.task.isCompleted) {
      _checkAnimationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TaskCardV2 oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.task.isCompleted != oldWidget.task.isCompleted) {
      if (widget.task.isCompleted) {
        _checkAnimationController.forward();
      } else {
        _checkAnimationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _checkAnimationController.dispose();
    super.dispose();
  }

  Color _getOriginColor(String origin) {
    switch (origin.toLowerCase()) {
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
    switch (origin.toLowerCase()) {
      case 'personal':
        return 'Pessoal';
      case 'company':
        return 'Trabalho';
      case 'ai':
        return 'IA';
      case 'recurring':
        return 'Recorrente';
      default:
        return origin;
    }
  }

  Color _getPriorityColor(String? priority) {
    switch (priority?.toLowerCase()) {
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
    switch (priority?.toLowerCase()) {
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

  String _getDateLabel(DateTime? dueDate) {
    if (dueDate == null) return '';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (taskDate.isBefore(today)) {
      return 'Atrasada';
    } else if (taskDate == today) {
      return 'Hoje';
    } else if (taskDate == tomorrow) {
      return 'Amanhã';
    } else {
      return DateFormat('dd/MM').format(dueDate);
    }
  }

  Color _getDateColor(DateTime? dueDate) {
    if (dueDate == null) return AppColors.textSecondary;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(dueDate.year, dueDate.month, dueDate.day);

    if (taskDate.isBefore(today)) {
      return AppColors.priorityHigh;
    } else if (taskDate == today) {
      return AppColors.warning;
    } else {
      return AppColors.textSecondary;
    }
  }

  bool _isOverdue() {
    if (widget.task.dueDate == null || widget.task.isCompleted) return false;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final taskDate = DateTime(
      widget.task.dueDate!.year,
      widget.task.dueDate!.month,
      widget.task.dueDate!.day,
    );
    return taskDate.isBefore(today);
  }

  void _handleToggle() {
    // Haptic feedback
    HapticFeedback.lightImpact();
    widget.onToggle();
  }

  @override
  Widget build(BuildContext context) {
    final isOverdue = _isOverdue();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: Dismissible(
        key: Key(widget.task.id),
        // Swipe direita: concluir/retomar
        confirmDismiss: (direction) async {
          if (direction == DismissDirection.startToEnd) {
            _handleToggle();
            return false; // Não remove o item
          }
          return false;
        },
        background: _buildSwipeBackground(
          color: AppColors.success,
          icon: Icons.check,
          alignment: Alignment.centerLeft,
        ),
        secondaryBackground: _buildSwipeActionsBackground(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: widget.isDark ? AppColors.darkCard : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isOverdue
                  ? AppColors.priorityHigh.withOpacity(0.3)
                  : widget.isDark
                      ? AppColors.darkBorder.withOpacity(0.1)
                      : const Color(0xFFE0E0E0),
              width: 1,
            ),
            boxShadow: _isHovered
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : [
                    BoxShadow(
                      color: widget.isDark
                          ? Colors.black.withOpacity(0.1)
                          : Colors.black.withOpacity(0.03),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    )
                  ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.onTap,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                child: Row(
                  children: [
                    // Checkbox circular moderno
                    _buildModernCheckbox(),
                    const SizedBox(width: 12),

                    // Conteúdo
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Título
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 150),
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: widget.task.isCompleted
                                  ? AppColors.textSecondary.withOpacity(0.6)
                                  : widget.isDark
                                      ? AppColors.textPrimary
                                      : const Color(0xFF1C1C1C),
                              decoration: widget.task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                              decorationColor: AppColors.textSecondary.withOpacity(0.4),
                              decorationThickness: 2,
                              fontFamily: 'Inter',
                              height: 1.3,
                            ),
                            child: Text(
                              widget.task.title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),

                          const SizedBox(height: 6),

                          // Chips (Contexto, Prioridade, Data)
                          Wrap(
                            spacing: 6,
                            runSpacing: 4,
                            children: [
                              // Contexto (Pessoal/Trabalho)
                              _buildChip(
                                label: _getOriginLabel(widget.task.origin),
                                color: _getOriginColor(widget.task.origin),
                                icon: widget.task.origin.toLowerCase() == 'company'
                                    ? Icons.business_center
                                    : Icons.person,
                              ),

                              // Prioridade
                              if (widget.task.priority != null)
                                _buildChip(
                                  label: _getPriorityLabel(widget.task.priority),
                                  color: _getPriorityColor(widget.task.priority),
                                  icon: widget.task.priority?.toLowerCase() == 'high'
                                      ? Icons.priority_high
                                      : null,
                                ),

                              // Data
                              if (widget.task.dueDate != null)
                                _buildChip(
                                  label: _getDateLabel(widget.task.dueDate),
                                  color: _getDateColor(widget.task.dueDate),
                                  icon: Icons.schedule,
                                  isOverdue: isOverdue,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Menu "..."
                    _buildMoreMenu(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildModernCheckbox() {
    return GestureDetector(
      onTap: _handleToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: widget.task.isCompleted
                ? AppColors.primary
                : AppColors.textSecondary.withOpacity(0.4),
            width: 2,
          ),
          color: widget.task.isCompleted ? AppColors.primary : Colors.transparent,
        ),
        child: widget.task.isCompleted
            ? ScaleTransition(
                scale: _scaleAnimation,
                child: const Icon(
                  Icons.check,
                  size: 16,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required Color color,
    IconData? icon,
    bool isOverdue = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
              fontFamily: 'Inter',
              height: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoreMenu() {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        size: 20,
        color: widget.isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
      ),
      padding: EdgeInsets.zero,
      splashRadius: 20,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(Icons.edit_outlined, size: 18, color: AppColors.textSecondary),
              const SizedBox(width: 12),
              const Text('Editar', style: TextStyle(fontSize: 14)),
            ],
          ),
        ),
        if (widget.onPostpone != null)
          PopupMenuItem(
            value: 'postpone',
            child: Row(
              children: [
                Icon(Icons.schedule, size: 18, color: AppColors.warning),
                const SizedBox(width: 12),
                const Text('Adiar +1 dia', style: TextStyle(fontSize: 14)),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete_outline, size: 18, color: AppColors.priorityHigh),
              const SizedBox(width: 12),
              Text(
                'Apagar',
                style: TextStyle(fontSize: 14, color: AppColors.priorityHigh),
              ),
            ],
          ),
        ),
      ],
      onSelected: (value) {
        HapticFeedback.lightImpact();
        switch (value) {
          case 'edit':
            widget.onEdit?.call();
            break;
          case 'postpone':
            widget.onPostpone?.call();
            break;
          case 'delete':
            widget.onDelete?.call();
            break;
        }
      },
    );
  }

  Widget _buildSwipeBackground({
    required Color color,
    required IconData icon,
    required Alignment alignment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white, size: 28),
    );
  }

  Widget _buildSwipeActionsBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.warning.withOpacity(0.8),
            AppColors.priorityHigh.withOpacity(0.9),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_outlined, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Icon(Icons.schedule, color: Colors.white, size: 24),
          const SizedBox(width: 16),
          Icon(Icons.delete_outline, color: Colors.white, size: 24),
        ],
      ),
    );
  }
}
