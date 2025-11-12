// lib/features/finance/presentation/pages/transaction_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/finance_providers.dart';

class TransactionFormPage extends ConsumerStatefulWidget {
  final TransactionEntity? transaction;

  const TransactionFormPage({super.key, this.transaction});

  @override
  ConsumerState<TransactionFormPage> createState() =>
      _TransactionFormPageState();
}

class _TransactionFormPageState extends ConsumerState<TransactionFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();

  TransactionType _type = TransactionType.expense;
  String? _selectedCategoryId;
  DateTime _date = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transaction != null) {
      _titleController.text = widget.transaction!.title;
      _amountController.text = widget.transaction!.amount.toString();
      _descriptionController.text = widget.transaction!.description ?? '';
      _type = widget.transaction!.type;
      _selectedCategoryId = widget.transaction!.categoryId;
      _date = widget.transaction!.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() => _date = picked);
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      final transaction = TransactionEntity(
        id: widget.transaction?.id ?? '',
        userId: userId,
        title: _titleController.text.trim(),
        amount: double.parse(_amountController.text),
        type: _type,
        categoryId: _selectedCategoryId!,
        date: _date,
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        createdAt: widget.transaction?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.transaction == null) {
        await ref
            .read(transactionControllerProvider.notifier)
            .createTransaction(transaction);
      } else {
        await ref
            .read(transactionControllerProvider.notifier)
            .updateTransaction(transaction);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.transaction == null
                  ? 'Transação criada com sucesso!'
                  : 'Transação atualizada!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.lightBackground : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.lightBackground : const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.transaction == null ? 'Nova Transação' : 'Editar Transação',
          style: AppTextStyles.headingH2.copyWith(
            color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipo (Receita/Despesa)
            Container(
              decoration: BoxDecoration(
                color: AppColors.lightBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = TransactionType.expense),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _type == TransactionType.expense
                              ? AppColors.error.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(12),
                            bottomLeft: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          '💸 Despesa',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _type == TransactionType.expense
                                ? AppColors.error
                                : AppColors.textSecondary,
                            fontWeight: _type == TransactionType.expense
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 40, color: AppColors.border),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = TransactionType.income),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: _type == TransactionType.income
                              ? AppColors.success.withOpacity(0.1)
                              : Colors.transparent,
                          borderRadius: const BorderRadius.only(
                            topRight: Radius.circular(12),
                            bottomRight: Radius.circular(12),
                          ),
                        ),
                        child: Text(
                          '💰 Receita',
                          textAlign: TextAlign.center,
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: _type == TransactionType.income
                                ? AppColors.success
                                : AppColors.textSecondary,
                            fontWeight: _type == TransactionType.income
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Título
            TextFormField(
              controller: _titleController,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
              ),
              decoration: InputDecoration(
                labelText: 'Título *',
                hintText: 'Ex: Almoço no restaurante',
                filled: true,
                fillColor: isDark ? AppColors.lightBackground : Colors.white,
                labelStyle: TextStyle(
                  color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: TextStyle(
                  color: isDark ? AppColors.textSecondary.withOpacity(0.6) : const Color(0xFF8C8C8C),
                  fontFamily: 'Inter',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.border : const Color(0xFFE0E0E0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.border : const Color(0xFFE0E0E0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O título é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Valor
            TextFormField(
              controller: _amountController,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Valor *',
                hintText: '0.00',
                prefixText: 'R\$ ',
                prefixStyle: TextStyle(
                  color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                  fontFamily: 'Inter',
                ),
                filled: true,
                fillColor: isDark ? AppColors.lightBackground : Colors.white,
                labelStyle: TextStyle(
                  color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: TextStyle(
                  color: isDark ? AppColors.textSecondary.withOpacity(0.6) : const Color(0xFF8C8C8C),
                  fontFamily: 'Inter',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.border : const Color(0xFFE0E0E0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.border : const Color(0xFFE0E0E0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'O valor é obrigatório';
                }
                if (double.tryParse(value) == null) {
                  return 'Valor inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Categoria
            categoriesAsync.when(
              data: (categories) {
                final filteredCategories = categories.where((cat) {
                  return cat.type.toJson() == _type.toJson() ||
                      cat.type.toJson() == 'both';
                }).toList();

                return DropdownButtonFormField<String>(
                  value: _selectedCategoryId,
                  dropdownColor: isDark ? AppColors.lightBackground : Colors.white,
                  style: TextStyle(
                    color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                    fontFamily: 'Inter',
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Categoria *',
                    filled: true,
                    fillColor: isDark ? AppColors.lightBackground : Colors.white,
                    labelStyle: TextStyle(
                      color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.border : const Color(0xFFE0E0E0),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.border : const Color(0xFFE0E0E0),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                  ),
                  hint: Text(
                    'Selecione uma categoria',
                    style: TextStyle(
                      color: isDark ? AppColors.textSecondary.withOpacity(0.6) : const Color(0xFF8C8C8C),
                      fontFamily: 'Inter',
                    ),
                  ),
                  items: filteredCategories.map((category) {
                    return DropdownMenuItem(
                      value: category.id,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${category.icon} ${category.name}',
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedCategoryId = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecione uma categoria';
                    }
                    return null;
                  },
                );
              },
              loading: () => const CircularProgressIndicator(color: AppColors.primary),
              error: (e, _) => Text(
                'Erro ao carregar categorias: $e',
                style: TextStyle(
                  color: isDark ? AppColors.error : const Color(0xFFC62828),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Data
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.lightBackground : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.border : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary, size: 20),
                    const SizedBox(width: 12),
                    Text(
                      'Data: ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                        fontFamily: 'Inter',
                      ),
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(_date),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Descrição (opcional)
            TextFormField(
              controller: _descriptionController,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
              ),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Adicione uma observação...',
                filled: true,
                fillColor: isDark ? AppColors.lightBackground : Colors.white,
                labelStyle: TextStyle(
                  color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: TextStyle(
                  color: isDark ? AppColors.textSecondary.withOpacity(0.6) : const Color(0xFF8C8C8C),
                  fontFamily: 'Inter',
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.border : const Color(0xFFE0E0E0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? AppColors.border : const Color(0xFFE0E0E0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Botão Salvar
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveTransaction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor: AppColors.primary.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: isDark ? 0 : 2,
                  shadowColor: Colors.black.withOpacity(0.1),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        widget.transaction == null ? 'Criar Transação' : 'Salvar Alterações',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
              ),
            ),

            // Botão Deletar (se editando)
            if (widget.transaction != null) ...[
              const SizedBox(height: 16),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: isDark ? AppColors.lightBackground : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        title: Text(
                          'Confirmar exclusão',
                          style: TextStyle(
                            color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        content: Text(
                          'Tem certeza que deseja excluir esta transação?',
                          style: TextStyle(
                            color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                            fontFamily: 'Inter',
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: Text(
                              'Cancelar',
                              style: TextStyle(
                                color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            style: TextButton.styleFrom(
                              foregroundColor: isDark ? AppColors.error : const Color(0xFFC62828),
                            ),
                            child: const Text(
                              'Excluir',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true && mounted) {
                      await ref
                          .read(transactionControllerProvider.notifier)
                          .deleteTransaction(widget.transaction!.id);

                      if (mounted) {
                        Navigator.pop(context, true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Transação excluída'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    }
                  },
                  icon: Icon(
                    Icons.delete_outline,
                    color: isDark ? AppColors.error : const Color(0xFFC62828),
                  ),
                  label: Text(
                    'Excluir Transação',
                    style: TextStyle(
                      color: isDark ? AppColors.error : const Color(0xFFC62828),
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark ? AppColors.error.withOpacity(0.5) : const Color(0xFFFFCDD2),
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: isDark ? Colors.transparent : const Color(0xFFFFEBEE),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
