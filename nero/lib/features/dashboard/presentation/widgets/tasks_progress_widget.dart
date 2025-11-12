import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';

/// Widget de progresso de tarefas com gráfico circular
class TasksProgressWidget extends StatelessWidget {
  final int completedTasks;
  final int totalTasks;
  final List<TaskItem> recentTasks;
  final VoidCallback? onViewAll;
  final bool isDark;

  const TasksProgressWidget({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
    required this.recentTasks,
    this.onViewAll,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.grey300,
          width: 1,
        ),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Tarefas do Dia',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: const Text(
                  'Ver todas',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gráfico circular e estatísticas
          Row(
            children: [
              // Gráfico circular
              SizedBox(
                width: 100,
                height: 100,
                child: CustomPaint(
                  painter: CircularProgressPainter(
                    percentage: percentage,
                    isDark: isDark,
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '${(percentage * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkText
                                : AppColors.lightText,
                          ),
                        ),
                        Text(
                          'concluído',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 24),

              // Estatísticas
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatRow(
                      Icons.check_circle,
                      'Concluídas',
                      completedTasks.toString(),
                      AppColors.success,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      Icons.pending,
                      'Pendentes',
                      (totalTasks - completedTasks).toString(),
                      AppColors.warning,
                    ),
                    const SizedBox(height: 12),
                    _buildStatRow(
                      Icons.list_alt,
                      'Total',
                      totalTasks.toString(),
                      AppColors.primary,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Lista de tarefas recentes
          if (recentTasks.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(),
            const SizedBox(height: 12),
            ...recentTasks.take(3).map((task) => _buildTaskItem(task)),
          ],

          // Estado vazio
          if (recentTasks.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.task_alt,
                      size: 48,
                      color: isDark
                          ? AppColors.darkTextSecondary.withOpacity(0.5)
                          : AppColors.lightTextSecondary.withOpacity(0.5),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Nenhuma tarefa para hoje',
                      style: TextStyle(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ],
    );
  }

  Widget _buildTaskItem(TaskItem task) {
    return Builder(
      builder: (context) => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () {
            // Navegar para detalhes da tarefa com Hero animation
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => _TaskDetailPlaceholder(task: task, isDark: isDark),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Hero(
              tag: 'task-${task.id}',
              child: Material(
                color: Colors.transparent,
                child: Row(
                  children: [
                    // Checkbox
                    Icon(
                      task.completed ? Icons.check_circle : Icons.circle_outlined,
                      color: task.completed ? AppColors.success : AppColors.grey400,
                      size: 20,
                    ),
                    const SizedBox(width: 12),

                    // Título
                    Expanded(
                      child: Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                          decoration: task.completed ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // Badge de prioridade
                    if (task.priority != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getPriorityColor(task.priority!).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.priority!,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: _getPriorityColor(task.priority!),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'alta':
        return AppColors.error;
      case 'média':
        return AppColors.warning;
      case 'baixa':
        return AppColors.info;
      default:
        return AppColors.grey500;
    }
  }
}

/// Painter para o gráfico circular de progresso
class CircularProgressPainter extends CustomPainter {
  final double percentage;
  final bool isDark;

  CircularProgressPainter({
    required this.percentage,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 8;

    // Background circle
    final backgroundPaint = Paint()
      ..color = isDark
          ? AppColors.grey800.withOpacity(0.3)
          : AppColors.grey200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    if (percentage > 0) {
      final progressPaint = Paint()
        ..shader = const LinearGradient(
          colors: [AppColors.primary, AppColors.aiAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(Rect.fromCircle(center: center, radius: radius))
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12
        ..strokeCap = StrokeCap.round;

      const startAngle = -pi / 2; // Start from top
      final sweepAngle = 2 * pi * percentage;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// Modelo de item de tarefa
class TaskItem {
  final String id;
  final String title;
  final bool completed;
  final String? priority;

  const TaskItem({
    required this.id,
    required this.title,
    required this.completed,
    this.priority,
  });
}

/// Placeholder para demonstrar Hero transition
/// TODO: Substituir pela TaskDetailPage real
class _TaskDetailPlaceholder extends StatelessWidget {
  final TaskItem task;
  final bool isDark;

  const _TaskDetailPlaceholder({
    required this.task,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da Tarefa'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero widget deve ter a mesma tag
            Hero(
              tag: 'task-${task.id}',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.lightCard,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppColors.cardShadow,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        task.completed ? Icons.check_circle : Icons.circle_outlined,
                        color: task.completed ? AppColors.success : AppColors.grey400,
                        size: 28,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                            decoration: task.completed ? TextDecoration.lineThrough : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Informações adicionais
            Text(
              'Detalhes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
            const SizedBox(height: 16),

            _buildDetailRow('Status', task.completed ? 'Concluída' : 'Pendente'),
            if (task.priority != null) ...[
              const SizedBox(height: 12),
              _buildDetailRow('Prioridade', task.priority!),
            ],
            const SizedBox(height: 12),
            _buildDetailRow('ID', task.id),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.grey300,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }
}
