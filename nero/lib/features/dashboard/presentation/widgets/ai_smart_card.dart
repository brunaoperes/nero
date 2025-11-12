import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';

/// Card de sugestão da IA - só aparece quando há dados reais
class AiSmartCard extends StatelessWidget {
  final String suggestion;
  final String category;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDark;

  const AiSmartCard({
    super.key,
    required this.suggestion,
    required this.category,
    required this.icon,
    this.onTap,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            // Gradiente premium: azul profundo → preto (mesmo de finanças)
            gradient: const LinearGradient(
              colors: [
                Color(0xFF1A2A6C), // Azul profundo (início)
                Color(0xFF162447), // Azul escuro (meio)
                Color(0xFF000000), // Preto (fim)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.35), // Sombra mais profunda
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Reduzido de 20
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center, // Mudado para center
                  children: [
                // Ícone com glow (reduzido)
                Container(
                  padding: const EdgeInsets.all(10), // Reduzido de 12
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 24, // Reduzido de 28
                  ),
                ),
                const SizedBox(width: 12), // Reduzido de 16

                    // Conteúdo
                    Expanded(
                      child: Text(
                        suggestion,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13, // Reduzido de 14
                          fontWeight: FontWeight.w600,
                          height: 1.3, // Reduzido de 1.4
                        ),
                        maxLines: 2, // Reduzido de 3
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8), // Reduzido de 12

                    // Seta
                    Icon(
                      Icons.arrow_forward_ios,
                      color: Colors.white.withOpacity(0.8),
                      size: 16, // Reduzido de 18
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
}

/// Widget que decide se mostra o card de IA ou uma mensagem de onboarding
class AiSmartCardWrapper extends StatelessWidget {
  final bool hasUserData;
  final String? suggestion;
  final String? category;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool isDark;

  const AiSmartCardWrapper({
    super.key,
    required this.hasUserData,
    this.suggestion,
    this.category,
    this.icon,
    this.onTap,
    this.isDark = true,
  });

  @override
  Widget build(BuildContext context) {
    // Se não há dados suficientes, mostra card de onboarding (compacto)
    if (!hasUserData) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Compacto
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.grey300,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.psychology_outlined,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.lightTextSecondary,
              size: 28, // Reduzido de 32
            ),
            const SizedBox(width: 12), // Reduzido de 16
            Expanded(
              child: Text(
                'Continue usando o Nero para receber insights personalizados da IA',
                style: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                  fontSize: 13, // Reduzido de 14
                  height: 1.3, // Reduzido de 1.4
                ),
                maxLines: 2, // Limitar a 2 linhas
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    // Se há dados, mostra o card de sugestão da IA
    return AiSmartCard(
      suggestion: suggestion ?? 'Suas finanças estão equilibradas!',
      category: category ?? 'Insight',
      icon: icon ?? Icons.lightbulb,
      onTap: onTap,
      isDark: isDark,
    );
  }
}
