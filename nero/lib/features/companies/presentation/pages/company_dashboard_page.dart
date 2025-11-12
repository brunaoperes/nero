import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/company_model.dart';
import '../../../tasks/presentation/pages/tasks_list_page.dart';
import '../providers/company_providers.dart';
import '../widgets/company_stats_card.dart';
import '../widgets/company_quick_actions.dart';
import '../widgets/company_timeline_widget.dart';
import '../widgets/company_checklist_widget.dart';
import '../widgets/upcoming_meetings_widget.dart';
import 'company_form_page.dart';

class CompanyDashboardPage extends ConsumerWidget {
  final CompanyModel company;

  const CompanyDashboardPage({
    super.key,
    required this.company,
  });

  void _showOptionsMenu(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightCard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary).withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.primary),
              title: Text(
                'Editar Empresa',
                style: TextStyle(
                  color: isDark ? AppColors.textPrimary : AppColors.lightText,
                  fontFamily: 'Inter',
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CompanyFormPage(company: company),
                  ),
                );
                if (result == true) {
                  ref.invalidate(companyStatsProvider(company.id));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Deletar Empresa',
                style: TextStyle(
                  color: Colors.red,
                  fontFamily: 'Inter',
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightCard,
        title: Text(
          'Deletar Empresa',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColors.lightText,
          ),
        ),
        content: Text(
          'Tem certeza que deseja deletar "${company.name}"?\n\nEsta ação não pode ser desfeita.',
          style: TextStyle(
            color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Deletar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(companiesListProvider.notifier)
          .deleteCompany(company.id);

      if (context.mounted) {
        if (success) {
          Navigator.pop(context); // Volta para lista de empresas
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Empresa deletada com sucesso!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao deletar empresa'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(companyStatsProvider(company.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimary : AppColors.lightIcon,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              company.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimary : AppColors.lightText,
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              _getTypeLabel(company.type),
              style: TextStyle(
                fontSize: 12,
                color: (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary).withOpacity(0.7),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: isDark ? AppColors.textPrimary : AppColors.lightIcon,
            ),
            onPressed: () => _showOptionsMenu(context, ref),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(companyStatsProvider(company.id));
        },
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header com logo e info
              _buildHeader(context),
              const SizedBox(height: 20),

              // Estatísticas
              Text(
                'Estatísticas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: isDark ? AppColors.textPrimary : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 12),
              statsAsync.when(
                data: (stats) => CompanyStatsCard(stats: stats),
                loading: () => const Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                ),
                error: (_, __) => const SizedBox(),
              ),
              const SizedBox(height: 20),

              // Ações Rápidas
              Text(
                'Ações Rápidas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: isDark ? AppColors.textPrimary : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 12),
              CompanyQuickActions(company: company),
              const SizedBox(height: 20),

              // Seção de Tarefas
              _buildSection(
                context,
                title: 'Tarefas da Empresa',
                icon: Icons.task_alt,
                onSeeAll: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => TasksListPage(
                        companyId: company.id,
                        companyName: company.name,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Reuniões Próximas
              Text(
                'Reuniões Agendadas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: isDark ? AppColors.textPrimary : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder.withOpacity(0.1)
                        : AppColors.lightBorder,
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: UpcomingMeetingsWidget(companyId: company.id),
              ),
              const SizedBox(height: 16),

              // Checklists Pendentes
              Text(
                'Checklists Pendentes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: isDark ? AppColors.textPrimary : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder.withOpacity(0.1)
                        : AppColors.lightBorder,
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: CompanyChecklistWidget(companyId: company.id),
              ),
              const SizedBox(height: 16),

              // Timeline de Atividades
              Text(
                'Atividades Recentes',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: isDark ? AppColors.textPrimary : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark
                        ? AppColors.darkBorder.withOpacity(0.1)
                        : AppColors.lightBorder,
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                ),
                child: CompanyTimelineWidget(
                  companyId: company.id,
                  limit: 5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withOpacity(0.1)
              : AppColors.lightBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Row(
        children: [
          // Logo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: _getTypeColor(company.type).withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.business,
              color: _getTypeColor(company.type),
              size: 32,
            ),
          ),
          const SizedBox(width: 16),

          // Informações
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (company.cnpj != null && company.cnpj!.isNotEmpty) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: 14,
                        color: (isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary)
                            .withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'CNPJ: ${company.cnpj}',
                        style: TextStyle(
                          fontSize: 12,
                          color: (isDark
                                  ? AppColors.textSecondary
                                  : AppColors.lightTextSecondary)
                              .withOpacity(0.8),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                if (company.description != null && company.description!.isNotEmpty)
                  Text(
                    company.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: (isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary)
                          .withOpacity(0.9),
                      fontFamily: 'Inter',
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: company.isActive
                        ? const Color(0xFF009E0F).withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    company.isActive ? '✓ Ativa' : '✗ Inativa',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: company.isActive
                          ? const Color(0xFF009E0F)
                          : Colors.red,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onSeeAll,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? AppColors.darkBorder.withOpacity(0.1)
              : AppColors.lightBorder,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimary : AppColors.lightText,
                fontFamily: 'Inter',
              ),
            ),
          ),
          TextButton(
            onPressed: onSeeAll,
            child: const Text(
              'Ver todas',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'mei':
        return 'MEI';
      case 'small':
        return 'Pequena Empresa';
      case 'services':
        return 'Serviços';
      default:
        return type;
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'mei':
        return const Color(0xFFFFD700);
      case 'small':
        return AppColors.primary;
      case 'services':
        return const Color(0xFF9C27B0);
      default:
        return AppColors.textSecondary;
    }
  }
}
