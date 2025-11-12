import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/sync_service.dart';

/// Widget indicador de status de sincronização
///
/// Mostra:
/// - Badge "Offline" quando sem conexão
/// - Ícone de sincronização quando sincronizando
/// - Última sincronização
/// - Operações pendentes
class SyncStatusIndicator extends ConsumerWidget {
  final bool showDetails;

  const SyncStatusIndicator({
    super.key,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final connectionAsync = ref.watch(connectionStatusProvider);
    final syncAsync = ref.watch(syncStateProvider);

    return connectionAsync.when(
      data: (isOnline) {
        if (!isOnline) {
          return _buildOfflineBadge(context);
        }

        return syncAsync.when(
          data: (syncState) => _buildSyncStatus(context, ref, syncState),
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildOfflineBadge(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.warning.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.warning.withOpacity(0.5),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.cloud_off,
            size: 16,
            color: AppColors.warning,
          ),
          const SizedBox(width: 6),
          Text(
            'Offline',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSyncStatus(BuildContext context, WidgetRef ref, SyncState syncState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (syncState.isSyncing) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Sincronizando...',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
            ),
          ],
        ),
      );
    }

    if (syncState.hasPendingOperations && showDetails) {
      return GestureDetector(
        onTap: () => _showSyncDetails(context, ref, syncState),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.info.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.info.withOpacity(0.5),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.cloud_upload,
                size: 16,
                color: AppColors.info,
              ),
              const SizedBox(width: 6),
              Text(
                '${syncState.pendingOperations} pendentes',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (syncState.lastSyncTime != null && showDetails) {
      final timeAgo = _getTimeAgo(syncState.lastSyncTime!);
      return GestureDetector(
        onTap: () => _showSyncDetails(context, ref, syncState),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.check_circle,
              size: 16,
              color: AppColors.success.withOpacity(0.7),
            ),
            const SizedBox(width: 6),
            Text(
              'Sincronizado $timeAgo',
              style: TextStyle(
                fontSize: 11,
                color: (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                    .withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'agora';
    } else if (difference.inMinutes < 60) {
      return 'há ${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return 'há ${difference.inHours}h';
    } else {
      return 'há ${difference.inDays}d';
    }
  }

  void _showSyncDetails(BuildContext context, WidgetRef ref, SyncState syncState) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm', 'pt_BR');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Título
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.sync, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Text(
                      'Status de Sincronização',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkText : AppColors.lightText,
                      ),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Detalhes
              if (syncState.lastSyncTime != null)
                ListTile(
                  leading: const Icon(Icons.access_time, color: AppColors.success),
                  title: const Text('Última Sincronização'),
                  subtitle: Text(dateFormat.format(syncState.lastSyncTime!)),
                ),

              if (syncState.hasPendingOperations)
                ListTile(
                  leading: const Icon(Icons.cloud_upload, color: AppColors.warning),
                  title: const Text('Operações Pendentes'),
                  subtitle: Text('${syncState.pendingOperations} operações aguardando sincronização'),
                ),

              if (syncState.message != null)
                ListTile(
                  leading: Icon(
                    syncState.hasError ? Icons.error : Icons.info,
                    color: syncState.hasError ? AppColors.error : AppColors.info,
                  ),
                  title: const Text('Status'),
                  subtitle: Text(syncState.message!),
                ),

              // Botão de sincronizar
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: syncState.isSyncing
                        ? null
                        : () {
                            final service = ref.read(syncServiceProvider);
                            service.sync();
                            Navigator.pop(context);
                          },
                    icon: Icon(syncState.isSyncing ? Icons.hourglass_empty : Icons.sync),
                    label: Text(syncState.isSyncing ? 'Sincronizando...' : 'Sincronizar Agora'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
