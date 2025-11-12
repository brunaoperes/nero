import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Configurações de acessibilidade
class AccessibilitySettings {
  final bool highContrast;
  final bool largeText;
  final bool reduceAnimations;
  final bool screenReaderEnabled;
  final double textScaleFactor;

  const AccessibilitySettings({
    this.highContrast = false,
    this.largeText = false,
    this.reduceAnimations = false,
    this.screenReaderEnabled = false,
    this.textScaleFactor = 1.0,
  });

  AccessibilitySettings copyWith({
    bool? highContrast,
    bool? largeText,
    bool? reduceAnimations,
    bool? screenReaderEnabled,
    double? textScaleFactor,
  }) {
    return AccessibilitySettings(
      highContrast: highContrast ?? this.highContrast,
      largeText: largeText ?? this.largeText,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
      screenReaderEnabled: screenReaderEnabled ?? this.screenReaderEnabled,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'highContrast': highContrast,
      'largeText': largeText,
      'reduceAnimations': reduceAnimations,
      'screenReaderEnabled': screenReaderEnabled,
      'textScaleFactor': textScaleFactor,
    };
  }

  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) {
    return AccessibilitySettings(
      highContrast: json['highContrast'] ?? false,
      largeText: json['largeText'] ?? false,
      reduceAnimations: json['reduceAnimations'] ?? false,
      screenReaderEnabled: json['screenReaderEnabled'] ?? false,
      textScaleFactor: json['textScaleFactor'] ?? 1.0,
    );
  }
}

/// Notifier para gerenciar configurações de acessibilidade
class AccessibilityNotifier extends StateNotifier<AccessibilitySettings> {
  AccessibilityNotifier() : super(const AccessibilitySettings()) {
    _loadSettings();
  }

  static const String _prefsKey = 'accessibility_settings';

  /// Carrega configurações salvas
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString(_prefsKey);

      if (json != null) {
        // Aqui você pode converter JSON para AccessibilitySettings
        // Por enquanto, vamos manter as configurações padrão
      }
    } catch (e) {
      debugPrint('Erro ao carregar configurações de acessibilidade: $e');
    }
  }

  /// Salva configurações
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Aqui você pode salvar as configurações em JSON
      await prefs.setString(_prefsKey, state.toJson().toString());
    } catch (e) {
      debugPrint('Erro ao salvar configurações de acessibilidade: $e');
    }
  }

  /// Toggle alto contraste
  void toggleHighContrast() {
    state = state.copyWith(highContrast: !state.highContrast);
    _saveSettings();
  }

  /// Toggle texto grande
  void toggleLargeText() {
    state = state.copyWith(largeText: !state.largeText);
    _saveSettings();
  }

  /// Toggle reduzir animações
  void toggleReduceAnimations() {
    state = state.copyWith(reduceAnimations: !state.reduceAnimations);
    _saveSettings();
  }

  /// Toggle screen reader
  void toggleScreenReader() {
    state = state.copyWith(screenReaderEnabled: !state.screenReaderEnabled);
    _saveSettings();
  }

  /// Ajusta fator de escala de texto
  void setTextScaleFactor(double factor) {
    state = state.copyWith(textScaleFactor: factor.clamp(0.8, 2.0));
    _saveSettings();
  }

  /// Reseta para configurações padrão
  void reset() {
    state = const AccessibilitySettings();
    _saveSettings();
  }
}

/// Provider de configurações de acessibilidade
final accessibilityProvider =
    StateNotifierProvider<AccessibilityNotifier, AccessibilitySettings>((ref) {
  return AccessibilityNotifier();
});

/// Provider para verificar se alto contraste está ativo
final highContrastProvider = Provider<bool>((ref) {
  return ref.watch(accessibilityProvider).highContrast;
});

/// Provider para verificar se texto grande está ativo
final largeTextProvider = Provider<bool>((ref) {
  return ref.watch(accessibilityProvider).largeText;
});

/// Provider para verificar se deve reduzir animações
final reduceAnimationsProvider = Provider<bool>((ref) {
  return ref.watch(accessibilityProvider).reduceAnimations;
});

/// Provider para verificar se screen reader está ativo
final screenReaderProvider = Provider<bool>((ref) {
  return ref.watch(accessibilityProvider).screenReaderEnabled;
});

/// Provider para fator de escala de texto
final textScaleFactorProvider = Provider<double>((ref) {
  return ref.watch(accessibilityProvider).textScaleFactor;
});
