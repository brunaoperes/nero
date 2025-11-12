import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../../../shared/models/bank_account_model.dart';
import '../providers/transaction_providers.dart';
import '../providers/bank_account_providers.dart';
import '../widgets/attachments_widget.dart';
import '../widgets/numeric_keyboard.dart';
import '../widgets/transaction_suggestions_overlay.dart';
import '../widgets/category_picker_modal.dart';
import '../widgets/account_picker_modal.dart';
import '../widgets/status_joia_indicator.dart';
import '../../domain/models/transaction_suggestion_model.dart';

/// Página de Nova Transação - Redesign modelo Organize
class AddTransactionPageNew extends ConsumerStatefulWidget {
  final String? transactionId;

  const AddTransactionPageNew({
    super.key,
    this.transactionId,
  });

  @override
  ConsumerState<AddTransactionPageNew> createState() =>
      _AddTransactionPageNewState();
}

class _AddTransactionPageNewState extends ConsumerState<AddTransactionPageNew> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _observationController = TextEditingController();
  final _descriptionFocusNode = FocusNode();
  final _observationFocusNode = FocusNode();

  // Estado
  String _type = 'expense'; // expense, income, transfer
  String _amountText = '';
  String? _category;
  bool _showNumericKeyboard = true; // Controla visibilidade do teclado numérico

  // Categorias separadas por tipo (preservar estado ao trocar)
  String? _categoryExpense;
  String? _categoryIncome;

  String? _selectedAccount;
  String? _destinationAccount; // Para transferências
  DateTime _selectedDate = DateTime.now();
  List<String> _attachments = [];
  bool _isLoading = false;

  // Status de pagamento (Joia - Pago/Não pago)
  bool _isPaid = true; // Padrão: Pago (joia para cima)
  DateTime? _paidAt; // Data efetiva do pagamento

  // Dados da transação existente (para edição)
  String? _existingTransactionId;
  DateTime? _existingCreatedAt;
  String? _existingTransferId;

  // ID temporário para anexos
  late String _tempTransactionId;

  // Controle de mudanças não salvas
  bool _hasUnsavedChanges = false;
  bool _isSaving = false;

  // Snapshot do estado inicial para comparação
  Map<String, dynamic>? _initialSnapshot;

  // Autopreenchimento inteligente
  TransactionModel? _suggestedTransaction;
  Timer? _descriptionDebouncer;
  Timer? _overlayCloseTimer;
  OverlayEntry? _suggestionsOverlay;
  final LayerLink _layerLink = LayerLink();
  List<TransactionSuggestion> _currentSuggestions = [];
  bool _isApplyingSuggestion = false; // Flag para evitar loop ao aplicar sugestão

  @override
  void initState() {
    super.initState();
    _tempTransactionId = widget.transactionId ?? const Uuid().v4();

    _descriptionController.addListener(_checkForChanges);
    _descriptionController.addListener(_onDescriptionChanged);
    _observationController.addListener(_checkForChanges);

    // Listeners de foco para controlar teclado
    _descriptionFocusNode.addListener(_onDescriptionFocusChange);
    _observationFocusNode.addListener(_onObservationFocusChange);

    if (widget.transactionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadTransaction();
      });
    } else {
      // Para nova transação, criar snapshot do estado vazio
      _createSnapshot();
    }
  }

  @override
  void dispose() {
    _descriptionDebouncer?.cancel();
    _overlayCloseTimer?.cancel();
    _hideOverlay();
    _descriptionController.dispose();
    _observationController.dispose();
    _descriptionFocusNode.dispose();
    _observationFocusNode.dispose();
    super.dispose();
  }

  /// Cria snapshot do estado atual para comparação futura
  void _createSnapshot() {
    _initialSnapshot = {
      'type': _type,
      'amountText': _amountText,
      'isPaid': _isPaid,
      'category': _category,
      'selectedAccount': _selectedAccount,
      'destinationAccount': _destinationAccount,
      'selectedDate': _selectedDate.toIso8601String(),
      'description': _descriptionController.text,
      'observation': _observationController.text,
      'attachments': List<String>.from(_attachments),
    };
  }

  /// Normaliza string removendo espaços extras
  String _normalizeString(String? str) {
    return (str ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  /// Verifica se há alterações reais em relação ao estado inicial
  bool get _isDirty {
    // Se snapshot ainda não foi criado, não há mudanças
    if (_initialSnapshot == null) return false;

    // Comparar cada campo com normalização
    if (_type != _initialSnapshot!['type']) return true;
    if (_amountText != _initialSnapshot!['amountText']) return true;
    if (_isPaid != _initialSnapshot!['isPaid']) return true;
    if (_category != _initialSnapshot!['category']) return true;
    if (_selectedAccount != _initialSnapshot!['selectedAccount']) return true;
    if (_destinationAccount != _initialSnapshot!['destinationAccount']) return true;
    if (_selectedDate.toIso8601String() != _initialSnapshot!['selectedDate']) return true;

    // Comparar strings normalizadas
    if (_normalizeString(_descriptionController.text) !=
        _normalizeString(_initialSnapshot!['description'] as String?)) return true;
    if (_normalizeString(_observationController.text) !=
        _normalizeString(_initialSnapshot!['observation'] as String?)) return true;

    // Comparar anexos
    final currentAttachments = _attachments.toSet();
    final initialAttachments = (_initialSnapshot!['attachments'] as List<String>).toSet();
    if (!currentAttachments.containsAll(initialAttachments) ||
        !initialAttachments.containsAll(currentAttachments)) return true;

    return false;
  }

  /// Listener de foco do campo Descrição
  void _onDescriptionFocusChange() {
    debugPrint('👁️ [FOCO] hasFocus=${_descriptionFocusNode.hasFocus}');

    if (_descriptionFocusNode.hasFocus) {
      // Quando descrição recebe foco, cancelar timer de fechamento e esconder teclado numérico
      _overlayCloseTimer?.cancel();
      setState(() {
        _showNumericKeyboard = false;
      });
    } else {
      // Quando descrição perde foco, usar um delay para não fechar
      // se foi apenas um evento temporário (ex: inserção do overlay)
      _overlayCloseTimer?.cancel();
      _overlayCloseTimer = Timer(const Duration(milliseconds: 150), () {
        if (!_descriptionFocusNode.hasFocus && mounted) {
          debugPrint('👁️ [FOCO] Perdeu foco definitivamente, fechando overlay');
          _hideOverlay();
        }
      });
    }
  }

  /// Listener de foco do campo Observação
  void _onObservationFocusChange() {
    if (_observationFocusNode.hasFocus) {
      // Quando observação recebe foco, esconder teclado numérico e overlay
      _hideOverlay();
      setState(() {
        _showNumericKeyboard = false;
      });
    }
  }

  /// Mostra o teclado numérico e remove foco de outros campos
  void _showNumericKeyboardAndUnfocus() {
    // Esconder overlay de sugestões
    _hideOverlay();

    // Remover foco de todos os campos
    _descriptionFocusNode.unfocus();
    _observationFocusNode.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();

    // Mostrar teclado numérico
    setState(() {
      _showNumericKeyboard = true;
    });
  }

  /// Esconde o teclado numérico
  void _hideNumericKeyboard() {
    setState(() {
      _showNumericKeyboard = false;
    });
  }

  void _checkForChanges() {
    // Não faz nada - usamos _isDirty para verificar alterações
    // Mantido para manter compatibilidade com listeners existentes
  }

  /// Alterna status de pagamento (Pago ⇄ Não pago)
  void _togglePaidStatus() {
    setState(() {
      _isPaid = !_isPaid;

      // Atualizar paidAt conforme o novo status
      if (_isPaid) {
        _paidAt = DateTime.now();
      } else {
        _paidAt = null;
      }

      _checkForChanges();
    });

    // Feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isPaid ? 'Marcado como pago' : 'Marcado como não pago',
          style: const TextStyle(fontSize: 14),
        ),
        duration: const Duration(milliseconds: 1500),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.only(bottom: 60, left: 16, right: 16),
      ),
    );
  }

  /// Salva a categoria atual no estado específico do tipo
  void _saveCurrentCategory() {
    if (_type == 'expense') {
      _categoryExpense = _category;
    } else if (_type == 'income') {
      _categoryIncome = _category;
    }
  }

  /// Restaura a categoria do novo tipo selecionado
  void _restoreCategoryForType(String newType) {
    if (newType == 'expense') {
      _category = _categoryExpense;
    } else if (newType == 'income') {
      _category = _categoryIncome;
    } else if (newType == 'transfer') {
      _category = null; // Transferências não têm categoria
    }
  }

  /// Troca o tipo de transação preservando as categorias
  void _changeType(String newType) {
    if (_type == newType) return;

    debugPrint('🔄 [TIPO] Trocando tipo de $_type para $newType');

    // 1. Limpar completamente o estado de sugestões (evitar "memória fantasma")
    _hideOverlay();
    _currentSuggestions = [];
    _descriptionDebouncer?.cancel();

    setState(() {
      // 2. Salvar a categoria atual no estado do tipo atual
      _saveCurrentCategory();

      // 3. Trocar o tipo
      _type = newType;

      // 4. Restaurar a categoria do novo tipo
      _restoreCategoryForType(newType);

      // 5. Transferências são sempre pagas
      if (newType == 'transfer') {
        _isPaid = true;
      }

      _checkForChanges();
    });

    // 6. Recalcular sugestões SOMENTE se o campo descrição tiver foco E texto válido
    final query = _descriptionController.text.trim();
    if (_descriptionFocusNode.hasFocus && query.length >= 2) {
      debugPrint('🔄 [TIPO] Campo com foco e texto válido, recalculando sugestões para: $newType');
      _descriptionDebouncer = Timer(const Duration(milliseconds: 200), () async {
        await _searchForSimilarTransaction(query);
      });
    } else {
      debugPrint('🔄 [TIPO] Campo sem foco ou texto insuficiente, não recalcula sugestões');
    }
  }

  /// Listener do campo de descrição com debounce (200ms)
  void _onDescriptionChanged() {
    // Skip se estamos aplicando uma sugestão programaticamente (evita loop infinito)
    if (_isApplyingSuggestion) {
      debugPrint('🟠 [DESCRIÇÃO] Skip - aplicando sugestão');
      return;
    }

    // Limpar estado de seleção anterior ao editar (evita memória fantasma)
    if (_currentSuggestions.isNotEmpty) {
      debugPrint('🔄 [DESCRIÇÃO] Texto editado, limpando estado de seleção anterior');
    }

    // Cancelar timer anterior
    _descriptionDebouncer?.cancel();

    final query = _descriptionController.text.trim();

    // Se query vazia, esconder overlay
    if (query.isEmpty) {
      _hideOverlay();
      _currentSuggestions = [];
      return;
    }

    // Criar novo timer (200ms de espera - conforme spec)
    _descriptionDebouncer = Timer(const Duration(milliseconds: 200), () async {
      debugPrint('🔍 [BUSCA] Buscando sugestões para: "$query" (tipo: $_type)');
      await _searchForSimilarTransaction(query);
    });
  }

  /// Busca transações com descrição similar usando busca fuzzy
  Future<void> _searchForSimilarTransaction(String query) async {
    // Só em modo de criação (não em edição)
    if (widget.transactionId != null) {
      return;
    }

    // Só buscar se tiver ao menos 2 caracteres
    if (query.length < 2) {
      _hideOverlay();
      return;
    }

    try {
      // Buscar sugestões usando o repositório, filtrando por tipo atual
      final repository = ref.read(transactionSuggestionsRepositoryProvider);
      final suggestions = await repository.searchSuggestions(query, type: _type);

      debugPrint('✅ [BUSCA] Encontradas ${suggestions.length} sugestões para "$query" (tipo: $_type)');
      if (suggestions.isNotEmpty) {
        debugPrint('   📋 Sugestões: ${suggestions.map((s) => s.description).join(", ")}');
      }

      _currentSuggestions = suggestions;

      // Mostrar overlay se houver sugestões
      if (mounted && suggestions.isNotEmpty) {
        _showOverlay();
      } else if (mounted) {
        _hideOverlay();
      }
    } catch (e) {
      debugPrint('❌ [ERRO] Erro ao buscar sugestões: $e');
      _hideOverlay();
    }
  }

  /// Mostra o overlay de sugestões
  void _showOverlay() {
    // Cancelar qualquer timer de fechamento pendente
    _overlayCloseTimer?.cancel();

    // Remover overlay anterior se existir
    _hideOverlay();

    debugPrint('🔵 [OVERLAY] Mostrando overlay com ${_currentSuggestions.length} sugestões');

    _suggestionsOverlay = OverlayEntry(
      builder: (context) => Positioned(
        width: MediaQuery.of(context).size.width - 32, // Mesma largura do TextField
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: const Offset(0, 56), // Abaixo do TextField
          child: TransactionSuggestionsOverlay(
            suggestions: _currentSuggestions,
            currentQuery: _descriptionController.text.trim(),
            onSuggestionSelected: _applySuggestion,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_suggestionsOverlay!);
    debugPrint('🔵 [OVERLAY] Overlay inserido no contexto');
  }

  /// Esconde o overlay de sugestões
  void _hideOverlay() {
    if (_suggestionsOverlay != null) {
      debugPrint('🔴 [OVERLAY] Escondendo overlay');
    }
    _suggestionsOverlay?.remove();
    _suggestionsOverlay = null;
  }

  /// Aplica uma sugestão selecionada
  void _applySuggestion(TransactionSuggestion suggestion, {bool includeAmount = false}) {
    debugPrint('🟢 [SUGESTÃO] Aplicando sugestão: ${suggestion.description}');
    debugPrint('🟢 [SUGESTÃO] includeAmount: $includeAmount');

    // Flag para evitar loop infinito (antes de mudar o texto)
    _isApplyingSuggestion = true;
    _hideOverlay();

    setState(() {
      // Preencher campos (EXCETO data que mantém a atual)
      _descriptionController.text = suggestion.description;
      _category = suggestion.category;
      _selectedAccount = suggestion.account;
      _isPaid = suggestion.paymentStatus == 'paid';

      debugPrint('🟢 [SUGESTÃO] Categoria: ${suggestion.category}');
      debugPrint('🟢 [SUGESTÃO] Conta: ${suggestion.account}');
      debugPrint('🟢 [SUGESTÃO] Status: ${suggestion.paymentStatus}');

      // Preencher valor se solicitado
      if (includeAmount && suggestion.lastAmount != null && suggestion.lastAmount! > 0) {
        _amountText = (suggestion.lastAmount! * 100).toInt().toString();
        debugPrint('🟢 [SUGESTÃO] Valor preenchido: ${suggestion.lastAmount}');
      }

      // Salvar categoria no estado específico do tipo (assumindo que mantém o tipo atual)
      if (_type == 'expense') {
        _categoryExpense = suggestion.category;
      } else if (_type == 'income') {
        _categoryIncome = suggestion.category;
      }

      _checkForChanges();
    });

    // Resetar flag após o frame (para permitir busca novamente quando usuário digitar)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _isApplyingSuggestion = false;
      debugPrint('🟠 [DESCRIÇÃO] Flag resetada - pode buscar novamente');
    });

    // Feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(includeAmount
            ? 'Campos preenchidos com valor anterior'
            : 'Campos preenchidos (exceto valor)'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.success,
      ),
    );

    debugPrint('🟢 [SUGESTÃO] Sugestão aplicada com sucesso!');

    // Focar no próximo campo (valor ou categoria)
    if (!includeAmount) {
      _showNumericKeyboard = true;
    }
  }

  /// Aplica os dados da transação sugerida (método antigo - manter por compatibilidade)
  void _applyPreviousTransaction() {
    if (_suggestedTransaction == null) return;

    final suggestion = _suggestedTransaction!;

    setState(() {
      // Preencher campos (EXCETO descrição que já está preenchida e data)
      _type = suggestion.type;
      _category = suggestion.category;
      _selectedAccount = suggestion.account;
      _destinationAccount = suggestion.destinationAccount;
      _isPaid = suggestion.paymentStatus == 'paid';

      // Preencher valor
      if (suggestion.amount > 0) {
        _amountText = (suggestion.amount * 100).toInt().toString();
      }

      // Salvar categoria no estado específico do tipo
      if (suggestion.type == 'expense') {
        _categoryExpense = suggestion.category;
      } else if (suggestion.type == 'income') {
        _categoryIncome = suggestion.category;
      }

      // Limpar sugestão após aplicar
      _suggestedTransaction = null;

      _checkForChanges();
    });

    // Feedback visual
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Campos preenchidos com base na transação anterior'),
        duration: Duration(seconds: 2),
        backgroundColor: AppColors.success,
      ),
    );
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
          _existingTransferId = transaction.transferId;
          _type = transaction.type;
          _category = transaction.category;

          // Salvar categoria no estado específico do tipo
          if (transaction.type == 'expense') {
            _categoryExpense = transaction.category;
          } else if (transaction.type == 'income') {
            _categoryIncome = transaction.category;
          }

          _amountText = (transaction.amount * 100).toInt().toString();
          _descriptionController.text = transaction.description ?? '';
          _selectedAccount = transaction.account;
          _destinationAccount = transaction.destinationAccount;
          _selectedDate = transaction.date ?? DateTime.now();
          _isPaid = transaction.isPaid;
          _paidAt = transaction.paidAt;
          _attachments = transaction.attachments ?? [];
        });

        // Criar snapshot após carregar dados
        _createSnapshot();
      } catch (e) {
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

  double get _amount {
    if (_amountText.isEmpty) return 0.0;
    return int.parse(_amountText) / 100.0;
  }

  String get _formattedAmount {
    if (_amountText.isEmpty) return 'R\$ 0,00';
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');
    return formatter.format(_amount);
  }

  /// Verifica se é possível salvar a transação
  bool _canSave() {
    // Valor deve ser maior que 0
    if (_amount <= 0) return false;

    // Descrição não pode estar vazia
    if (_descriptionController.text.trim().isEmpty) return false;

    // Categoria obrigatória para despesas e receitas
    if (_type != 'transfer' && _category == null) return false;

    // Conta obrigatória
    if (_selectedAccount == null) return false;

    // Para transferências, conta de destino obrigatória
    if (_type == 'transfer' && _destinationAccount == null) return false;

    // Para transferências, contas devem ser diferentes
    if (_type == 'transfer' && _selectedAccount == _destinationAccount) return false;

    return true;
  }

  /// Retorna o ícone do banco baseado no iconKey
  IconData _getBankIcon(String? iconKey) {
    if (iconKey == null || iconKey.isEmpty) {
      return Icons.account_balance_wallet;
    }

    switch (iconKey.toLowerCase()) {
      case 'nubank':
        return Icons.account_balance;
      case 'inter':
        return Icons.account_balance;
      case 'itau':
        return Icons.account_balance;
      case 'bradesco':
        return Icons.account_balance;
      case 'santander':
        return Icons.account_balance;
      case 'caixa':
        return Icons.account_balance;
      case 'bb':
      case 'banco_do_brasil':
        return Icons.account_balance;
      case 'picpay':
        return Icons.account_balance_wallet;
      case 'mercadopago':
        return Icons.account_balance_wallet;
      case 'cash':
      case 'dinheiro':
        return Icons.payments;
      case 'credit':
      case 'credito':
        return Icons.credit_card;
      default:
        return Icons.account_balance_wallet;
    }
  }

  /// Retorna a cor do banco baseado no iconKey ou color personalizado
  Color _getBankColor(BankAccountModel account) {
    // Se tem cor personalizada, usar ela
    if (account.color != null && account.color!.isNotEmpty) {
      try {
        return Color(int.parse(account.color!.replaceFirst('#', '0xFF')));
      } catch (_) {
        // Se falhar ao parsear, usar cor padrão baseada no iconKey
      }
    }

    // Verificar se iconKey não é null ou vazio
    if (account.iconKey == null || account.iconKey.isEmpty) {
      return AppColors.primary;
    }

    // Cores padrão baseadas no banco
    switch (account.iconKey.toLowerCase()) {
      case 'nubank':
        return const Color(0xFF820AD1);
      case 'inter':
        return const Color(0xFFFF7A00);
      case 'itau':
        return const Color(0xFF0B4C8C);
      case 'bradesco':
        return const Color(0xFFCC092F);
      case 'santander':
        return const Color(0xFFEC0000);
      case 'caixa':
        return const Color(0xFF0066A1);
      case 'bb':
      case 'banco_do_brasil':
        return const Color(0xFFFEDD00);
      case 'picpay':
        return const Color(0xFF21C25E);
      case 'mercadopago':
        return const Color(0xFF009EE3);
      case 'cash':
      case 'dinheiro':
        return const Color(0xFF4CAF50);
      case 'credit':
      case 'credito':
        return const Color(0xFF9C27B0);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.transactionId != null;

    return PopScope(
      canPop: !_isDirty || _isSaving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        if (_isDirty && !_isSaving) {
          final shouldPop = await _showUnsavedChangesDialog();
          if (shouldPop == true && context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leadingWidth: 64,
          leading: Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (_isDirty && !_isSaving) {
                    final shouldPop = await _showUnsavedChangesDialog();
                    if (shouldPop == true && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                borderRadius: BorderRadius.circular(22),
                child: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.close_rounded,
                    color: Color(0xFF1C1C1C),
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
          title: Text(
            isEditing ? 'Editar Transação' : 'Nova Transação',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF212121),
            ),
          ),
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : ElevatedButton(
                      onPressed: _canSave() ? _saveTransaction : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: AppColors.primary.withOpacity(0.4),
                        foregroundColor: Colors.white,
                        disabledForegroundColor: Colors.white.withOpacity(0.4),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        'Salvar',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
            ),
          ],
        ),
        body: Column(
          children: [
            // Barra de tipo (Despesa/Receita/Transferência)
            _buildTypeSelector(),

            // Conteúdo rolável
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Campo de valor grande
                    _buildValueField(),
                    const SizedBox(height: 24),

                    // Descrição
                    _buildDescriptionField(),
                    const SizedBox(height: 16),

                    // Categoria (apenas se não for transferência)
                    if (_type != 'transfer') ...[
                      _buildCategoryField(),
                      const SizedBox(height: 16),
                    ],

                    // Conta de origem / Conta (sempre presente)
                    _buildAccountField(),
                    const SizedBox(height: 16),

                    // Conta de destino (apenas para transferências)
                    if (_type == 'transfer') ...[
                      _buildDestinationAccountField(),
                      const SizedBox(height: 16),
                    ],

                    // Data
                    _buildDateField(),
                    const SizedBox(height: 16),

                    // Observação
                    _buildObservationField(),
                    const SizedBox(height: 16),

                    // Anexos
                    _buildAttachmentsField(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),

            // Teclado numérico (condicional)
            if (_showNumericKeyboard)
              NumericKeyboard(
                onKeyTap: (key) {
                  setState(() {
                    _amountText += key;
                    _checkForChanges();
                  });
                },
                onBackspace: () {
                  if (_amountText.isNotEmpty) {
                    setState(() {
                      _amountText = _amountText.substring(0, _amountText.length - 1);
                      _checkForChanges();
                    });
                  }
                },
                onClear: () {
                  setState(() {
                    _amountText = '';
                    _checkForChanges();
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Barra de seleção de tipo
  Widget _buildTypeSelector() {
    return Container(
      height: 48,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildTypeTab('Despesa', 'expense', AppColors.error),
          _buildTypeTab('Receita', 'income', AppColors.success),
          _buildTypeTab('Transferência', 'transfer', AppColors.primary),
        ],
      ),
    );
  }

  Widget _buildTypeTab(String label, String value, Color color) {
    final isSelected = _type == value;

    return Expanded(
      child: InkWell(
        onTap: () => _changeType(value),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? color : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? color : const Color(0xFF757575),
            ),
          ),
        ),
      ),
    );
  }

  /// Campo de valor grande e centralizado
  Widget _buildValueField() {
    // Definir cor do valor baseado no tipo e status
    Color valueColor;
    if (_type == 'expense') {
      valueColor = AppColors.error;
    } else if (_type == 'income') {
      valueColor = AppColors.success;
    } else {
      valueColor = AppColors.primary;
    }

    // Aplicar opacidade se estiver pendente
    if (!_isPaid && _type != 'transfer') {
      valueColor = valueColor.withOpacity(0.7);
    }

    return GestureDetector(
      onTap: _showNumericKeyboardAndUnfocus,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Valor
            Text(
              _formattedAmount,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w700,
                color: valueColor,
              ),
            ),
            const SizedBox(width: 16),

            // Indicador de pagamento (joia)
            StatusJoiaIndicator(
              isPaid: _isPaid,
              onToggle: _togglePaidStatus,
              type: _type,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionField() {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _descriptionController,
            focusNode: _descriptionFocusNode,
            keyboardType: TextInputType.text,
            textInputAction: TextInputAction.next,
            onTap: () {
            // Garantir que o teclado numérico seja escondido
            setState(() {
              _showNumericKeyboard = false;
            });
          },
          onFieldSubmitted: (value) {
            // Fechar overlay ao pressionar Enter/Done
            _hideOverlay();
          },
          decoration: const InputDecoration(
            labelText: 'Descrição',
            hintText: 'Ex: Supermercado',
            filled: true,
            fillColor: Color(0xFFF5F5F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          style: const TextStyle(fontSize: 16),
        ),
        // Sugestão de autopreenchimento
        if (_suggestedTransaction != null) ...[
          const SizedBox(height: 8),
          _buildSuggestionChip(),
        ],
      ],
      ),
    );
  }

  /// Widget de sugestão de autopreenchimento
  Widget _buildSuggestionChip() {
    if (_suggestedTransaction == null) return const SizedBox.shrink();

    final suggestion = _suggestedTransaction!;
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');

    return InkWell(
      onTap: _applyPreviousTransaction,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: AppColors.primary.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.lightbulb_outline,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Preencher com base em transação anterior',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatter.format(suggestion.amount)} • ${suggestion.category ?? 'Sem categoria'} • ${suggestion.account ?? 'Sem conta'}',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward,
              color: AppColors.primary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryField() {
    // Garantir que não há categorias duplicadas
    final categories = _type == 'expense'
        ? AppConstants.expenseCategories
        : AppConstants.incomeCategories;
    final uniqueCategories = categories.toSet().toList();

    // Se a categoria atual não está na lista, limpar
    if (_category != null && !uniqueCategories.contains(_category)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _category = null;
          });
        }
      });
    }

    // OPÇÃO C: Campo clicável que abre modal premium
    return GestureDetector(
      onTap: () {
        // Fechar teclados antes de abrir modal
        _hideOverlay();
        FocusManager.instance.primaryFocus?.unfocus();
        _hideNumericKeyboard();

        // Abrir modal de seleção
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => CategoryPickerModal(
            selectedCategory: _category,
            categories: uniqueCategories,
            getCategoryColor: _getCategoryColor,
            getCategoryIcon: safeCategoryIcon,
            onCategorySelected: (category) {
              setState(() {
                _category = category;

                // Salvar no estado específico do tipo atual
                if (_type == 'expense') {
                  _categoryExpense = category;
                } else if (_type == 'income') {
                  _categoryIncome = category;
                }

                _checkForChanges();
              });
            },
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Ícone
            Icon(
              safeCategoryIcon(_category),
              color: _getCategoryColor(_category),
              size: 24,
            ),
            const SizedBox(width: 12),
            // Texto
            Expanded(
              child: Text(
                _category ?? 'Selecionar categoria',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: _category != null ? const Color(0xFF1C1C1C) : const Color(0xFF9E9E9E),
                ),
              ),
            ),
            // Seta
            const Icon(
              Icons.arrow_drop_down,
              color: Color(0xFF9E9E9E),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountField() {
    final bankAccountsAsync = ref.watch(bankAccountsListProvider);

    return bankAccountsAsync.when(
      data: (accounts) {
        // Encontrar conta selecionada para pegar o iconKey
        final selectedAccountObj = _selectedAccount != null
            ? accounts.firstWhere(
                (a) => a.name == _selectedAccount,
                orElse: () => accounts.first,
              )
            : null;

        // OPÇÃO C: Campo clicável que abre modal premium
        return GestureDetector(
          onTap: () {
            // Fechar teclados antes de abrir modal
            _hideOverlay();
            FocusManager.instance.primaryFocus?.unfocus();
            _hideNumericKeyboard();

            // Abrir modal de seleção
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AccountPickerModal(
                selectedAccountName: _selectedAccount,
                accounts: accounts,
                getBankColor: _getBankColor,
                getBankIcon: safeAccountIcon,
                title: _type == 'transfer' ? 'Conta de Origem' : 'Selecionar Conta',
                onAccountSelected: (accountName) {
                  setState(() {
                    _selectedAccount = accountName;
                    _checkForChanges();
                  });
                },
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Ícone
                if (selectedAccountObj != null)
                  Icon(
                    safeAccountIcon(selectedAccountObj.iconKey),
                    color: _getBankColor(selectedAccountObj),
                    size: 24,
                  )
                else
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Color(0xFF9E9E9E),
                    size: 24,
                  ),
                const SizedBox(width: 12),
                // Texto
                Expanded(
                  child: Text(
                    _selectedAccount ?? 'Selecionar conta',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _selectedAccount != null ? const Color(0xFF1C1C1C) : const Color(0xFF9E9E9E),
                    ),
                  ),
                ),
                // Seta
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF9E9E9E),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Erro ao carregar contas'),
    );
  }

  Widget _buildDestinationAccountField() {
    final bankAccountsAsync = ref.watch(bankAccountsListProvider);

    return bankAccountsAsync.when(
      data: (accounts) {
        // Encontrar conta destino selecionada para pegar o iconKey
        final selectedDestAccountObj = _destinationAccount != null
            ? accounts.firstWhere(
                (a) => a.name == _destinationAccount,
                orElse: () => accounts.first,
              )
            : null;

        // OPÇÃO C: Campo clicável que abre modal premium
        return GestureDetector(
          onTap: () {
            // Fechar teclados antes de abrir modal
            _hideOverlay();
            FocusManager.instance.primaryFocus?.unfocus();
            _hideNumericKeyboard();

            // Abrir modal de seleção
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => AccountPickerModal(
                selectedAccountName: _destinationAccount,
                accounts: accounts,
                getBankColor: _getBankColor,
                getBankIcon: safeAccountIcon,
                title: 'Conta de Destino',
                onAccountSelected: (accountName) {
                  setState(() {
                    _destinationAccount = accountName;
                    _checkForChanges();
                  });
                },
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                // Ícone
                if (selectedDestAccountObj != null)
                  Icon(
                    safeAccountIcon(selectedDestAccountObj.iconKey),
                    color: _getBankColor(selectedDestAccountObj),
                    size: 24,
                  )
                else
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: Color(0xFF9E9E9E),
                    size: 24,
                  ),
                const SizedBox(width: 12),
                // Texto
                Expanded(
                  child: Text(
                    _destinationAccount ?? 'Selecionar conta de destino',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: _destinationAccount != null ? const Color(0xFF1C1C1C) : const Color(0xFF9E9E9E),
                    ),
                  ),
                ),
                // Seta
                const Icon(
                  Icons.arrow_drop_down,
                  color: Color(0xFF9E9E9E),
                ),
              ],
            ),
          ),
        );
      },
      loading: () => const CircularProgressIndicator(),
      error: (_, __) => const Text('Erro ao carregar contas'),
    );
  }

  Widget _buildDateField() {
    return InkWell(
      onTap: () {
        // Fechar todos os teclados e overlay antes de abrir o date picker
        _hideOverlay();
        FocusManager.instance.primaryFocus?.unfocus();
        _hideNumericKeyboard();
        _selectDate();
      },
      child: InputDecorator(
        decoration: const InputDecoration(
          labelText: 'Data',
          filled: true,
          fillColor: Color(0xFFF5F5F5),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd/MM/yyyy').format(_selectedDate),
              style: const TextStyle(fontSize: 16),
            ),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildObservationField() {
    return TextFormField(
      controller: _observationController,
      focusNode: _observationFocusNode,
      keyboardType: TextInputType.text,
      textInputAction: TextInputAction.done,
      maxLines: 3,
      onTap: () {
        // Garantir que o teclado numérico seja escondido
        setState(() {
          _showNumericKeyboard = false;
        });
      },
      decoration: const InputDecoration(
        labelText: 'Observação (opcional)',
        hintText: 'Adicione uma observação...',
        filled: true,
        fillColor: Color(0xFFF5F5F5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          borderSide: BorderSide.none,
        ),
        contentPadding: EdgeInsets.all(16),
      ),
      style: const TextStyle(fontSize: 14),
    );
  }

  Widget _buildAttachmentsField() {
    final userId = SupabaseService.client.auth.currentUser?.id ?? '';

    return AttachmentsWidget(
      attachments: _attachments,
      userId: userId,
      transactionId: _tempTransactionId,
      isDark: false,
      onAttachmentsChanged: (updated) {
        setState(() {
          _attachments = updated;
        });
        _checkForChanges();
      },
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _checkForChanges();
    }
  }

  Future<bool?> _showUnsavedChangesDialog() async {
    // Esconder overlay antes de mostrar o diálogo (evita sobreposição)
    _hideOverlay();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título
              Text(
                'Mudanças não salvas',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFFAFAFA) : const Color(0xFF111111),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),

              // Descrição
              Text(
                'Você fez alterações que ainda não foram salvas. Deseja salvar antes de sair?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFFBFBFBF) : const Color(0xFF5A5A5A),
                  height: 1.4,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 24),

              // Botões com fundos coloridos e equilibrados
              Row(
                children: [
                  // Cancelar
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF4F4F4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFFD3D3D3) : const Color(0xFF5A5A5A),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Cancelar',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Descartar
                  Expanded(
                    child: Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF3A1E1E) : const Color(0xFFFFF4F4),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark ? const Color(0xFFFF6F6F) : const Color(0xFFE53935),
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Inter',
                          ),
                          padding: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Descartar',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // Salvar (primário)
                  Expanded(
                    child: SizedBox(
                      height: 44,
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context, false);
                          await _saveTransaction();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark ? const Color(0xFF0D6EFD) : const Color(0xFF007BFF),
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Inter',
                          ),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'Salvar',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          ),
      ),
    );
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Informe um valor válido'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _isSaving = true;
    });

    try {
      final userId = SupabaseService.client.auth.currentUser!.id;

      // Se for transferência, criar duas movimentações
      if (_type == 'transfer') {
        await _createTransfer(userId);
      } else {
        // Transação normal
        final transaction = TransactionModel(
          id: _existingTransactionId ?? _tempTransactionId,
          userId: userId,
          amount: _amount,
          type: _type,
          category: _category,
          description: _descriptionController.text.isEmpty
              ? null
              : _descriptionController.text,
          account: _selectedAccount,
          date: _selectedDate,
          paymentStatus: _isPaid ? 'paid' : 'pending',
          isPaid: _isPaid,
          paidAt: _paidAt,
          source: 'manual',
          attachments: _attachments.isEmpty ? null : _attachments,
          createdAt: _existingCreatedAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        final bool success;
        if (widget.transactionId != null) {
          success = await ref
              .read(transactionsListProvider.notifier)
              .updateTransaction(transaction);
        } else {
          success = await ref
              .read(transactionsListProvider.notifier)
              .createTransaction(transaction);
        }

        if (mounted && success) {
          setState(() {
            _hasUnsavedChanges = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.transactionId != null
                    ? 'Transação atualizada com sucesso!'
                    : 'Transação criada com sucesso!',
              ),
              backgroundColor: AppColors.success,
            ),
          );
          Navigator.pop(context);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao salvar transação'),
              backgroundColor: AppColors.error,
            ),
          );
        }
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
        setState(() {
          _isLoading = false;
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _createTransfer(String userId) async {
    final transferId = _existingTransferId ?? const Uuid().v4();

    // Saída da conta de origem
    final outgoing = TransactionModel(
      id: _existingTransactionId ?? const Uuid().v4(),
      userId: userId,
      amount: _amount,
      type: 'transfer',
      description: _descriptionController.text.isEmpty
          ? 'Transferência para $_destinationAccount'
          : _descriptionController.text,
      account: _selectedAccount,
      destinationAccount: _destinationAccount,
      date: _selectedDate,
      paymentStatus: 'paid', // Transferências são sempre pagas
      isPaid: true, // Transferências são sempre pagas
      paidAt: DateTime.now(),
      source: 'manual',
      transferId: transferId,
      attachments: _attachments.isEmpty ? null : _attachments,
      createdAt: _existingCreatedAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Entrada na conta de destino
    final incoming = TransactionModel(
      id: const Uuid().v4(),
      userId: userId,
      amount: _amount,
      type: 'transfer',
      description: _descriptionController.text.isEmpty
          ? 'Transferência de $_selectedAccount'
          : _descriptionController.text,
      account: _destinationAccount,
      destinationAccount: _selectedAccount,
      date: _selectedDate,
      paymentStatus: 'paid',
      isPaid: true,
      paidAt: DateTime.now(),
      source: 'manual',
      transferId: transferId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    // Salvar ambas as transações
    final success1 = await ref
        .read(transactionsListProvider.notifier)
        .createTransaction(outgoing);

    final success2 = await ref
        .read(transactionsListProvider.notifier)
        .createTransaction(incoming);

    if (mounted && success1 && success2) {
      setState(() {
        _hasUnsavedChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Transferência realizada com sucesso!'),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao criar transferência'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  /// Retorna a cor da categoria baseada no nome
  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'alimentação':
      case 'alimentacao':
        return const Color(0xFFFF6B6B);
      case 'transporte':
        return const Color(0xFF4ECDC4);
      case 'moradia':
        return const Color(0xFF95E1D3);
      case 'saúde':
      case 'saude':
        return const Color(0xFFFF8B94);
      case 'educação':
      case 'educacao':
        return const Color(0xFF5F9DF7);
      case 'lazer':
        return const Color(0xFFFFA07A);
      case 'vestuário':
      case 'vestuario':
        return const Color(0xFFDDA15E);
      case 'salário':
      case 'salario':
        return const Color(0xFF06C46B);
      case 'freelance':
        return const Color(0xFF7B68EE);
      case 'investimentos':
        return const Color(0xFF20B2AA);
      case 'vendas':
        return const Color(0xFF32CD32);
      default:
        return AppColors.primary;
    }
  }

  /// Retorna o ícone da categoria baseada no nome
  IconData _getCategoryIcon(String? category) {
    switch (category?.toLowerCase()) {
      case 'alimentação':
      case 'alimentacao':
        return Icons.restaurant;
      case 'transporte':
        return Icons.directions_car;
      case 'moradia':
        return Icons.home;
      case 'saúde':
      case 'saude':
        return Icons.local_hospital;
      case 'educação':
      case 'educacao':
        return Icons.school;
      case 'lazer':
        return Icons.sports_esports;
      case 'vestuário':
      case 'vestuario':
        return Icons.shopping_bag;
      case 'salário':
      case 'salario':
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

  /// Retorna emoji para categoria (alternativa ao Icon widget para evitar conflitos de mouse tracking)
  String _getCategoryEmoji(String? category) {
    switch (category?.toLowerCase()) {
      case 'alimentação':
      case 'alimentacao':
        return '🍽️';
      case 'transporte':
        return '🚗';
      case 'moradia':
        return '🏠';
      case 'saúde':
      case 'saude':
        return '🏥';
      case 'educação':
      case 'educacao':
        return '📚';
      case 'lazer':
        return '🎮';
      case 'vestuário':
      case 'vestuario':
        return '👕';
      case 'salário':
      case 'salario':
        return '💰';
      case 'freelance':
        return '💼';
      case 'investimentos':
        return '📈';
      case 'vendas':
        return '🛒';
      default:
        return '📁';
    }
  }

  /// Retorna emoji para banco (alternativa ao Icon widget para evitar conflitos de mouse tracking)
  String _getBankEmoji(String? iconKey) {
    if (iconKey == null || iconKey.isEmpty) {
      return '💳';
    }

    switch (iconKey.toLowerCase()) {
      case 'nubank':
        return '🏦'; // Roxo do Nubank
      case 'inter':
        return '🟠'; // Laranja do Inter
      case 'itau':
        return '🔷'; // Azul do Itaú
      case 'bradesco':
        return '🔴'; // Vermelho do Bradesco
      case 'santander':
        return '🔺'; // Vermelho do Santander
      case 'caixa':
        return '🔵'; // Azul da Caixa
      case 'bb':
      case 'banco_do_brasil':
        return '🟡'; // Amarelo do BB
      case 'picpay':
        return '💚'; // Verde do PicPay
      case 'mercadopago':
        return '🔵'; // Azul do Mercado Pago
      case 'cash':
      case 'dinheiro':
        return '💵';
      case 'credit':
      case 'credito':
        return '💳';
      default:
        return '🏦';
    }
  }

  /// Ícone seguro para categoria (usado no prefixIcon - OPÇÃO A)
  /// Retorna IconData sem causar conflitos de mouse tracking
  IconData safeCategoryIcon(String? category) {
    if (category == null || category.isEmpty) {
      return Icons.label_rounded;
    }

    switch (category.toLowerCase()) {
      case 'alimentação':
      case 'alimentacao':
        return Icons.restaurant_rounded;
      case 'transporte':
        return Icons.directions_car_rounded;
      case 'moradia':
        return Icons.home_rounded;
      case 'saúde':
      case 'saude':
        return Icons.local_hospital_rounded;
      case 'educação':
      case 'educacao':
        return Icons.school_rounded;
      case 'lazer':
        return Icons.sports_esports_rounded;
      case 'vestuário':
      case 'vestuario':
        return Icons.shopping_bag_rounded;
      case 'salário':
      case 'salario':
        return Icons.attach_money_rounded;
      case 'freelance':
        return Icons.work_rounded;
      case 'investimentos':
        return Icons.trending_up_rounded;
      case 'vendas':
        return Icons.point_of_sale_rounded;
      default:
        return Icons.label_rounded;
    }
  }

  /// Ícone seguro para conta/banco (usado no prefixIcon - OPÇÃO A)
  /// Retorna IconData sem causar conflitos de mouse tracking
  IconData safeAccountIcon(String? iconKey) {
    if (iconKey == null || iconKey.isEmpty) {
      return Icons.account_balance_wallet_rounded;
    }

    switch (iconKey.toLowerCase()) {
      case 'nubank':
      case 'inter':
      case 'itau':
      case 'bradesco':
      case 'santander':
      case 'caixa':
      case 'bb':
      case 'banco_do_brasil':
        return Icons.account_balance_rounded;
      case 'picpay':
      case 'mercadopago':
        return Icons.account_balance_wallet_rounded;
      case 'cash':
      case 'dinheiro':
        return Icons.payments_rounded;
      case 'credit':
      case 'credito':
        return Icons.credit_card_rounded;
      default:
        return Icons.account_balance_wallet_rounded;
    }
  }
}
