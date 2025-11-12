import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../providers/finance_providers.dart';
import '../widgets/financial_summary_card.dart';
import 'budgets_page.dart';
import 'finance_charts_page.dart';
import 'goals_page.dart';
import 'transaction_form_page.dart';
import 'transactions_list_page.dart';

/// Página principal de finanças com abas
class FinanceHomePage extends ConsumerStatefulWidget {
  const FinanceHomePage({super.key});

  @override
  ConsumerState<FinanceHomePage> createState() => _FinanceHomePageState();
}

class _FinanceHomePageState extends ConsumerState<FinanceHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final period = DateRange.currentMonth();
    final summaryAsync = ref.watch(financialSummaryProvider(period));

    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Finanças',
              style: AppTextStyles.headingH2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Controle total do seu dinheiro',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          // Botão de exportar
          IconButton(
            icon: const Icon(Icons.download, color: AppColors.primary),
            onPressed: () {
              _showExportDialog(context);
            },
          ),
          // Botão de filtro de período
          IconButton(
            icon: const Icon(Icons.calendar_today, color: AppColors.textSecondary),
            onPressed: () {
              _showPeriodSelector(context);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          labelStyle: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'Resumo'),
            Tab(text: 'Transações'),
            Tab(text: 'Orçamentos'),
            Tab(text: 'Metas'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Card de resumo financeiro (sempre visível)
          summaryAsync.when(
            data: (summary) => FinancialSummaryCard(
              income: summary['income'] ?? 0,
              expense: summary['expense'] ?? 0,
              balance: summary['balance'] ?? 0,
              period: period,
            ),
            loading: () => const Padding(
              padding: const EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Erro ao carregar resumo: $error',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),

          // Conteúdo das abas
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                FinanceChartsPage(),
                TransactionsListPage(),
                BudgetsPage(),
                GoalsPage(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'finance_home_page_fab',
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const TransactionFormPage(),
            ),
          );

          if (result == true && mounted) {
            ref.invalidate(transactionsProvider);
            ref.invalidate(financialSummaryProvider);
          }
        },
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Nova Transação',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exportar Dados'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: AppColors.error),
              title: const Text('Exportar PDF'),
              subtitle: const Text('Relatório completo em PDF'),
              onTap: () {
                Navigator.pop(context);
                _exportToPDF();
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart, color: AppColors.success),
              title: const Text('Exportar Excel'),
              subtitle: const Text('Planilha com todas as transações'),
              onTap: () {
                Navigator.pop(context);
                _exportToExcel();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showPeriodSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Selecionar Período',
              style: AppTextStyles.headingH3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Mês Atual'),
              onTap: () {
                // TODO: Implementar troca de período
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Mês Anterior'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Últimos 30 dias'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Ano Atual'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Personalizado'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () {
                Navigator.pop(context);
                // TODO: Abrir seletor de datas
              },
            ),
          ],
        ),
      ),
    );
  }

  void _exportToPDF() {
    // TODO: Implementar exportação PDF
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportação PDF em desenvolvimento'),
        backgroundColor: AppColors.info,
      ),
    );
  }

  void _exportToExcel() {
    // TODO: Implementar exportação Excel
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Exportação Excel em desenvolvimento'),
        backgroundColor: AppColors.info,
      ),
    );
  }
}
