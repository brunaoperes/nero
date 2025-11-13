import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Serviço para detectar a origem da instalação do app
class InstallerDetector {
  static const MethodChannel _channel =
      MethodChannel('com.nero.app/installer');

  /// Nomes de pacotes conhecidos da Play Store
  static const List<String> _playStorePackages = [
    'com.android.vending', // Google Play Store
    'com.google.android.feedback', // Google Play Services
  ];

  /// Verifica se o app foi instalado via Play Store
  static Future<bool> isInstalledFromPlayStore() async {
    if (!Platform.isAndroid) {
      debugPrint('InstallerDetector: Não é Android');
      return false;
    }

    try {
      final String? installerPackage = await _channel.invokeMethod(
        'getInstallerPackageName',
      );

      debugPrint('InstallerDetector: Instalador detectado: $installerPackage');

      if (installerPackage == null) {
        debugPrint('InstallerDetector: Nenhum instalador detectado (sideload)');
        return false;
      }

      final isPlayStore = _playStorePackages.contains(installerPackage);
      debugPrint('InstallerDetector: É Play Store? $isPlayStore');

      return isPlayStore;
    } on PlatformException catch (e) {
      debugPrint('InstallerDetector: Erro ao detectar instalador: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('InstallerDetector: Erro inesperado: $e');
      return false;
    }
  }

  /// Obtém o nome do pacote do instalador
  static Future<String?> getInstallerPackageName() async {
    if (!Platform.isAndroid) {
      return null;
    }

    try {
      final String? installerPackage = await _channel.invokeMethod(
        'getInstallerPackageName',
      );
      return installerPackage;
    } on PlatformException catch (e) {
      debugPrint('Erro ao obter instalador: ${e.message}');
      return null;
    }
  }

  /// Retorna uma descrição amigável da origem da instalação
  static Future<String> getInstallSourceDescription() async {
    if (!Platform.isAndroid) {
      return 'N/A (não é Android)';
    }

    final installerPackage = await getInstallerPackageName();

    if (installerPackage == null) {
      return 'Instalação manual (sideload)';
    }

    switch (installerPackage) {
      case 'com.android.vending':
        return 'Google Play Store';
      case 'com.google.android.feedback':
        return 'Google Play Services';
      case 'com.android.packageinstaller':
        return 'Instalador do sistema';
      case 'com.google.android.packageinstaller':
        return 'Instalador Google';
      default:
        return 'Outra fonte: $installerPackage';
    }
  }
}
