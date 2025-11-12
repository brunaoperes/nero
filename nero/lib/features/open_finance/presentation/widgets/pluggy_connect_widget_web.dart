import 'package:flutter/material.dart';
import 'dart:html' as html;
import 'dart:ui' as ui;
import '../../../../core/services/open_finance_service.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/utils/app_logger.dart';

/// Widget para conectar banco usando Pluggy Connect (versão Web)
class PluggyConnectWidgetWeb extends StatefulWidget {
  final Function(String itemId) onSuccess;
  final Function(String error) onError;

  const PluggyConnectWidgetWeb({
    super.key,
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<PluggyConnectWidgetWeb> createState() => _PluggyConnectWidgetWebState();
}

class _PluggyConnectWidgetWebState extends State<PluggyConnectWidgetWeb> {
  final OpenFinanceService _openFinanceService = OpenFinanceService();
  bool _isLoading = true;
  String? _errorMessage;
  String? _connectToken;
  String? _viewId;
  static int _nextViewId = 0;

  @override
  void initState() {
    super.initState();
    // Generate unique view ID to allow multiple instances
    _viewId = 'pluggy-connect-iframe-${_nextViewId++}';
    _initializePluggyConnect();
  }

  Future<void> _initializePluggyConnect() async {
    try {
      AppLogger.info('Iniciando Pluggy Connect (Web)');

      // Get connect token from backend
      final token = await _openFinanceService.getConnectToken();

      AppLogger.info('Token recebido', data: {
        'tokenPreview': token.substring(0, 20),
        'tokenLength': token.length,
      });

      setState(() {
        _connectToken = token;
      });

      final url = _buildPluggyConnectUrl(token);
      AppLogger.debug('URL Pluggy Connect', data: {'url': url});

      // Register the view factory for the iframe
      // ignore: undefined_prefixed_name
      ui.platformViewRegistry.registerViewFactory(
        _viewId!,
        (int viewId) {
          AppLogger.debug('Criando IFrame Pluggy', data: {'viewId': viewId});

          final iframe = html.IFrameElement()
            ..src = url
            ..style.border = 'none'
            ..style.width = '100%'
            ..style.height = '100%'
            ..setAttribute('allow', 'clipboard-write')
            ..setAttribute('sandbox', 'allow-same-origin allow-scripts allow-popups allow-forms allow-modals');

          AppLogger.debug('IFrame criado', data: {'src': iframe.src});

          // Listen for messages from Pluggy Connect
          html.window.addEventListener('message', _handleMessage);

          return iframe;
        },
      );

      setState(() {
        _isLoading = false;
      });

      AppLogger.info('Pluggy Connect inicializado com sucesso (Web)');
    } catch (e) {
      AppLogger.error('Erro ao inicializar Pluggy Connect (Web)', error: e);
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      widget.onError(e.toString());
    }
  }

  String _buildPluggyConnectUrl(String token) {
    // Pluggy Connect Widget URL
    return 'https://connect.pluggy.ai/?connectToken=$token';
  }

  void _handleMessage(html.Event event) {
    if (event is html.MessageEvent) {
      try {
        final data = event.data;
        final origin = event.origin;

        AppLogger.debug('Mensagem recebida do Pluggy', data: {
          'origin': origin,
          'dataType': data.runtimeType.toString(),
          'data': data.toString(),
        });

        // Ignore messages from post-robot (Pluggy's internal communication)
        if (data is String && data.contains('__post_robot_')) {
          AppLogger.debug('Ignorando mensagem post-robot (String)');
          return;
        }

        if (data is Map && data.containsKey('__post_robot_')) {
          AppLogger.debug('Ignorando mensagem post-robot (Map)');
          return;
        }

        // Parse the message from Pluggy Connect
        if (data is Map) {
          final eventType = data['event'];
          AppLogger.debug('Evento Pluggy recebido', data: {'eventType': eventType});

          if (eventType == 'success') {
            final itemId = data['itemId'];
            AppLogger.info('Conexão bancária bem-sucedida', data: {'itemId': itemId});
            if (itemId != null) {
              widget.onSuccess(itemId.toString());
            }
          } else if (eventType == 'error') {
            final error = data['message'] ?? 'Unknown error';
            AppLogger.error('Erro na conexão bancária', error: error);
            widget.onError(error.toString());
          } else if (eventType == 'close') {
            AppLogger.info('Modal Pluggy fechado pelo usuário');
            // User closed the widget
            Navigator.of(context).pop();
          }
        }
      } catch (e, stack) {
        AppLogger.error('Erro ao processar mensagem do Pluggy', error: e, stackTrace: stack);
      }
    }
  }

  @override
  void dispose() {
    html.window.removeEventListener('message', _handleMessage);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'Conectar Banco',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Loading indicator
          if (_isLoading)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Carregando Pluggy Connect...'),
                  ],
                ),
              ),
            ),

          // Error message
          if (_errorMessage != null && !_isLoading)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Erro ao carregar',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                            _errorMessage = null;
                          });
                          _initializePluggyConnect();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // IFrame (Web)
          if (_connectToken != null && _errorMessage == null && !_isLoading && _viewId != null)
            Expanded(
              child: HtmlElementView(
                viewType: _viewId!,
              ),
            ),
        ],
      ),
    );
  }
}
