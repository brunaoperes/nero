import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/providers/accessibility_provider.dart';
import '../../../../core/widgets/accessibility_widgets.dart';

/// Página de Configurações de Acessibilidade
class AccessibilitySettingsPage extends ConsumerWidget {
  const AccessibilitySettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final a11ySettings = ref.watch(accessibilityProvider);
    final a11yNotifier = ref.read(accessibilityProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Acessibilidade'),
        actions: [
          // Botão de ajuda com atalhos de teclado
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showKeyboardShortcuts(context),
            tooltip: 'Atalhos de teclado',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Seção: Visual
          _buildSectionHeader('Visual', Icons.visibility, isDark),
          const SizedBox(height: 16),

          // Alto Contraste
          AccessibleCard(
            semanticLabel: 'Alto contraste. ${a11ySettings.highContrast ? "Ativado" : "Desativado"}',
            tooltip: 'Aumenta o contraste de cores para melhor legibilidade',
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            child: AccessibleSwitch(
              value: a11ySettings.highContrast,
              onChanged: (_) => a11yNotifier.toggleHighContrast(),
              label: 'Alto Contraste',
              semanticLabel: 'Alternar alto contraste',
            ),
          ),
          const SizedBox(height: 12),

          // Texto Grande
          AccessibleCard(
            semanticLabel: 'Texto grande. ${a11ySettings.largeText ? "Ativado" : "Desativado"}',
            tooltip: 'Aumenta o tamanho do texto em todo o aplicativo',
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            child: AccessibleSwitch(
              value: a11ySettings.largeText,
              onChanged: (_) => a11yNotifier.toggleLargeText(),
              label: 'Texto Grande',
              semanticLabel: 'Alternar texto grande',
            ),
          ),
          const SizedBox(height: 12),

          // Escala de Texto
          AccessibleCard(
            semanticLabel: 'Tamanho do texto. Atual: ${(a11ySettings.textScaleFactor * 100).toInt()}%',
            tooltip: 'Ajuste fino do tamanho do texto',
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tamanho do Texto',
                      style: TextStyle(fontSize: 16),
                    ),
                    Text(
                      '${(a11ySettings.textScaleFactor * 100).toInt()}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Slider de tamanho do texto',
                  value: '${(a11ySettings.textScaleFactor * 100).toInt()}%',
                  child: Slider(
                    value: a11ySettings.textScaleFactor,
                    min: 0.8,
                    max: 2.0,
                    divisions: 12,
                    activeColor: AppColors.primary,
                    onChanged: (value) => a11yNotifier.setTextScaleFactor(value),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '80%',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    Text(
                      '200%',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Seção: Movimento
          _buildSectionHeader('Movimento', Icons.motion_photos_on, isDark),
          const SizedBox(height: 16),

          // Reduzir Animações
          AccessibleCard(
            semanticLabel: 'Reduzir animações. ${a11ySettings.reduceAnimations ? "Ativado" : "Desativado"}',
            tooltip: 'Reduz ou desativa animações para evitar distração',
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            child: AccessibleSwitch(
              value: a11ySettings.reduceAnimations,
              onChanged: (_) => a11yNotifier.toggleReduceAnimations(),
              label: 'Reduzir Animações',
              semanticLabel: 'Alternar reduzir animações',
            ),
          ),

          const SizedBox(height: 32),

          // Seção: Leitores de Tela
          _buildSectionHeader('Leitores de Tela', Icons.record_voice_over, isDark),
          const SizedBox(height: 16),

          // Screen Reader
          AccessibleCard(
            semanticLabel: 'Otimizações para leitores de tela. ${a11ySettings.screenReaderEnabled ? "Ativado" : "Desativado"}',
            tooltip: 'Ativa otimizações para usuários de leitores de tela',
            backgroundColor: isDark ? AppColors.darkCard : AppColors.lightCard,
            child: AccessibleSwitch(
              value: a11ySettings.screenReaderEnabled,
              onChanged: (_) => a11yNotifier.toggleScreenReader(),
              label: 'Otimizar para Leitor de Tela',
              semanticLabel: 'Alternar otimizações para leitor de tela',
            ),
          ),

          const SizedBox(height: 32),

          // Informações
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.info.withOpacity(0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sobre Acessibilidade',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Este aplicativo foi desenvolvido com recursos de acessibilidade para garantir que todos possam usá-lo confortavelmente.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Botão de Reset
          AccessibleButton(
            onPressed: () => _showResetDialog(context, a11yNotifier),
            semanticLabel: 'Restaurar configurações padrão',
            tooltip: 'Volta todas as configurações ao padrão',
            backgroundColor: AppColors.error.withOpacity(0.1),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restore, color: AppColors.error),
                  SizedBox(width: 8),
                  Text(
                    'Restaurar Padrão',
                    style: TextStyle(
                      color: AppColors.error,
                      fontWeight: FontWeight.bold,
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

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ],
    );
  }

  void _showResetDialog(BuildContext context, AccessibilityNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restaurar Padrão'),
        content: const Text(
          'Tem certeza que deseja restaurar todas as configurações de acessibilidade para o padrão?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              notifier.reset();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configurações restauradas'),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Restaurar'),
          ),
        ],
      ),
    );
  }

  void _showKeyboardShortcuts(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const KeyboardShortcutsHelp(
        shortcuts: {
          'Tab': 'Navegar entre elementos',
          'Enter/Espaço': 'Ativar elemento selecionado',
          'Esc': 'Fechar diálogo ou voltar',
          'Ctrl + +': 'Aumentar tamanho do texto',
          'Ctrl + -': 'Diminuir tamanho do texto',
          'Ctrl + 0': 'Resetar tamanho do texto',
        },
      ),
    );
  }
}
