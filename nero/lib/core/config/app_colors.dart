import 'package:flutter/material.dart';

/// Paleta de cores do Nero
/// Seguindo a identidade visual especificada no design system
class AppColors {
  AppColors._();

  // ==================== Cores Principais ====================

  /// Azul Elétrico - Cor primária do app
  /// Usada em botões, ícones ativos e elementos interativos
  static const Color primary = Color(0xFF0072FF);

  /// Dourado Suave - Cor secundária
  /// Usada em ícones da IA e detalhes premium
  static const Color secondary = Color(0xFFFFD700);

  /// Azul Ciano - Accent da IA
  /// Cor de destaque em elementos da IA
  static const Color aiAccent = Color(0xFF00E5FF);

  /// Azul Cyan Suave - IA secundária (para botões sutis)
  /// Usado em botões de sugestão e elementos da IA com menor destaque
  static const Color aiSecondary = Color(0xFF00C6FF);

  // ==================== Tema Claro (Clean e Sofisticado) ====================

  /// Fundo principal do tema claro - bem suave
  static const Color lightBackground = Color(0xFFFAFAFA);

  /// Fundo de cards e containers no tema claro
  static const Color lightCard = Color(0xFFFFFFFF);

  /// Fundo de cards elevados no tema claro
  static const Color lightCardElevated = Color(0xFFF4F4F4);

  /// Cor de texto principal no tema claro - preto grafite com alto contraste
  static const Color lightText = Color(0xFF1C1C1C);

  /// Cor de texto secundário no tema claro - cinza médio legível
  static const Color lightTextSecondary = Color(0xFF5F5F5F);

  /// Cor de ícones no tema claro - contraste forte
  static const Color lightIcon = Color(0xFF2E2E2E);

  /// Cor de bordas no tema claro - mais visível
  static const Color lightBorder = Color(0xFFE5E5E5);

  // ==================== Tema Escuro (Minimalista Moderno) ====================

  /// Fundo principal do tema escuro - preto profundo minimalista
  static const Color darkBackground = Color(0xFF0E0E10);

  /// Fundo de cards e containers no tema escuro - cinza neutro
  static const Color darkCard = Color(0xFF18181B);

  /// Fundo de cards elevados no tema escuro
  static const Color darkCardElevated = Color(0xFF242424);

  /// Fundo de superfícies alternativas - compatibilidade
  static const Color darkSurface = Color(0xFF18181B);

  /// Cor de texto principal no tema escuro
  static const Color darkText = Color(0xFFEAEAEA);

  /// Cor de texto secundário no tema escuro
  static const Color darkTextSecondary = Color(0xFF9E9E9E);

  /// Cor de bordas e divisores no tema escuro - sutil
  static const Color darkBorder = Color(0xFF2A2A2D);

  // ==================== Cores de Estado ====================

  /// Cor de sucesso
  static const Color success = Color(0xFF00C853);

  /// Cor de erro
  static const Color error = Color(0xFFFF3B30);

  /// Cor de aviso
  static const Color warning = Color(0xFFFF9500);

  /// Cor de informação
  static const Color info = Color(0xFF0072FF);

  // ==================== Cores de Prioridade (Sutis) ====================

  /// Prioridade Baixa - Verde suave pastel
  static const Color priorityLow = Color(0xFFA7E9AF);

  /// Prioridade Média - Amarelo suave pastel
  static const Color priorityMedium = Color(0xFFFFE29A);

  /// Prioridade Alta - Vermelho suave pastel
  static const Color priorityHigh = Color(0xFFF8B4B4);

  /// Background do botão de IA - Azul clarinho
  static const Color aiButtonBackground = Color(0xFFE8F0FF);

  // ==================== Cores Neutras ====================

  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // ==================== Gradientes ====================

  /// Gradiente primário do Nero
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFF0052CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente da IA (Azul Elétrico → Ciano)
  static const LinearGradient aiGradient = LinearGradient(
    colors: [primary, aiAccent], // #0072FF → #00E5FF
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente dourado premium
  static const LinearGradient premiumGradient = LinearGradient(
    colors: [secondary, Color(0xFFFFE55C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente financeiro (verde)
  static const LinearGradient financialGradient = LinearGradient(
    colors: [success, Color(0xFF00A86B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Gradiente de alerta (vermelho)
  static const LinearGradient alertGradient = LinearGradient(
    colors: [error, Color(0xFFD32F2F)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ==================== Sombras ====================

  /// Sombra leve para cards no tema claro
  static List<BoxShadow> get cardShadowLight => [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];

  /// Sombra leve para cards no tema escuro
  static List<BoxShadow> get cardShadowDark => [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ];

  /// Sombra para cards (legacy - compatibilidade)
  static List<BoxShadow> get cardShadow => cardShadowLight;

  /// Sombra média para elementos elevados
  static List<BoxShadow> get elevatedShadow => [
        BoxShadow(
          color: Colors.black.withOpacity(0.12),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  /// Sombra para elementos com glow (IA)
  static List<BoxShadow> get glowShadow => [
        BoxShadow(
          color: aiAccent.withOpacity(0.3),
          blurRadius: 20,
          offset: const Offset(0, 0),
        ),
      ];

  // ==================== Aliases para facilitar uso ====================

  /// Alias para darkText - Texto primário no tema escuro
  static const Color textPrimary = darkText;

  /// Alias para darkTextSecondary - Texto secundário no tema escuro
  static const Color textSecondary = darkTextSecondary;
}
