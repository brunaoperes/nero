import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_filex/open_filex.dart';
import '../models/update_info.dart';
import 'installer_detector.dart';

/// Serviço responsável por gerenciar atualizações do app
class AppUpdateService {
  static const String _manifestUrl =
      'https://raw.githubusercontent.com/brunaoperes/nero/main/updates/latest.json';

  static const Duration _checkInterval = Duration(hours: 24);
  static const String _lastCheckKey = 'last_update_check';
  static const String _updateSkippedKey = 'update_skipped_version';

  final Dio _dio;
  final FlutterSecureStorage _storage;
  final _progressController = StreamController<DownloadProgress>.broadcast();
  CancelToken? _downloadCancelToken;
  String? _currentDownloadPath;

  AppUpdateService({
    Dio? dio,
    FlutterSecureStorage? storage,
  })  : _dio = dio ?? Dio(),
        _storage = storage ?? const FlutterSecureStorage() {
    _configureDio();
  }

  void _configureDio() {
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.receiveTimeout = const Duration(seconds: 60);
    _dio.options.validateStatus = (status) => status! < 500;
  }

  Stream<DownloadProgress> get progressStream => _progressController.stream;

  /// Verifica se é necessário checar atualizações
  Future<bool> shouldCheckForUpdates() async {
    // MODO TESTE: Sempre permite checagem
    return true;

    /* DESCOMENTE PARA USAR INTERVALO DE 24H EM PRODUÇÃO:
    try {
      final lastCheckStr = await _storage.read(key: _lastCheckKey);
      if (lastCheckStr == null) return true;

      final lastCheck = DateTime.parse(lastCheckStr);
      final now = DateTime.now();
      return now.difference(lastCheck) >= _checkInterval;
    } catch (e) {
      return true; // Em caso de erro, permitir checagem
    }
    */
  }

  /// Marca que a checagem foi realizada
  Future<void> _markCheckCompleted() async {
    await _storage.write(
      key: _lastCheckKey,
      value: DateTime.now().toIso8601String(),
    );
  }

  /// Verifica se o app foi instalado via Play Store
  Future<bool> isInstalledFromPlayStore() async {
    return await InstallerDetector.isInstalledFromPlayStore();
  }

  String? _lastError;

  String? get lastError => _lastError;

  /// Busca informações sobre atualizações disponíveis
  Future<UpdateInfo?> checkForUpdates({
    String? customManifestUrl,
  }) async {
    _lastError = null;

    try {
      final url = customManifestUrl ?? _manifestUrl;

      debugPrint('🔍 DEBUG: Buscando atualizações em: $url');

      final response = await _dio.get(
        url,
        options: Options(
          responseType: ResponseType.plain,
          headers: {
            'Cache-Control': 'no-cache',
            'Accept': 'application/json',
          },
        ),
      );

      debugPrint('🔍 DEBUG: Status code: ${response.statusCode}');
      debugPrint('🔍 DEBUG: Response type: ${response.data.runtimeType}');

      if (response.statusCode == 200) {
        debugPrint('🔍 DEBUG: Resposta recebida, parseando JSON...');

        // Parse manual do JSON
        final jsonData = jsonDecode(response.data as String);
        final updateInfo = UpdateInfo.fromJson(jsonData);
        await _markCheckCompleted();

        debugPrint('✅ DEBUG: Informações de atualização recebidas: ${updateInfo.versionName} (${updateInfo.versionCode})');

        return updateInfo;
      } else {
        _lastError = 'HTTP ${response.statusCode}: ${response.statusMessage}\nResponse: ${response.data}';
        debugPrint('❌ DEBUG: Falha ao buscar atualizações: ${response.statusCode}');
        debugPrint('❌ DEBUG: Response body: ${response.data}');
        return null;
      }
    } on DioException catch (e) {
      _lastError = 'DioException: ${e.type.toString()} - ${e.message}';
      debugPrint('❌ DEBUG: Erro de rede ao buscar atualizações: ${e.message}');
      debugPrint('❌ DEBUG: Tipo de erro: ${e.type}');
      return null;
    } catch (e) {
      _lastError = 'Exception: $e';
      debugPrint('❌ DEBUG: Erro ao buscar atualizações: $e');
      return null;
    }
  }

  /// Verifica se há atualização disponível
  Future<UpdateInfo?> getAvailableUpdate({
    String? customManifestUrl,
  }) async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;

      debugPrint('🔍 DEBUG: Versão instalada: ${packageInfo.version} (code: $currentVersionCode)');

      final updateInfo = await checkForUpdates(
        customManifestUrl: customManifestUrl,
      );

      if (updateInfo == null) {
        debugPrint('❌ DEBUG: updateInfo é null - não conseguiu buscar do servidor');
        return null;
      }

      debugPrint('📦 DEBUG: Versão disponível: ${updateInfo.versionName} (code: ${updateInfo.versionCode})');

      // Verifica se a versão foi ignorada pelo usuário
      final skippedVersion = await _storage.read(key: _updateSkippedKey);
      debugPrint('⏭️  DEBUG: Versão ignorada: $skippedVersion');

      if (skippedVersion == updateInfo.versionCode.toString() &&
          !updateInfo.mandatory) {
        debugPrint('🚫 Atualização ${updateInfo.versionName} foi ignorada pelo usuário');
        return null;
      }

      // Verifica se há atualização disponível
      debugPrint('🔢 DEBUG: Comparando $currentVersionCode < ${updateInfo.versionCode}');

      if (updateInfo.hasUpdate(currentVersionCode)) {
        debugPrint('✅ DEBUG: Atualização disponível!');
        return updateInfo;
      }

      debugPrint('ℹ️  App está na versão mais recente');
      return null;
    } catch (e) {
      debugPrint('❌ Erro ao verificar atualização disponível: $e');
      return null;
    }
  }

  /// Marca uma versão como ignorada
  Future<void> skipVersion(int versionCode) async {
    await _storage.write(
      key: _updateSkippedKey,
      value: versionCode.toString(),
    );
  }

  /// Limpa a versão ignorada
  Future<void> clearSkippedVersion() async {
    await _storage.delete(key: _updateSkippedKey);
  }

  /// Baixa o APK de atualização
  Future<String?> downloadUpdate(
    UpdateInfo updateInfo, {
    Function(DownloadProgress)? onProgress,
  }) async {
    try {
      _downloadCancelToken = CancelToken();

      final tempDir = await getTemporaryDirectory();
      final fileName = 'app_update_${updateInfo.versionCode}.apk';
      _currentDownloadPath = '${tempDir.path}/$fileName';

      _emitProgress(DownloadProgress(status: DownloadStatus.downloading));

      await _dio.download(
        updateInfo.apkUrl,
        _currentDownloadPath,
        cancelToken: _downloadCancelToken,
        onReceiveProgress: (received, total) {
          final progress = DownloadProgress(
            status: DownloadStatus.downloading,
            bytesReceived: received,
            totalBytes: total,
          );
          _emitProgress(progress);
          onProgress?.call(progress);
        },
      );

      // Verificar hash SHA-256
      _emitProgress(DownloadProgress(status: DownloadStatus.verifying));

      final isValid = await _verifyFileHash(
        _currentDownloadPath!,
        updateInfo.apkSha256,
      );

      if (!isValid) {
        _emitProgress(
          DownloadProgress(
            status: DownloadStatus.failed,
            error: 'Hash SHA-256 inválido. O arquivo pode estar corrompido.',
          ),
        );
        // Deletar arquivo corrompido
        final file = File(_currentDownloadPath!);
        if (await file.exists()) {
          await file.delete();
        }
        return null;
      }

      _emitProgress(DownloadProgress(status: DownloadStatus.completed));

      debugPrint('Download concluído: $_currentDownloadPath');

      return _currentDownloadPath;
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        _emitProgress(DownloadProgress(status: DownloadStatus.paused));
        debugPrint('Download pausado pelo usuário');
      } else {
        _emitProgress(
          DownloadProgress(
            status: DownloadStatus.failed,
            error: 'Erro ao baixar: ${e.message}',
          ),
        );
        debugPrint('Erro ao baixar atualização: ${e.message}');
      }
      return null;
    } catch (e) {
      _emitProgress(
        DownloadProgress(
          status: DownloadStatus.failed,
          error: 'Erro inesperado: $e',
        ),
      );
      debugPrint('Erro ao baixar atualização: $e');
      return null;
    }
  }

  /// Verifica o hash SHA-256 do arquivo
  Future<bool> _verifyFileHash(String filePath, String expectedHash) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      final digest = sha256.convert(bytes);
      final actualHash = digest.toString();

      debugPrint('Hash esperado: $expectedHash');
      debugPrint('Hash atual: $actualHash');

      return actualHash.toLowerCase() == expectedHash.toLowerCase();
    } catch (e) {
      debugPrint('Erro ao verificar hash: $e');
      return false;
    }
  }

  /// Pausa o download atual
  void pauseDownload() {
    _downloadCancelToken?.cancel('Download pausado');
  }

  /// Instala o APK baixado
  Future<bool> installUpdate(String apkPath) async {
    try {
      if (!Platform.isAndroid) {
        debugPrint('Instalação de APK só é suportada no Android');
        return false;
      }

      final file = File(apkPath);
      if (!await file.exists()) {
        debugPrint('Arquivo APK não encontrado: $apkPath');
        return false;
      }

      _emitProgress(DownloadProgress(status: DownloadStatus.installing));

      // Abre o APK com o instalador do sistema
      final result = await OpenFilex.open(apkPath);

      debugPrint('Resultado da instalação: ${result.message}');

      // OpenFilex retorna "done" se abriu com sucesso
      return result.type == ResultType.done;
    } catch (e) {
      _emitProgress(
        DownloadProgress(
          status: DownloadStatus.failed,
          error: 'Erro ao instalar: $e',
        ),
      );
      debugPrint('Erro ao instalar atualização: $e');
      return false;
    }
  }

  /// Limpa arquivos temporários de atualização
  Future<void> cleanupUpdateFiles() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final files = tempDir.listSync();

      for (final file in files) {
        if (file.path.contains('app_update_') && file.path.endsWith('.apk')) {
          try {
            await file.delete();
            debugPrint('Arquivo de atualização deletado: ${file.path}');
          } catch (e) {
            debugPrint('Erro ao deletar arquivo: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Erro ao limpar arquivos de atualização: $e');
    }
  }

  /// Obtém informações da versão atual do app
  Future<Map<String, dynamic>> getCurrentVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return {
        'versionName': packageInfo.version,
        'versionCode': int.tryParse(packageInfo.buildNumber) ?? 0,
        'appName': packageInfo.appName,
        'packageName': packageInfo.packageName,
      };
    } catch (e) {
      debugPrint('Erro ao obter versão atual: $e');
      return {};
    }
  }

  void _emitProgress(DownloadProgress progress) {
    if (!_progressController.isClosed) {
      _progressController.add(progress);
    }
  }

  void dispose() {
    _downloadCancelToken?.cancel();
    _progressController.close();
  }
}
