import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/bank_connection_model.dart';
import '../../../../core/config/app_colors.dart';

/// Card de conexão bancária
class BankConnectionCard extends StatelessWidget {
  final BankConnectionModel connection;
  final VoidCallback onSync;
  final VoidCallback onDelete;

  const BankConnectionCard({
    super.key,
    required this.connection,
    required this.onSync,
    required this.onDelete,
  });

  Color _getStatusColor() {
    switch (connection.status) {
      case 'UPDATED':
        return Colors.green;
      case 'UPDATING':
        return Colors.orange;
      case 'LOGIN_ERROR':
        return Colors.red;
      case 'OUTDATED':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText() {
    switch (connection.status) {
      case 'UPDATED':
        return 'Atualizado';
      case 'UPDATING':
        return 'Atualizando...';
      case 'LOGIN_ERROR':
        return 'Erro de Login';
      case 'OUTDATED':
        return 'Desatualizado';
      default:
        return connection.status;
    }
  }

  IconData _getStatusIcon() {
    switch (connection.status) {
      case 'UPDATED':
        return Icons.check_circle;
      case 'UPDATING':
        return Icons.sync;
      case 'LOGIN_ERROR':
        return Icons.error;
      case 'OUTDATED':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // TODO: Navigate to connection details
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com logo e nome do banco
              Row(
                children: [
                  // Logo do banco
                  if (connection.connectorImageUrl != null)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: NetworkImage(connection.connectorImageUrl!),
                          fit: BoxFit.contain,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance,
                        color: AppColors.primary,
                      ),
                    ),
                  const SizedBox(width: 12),

                  // Nome e status
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          connection.connectorName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              _getStatusIcon(),
                              size: 14,
                              color: _getStatusColor(),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _getStatusText(),
                              style: TextStyle(
                                fontSize: 12,
                                color: _getStatusColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Menu de ações
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert),
                    onSelected: (value) {
                      switch (value) {
                        case 'sync':
                          onSync();
                          break;
                        case 'delete':
                          onDelete();
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'sync',
                        child: Row(
                          children: [
                            Icon(Icons.sync, size: 20),
                            SizedBox(width: 12),
                            Text('Sincronizar'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 12),
                            Text('Remover', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Informações adicionais
              if (connection.lastSyncAt != null) ...[
                const SizedBox(height: 12),
                const Divider(),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 14,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Última sincronização: ${_formatDate(connection.lastSyncAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],

              // Mensagem de erro
              if (connection.errorMessage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 16,
                        color: Colors.red[700],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          connection.errorMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Agora';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}min atrás';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h atrás';
    } else if (diff.inDays == 1) {
      return 'Ontem';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} dias atrás';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }
}
