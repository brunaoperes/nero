import 'package:flutter/material.dart';
import '../../../../core/utils/app_logger.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/services/open_finance_service.dart';
import '../../../../core/config/app_colors.dart';

// Importação condicional para evitar erros de compilação
import 'pluggy_connect_widget_web_stub.dart'
    if (dart.library.html) 'pluggy_connect_widget_web.dart';

/// Widget para conectar banco usando Pluggy Connect (multiplataforma)
class PluggyConnectWidget extends StatelessWidget {
  final Function(String itemId) onSuccess;
  final Function(String error) onError;

  const PluggyConnectWidget({
    super.key,
    required this.onSuccess,
    required this.onError,
  });

  @override
  Widget build(BuildContext context) {
    // Se estiver na web, usar versão web
    if (kIsWeb) {
      return PluggyConnectWidgetWeb(
        onSuccess: onSuccess,
        onError: onError,
      );
    }

    // Se estiver no mobile, usar versão mobile
    return _PluggyConnectWidgetMobile(
      onSuccess: onSuccess,
      onError: onError,
    );
  }
}

/// Widget para conectar banco usando Pluggy Connect (versão Mobile)
class _PluggyConnectWidgetMobile extends StatefulWidget {
  final Function(String itemId) onSuccess;
  final Function(String error) onError;

  const _PluggyConnectWidgetMobile({
    required this.onSuccess,
    required this.onError,
  });

  @override
  State<_PluggyConnectWidgetMobile> createState() => _PluggyConnectWidgetMobileState();
}

class _PluggyConnectWidgetMobileState extends State<_PluggyConnectWidgetMobile> {
  final OpenFinanceService _openFinanceService = OpenFinanceService();
  WebViewController? _webViewController;
  bool _isLoading = true;
  String? _errorMessage;
  String? _connectToken;

  @override
  void initState() {
    super.initState();
    _initializePluggyConnect();
  }

  Future<void> _initializePluggyConnect() async {
    try {
      // Get connect token from backend
      final token = await _openFinanceService.getConnectToken();

      setState(() {
        _connectToken = token;
      });

      // Initialize WebView with Pluggy Connect URL
      _webViewController = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.white)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              AppLogger.debug('Página iniciou carregamento', data: {'url': url});
            },
            onPageFinished: (String url) {
              AppLogger.debug('Página finalizou carregamento', data: {'url': url});
              setState(() {
                _isLoading = false;
              });
            },
            onWebResourceError: (WebResourceError error) {
              AppLogger.warning('Erro no recurso web', data: {'error': error.description});
              setState(() {
                _errorMessage = error.description;
                _isLoading = false;
              });
            },
            onNavigationRequest: (NavigationRequest request) {
              // Handle navigation
              AppLogger.debug('Requisição de navegação', data: {'url': request.url});

              // Check for success callback
              if (request.url.contains('onSuccess')) {
                _handleSuccess(request.url);
                return NavigationDecision.prevent;
              }

              // Check for error callback
              if (request.url.contains('onError')) {
                _handleError(request.url);
                return NavigationDecision.prevent;
              }

              return NavigationDecision.navigate;
            },
          ),
        )
        ..addJavaScriptChannel(
          'PluggyConnect',
          onMessageReceived: (JavaScriptMessage message) {
            AppLogger.debug('Mensagem do JS', data: {'message': message.message});
            _handleJavaScriptMessage(message.message);
          },
        )
        ..loadRequest(
          Uri.parse(_buildPluggyConnectUrl(token)),
        );
    } catch (e) {
      AppLogger.error('Erro ao inicializar Pluggy Connect', error: e);
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      widget.onError(e.toString());
    }
  }

  String _buildPluggyConnectUrl(String token) {
    // Pluggy Connect Widget URL
    // https://connect.pluggy.ai/?connectToken=YOUR_TOKEN
    return 'https://connect.pluggy.ai/?connectToken=$token';
  }

  void _handleJavaScriptMessage(String message) {
    try {
      // Parse the message (usually JSON)
      // Expected format: {"event": "success", "itemId": "xxx"}
      // or {"event": "error", "message": "xxx"}

      if (message.contains('success')) {
        final itemId = _extractItemId(message);
        if (itemId != null) {
          widget.onSuccess(itemId);
        }
      } else if (message.contains('error')) {
        final errorMsg = _extractError(message);
        widget.onError(errorMsg ?? 'Unknown error');
      }
    } catch (e) {
      AppLogger.error('Erro ao processar mensagem JS', error: e);
    }
  }

  void _handleSuccess(String url) {
    final itemId = Uri.parse(url).queryParameters['itemId'];
    if (itemId != null) {
      widget.onSuccess(itemId);
    }
  }

  void _handleError(String url) {
    final error = Uri.parse(url).queryParameters['error'];
    widget.onError(error ?? 'Unknown error');
  }

  String? _extractItemId(String message) {
    // Simple extraction - you may need to parse JSON properly
    final match = RegExp(r'"itemId"\s*:\s*"([^"]+)"').firstMatch(message);
    return match?.group(1);
  }

  String? _extractError(String message) {
    final match = RegExp(r'"message"\s*:\s*"([^"]+)"').firstMatch(message);
    return match?.group(1);
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

          // WebView
          if (_webViewController != null && _errorMessage == null)
            Expanded(
              child: WebViewWidget(controller: _webViewController!),
            ),
        ],
      ),
    );
  }
}
