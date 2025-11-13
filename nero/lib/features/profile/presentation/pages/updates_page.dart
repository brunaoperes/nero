import 'package:flutter/material.dart';
import '../../../../shared/models/update_info.dart';
import '../../../../core/services/app_update_service.dart';
import '../../../../shared/widgets/update_dialog.dart';

/// Tela de verificação e gerenciamento de atualizações
class UpdatesPage extends StatefulWidget {
  const UpdatesPage({super.key});

  @override
  State<UpdatesPage> createState() => _UpdatesPageState();
}

class _UpdatesPageState extends State<UpdatesPage> {
  final AppUpdateService _updateService = AppUpdateService();
  bool _isChecking = false;
  UpdateInfo? _availableUpdate;
  Map<String, dynamic>? _currentVersion;
  String? _errorMessage;
  bool _isFromPlayStore = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentVersion();
    _checkInstallSource();
  }

  @override
  void dispose() {
    _updateService.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentVersion() async {
    final version = await _updateService.getCurrentVersion();
    if (mounted) {
      setState(() {
        _currentVersion = version;
      });
    }
  }

  Future<void> _checkInstallSource() async {
    final isPlayStore = await _updateService.isInstalledFromPlayStore();
    if (mounted) {
      setState(() {
        _isFromPlayStore = isPlayStore;
      });
    }
  }

  Future<void> _checkForUpdates() async {
    if (_isFromPlayStore) {
      _showPlayStoreMessage();
      return;
    }

    setState(() {
      _isChecking = true;
      _errorMessage = null;
      _availableUpdate = null;
    });

    try {
      final update = await _updateService.getAvailableUpdate();

      if (mounted) {
        setState(() {
          _availableUpdate = update;
          _isChecking = false;
        });

        if (update != null) {
          _showUpdateDialog(update);
        } else {
          _showUpToDateMessage();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isChecking = false;
          _errorMessage = 'Erro ao verificar atualizações: $e';
        });
      }
    }
  }

  void _showUpdateDialog(UpdateInfo updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: !updateInfo.mandatory,
      builder: (context) => UpdateDialog(
        updateInfo: updateInfo,
        updateService: _updateService,
        mandatory: updateInfo.mandatory,
      ),
    );
  }

  void _showUpToDateMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Você já está na versão mais recente!'),
          ],
        ),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showPlayStoreMessage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Atualização via Play Store'),
        content: const Text(
          'Este app foi instalado via Play Store. '
          'Para atualizar, acesse a Play Store e procure por atualizações disponíveis.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendi'),
          ),
        ],
      ),
    );
  }

  Future<void> _cleanupFiles() async {
    try {
      await _updateService.cleanupUpdateFiles();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Arquivos temporários removidos'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao limpar arquivos: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atualizações'),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Card com informações da versão atual
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Versão Atual',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_currentVersion != null) ...[
                    _buildInfoRow(
                      'Versão',
                      _currentVersion!['versionName'] ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'Código',
                      _currentVersion!['versionCode']?.toString() ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'App',
                      _currentVersion!['appName'] ?? 'N/A',
                    ),
                    _buildInfoRow(
                      'Pacote',
                      _currentVersion!['packageName'] ?? 'N/A',
                    ),
                    if (_isFromPlayStore)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 16,
                              color: Colors.green.shade700,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Instalado via Play Store',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ] else
                    const Center(child: CircularProgressIndicator()),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Botão de verificar atualizações
          FilledButton.icon(
            onPressed: _isChecking ? null : _checkForUpdates,
            icon: _isChecking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.system_update),
            label: Text(
              _isChecking ? 'Verificando...' : 'Verificar Atualizações',
            ),
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

          const SizedBox(height: 8),

          // Botão de limpar arquivos temporários
          OutlinedButton.icon(
            onPressed: _cleanupFiles,
            icon: const Icon(Icons.delete_outline),
            label: const Text('Limpar Arquivos Temporários'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),

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

          const SizedBox(height: 24),

          // Informações adicionais
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.help_outline,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Sobre Atualizações',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'O app verifica automaticamente por atualizações a cada 24 horas. '
                    'Você também pode verificar manualmente usando o botão acima.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Atualizações obrigatórias devem ser instaladas para continuar '
                    'usando o app.',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
