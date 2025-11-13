import 'package:flutter/material.dart';
import '../models/update_info.dart';
import '../services/app_update_service.dart';
import '../widgets/update_dialog.dart';

/// Tela de verificação e gerenciamento de atualizações
class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
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

  void _showUpToDateMessage() async {
    // DEBUG: Mostrar informações detalhadas
    final packageInfo = await _updateService.getCurrentVersion();

    UpdateInfo? updateInfo;

    updateInfo = await _updateService.checkForUpdates();

    final errorMessage = _updateService.lastError ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('🔍 DEBUG - Informações Detalhadas'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('📱 VERSÃO INSTALADA:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('  Nome: ${packageInfo['versionName']}'),
              Text('  Code: ${packageInfo['versionCode']}'),
              SizedBox(height: 16),
              Text('🌐 TENTANDO BUSCAR:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('  https://raw.githubusercontent.com/brunaoperes/nero/main/updates/latest.json', style: TextStyle(fontSize: 10)),
              SizedBox(height: 16),
              Text('🌐 VERSÃO NO SERVIDOR:', style: TextStyle(fontWeight: FontWeight.bold)),
              if (updateInfo != null) ...[
                Text('  ✅ SUCESSO!', style: TextStyle(color: Colors.green)),
                Text('  Nome: ${updateInfo.versionName}'),
                Text('  Code: ${updateInfo.versionCode}'),
                Text('  URL: ${updateInfo.apkUrl}', style: TextStyle(fontSize: 10)),
              ] else ...[
                Text('  ❌ Não conseguiu buscar do servidor!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                if (errorMessage.isNotEmpty) ...[
                  SizedBox(height: 8),
                  Text('ERRO DETALHADO:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                  Text('  $errorMessage', style: TextStyle(fontSize: 11, color: Colors.red)),
                ],
              ],
              SizedBox(height: 16),
              Text('🔢 COMPARAÇÃO:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('  ${packageInfo['versionCode']} < ${updateInfo?.versionCode ?? '?'}'),
              Text('  Resultado: ${updateInfo != null && (packageInfo['versionCode'] as int) < updateInfo.versionCode ? '✅ Há atualização' : '❌ Não há atualização'}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
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
                    'Este app verifica automaticamente por atualizações a cada 24 horas. '
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
