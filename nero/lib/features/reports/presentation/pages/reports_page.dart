import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../domain/models/report_config.dart';
import '../../providers/reports_provider.dart';
import '../widgets/report_type_selector.dart';
import '../widgets/report_filter_widget.dart';

/// Tela de Relatórios
class ReportsPage extends ConsumerStatefulWidget {
  const ReportsPage({super.key});

  @override
  ConsumerState<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends ConsumerState<ReportsPage> {
  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final config = ref.watch(reportConfigProvider);
    final generationState = ref.watch(reportGenerationProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Relatórios'),
        elevation: 0,
        actions: [
          // Botão de presets
          PopupMenuButton<ReportPreset>(
            icon: const Icon(Icons.bookmarks),
            tooltip: 'Presets Rápidos',
            onSelected: (preset) {
              ref.read(reportConfigProvider.notifier).applyPreset(preset);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: ReportPreset.weeklyTasks,
                child: ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Tarefas da Semana'),
                  subtitle: Text('PDF com tarefas desta semana'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: ReportPreset.monthlyFinance,
                child: ListTile(
                  leading: Icon(Icons.attach_money),
                  title: Text('Finanças do Mês'),
                  subtitle: Text('Excel com finanças deste mês'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: ReportPreset.yearlyConsolidated,
                child: ListTile(
                  leading: Icon(Icons.analytics),
                  title: Text('Consolidado do Ano'),
                  subtitle: Text('PDF completo do ano'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
          // Botão de reset
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Resetar',
            onPressed: () {
              ref.read(reportConfigProvider.notifier).reset();
              ref.read(reportGenerationProvider.notifier).clear();
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Conteúdo principal
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Seletor de tipo
                ReportTypeSelector(
                  selectedType: config.type,
                  onTypeSelected: (type) {
                    ref.read(reportConfigProvider.notifier).setType(type);
                  },
                  isDark: isDark,
                ),

                const SizedBox(height: 24),

                // Filtros
                ReportFilterWidget(
                  config: config,
                  onPeriodChanged: (period) {
                    ref.read(reportConfigProvider.notifier).setPeriod(period);
                  },
                  onStartDateChanged: (date) {
                    ref.read(reportConfigProvider.notifier).setStartDate(date);
                  },
                  onEndDateChanged: (date) {
                    ref.read(reportConfigProvider.notifier).setEndDate(date);
                  },
                  onFormatChanged: (format) {
                    ref.read(reportConfigProvider.notifier).setFormat(format);
                  },
                  onIncludeCompletedChanged: (value) {
                    ref.read(reportConfigProvider.notifier).setIncludeCompleted(value);
                  },
                  onIncludePendingChanged: (value) {
                    ref.read(reportConfigProvider.notifier).setIncludePending(value);
                  },
                  onIncludeIncomeChanged: (value) {
                    ref.read(reportConfigProvider.notifier).setIncludeIncome(value);
                  },
                  onIncludeExpensesChanged: (value) {
                    ref.read(reportConfigProvider.notifier).setIncludeExpenses(value);
                  },
                  isDark: isDark,
                ),

                const SizedBox(height: 24),

                // Resumo da configuração
                if (config.isValid()) _buildConfigSummary(config, isDark),

                const SizedBox(height: 100), // Espaço para o botão fixo
              ],
            ),
          ),

          // Overlay de loading
          if (generationState.isGenerating)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: Center(
                child: Card(
                  margin: const EdgeInsets.all(40),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(),
                        const SizedBox(height: 16),
                        Text(
                          'Gerando relatório...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? AppColors.darkText : AppColors.lightText,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(generationState.progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        LinearProgressIndicator(
                          value: generationState.progress,
                          backgroundColor: AppColors.grey300,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // Botão de gerar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.lightCard,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: config.isValid() && !generationState.isGenerating
                      ? () => _generateReport()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor: AppColors.grey300,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        config.format == ReportFormat.pdf
                            ? Icons.picture_as_pdf
                            : Icons.table_chart,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Gerar Relatório ${config.getFormatLabel()}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfigSummary(ReportConfig config, bool isDark) {
    final summary = config.getSummary();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.info.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.info.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.info,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Resumo da Configuração',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...summary.entries.map((entry) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 100,
                      child: Text(
                        '${entry.key}:',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.darkText : AppColors.lightText,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Future<void> _generateReport() async {
    final config = ref.read(reportConfigProvider);

    // Validar configuração
    if (!config.isValid()) {
      _showError('Configuração inválida. Verifique os campos.');
      return;
    }

    // Gerar relatório
    final file = await ref.read(reportGenerationProvider.notifier).generateReport();

    if (file != null) {
      // Sucesso - mostrar opções
      _showSuccessDialog(file);
    } else {
      // Erro
      final error = ref.read(reportGenerationProvider).errorMessage;
      _showError(error ?? 'Erro ao gerar relatório');
    }
  }

  void _showSuccessDialog(file) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.success),
            SizedBox(width: 8),
            Text('Relatório Gerado!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Seu relatório foi gerado com sucesso.'),
            const SizedBox(height: 8),
            Text(
              'Arquivo: ${file.path.split('/').last}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await Share.shareXFiles([XFile(file.path)]);
              if (mounted) Navigator.pop(context);
            },
            icon: const Icon(Icons.share),
            label: const Text('Compartilhar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
