import 'package:flutter/material.dart';
import 'package:nero/core/utils/app_logger.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gerenciar o tema da aplicação
final themeProvider = StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

/// Notifier para gerenciar o estado do tema
class ThemeNotifier extends StateNotifier<ThemeMode> {
  static const String _themeKey = 'theme_mode';

  ThemeNotifier() : super(ThemeMode.dark) {
    _loadTheme();
  }

  /// Carrega o tema salvo nas preferências
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeKey);

      if (themeModeString != null) {
        state = ThemeMode.values.firstWhere(
          (mode) => mode.toString() == themeModeString,
          orElse: () => ThemeMode.dark,
        );
      }
    } catch (e) {
      AppLogger.error('Erro ao carregar tema', error: e);
    }
  }

  /// Alterna entre tema claro e escuro
  Future<void> toggleTheme() async {
    try {
      final newTheme = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
      state = newTheme;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, newTheme.toString());
    } catch (e) {
      AppLogger.error('Erro ao salvar tema', error: e);
    }
  }

  /// Define um tema específico
  Future<void> setTheme(ThemeMode mode) async {
    try {
      state = mode;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeKey, mode.toString());
    } catch (e) {
      AppLogger.error('Erro ao definir tema', error: e);
    }
  }

  /// Retorna true se o tema atual é escuro
  bool get isDarkMode => state == ThemeMode.dark;
}
