import 'package:flutter/material.dart';
import '../../core/config/app_colors.dart';

/// Widget de foco exibindo progresso das tarefas do dia
class FocusWidget extends StatelessWidget {
  final int pendingTasks;
  final int totalTasks;

  const FocusWidget({
    super.key,
    required this.pendingTasks,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context) {
    final completedTasks = totalTasks - pendingTasks;
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    final isCompleted = pendingTasks == 0 && totalTasks > 0;

    String getMessage() {
      if (isCompleted) {
        return '🎯 Parabéns! Você zerou o dia!';
      } else if (totalTasks == 0) {
        return 'Nenhuma tarefa para hoje';
      } else if (pendingTasks == 1) {
        return 'Falta 1 tarefa para zerar o dia';
      } else {
        return 'Faltam $pendingTasks tarefas para zerar o dia';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: isCompleted
            ? const Color(0xFFDFFFE0) // Verde pastel
            : AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: isCompleted
            ? Border.all(color: const Color(0xFF009E0F).withOpacity(0.2))
            : Border.all(color: AppColors.darkBorder.withOpacity(0.1)),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Mensagem centralizada
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCompleted ? Icons.celebration_outlined : Icons.center_focus_strong_outlined,
                size: 20,
                color: isCompleted
                    ? const Color(0xFF009E0F)
                    : AppColors.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  getMessage(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isCompleted
                        ? const Color(0xFF009E0F)
                        : AppColors.textPrimary,
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ],
          ),

          if (totalTasks > 0) ...[
            const SizedBox(height: 12),

            // Barra de progresso fina
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: isCompleted
                    ? const Color(0xFF009E0F).withOpacity(0.2)
                    : AppColors.grey300.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation(
                  isCompleted
                      ? const Color(0xFF009E0F)
                      : AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Informações de progresso
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '$completedTasks de $totalTasks concluídas',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary.withOpacity(0.8),
                    fontFamily: 'Inter',
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isCompleted
                        ? const Color(0xFF009E0F)
                        : AppColors.primary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
