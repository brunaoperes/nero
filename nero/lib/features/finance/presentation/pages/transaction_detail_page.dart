import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/transaction_model.dart';
import '../providers/transaction_providers.dart';

/// Página de detalhes de uma transação
class TransactionDetailPage extends ConsumerWidget {
  final String transactionId;

  const TransactionDetailPage({
    super.key,
    required this.transactionId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsListProvider);

    return transactionsAsync.when(
      data: (transactions) {
        final transaction = transactions.firstWhere(
          (t) => t.id == transactionId,
          orElse: () => throw Exception('Transação não encontrada'),
        );

        return _buildDetailPage(context, ref, transaction);
      },
      loading: () => Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text('Detalhes da Transação'),
        ),
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Text('Erro'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Transação não encontrada',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Voltar'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailPage(
    BuildContext context,
    WidgetRef ref,
    TransactionModel transaction,
  ) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');
    final dateFormat = DateFormat('dd/MM/yyyy', 'pt_BR');
    final timeFormat = DateFormat('HH:mm', 'pt_BR');
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final isIncome = transaction.type == 'income';
    final amountColor = isIncome
        ? AppColors.success
        : (isDark ? AppColors.error : const Color(0xFFC62828));
    final icon = _getCategoryIcon(transaction.category);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimary : AppColors.lightIcon,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Detalhes da Transação',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.lightText,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppColors.primary),
            onPressed: () {
              context.push('/finance/edit/${transaction.id}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: AppColors.error),
            onPressed: () => _confirmDelete(context, ref, transaction.id),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card Principal com Valor
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: isDark
                    ? LinearGradient(
                        colors: isIncome
                            ? [AppColors.success, AppColors.success.withOpacity(0.7)]
                            : [AppColors.error, AppColors.error.withOpacity(0.7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isDark
                    ? null
                    : (isIncome
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFE5E5)),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: amountColor.withOpacity(isDark ? 0.3 : 0.1),
                    blurRadius: isDark ? 20 : 10,
                    offset: Offset(0, isDark ? 8 : 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : amountColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      size: 48,
                      color: isDark ? Colors.white : amountColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    transaction.category ?? 'Sem categoria',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : amountColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${isIncome ? '+' : '-'} ${currencyFormat.format(transaction.amount)}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : amountColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white.withOpacity(0.2)
                          : (isIncome
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFBEAEA)),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      isIncome ? 'Receita' : 'Despesa',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : amountColor,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Informações Detalhadas
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Informações',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Descrição
                  _buildInfoCard(
                    icon: Icons.description_outlined,
                    label: 'Descrição',
                    value: transaction.description ?? 'Sem descrição',
                    isDark: isDark,
                  ),

                  // Data e Hora
                  _buildInfoCard(
                    icon: Icons.calendar_today,
                    label: 'Data',
                    value: dateFormat.format(transaction.date ?? DateTime.now()),
                    isDark: isDark,
                  ),

                  _buildInfoCard(
                    icon: Icons.access_time,
                    label: 'Hora',
                    value: timeFormat.format(transaction.createdAt ?? DateTime.now()),
                    isDark: isDark,
                  ),

                  // Origem
                  _buildInfoCard(
                    icon: Icons.source,
                    label: 'Origem',
                    value: _getSourceLabel(transaction.source),
                    isDark: isDark,
                  ),

                  // Conta / Banco
                  _buildInfoCard(
                    icon: Icons.account_balance_wallet,
                    label: 'Conta / Banco',
                    value: transaction.account ?? 'Não informada',
                    isDark: isDark,
                  ),

                  // Categoria
                  _buildInfoCard(
                    icon: Icons.category,
                    label: 'Categoria',
                    value: transaction.category ?? 'Não categorizada',
                    isDark: isDark,
                  ),

                  // Badge IA se foi sugerida
                  if (transaction.suggestedCategory != null) ...[
                    const SizedBox(height: 8),
                    _buildAIBadge(context, transaction),
                  ],

                  const SizedBox(height: 24),

                  // Metadados
                  _buildMetadataSection(context, transaction),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActions(context, ref, transaction),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2A2A2A)
              : const Color(0xFFE0E0E0),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF2E2E2E)
                  : AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? const Color(0xFF9E9E9E)
                        : const Color(0xFF5F5F5F),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAIBadge(BuildContext context, TransactionModel transaction) {
    final confidence = transaction.categoryConfidence;
    final wasConfirmed = transaction.categoryConfirmed;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(isDark ? 0.1 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(isDark ? 0.3 : 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(isDark ? 0.2 : 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.auto_awesome,
              size: 20,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categorizada por IA',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Categoria sugerida: ${transaction.suggestedCategory}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark
                        ? const Color(0xFF9E9E9E)
                        : const Color(0xFF3A3A3A),
                    fontFamily: 'Inter',
                  ),
                ),
                if (confidence != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Confiança: ${(confidence * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark
                          ? const Color(0xFF9E9E9E)
                          : const Color(0xFF3A3A3A),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (wasConfirmed)
            const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 20,
            ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(BuildContext context, TransactionModel transaction) {
    final createdAt = transaction.createdAt;
    final updatedAt = transaction.updatedAt;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Metadados',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E1E1E)
                : const Color(0xFFF4F4F4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFE0E0E0),
            ),
          ),
          child: Column(
            children: [
              _buildMetadataRow(
                'ID',
                '${transaction.id.substring(0, 8)}...',
                isDark,
              ),
              if (createdAt != null) ...[
                Divider(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFE0E0E0),
                  height: 24,
                ),
                _buildMetadataRow(
                  'Criada em',
                  DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(createdAt),
                  isDark,
                ),
              ],
              if (updatedAt != null && updatedAt != createdAt) ...[
                Divider(
                  color: isDark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFE0E0E0),
                  height: 24,
                ),
                _buildMetadataRow(
                  'Atualizada em',
                  DateFormat('dd/MM/yyyy HH:mm', 'pt_BR').format(updatedAt),
                  isDark,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMetadataRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? const Color(0xFF9E9E9E)
                : const Color(0xFF5F5F5F),
            fontFamily: 'Inter',
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    WidgetRef ref,
    TransactionModel transaction,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark
                ? const Color(0xFF2A2A2A)
                : AppColors.lightBorder,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              flex: 1,
              child: ElevatedButton.icon(
                onPressed: () => _confirmDelete(context, ref, transaction.id),
                icon: const Icon(Icons.delete, size: 20),
                label: const Text(
                  'Excluir',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? Colors.transparent
                      : const Color(0xFFFFE9E9),
                  foregroundColor: isDark
                      ? AppColors.error
                      : const Color(0xFFC62828),
                  elevation: 0,
                  side: isDark
                      ? const BorderSide(color: AppColors.error)
                      : BorderSide.none,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 1,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push('/finance/edit/${transaction.id}');
                },
                icon: const Icon(Icons.edit, size: 20),
                label: const Text(
                  'Editar',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? AppColors.primary
                      : const Color(0xFFE8F0FF),
                  foregroundColor: isDark
                      ? Colors.white
                      : const Color(0xFF0072FF),
                  elevation: 0,
                  minimumSize: const Size(0, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSourceLabel(String? source) {
    switch (source?.toLowerCase()) {
      case 'manual':
        return 'Inserida manualmente';
      case 'pluggy':
        return 'Importada (Pluggy)';
      case 'ai':
        return 'Gerada pela IA';
      default:
        return source ?? 'Desconhecida';
    }
  }

  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'alimentação':
        return Icons.restaurant;
      case 'transporte':
        return Icons.directions_car;
      case 'moradia':
        return Icons.home;
      case 'saúde':
        return Icons.local_hospital;
      case 'educação':
        return Icons.school;
      case 'lazer':
        return Icons.sports_esports;
      case 'vestuário':
        return Icons.shopping_bag;
      case 'salário':
        return Icons.attach_money;
      case 'freelance':
        return Icons.work;
      case 'investimentos':
        return Icons.trending_up;
      case 'vendas':
        return Icons.point_of_sale;
      default:
        return Icons.category;
    }
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    String id,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        title: Text(
          'Excluir Transação',
          style: TextStyle(
            color: isDark ? AppColors.textPrimary : AppColors.lightText,
          ),
        ),
        content: Text(
          'Tem certeza que deseja excluir esta transação? Esta ação não pode ser desfeita.',
          style: TextStyle(
            color: isDark
                ? AppColors.textSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await ref
          .read(transactionsListProvider.notifier)
          .deleteTransaction(id);

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 12),
                  Text('✅ Transação excluída com sucesso!'),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          context.pop(); // Volta para lista
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Erro ao excluir transação'),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      }
    }
  }
}
