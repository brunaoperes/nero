// lib/features/company/presentation/pages/company_detail_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../domain/entities/company_entity.dart';
import '../providers/company_providers.dart';
import 'clients_page.dart';
import 'company_form_page.dart';
import 'contracts_page.dart';
import 'projects_page.dart';

class CompanyDetailPage extends ConsumerWidget {
  final CompanyEntity company;

  const CompanyDetailPage({super.key, required this.company});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(companySummaryProvider(company.id));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        title: Text(
          company.name,
          style: AppTextStyles.headingH2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CompanyFormPage(company: company),
                ),
              );
              if (result == true) {
                ref.invalidate(companySummaryProvider);
              }
            },
          ),
        ],
      ),
      body: summaryAsync.when(
        data: (summary) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Company Info Card
              _buildInfoCard(company),
              const SizedBox(height: 16),

              // Statistics Grid
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Clientes',
                      '${summary['totalClients']}',
                      'ativos',
                      Icons.people,
                      AppColors.primary,
                      () => _navigateToClients(context, company.id),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Contratos',
                      '${summary['activeContracts']}',
                      'ativos',
                      Icons.description,
                      AppColors.success,
                      () => _navigateToContracts(context, company.id),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      'Projetos',
                      '${summary['activeProjects']}',
                      'em andamento',
                      Icons.work,
                      AppColors.warning,
                      () => _navigateToProjects(context, company.id),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStatCard(
                      'Receita',
                      _formatCurrency(summary['totalContractValue'] ?? 0),
                      'total',
                      Icons.attach_money,
                      AppColors.info,
                      null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Financial Summary
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.success,
                      AppColors.success.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Resumo Financeiro',
                          style: AppTextStyles.headingH3.copyWith(
                            color: Colors.white,
                          ),
                        ),
                        const Icon(Icons.trending_up, color: Colors.white),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildFinanceRow(
                      'Total em Contratos',
                      _formatCurrency(summary['totalContractValue'] ?? 0),
                    ),
                    const SizedBox(height: 8),
                    _buildFinanceRow(
                      'Valores Pagos',
                      _formatCurrency(summary['totalPaidAmount'] ?? 0),
                    ),
                    const SizedBox(height: 8),
                    _buildFinanceRow(
                      'Pendente',
                      _formatCurrency(summary['pendingAmount'] ?? 0),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions
              Text(
                'Ações Rápidas',
                style: AppTextStyles.headingH3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildActionButton(
                'Gerenciar Clientes',
                Icons.people,
                AppColors.primary,
                () => _navigateToClients(context, company.id),
              ),
              _buildActionButton(
                'Ver Contratos',
                Icons.description,
                AppColors.success,
                () => _navigateToContracts(context, company.id),
              ),
              _buildActionButton(
                'Acompanhar Projetos',
                Icons.work,
                AppColors.warning,
                () => _navigateToProjects(context, company.id),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar dados',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.error),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(CompanyEntity company) {
    Color statusColor;
    switch (company.status) {
      case CompanyStatus.active:
        statusColor = AppColors.success;
        break;
      case CompanyStatus.inactive:
        statusColor = AppColors.error;
        break;
      case CompanyStatus.pending:
        statusColor = AppColors.warning;
        break;
      case CompanyStatus.archived:
        statusColor = AppColors.textSecondary;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(Icons.business, color: AppColors.primary, size: 32),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.name,
                      style: AppTextStyles.headingH2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      company.type.displayName,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  company.status.displayName,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (company.description != null) ...[
            const SizedBox(height: 16),
            Text(
              company.description!,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: [
              if (company.email != null)
                _buildInfoChip(Icons.email, company.email!),
              if (company.phone != null)
                _buildInfoChip(Icons.phone, company.phone!),
              if (company.website != null)
                _buildInfoChip(Icons.language, company.website!),
              _buildInfoChip(
                Icons.calendar_today,
                'Fundada em ${DateFormat('dd/MM/yyyy').format(company.foundedDate)}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback? onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.headingH2.copyWith(color: color),
            ),
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyLarge.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(
          label,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        tileColor: AppColors.lightBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: AppColors.border),
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }

  void _navigateToClients(BuildContext context, String companyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ClientsPage(companyId: companyId),
      ),
    );
  }

  void _navigateToContracts(BuildContext context, String companyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ContractsPage(companyId: companyId),
      ),
    );
  }

  void _navigateToProjects(BuildContext context, String companyId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectsPage(companyId: companyId),
      ),
    );
  }
}
