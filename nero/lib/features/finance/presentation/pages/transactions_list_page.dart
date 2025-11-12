// lib/features/finance/presentation/pages/transactions_list_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/finance_providers.dart';
import '../widgets/transaction_card.dart';
import 'transaction_form_page.dart';

class TransactionsListPage extends ConsumerStatefulWidget {
  const TransactionsListPage({super.key});

  @override
  ConsumerState<TransactionsListPage> createState() =>
      _TransactionsListPageState();
}

class _TransactionsListPageState extends ConsumerState<TransactionsListPage> {
  String _searchQuery = '';
  TransactionType? _filterType;
  String? _filterCategoryId;
  SortOption _sortOption = SortOption.dateDesc;

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    return Column(
      children: [
        // Barra de busca e filtros
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.lightBackground,
          child: Column(
            children: [
              // Campo de busca
              TextField(
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'Buscar transações...',
                  prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                  filled: true,
                  fillColor: AppColors.lightBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
              ),
              const SizedBox(height: 12),

              // Filtros
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    // Filtro de Tipo
                    _buildFilterChip(
                      label: _filterType == null
                          ? 'Tipo'
                          : _filterType == TransactionType.income
                              ? 'Receitas'
                              : 'Despesas',
                      isActive: _filterType != null,
                      onTap: () {
                        _showTypeFilter();
                      },
                    ),
                    const SizedBox(width: 8),

                    // Filtro de Categoria
                    categoriesAsync.when(
                      data: (categories) {
                        final selectedCategory = categories
                            .where((c) => c.id == _filterCategoryId)
                            .firstOrNull;
                        return _buildFilterChip(
                          label: selectedCategory == null
                              ? 'Categoria'
                              : '${selectedCategory.icon} ${selectedCategory.name}',
                          isActive: _filterCategoryId != null,
                          onTap: () {
                            _showCategoryFilter(categories);
                          },
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (_, __) => const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 8),

                    // Ordenação
                    _buildFilterChip(
                      label: _sortOption.label,
                      icon: Icons.sort,
                      onTap: () {
                        _showSortOptions();
                      },
                    ),

                    // Limpar filtros
                    if (_filterType != null || _filterCategoryId != null) ...[
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.clear, color: AppColors.error),
                        onPressed: () {
                          setState(() {
                            _filterType = null;
                            _filterCategoryId = null;
                          });
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),

        // Lista de transações
        Expanded(
          child: transactionsAsync.when(
            data: (transactions) {
              // Aplicar filtros
              var filteredTransactions = transactions.where((t) {
                // Filtro de busca
                if (_searchQuery.isNotEmpty &&
                    !t.title.toLowerCase().contains(_searchQuery)) {
                  return false;
                }

                // Filtro de tipo
                if (_filterType != null && t.type != _filterType) {
                  return false;
                }

                // Filtro de categoria
                if (_filterCategoryId != null &&
                    t.categoryId != _filterCategoryId) {
                  return false;
                }

                return true;
              }).toList();

              // Aplicar ordenação
              filteredTransactions = _sortTransactions(filteredTransactions);

              if (filteredTransactions.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _searchQuery.isNotEmpty || _filterType != null
                            ? Icons.search_off
                            : Icons.receipt_long,
                        size: 64,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty || _filterType != null
                            ? 'Nenhuma transação encontrada'
                            : 'Nenhuma transação ainda',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }

              // Agrupar por data
              final groupedTransactions = _groupByDate(filteredTransactions);

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: groupedTransactions.length,
                itemBuilder: (context, index) {
                  final date = groupedTransactions.keys.elementAt(index);
                  final dayTransactions = groupedTransactions[date]!;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cabeçalho da data
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          _formatDateHeader(date),
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),

                      // Transações do dia
                      ...dayTransactions.map((transaction) {
                        return TransactionCard(
                          transaction: transaction,
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionFormPage(
                                  transaction: transaction,
                                ),
                              ),
                            );

                            if (result == true) {
                              ref.invalidate(transactionsProvider);
                              ref.invalidate(financialSummaryProvider);
                            }
                          },
                        );
                      }),

                      const SizedBox(height: 16),
                    ],
                  );
                },
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
                    'Erro ao carregar transações',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: AppColors.error,
                    ),
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
        ),
      ],
    );
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    bool isActive = false,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withOpacity(0.1)
              : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isActive ? AppColors.primary : AppColors.textSecondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: AppTextStyles.bodySmall.copyWith(
                color: isActive ? AppColors.primary : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTypeFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filtrar por Tipo',
              style: AppTextStyles.headingH3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.check, color: Colors.transparent),
              title: const Text('Todas'),
              onTap: () {
                setState(() => _filterType = null);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.check,
                color: _filterType == TransactionType.income
                    ? AppColors.success
                    : Colors.transparent,
              ),
              title: const Text('Receitas'),
              trailing: const Icon(Icons.arrow_upward, color: AppColors.success),
              onTap: () {
                setState(() => _filterType = TransactionType.income);
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(
                Icons.check,
                color: _filterType == TransactionType.expense
                    ? AppColors.error
                    : Colors.transparent,
              ),
              title: const Text('Despesas'),
              trailing: const Icon(Icons.arrow_downward, color: AppColors.error),
              onTap: () {
                setState(() => _filterType = TransactionType.expense);
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryFilter(List<dynamic> categories) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filtrar por Categoria',
              style: AppTextStyles.headingH3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.check, color: Colors.transparent),
              title: const Text('Todas'),
              onTap: () {
                setState(() => _filterCategoryId = null);
                Navigator.pop(context);
              },
            ),
            ...categories.map((category) {
              return ListTile(
                leading: Icon(
                  Icons.check,
                  color: _filterCategoryId == category.id
                      ? AppColors.primary
                      : Colors.transparent,
                ),
                title: Text('${category.icon} ${category.name}'),
                onTap: () {
                  setState(() => _filterCategoryId = category.id);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ordenar por',
              style: AppTextStyles.headingH3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...SortOption.values.map((option) {
              return ListTile(
                leading: Icon(
                  Icons.check,
                  color: _sortOption == option
                      ? AppColors.primary
                      : Colors.transparent,
                ),
                title: Text(option.label),
                onTap: () {
                  setState(() => _sortOption = option);
                  Navigator.pop(context);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  List<TransactionEntity> _sortTransactions(List<TransactionEntity> transactions) {
    final sorted = List<TransactionEntity>.from(transactions);

    switch (_sortOption) {
      case SortOption.dateDesc:
        sorted.sort((a, b) => b.date.compareTo(a.date));
        break;
      case SortOption.dateAsc:
        sorted.sort((a, b) => a.date.compareTo(b.date));
        break;
      case SortOption.amountDesc:
        sorted.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case SortOption.amountAsc:
        sorted.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case SortOption.title:
        sorted.sort((a, b) => a.title.compareTo(b.title));
        break;
    }

    return sorted;
  }

  Map<String, List<TransactionEntity>> _groupByDate(
      List<TransactionEntity> transactions) {
    final Map<String, List<TransactionEntity>> grouped = {};

    for (final transaction in transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(transaction.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(transaction);
    }

    return grouped;
  }

  String _formatDateHeader(String dateKey) {
    final date = DateTime.parse(dateKey);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final transactionDate = DateTime(date.year, date.month, date.day);

    if (transactionDate == today) {
      return 'Hoje';
    } else if (transactionDate == yesterday) {
      return 'Ontem';
    } else {
      return DateFormat('dd/MM/yyyy - EEEE', 'pt_BR').format(date);
    }
  }
}

enum SortOption {
  dateDesc,
  dateAsc,
  amountDesc,
  amountAsc,
  title,
}

extension SortOptionExtension on SortOption {
  String get label {
    switch (this) {
      case SortOption.dateDesc:
        return 'Data (mais recente)';
      case SortOption.dateAsc:
        return 'Data (mais antiga)';
      case SortOption.amountDesc:
        return 'Valor (maior)';
      case SortOption.amountAsc:
        return 'Valor (menor)';
      case SortOption.title:
        return 'Título (A-Z)';
    }
  }
}
