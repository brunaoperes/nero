import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/transaction_providers.dart';

/// Widget de filtros para transações
class TransactionFilters extends ConsumerStatefulWidget {
  final VoidCallback onApplyFilters;

  const TransactionFilters({
    super.key,
    required this.onApplyFilters,
  });

  @override
  ConsumerState<TransactionFilters> createState() => _TransactionFiltersState();
}

class _TransactionFiltersState extends ConsumerState<TransactionFilters> {
  String? _selectedType;
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    // Inicializa com os valores atuais dos filtros
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedType = ref.read(transactionTypeFilterProvider);
      _selectedCategory = ref.read(transactionCategoryFilterProvider);
      _startDate = ref.read(transactionStartDateFilterProvider);
      _endDate = ref.read(transactionEndDateFilterProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _clearFilters,
                child: const Text('Limpar'),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Tipo de transação
          const Text(
            'Tipo',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              _buildFilterChip('Todas', null, _selectedType),
              _buildFilterChip('Receitas', 'income', _selectedType),
              _buildFilterChip('Despesas', 'expense', _selectedType),
            ],
          ),
          const SizedBox(height: 16),

          // Categoria
          const Text(
            'Categoria',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: _selectedCategory,
            decoration: const InputDecoration(
              hintText: 'Selecione uma categoria',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: [
              const DropdownMenuItem(value: null, child: Text('Todas')),
              ...(_selectedType == 'expense'
                      ? AppConstants.expenseCategories
                      : _selectedType == 'income'
                          ? AppConstants.incomeCategories
                          : [...AppConstants.incomeCategories, ...AppConstants.expenseCategories])
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      )),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCategory = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // Período
          const Text(
            'Período',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'De',
                  date: _startDate,
                  onTap: () => _selectDate(context, true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildDateField(
                  label: 'Até',
                  date: _endDate,
                  onTap: () => _selectDate(context, false),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Botão aplicar
          ElevatedButton(
            onPressed: _applyFilters,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Aplicar Filtros',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, String? selectedValue) {
    final isSelected = value == selectedValue;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() {
          _selectedType = value;
          // Limpa categoria se mudou o tipo
          if (_selectedType != selectedValue) {
            _selectedCategory = null;
          }
        });
      },
      selectedColor: AppColors.primary.withOpacity(0.2),
      checkmarkColor: AppColors.primary,
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          suffixIcon: const Icon(Icons.calendar_today, size: 18),
        ),
        child: Text(
          date != null
              ? '${date.day}/${date.month}/${date.year}'
              : 'Selecione',
          style: TextStyle(
            color: date != null ? null : Colors.grey,
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? DateTime.now()),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _applyFilters() {
    // Atualiza os providers
    ref.read(transactionTypeFilterProvider.notifier).state = _selectedType;
    ref.read(transactionCategoryFilterProvider.notifier).state = _selectedCategory;
    ref.read(transactionStartDateFilterProvider.notifier).state = _startDate;
    ref.read(transactionEndDateFilterProvider.notifier).state = _endDate;

    // Recarrega as transações com os filtros
    ref.read(transactionsListProvider.notifier).loadTransactions(
          type: _selectedType,
          category: _selectedCategory,
          startDate: _startDate,
          endDate: _endDate,
        );

    widget.onApplyFilters();
    Navigator.pop(context);
  }

  void _clearFilters() {
    setState(() {
      _selectedType = null;
      _selectedCategory = null;
      _startDate = null;
      _endDate = null;
    });

    // Limpa os providers
    ref.read(transactionTypeFilterProvider.notifier).state = null;
    ref.read(transactionCategoryFilterProvider.notifier).state = null;
    ref.read(transactionStartDateFilterProvider.notifier).state = null;
    ref.read(transactionEndDateFilterProvider.notifier).state = null;

    // Recarrega todas as transações
    ref.read(transactionsListProvider.notifier).loadTransactions();

    widget.onApplyFilters();
    Navigator.pop(context);
  }
}
