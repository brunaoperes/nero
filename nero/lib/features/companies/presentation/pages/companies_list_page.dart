import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/company_model.dart';
import '../providers/company_providers.dart';
import '../widgets/company_card.dart';
import 'company_form_page.dart';
import 'company_dashboard_page.dart';

class CompaniesListPage extends ConsumerWidget {
  const CompaniesListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companiesAsync = ref.watch(companiesListProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text('Minhas Empresas'),
      ),
      body: companiesAsync.when(
        data: (companies) {
          if (companies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business_outlined,
                    size: 64,
                    color: AppColors.textSecondary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '🏢 Você ainda não tem empresas.\\nCrie sua primeira empresa!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref.read(companiesListProvider.notifier).loadCompanies();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: companies.length,
              itemBuilder: (context, index) {
                final company = companies[index];
                return CompanyCard(
                  company: company,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => CompanyDashboardPage(company: company),
                      ),
                    );
                  },
                  onEdit: () => _editCompany(context, ref, company),
                  onDelete: () => _deleteCompany(context, ref, company),
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar empresas',
                style: TextStyle(
                  color: AppColors.textSecondary.withOpacity(0.7),
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () =>
                    ref.read(companiesListProvider.notifier).loadCompanies(),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'companies_list_page_fab',
        onPressed: () => _createCompany(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nova Empresa',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );
  }

  Future<void> _createCompany(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CompanyFormPage(),
      ),
    );

    if (result == true) {
      ref.read(companiesListProvider.notifier).loadCompanies();
    }
  }

  Future<void> _editCompany(
      BuildContext context, WidgetRef ref, CompanyModel company) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CompanyFormPage(company: company),
      ),
    );

    if (result == true) {
      ref.read(companiesListProvider.notifier).loadCompanies();
    }
  }

  Future<void> _deleteCompany(
      BuildContext context, WidgetRef ref, CompanyModel company) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Deletar Empresa',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Tem certeza que deseja deletar "${company.name}"?\\n\\nIsso deletará também todas as tarefas, reuniões e checklists associados.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success =
          await ref.read(companiesListProvider.notifier).deleteCompany(company.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Empresa deletada!' : 'Erro ao deletar empresa'),
            backgroundColor: success ? const Color(0xFF009E0F) : Colors.red,
          ),
        );
      }
    }
  }
}
