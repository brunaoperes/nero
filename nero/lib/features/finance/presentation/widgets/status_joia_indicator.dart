// lib/features/finance/presentation/widgets/status_joia_indicator.dart
import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';

/// Indicador "Joia" para status Pago/Não pago (estilo Organizze)
/// - Pago: joia para cima, cor do tema
/// - Não pago: joia para baixo, cor vermelha
class StatusJoiaIndicator extends StatelessWidget {
  final bool isPaid;
  final VoidCallback onToggle;
  final String type; // expense, income, transfer

  const StatusJoiaIndicator({
    super.key,
    required this.isPaid,
    required this.onToggle,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Transferência não tem joia
    if (type == 'transfer') {
      return const SizedBox.shrink();
    }

    // Cores baseadas no estado
    final Color joiaColor = isPaid
        ? (isDark ? AppColors.primary : const Color(0xFF4CAF50)) // Verde/tema quando pago
        : AppColors.error; // Vermelho quando não pago

    final IconData joiaIcon = isPaid
        ? Icons.thumb_up_rounded // Joia para cima
        : Icons.thumb_down_rounded; // Joia para baixo

    return Semantics(
      label: isPaid ? 'Pago' : 'Não pago',
      hint: 'Toque para alternar entre pago e não pago',
      button: true,
      child: GestureDetector(
        onTap: onToggle,
        onLongPress: () {
          // Tooltip/feedback em pressão longa
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                isPaid ? 'Marcar como não pago' : 'Marcar como pago',
                style: const TextStyle(fontSize: 14),
              ),
              duration: const Duration(milliseconds: 1500),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.only(bottom: 60, left: 16, right: 16),
            ),
          );
        },
        child: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: joiaColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            joiaIcon,
            color: joiaColor,
            size: 24,
          ),
        ),
      ),
    );
  }
}
