import 'package:flutter/material.dart';
import '../models/update_info.dart';
import '../services/app_update_service.dart';

/// Dialog que exibe informações sobre atualização disponível
class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;
  final AppUpdateService updateService;
  final bool mandatory;

  const UpdateDialog({
    super.key,
    required this.updateInfo,
    required this.updateService,
    this.mandatory = false,
  });

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  DownloadStatus _downloadStatus = DownloadStatus.idle;
  DownloadProgress? _currentProgress;
  String? _downloadedApkPath;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _listenToProgress();
  }

  void _listenToProgress() {
    widget.updateService.progressStream.listen((progress) {
      if (mounted) {
        setState(() {
          _downloadStatus = progress.status;
          _currentProgress = progress;

          if (progress.status == DownloadStatus.failed) {
            _errorMessage = progress.error;
          }
        });
      }
    });
  }

  Future<void> _startDownload() async {
    setState(() {
      _errorMessage = null;
    });

    final apkPath = await widget.updateService.downloadUpdate(
      widget.updateInfo,
    );

    if (apkPath != null) {
      setState(() {
        _downloadedApkPath = apkPath;
      });
    }
  }

  Future<void> _installUpdate() async {
    if (_downloadedApkPath == null) return;

    final success = await widget.updateService.installUpdate(_downloadedApkPath!);

    if (!success && mounted) {
      setState(() {
        _errorMessage = 'Falha ao iniciar instalação. Verifique as permissões.';
      });
    }
  }

  Future<void> _skipUpdate() async {
    if (!widget.mandatory) {
      await widget.updateService.skipVersion(widget.updateInfo.versionCode);
      if (mounted) {
        Navigator.of(context).pop(false);
      }
    }
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.mandatory && _downloadStatus != DownloadStatus.downloading,
      child: AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.system_update, color: Colors.blue),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                widget.mandatory
                    ? 'Atualização Obrigatória'
                    : 'Atualização Disponível',
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Versão
              Text(
                'Versão ${widget.updateInfo.versionName}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              // Changelog
              if (widget.updateInfo.changelog.isNotEmpty) ...[
                const Text(
                  'Novidades:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                ...widget.updateInfo.changelog.map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16)),
                          Expanded(child: Text(item)),
                        ],
                      ),
                    )),
                const SizedBox(height: 16),
              ],

              // Progresso do download
              if (_downloadStatus != DownloadStatus.idle) ...[
                const Divider(),
                const SizedBox(height: 8),
                _buildProgressSection(),
              ],

              // Mensagem de erro
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: _buildActions(),
      ),
    );
  }

  Widget _buildProgressSection() {
    switch (_downloadStatus) {
      case DownloadStatus.downloading:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Baixando atualização...'),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _currentProgress?.progress ?? 0,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_currentProgress?.progressPercentage.toStringAsFixed(1) ?? 0}%',
                  style: const TextStyle(fontSize: 12),
                ),
                Text(
                  '${_formatBytes(_currentProgress?.bytesReceived ?? 0)} / ${_formatBytes(_currentProgress?.totalBytes ?? 0)}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ],
        );

      case DownloadStatus.verifying:
        return const Column(
          children: [
            LinearProgressIndicator(),
            SizedBox(height: 8),
            Text('Verificando integridade do arquivo...'),
          ],
        );

      case DownloadStatus.completed:
        return Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade600),
            const SizedBox(width: 8),
            const Text('Download concluído!'),
          ],
        );

      case DownloadStatus.installing:
        return const Column(
          children: [
            LinearProgressIndicator(),
            SizedBox(height: 8),
            Text('Iniciando instalação...'),
          ],
        );

      case DownloadStatus.paused:
        return Row(
          children: [
            Icon(Icons.pause_circle, color: Colors.orange.shade600),
            const SizedBox(width: 8),
            const Text('Download pausado'),
          ],
        );

      case DownloadStatus.failed:
        return const SizedBox.shrink();

      default:
        return const SizedBox.shrink();
    }
  }

  List<Widget> _buildActions() {
    if (_downloadStatus == DownloadStatus.downloading) {
      return [
        TextButton(
          onPressed: () {
            widget.updateService.pauseDownload();
          },
          child: const Text('Pausar'),
        ),
      ];
    }

    if (_downloadStatus == DownloadStatus.completed) {
      return [
        if (!widget.mandatory)
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Depois'),
          ),
        FilledButton(
          onPressed: _installUpdate,
          child: const Text('Instalar'),
        ),
      ];
    }

    if (_downloadStatus == DownloadStatus.failed) {
      return [
        if (!widget.mandatory)
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
        FilledButton(
          onPressed: _startDownload,
          child: const Text('Tentar Novamente'),
        ),
      ];
    }

    // Estado inicial
    return [
      if (!widget.mandatory)
        TextButton(
          onPressed: _skipUpdate,
          child: const Text('Depois'),
        ),
      FilledButton(
        onPressed: _startDownload,
        child: const Text('Atualizar Agora'),
      ),
    ];
  }
}
