import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/bank_connection_model.dart';
import '../../../../core/services/open_finance_service.dart';
import '../widgets/bank_connection_card.dart';
import '../widgets/pluggy_connect_widget.dart';

/// Página de conexões bancárias (Open Finance)
class BankConnectionsPage extends ConsumerStatefulWidget {
  const BankConnectionsPage({super.key});

  @override
  ConsumerState<BankConnectionsPage> createState() => _BankConnectionsPageState();
}

class _BankConnectionsPageState extends ConsumerState<BankConnectionsPage> {
  final OpenFinanceService _openFinanceService = OpenFinanceService();
  bool _isLoading = true;
  List<BankConnectionModel> _connections = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  Future<void> _loadConnections() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final connections = await _openFinanceService.getConnections();
      setState(() {
        _connections = connections;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _syncConnection(String connectionId) async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sincronizando...')),
      );

      await _openFinanceService.syncConnection(connectionId);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sincronização concluída!'),
          backgroundColor: Colors.green,
        ),
      );

      _loadConnections();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao sincronizar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteConnection(String connectionId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover conexão'),
        content: const Text('Tem certeza que deseja remover esta conexão bancária?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remover'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await _openFinanceService.deleteConnection(connectionId);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Conexão removida'),
            backgroundColor: Colors.green,
          ),
        );
        _loadConnections();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showConnectWidget() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => PluggyConnectWidget(
        onSuccess: (itemId) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Banco conectado com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
          _loadConnections();
        },
        onError: (error) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao conectar: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Conexões Bancárias'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Erro ao carregar conexões',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _loadConnections,
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : _connections.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.account_balance_outlined,
                            size: 100,
                            color: Colors.grey[300],
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Nenhum banco conectado',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              'Conecte suas contas bancárias para importar transações automaticamente',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton.icon(
                            onPressed: _showConnectWidget,
                            icon: const Icon(Icons.add),
                            label: const Text('Conectar Banco'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadConnections,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _connections.length,
                        itemBuilder: (context, index) {
                          final connection = _connections[index];
                          return BankConnectionCard(
                            connection: connection,
                            onSync: () => _syncConnection(connection.id),
                            onDelete: () => _deleteConnection(connection.id),
                          );
                        },
                      ),
                    ),
      floatingActionButton: _connections.isNotEmpty
          ? FloatingActionButton.extended(
              heroTag: 'bank_connections_page_fab',
              onPressed: _showConnectWidget,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar Banco'),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            )
          : null,
    );
  }
}
