// lib/features/company/presentation/pages/clients_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../domain/entities/client_entity.dart';
import '../providers/company_providers.dart';
import '../widgets/client_card.dart';
import 'client_form_page.dart';

class ClientsPage extends ConsumerStatefulWidget {
  final String companyId;

  const ClientsPage({super.key, required this.companyId});

  @override
  ConsumerState<ClientsPage> createState() => _ClientsPageState();
}

class _ClientsPageState extends ConsumerState<ClientsPage> {
  ClientStatus? _filterStatus;

  @override
  Widget build(BuildContext context) {
    final clientsAsync = _filterStatus == null
        ? ref.watch(clientsProvider(widget.companyId))
        : ref.watch(clientsByStatusProvider((
            companyId: widget.companyId,
            status: _filterStatus!,
          )));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        title: Text(
          'Clientes',
          style: AppTextStyles.headingH2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          PopupMenuButton<ClientStatus?>(
            icon: const Icon(Icons.filter_list, color: AppColors.primary),
            onSelected: (status) {
              setState(() => _filterStatus = status);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Todos'),
              ),
              ...ClientStatus.values.map((status) {
                return PopupMenuItem(
                  value: status,
                  child: Text(status.displayName),
                );
              }),
            ],
          ),
        ],
      ),
      body: clientsAsync.when(
        data: (clients) {
          if (clients.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.people_outline,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _filterStatus == null
                        ? 'Nenhum cliente cadastrado'
                        : 'Nenhum cliente ${_filterStatus!.displayName.toLowerCase()}',
                    style: AppTextStyles.headingH3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Adicione seus primeiros clientes',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToForm(context, null),
                    icon: const Icon(Icons.add),
                    label: const Text('Adicionar Cliente'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Group clients by status
          final activeClients = clients.where((c) => c.status == ClientStatus.active).toList();
          final prospectClients = clients.where((c) => c.status == ClientStatus.prospect).toList();
          final otherClients = clients.where((c) => 
            c.status != ClientStatus.active && c.status != ClientStatus.prospect
          ).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (activeClients.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Clientes Ativos',
                      style: AppTextStyles.headingH3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${activeClients.length}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...activeClients.map((client) {
                  return ClientCard(
                    client: client,
                    onTap: () => _navigateToForm(context, client),
                  );
                }),
                const SizedBox(height: 24),
              ],

              if (prospectClients.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Prospectos',
                      style: AppTextStyles.headingH3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${prospectClients.length}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...prospectClients.map((client) {
                  return ClientCard(
                    client: client,
                    onTap: () => _navigateToForm(context, client),
                  );
                }),
                const SizedBox(height: 24),
              ],

              if (otherClients.isNotEmpty) ...[
                Text(
                  'Outros',
                  style: AppTextStyles.headingH3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                ...otherClients.map((client) {
                  return ClientCard(
                    client: client,
                    onTap: () => _navigateToForm(context, client),
                  );
                }),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar clientes',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'clients_page_fab',
        onPressed: () => _navigateToForm(context, null),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Novo Cliente',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, ClientEntity? client) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientFormPage(
          companyId: widget.companyId,
          client: client,
        ),
      ),
    );

    if (result == true) {
      ref.invalidate(clientsProvider);
      ref.invalidate(clientsByStatusProvider);
    }
  }
}
