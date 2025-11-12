import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';

/// Cabeçalho da tela de tarefas com anel de progresso
class TasksHeaderWidget extends StatelessWidget {
  final int completedTasks;
  final int pendingTasks;
  final int totalTasks;
  final bool isDark;

  const TasksHeaderWidget({
    super.key,
    required this.completedTasks,
    required this.pendingTasks,
    required this.totalTasks,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    final percentage = totalTasks > 0 ? (completedTasks / totalTasks) : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder.withOpacity(0.1) : const Color(0xFFE0E0E0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withOpacity(0.1)
                : Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Anel de progresso
          SizedBox(
            width: 80,
            height: 80,
            child: CustomPaint(
              painter: _ProgressRingPainter(
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
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                        fontFamily: 'Poppins',
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'completo',
                      style: TextStyle(
                        fontSize: 9,
                        color: isDark
                            ? AppColors.textSecondary.withOpacity(0.7)
                            : AppColors.textSecondary,
                        fontFamily: 'Inter',
                        height: 1,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 20),

          // Estatísticas
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow(
                  label: 'Concluídas',
                  value: completedTasks,
                  color: AppColors.success,
                  icon: Icons.check_circle,
                ),
                const SizedBox(height: 10),
                _buildStatRow(
                  label: 'Pendentes',
                  value: pendingTasks,
                  color: AppColors.warning,
                  icon: Icons.pending,
                ),
                const SizedBox(height: 10),
                _buildStatRow(
                  label: 'Total',
                  value: totalTasks,
                  color: AppColors.primary,
                  icon: Icons.list_alt,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required int value,
    required Color color,
    required IconData icon,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? AppColors.textSecondary.withOpacity(0.8)
                  : AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ),
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}

/// Painter personalizado para o anel de progresso
class _ProgressRingPainter extends CustomPainter {
  final double percentage;
  final bool isDark;

  _ProgressRingPainter({
    required this.percentage,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2 - 6;

    // Background circle (trilha cinza)
    final backgroundPaint = Paint()
      ..color = isDark
          ? AppColors.grey800.withOpacity(0.3)
          : const Color(0xFFE0E0E0)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc (gradiente)
    if (percentage > 0) {
      final rect = Rect.fromCircle(center: center, radius: radius);
      final gradient = SweepGradient(
        startAngle: -pi / 2,
        endAngle: -pi / 2 + (2 * pi * percentage),
        colors: [
          AppColors.primary,
          AppColors.aiAccent,
        ],
      );

      final progressPaint = Paint()
        ..shader = gradient.createShader(rect)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8
        ..strokeCap = StrokeCap.round;

      const startAngle = -pi / 2; // Começa do topo
      final sweepAngle = 2 * pi * percentage;

      canvas.drawArc(
        rect,
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
