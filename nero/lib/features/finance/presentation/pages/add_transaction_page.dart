import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/models/bank_account_model.dart';
import '../providers/transaction_providers.dart';
import '../providers/bank_account_providers.dart';
import '../widgets/attachments_widget.dart';

/// Formatador customizado de moeda brasileira
class BrazilianCurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove tudo que não é dígito
    String digitsOnly = newValue.text.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Converte para double (centavos)
    double value = double.parse(digitsOnly) / 100;

    // Formata como moeda brasileira
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$ ',
      decimalDigits: 2,
    );

    String formatted = formatter.format(value);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Página para adicionar ou editar uma transação - Design moderno e clean
class AddTransactionPage extends ConsumerStatefulWidget {
  final String? transactionId;

  const AddTransactionPage({
    super.key,
    this.transactionId,
  });

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  String _type = 'expense';
  String? _category;
  String? _selectedAccount; // Novo campo
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isAILoading = false;
  String? _aiSuggestedCategory;
  double? _aiConfidence;
  String? _aiReasoning;
  String? _amountError;
  List<String> _attachments = []; // URLs dos anexos

  // Dados da transação existente (para edição)
  String? _existingTransactionId;
  DateTime? _existingCreatedAt;

  // ID temporário para anexos (antes de salvar a transação)
  late String _tempTransactionId;

  // Controle de mudanças não salvas
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  // Valores iniciais para comparação
  String _initialType = 'expense';
  String? _initialCategory;
  String? _initialAccount;
  String _initialAmount = '';
  String _initialDescription = '';
  DateTime _initialDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    // Gerar ID temporário para anexos
    _tempTransactionId = widget.transactionId ?? const Uuid().v4();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();

    // Adicionar listeners para detectar mudanças
    _amountController.addListener(_checkForChanges);
    _descriptionController.addListener(_checkForChanges);

    // Se tiver ID, carregar a transação
    if (widget.transactionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTransaction();
      });
    } else {
      // Para nova transação, salvar estado inicial
      _saveInitialState();
    }
  }

  /// Salva o estado inicial do formulário
  void _saveInitialState() {
    _initialType = _type;
    _initialCategory = _category;
    _initialAccount = _selectedAccount;
    _initialAmount = _amountController.text;
    _initialDescription = _descriptionController.text;
    _initialDate = _selectedDate;
  }

  /// Verifica se houve mudanças no formulário
  void _checkForChanges() {
    final hasChanges = _type != _initialType ||
        _category != _initialCategory ||
        _selectedAccount != _initialAccount ||
        _amountController.text != _initialAmount ||
        _descriptionController.text != _initialDescription ||
        !_isSameDateWithoutTime(_selectedDate, _initialDate);

    if (hasChanges != _hasUnsavedChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  /// Compara duas datas ignorando o horário
  bool _isSameDateWithoutTime(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  void _loadTransaction() {
    if (widget.transactionId == null) return;

    final transactionsAsync = ref.read(transactionsListProvider);
    transactionsAsync.whenData((transactions) {
      try {
        final transaction = transactions.firstWhere(
          (t) => t.id == widget.transactionId,
        );

        setState(() {
          _existingTransactionId = transaction.id;
          _existingCreatedAt = transaction.createdAt;
          _type = transaction.type;
          _category = transaction.category;

          // Formatar valor como moeda
          final formatter = NumberFormat.currency(
            locale: 'pt_BR',
            symbol: 'R\$ ',
            decimalDigits: 2,
          );
          _amountController.text = formatter.format(transaction.amount);

          _descriptionController.text = transaction.description ?? '';
          _selectedAccount = transaction.account; // Carregar conta/banco
          _selectedDate = transaction.date ?? DateTime.now();

          // Carregar dados da IA se existirem
          _aiSuggestedCategory = transaction.suggestedCategory;
          _aiConfidence = transaction.categoryConfidence;

          // Carregar anexos
          _attachments = transaction.attachments ?? [];

          // Salvar estado inicial após carregar
          _saveInitialState();
        });
      } catch (e) {
        // Transação não encontrada
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Transação não encontrada'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // Extrai o valor numérico do texto formatado
  double? _getAmountValue() {
    final text = _amountController.text
        .replaceAll('R\$ ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(text);
  }

  // Cores dinâmicas baseadas no tema
  Color _getLabelColor(bool isDark) => isDark ? AppColors.darkText : const Color(0xFF1C1C1C);
  Color _getSecondaryColor(bool isDark) => isDark ? const Color(0xFF9E9E9E) : const Color(0xFF5F5F5F);
  Color _getBackgroundColor(bool isDark) => isDark ? const Color(0xFF1E1E1E) : Colors.white;
  Color _getBorderColor(bool isDark) => isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0);
  Color _getCardColor(bool isDark) => isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transactionId != null;
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    return PopScope(
      canPop: !_hasUnsavedChanges || _isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Se tem mudanças não salvas, mostrar diálogo
        if (_hasUnsavedChanges && !_isSaving) {
          final shouldPop = await _showUnsavedChangesDialog();
          if (shouldPop == true && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
      resizeToAvoidBottomInset: true, // Ajusta quando o teclado abre
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: _getLabelColor(isDark)),
          onPressed: () async {
            if (_hasUnsavedChanges && !_isSaving) {
              final result = await _showUnsavedChangesDialog();
              if (result == true && context.mounted) {
                Navigator.of(context).pop();
              }
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          isEditing ? 'Editar Transação' : 'Nova Transação',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: _getLabelColor(isDark),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Tipo de Transação - Design Compacto
                _buildTypeSelector(isDark),
                const SizedBox(height: 24),

                // Valor - Com máscara monetária
                _buildAmountField(isDark),
                const SizedBox(height: 24),

                // Categoria - Com botão IA
                _buildCategoryField(isDark),
                const SizedBox(height: 24),

                // Card de sugestão da IA
                if (_aiSuggestedCategory != null) ...[
                  _buildAISuggestionCard(isDark),
                  const SizedBox(height: 24),
                ],

                // NOVO: Campo Conta/Banco
                _buildAccountField(isDark),
                const SizedBox(height: 24),

                // Descrição
                _buildDescriptionField(isDark),
                const SizedBox(height: 24),

                // Data
                _buildDateField(isDark),
                const SizedBox(height: 24),

                // Anexos
                _buildAttachmentsField(isDark),
                const SizedBox(height: 32),

                // Botão Adicionar - Design moderno com elevação
                _buildSubmitButton(isEditing, isDark),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  /// Diálogo de confirmação para mudanças não salvas
  Future<bool?> _showUnsavedChangesDialog() async {
    final isDark = ref.read(themeProvider) == ThemeMode.dark;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: _getBackgroundColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: AppColors.warning,
              size: 24,
            ),
            const SizedBox(width: 12),
            Text(
              'Mudanças não salvas',
              style: TextStyle(
                color: _getLabelColor(isDark),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Você tem alterações não salvas. Deseja salvar antes de sair?',
          style: TextStyle(
            color: _getSecondaryColor(isDark),
            fontSize: 15,
          ),
        ),
        actions: [
          // Cancelar (não sair)
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: _getSecondaryColor(isDark),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Descartar (sair sem salvar)
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text(
              'Descartar',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Salvar e sair
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context, false);
              await _saveTransaction();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Salvar',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Selector de tipo moderno e compacto com cores suaves
  Widget _buildTypeSelector(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipo de Transação',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _getLabelColor(isDark),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                label: 'Receita',
                icon: Icons.arrow_upward,
                value: 'income',
                selectedBgColor: const Color(0xFFE6F4EA), // Verde suave
                selectedTextColor: const Color(0xFF137333), // Verde escuro
                unselectedBgColor: _getCardColor(isDark),
                unselectedTextColor: _getSecondaryColor(isDark),
                isDark: isDark,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeButton(
                label: 'Despesa',
                icon: Icons.arrow_downward,
                value: 'expense',
                selectedBgColor: const Color(0xFFFDE7E9), // Vermelho suave
                selectedTextColor: const Color(0xFFC62828), // Vermelho escuro
                unselectedBgColor: _getCardColor(isDark),
                unselectedTextColor: _getSecondaryColor(isDark),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton({
    required String label,
    required IconData icon,
    required String value,
    required Color selectedBgColor,
    required Color selectedTextColor,
    required Color unselectedBgColor,
    required Color unselectedTextColor,
    required bool isDark,
  }) {
    final isSelected = _type == value;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 56,
      child: InkWell(
        onTap: () {
          setState(() {
            _type = value;
            _category = null;
          });
          _checkForChanges();
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            color: isSelected ? selectedBgColor : unselectedBgColor,
            border: Border.all(
              color: isSelected
                  ? selectedTextColor.withOpacity(0.3)
                  : _getBorderColor(isDark),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? selectedTextColor : unselectedTextColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? selectedTextColor : unselectedTextColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Campo de valor com máscara monetária brasileira
  Widget _buildAmountField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attach_money, size: 18, color: _getSecondaryColor(isDark)),
            const SizedBox(width: 8),
            Text(
              'Valor',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getLabelColor(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            BrazilianCurrencyInputFormatter(),
          ],
          style: TextStyle(
            fontSize: 16,
            color: _getLabelColor(isDark),
          ),
          decoration: InputDecoration(
            hintText: 'Digite o valor da transação',
            hintStyle: TextStyle(color: _getSecondaryColor(isDark)),
            filled: true,
            fillColor: _getBackgroundColor(isDark),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _getBorderColor(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _getBorderColor(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
          validator: (value) {
            final amount = _getAmountValue();
            if (amount == null || amount <= 0) {
              return 'Informe um valor válido';
            }
            return null;
          },
          onChanged: (value) {
            setState(() {
              _amountError = null;
            });
          },
        ),
        if (_amountError != null) ...[
          const SizedBox(height: 8),
          Text(
            _amountError!,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  /// Campo de categoria com botão IA redesenhado
  Widget _buildCategoryField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.label_outline, size: 18, color: _getSecondaryColor(isDark)),
            const SizedBox(width: 8),
            Text(
              'Categoria',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getLabelColor(isDark),
              ),
            ),
            const Spacer(),
            // Botão IA redesenhado
            InkWell(
              onTap: _isAILoading ? null : _requestAICategorization,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isAILoading)
                      const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(AppColors.primary),
                        ),
                      )
                    else
                      const Icon(
                        Icons.auto_awesome,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    const SizedBox(width: 6),
                    const Text(
                      'IA Sugerir',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: _category,
          dropdownColor: _getBackgroundColor(isDark),
          style: TextStyle(
            fontSize: 16,
            color: _getLabelColor(isDark),
          ),
          decoration: InputDecoration(
            hintText: 'Selecione uma categoria',
            hintStyle: TextStyle(color: _getSecondaryColor(isDark)),
            filled: true,
            fillColor: _getBackgroundColor(isDark),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _getBorderColor(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _getBorderColor(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          items: (_type == 'expense'
                  ? AppConstants.expenseCategories
                  : AppConstants.incomeCategories)
              .map((category) => DropdownMenuItem(
                    value: category,
                    child: Text(category),
                  ))
              .toList(),
          onChanged: (value) {
            setState(() {
              _category = value;
            });
            _checkForChanges();
          },
          validator: (value) {
            if (value == null) {
              return 'Selecione uma categoria';
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Campo Conta/Banco - Dinâmico com provider
  Widget _buildAccountField(bool isDark) {
    // Buscar contas dinamicamente do provider
    final bankAccountsAsync = ref.watch(bankAccountsListProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 18, color: _getSecondaryColor(isDark)),
            const SizedBox(width: 8),
            Text(
              'Conta / Banco',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getLabelColor(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        bankAccountsAsync.when(
          data: (bankAccounts) {
            // Criar lista de nomes das contas
            final accountNames = bankAccounts.map((account) => account.name).toList();

            // Verificar se a conta selecionada ainda existe
            if (_selectedAccount != null && !accountNames.contains(_selectedAccount)) {
              // Se a conta foi deletada, limpar seleção
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _selectedAccount = null;
                  });
                }
              });
            }

            return DropdownButtonFormField<String>(
              value: accountNames.contains(_selectedAccount) ? _selectedAccount : null,
              dropdownColor: _getBackgroundColor(isDark),
              style: TextStyle(
                fontSize: 16,
                color: _getLabelColor(isDark),
              ),
              decoration: InputDecoration(
                hintText: accountNames.isEmpty
                    ? 'Nenhuma conta cadastrada'
                    : 'Selecione a conta',
                hintStyle: TextStyle(color: _getSecondaryColor(isDark)),
                filled: true,
                fillColor: _getBackgroundColor(isDark),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _getBorderColor(isDark)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: _getBorderColor(isDark)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              items: [
                // Lista dinâmica de contas do banco de dados
                ...accountNames.map((accountName) => DropdownMenuItem(
                      value: accountName,
                      child: Text(accountName),
                    )),
                // Opção para adicionar nova conta
                const DropdownMenuItem(
                  value: '__add_new__',
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline, color: AppColors.primary, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Adicionar nova conta',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              onChanged: (value) {
                if (value == '__add_new__') {
                  _showAddAccountDialog(isDark);
                } else {
                  setState(() {
                    _selectedAccount = value;
                  });
                  _checkForChanges();
                }
              },
              validator: (value) {
                if (value == null || value == '__add_new__') {
                  return 'Selecione uma conta';
                }
                return null;
              },
            );
          },
          loading: () => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getBackgroundColor(isDark),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _getBorderColor(isDark)),
            ),
            child: Row(
              children: [
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 12),
                Text(
                  'Carregando contas...',
                  style: TextStyle(color: _getSecondaryColor(isDark)),
                ),
              ],
            ),
          ),
          error: (error, stack) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getBackgroundColor(isDark),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.error),
            ),
            child: Row(
              children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Erro ao carregar contas',
                    style: TextStyle(color: _getSecondaryColor(isDark)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Modal para adicionar nova conta - Salva no banco de dados
  Future<void> _showAddAccountDialog(bool isDark) async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: _getBackgroundColor(isDark),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Adicionar Nova Conta',
          style: TextStyle(
            color: _getLabelColor(isDark),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: _getLabelColor(isDark)),
          decoration: InputDecoration(
            hintText: 'Ex: Caixa PJ, Carteira, Nubank',
            hintStyle: TextStyle(color: _getSecondaryColor(isDark)),
            filled: true,
            fillColor: _getCardColor(isDark),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _getBorderColor(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _getBorderColor(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(color: _getSecondaryColor(isDark)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final accountName = controller.text.trim();
              if (accountName.isNotEmpty) {
                Navigator.pop(context); // Fechar modal primeiro

                // Criar BankAccountModel
                final account = BankAccountModel(
                  id: '',
                  userId: '',
                  name: accountName,
                  balance: 0.0,
                  color: '0072FF', // Azul padrão
                  icon: 'account_balance_wallet',
                  iconKey: 'generic', // Ícone genérico
                  isActive: true,
                );

                // Salvar no banco de dados via provider
                final success = await ref
                    .read(bankAccountsListProvider.notifier)
                    .createBankAccount(account);

                if (mounted) {
                  if (success) {
                    // Selecionar a conta recém-criada
                    setState(() {
                      _selectedAccount = accountName;
                    });
                    _checkForChanges();

                    // Feedback de sucesso
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.check_circle, color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                            Text('Conta "$accountName" adicionada!'),
                          ],
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  } else {
                    // Feedback de erro
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(Icons.error_outline, color: Colors.white, size: 20),
                            const SizedBox(width: 12),
                            const Text('Erro ao adicionar conta'),
                          ],
                        ),
                        backgroundColor: AppColors.error,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Adicionar'),
          ),
        ],
      ),
    );
  }

  /// Card de sugestão da IA redesenhado
  Widget _buildAISuggestionCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.lightbulb_outline,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A IA sugere:',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getSecondaryColor(isDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _aiSuggestedCategory!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${(_aiConfidence! * 100).toStringAsFixed(0)}% de confiança',
                  style: TextStyle(
                    fontSize: 12,
                    color: _getSecondaryColor(isDark),
                  ),
                ),
                if (_aiReasoning != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _aiReasoning!,
                    style: TextStyle(
                      fontSize: 13,
                      color: _getSecondaryColor(isDark),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Campo de descrição melhorado
  Widget _buildDescriptionField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.description_outlined, size: 18, color: _getSecondaryColor(isDark)),
            const SizedBox(width: 8),
            Text(
              'Descrição (opcional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getLabelColor(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _descriptionController,
          maxLines: 3,
          style: TextStyle(
            fontSize: 14,
            color: _getLabelColor(isDark),
          ),
          decoration: InputDecoration(
            hintText: 'Adicione uma observação ou detalhe da transação…',
            hintStyle: TextStyle(color: _getSecondaryColor(isDark)),
            filled: true,
            fillColor: _getBackgroundColor(isDark),
            contentPadding: const EdgeInsets.all(16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _getBorderColor(isDark)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: _getBorderColor(isDark)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  /// Campo de anexos
  Widget _buildAttachmentsField(bool isDark) {
    final userId = SupabaseService.client.auth.currentUser?.id ?? '';

    return AttachmentsWidget(
      attachments: _attachments,
      userId: userId,
      transactionId: _tempTransactionId,
      isDark: isDark,
      onAttachmentsChanged: (updatedAttachments) {
        setState(() {
          _attachments = updatedAttachments;
        });
        _checkForChanges();
      },
    );
  }

  /// Campo de data melhorado com tema dinâmico
  Widget _buildDateField(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.calendar_today_outlined, size: 18, color: _getSecondaryColor(isDark)),
            const SizedBox(width: 8),
            Text(
              'Data',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _getLabelColor(isDark),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectDate,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: _getBackgroundColor(isDark),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: _getBorderColor(isDark)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy', 'pt_BR').format(_selectedDate),
                  style: TextStyle(
                    fontSize: 16,
                    color: _getLabelColor(isDark),
                  ),
                ),
                const Icon(
                  Icons.calendar_month,
                  color: AppColors.primary,
                  size: 22,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Botão submit redesenhado com elevação
  Widget _buildSubmitButton(bool isEditing, bool isDark) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTransaction,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    isEditing ? 'Salvar Alterações' : 'Adicionar Transação',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final isDark = ref.read(themeProvider) == ThemeMode.dark;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: isDark
              ? ThemeData.dark().copyWith(
                  colorScheme: const ColorScheme.dark(
                    primary: AppColors.primary,
                    surface: Color(0xFF1E1E1E),
                  ),
                )
              : ThemeData.light().copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: AppColors.primary,
                    surface: Colors.white,
                  ),
                ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _checkForChanges();
    }
  }

  /// Solicita categorização automática via IA
  Future<void> _requestAICategorization() async {
    // Validações
    if (_descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Digite uma descrição para usar a IA'),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    final amount = _getAmountValue();
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.white),
              SizedBox(width: 12),
              Text('Digite um valor válido para usar a IA'),
            ],
          ),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    setState(() {
      _isAILoading = true;
      _aiSuggestedCategory = null;
      _aiConfidence = null;
      _aiReasoning = null;
    });

    try {
      final aiService = ref.read(aiServiceProvider);
      final userId = SupabaseService.client.auth.currentUser!.id;

      final response = await aiService.categorizeTransaction(
        description: _descriptionController.text,
        amount: amount,
        type: _type,
        userId: userId,
      );

      if (mounted) {
        setState(() {
          _aiSuggestedCategory = response.category;
          _aiConfidence = response.confidence;
          _aiReasoning = response.reasoning;
          _category = response.category;
        });
        _checkForChanges();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '✨ ${response.category} (${(response.confidence * 100).toStringAsFixed(0)}% confiança)',
                  ),
                ),
              ],
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro ao usar IA: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isAILoading = false;
        });
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _isSaving = true;
    });

    try {
      final amount = _getAmountValue();
      if (amount == null || amount <= 0) {
        setState(() {
          _amountError = 'Informe um valor válido';
          _isLoading = false;
        });
        return;
      }

      final userId = SupabaseService.client.auth.currentUser!.id;

      final transaction = TransactionModel(
        id: _existingTransactionId ?? _tempTransactionId,
        userId: userId,
        amount: amount,
        type: _type,
        category: _category,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        account: _selectedAccount, // Salvar conta/banco
        date: _selectedDate,
        source: 'manual',
        suggestedCategory: _aiSuggestedCategory,
        categoryConfidence: _aiConfidence,
        categoryConfirmed: _aiSuggestedCategory != null && _category == _aiSuggestedCategory,
        attachments: _attachments.isEmpty ? null : _attachments, // Salvar anexos
        createdAt: _existingCreatedAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // LOG: Antes de salvar
      print('🔵 [AddTransactionPage] Salvando transação:');
      print('  - ID: ${transaction.id}');
      print('  - Type: ${transaction.type}');
      print('  - Amount: ${transaction.amount}');
      print('  - Category: ${transaction.category}');
      print('  - Account: ${transaction.account}');
      print('  - Description: ${transaction.description}');
      print('  - Date: ${transaction.date}');
      print('  - Is Update: ${widget.transactionId != null}');
      print('  - toJson: ${transaction.toJson()}');

      final bool success;
      if (widget.transactionId != null) {
        print('🔵 [AddTransactionPage] Chamando updateTransaction...');
        success = await ref
            .read(transactionsListProvider.notifier)
            .updateTransaction(transaction);
      } else {
        print('🔵 [AddTransactionPage] Chamando createTransaction...');
        success = await ref
            .read(transactionsListProvider.notifier)
            .createTransaction(transaction);
      }

      print('🔵 [AddTransactionPage] Resultado: ${success ? "SUCESSO" : "FALHA"}');

      if (mounted) {
        if (success) {
          // Resetar flag de mudanças não salvas
          setState(() {
            _hasUnsavedChanges = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Text(
                    widget.transactionId != null
                        ? '✅ Transação atualizada com sucesso!'
                        : '✅ Transação adicionada com sucesso!',
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 12),
                  Text('Erro ao salvar transação'),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erro: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSaving = false;
        });
      }
    }
  }
}
