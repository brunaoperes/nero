import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/utils/transaction_grouping_utils.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/services/balance_calculator_service.dart';
import '../../../../shared/models/transaction_model.dart';
import '../providers/transaction_providers.dart';
import '../providers/bank_account_providers.dart';
import '../../../ai/presentation/providers/ai_providers.dart';
import '../widgets/month_selector_widget.dart';
import '../widgets/time_filter_bottom_sheet.dart';
import '../widgets/dynamic_filter_header.dart';
import '../widgets/transaction_date_header.dart';
import '../widgets/swipeable_transaction_card.dart';
import '../../domain/models/time_filter_model.dart';
import '../../domain/models/transaction_group_model.dart';

/// Página de Finanças - Design moderno e clean
class TransactionsPage extends ConsumerStatefulWidget {
  final String? accountFilter;

  const TransactionsPage({super.key, this.accountFilter});

  @override
  ConsumerState<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends ConsumerState<TransactionsPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _animationController;
  String? _filterType;
  String? _filterAccount;
  DateTime _selectedMonth = DateTime.now();
  final bool _showAIAnalysis = true; // Ativado por padrão

  // Filtro temporal ativo (fonte da verdade)
  late FiltroTempo _filtroAtivo;

  // Controle de swipe: apenas um item aberto por vez
  final Map<String, GlobalKey<SwipeableTransactionCardState>> _swipeKeys = {};
  String? _openedSwipeId;

  @override
  void initState() {
    super.initState();
    _filterAccount = widget.accountFilter;
    _filtroAtivo = FiltroTempo.mes(_selectedMonth); // Inicializa com mês atual
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Exibe o menu de filtros de tempo
  void _showTimeFilterMenu() async {
    print('📅 [TransactionsPage] _showTimeFilterMenu() CHAMADO!');

    final result = await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return TimeFilterBottomSheet(
          filtroAtual: _filtroAtivo,
          onFiltroSelecionado: (novoFiltro) {
            print('📅 [TransactionsPage] Filtro selecionado: ${novoFiltro.tipo}');

            setState(() {
              _filtroAtivo = novoFiltro;

              // Atualizar o mês selecionado se for filtro de mês
              if (novoFiltro.tipo == IntervaloFiltro.mes) {
                _selectedMonth = novoFiltro.start;
              }
            });
          },
        );
      },
    );

    // Se o bottom sheet retornou sinal para abrir date picker
    if (result == '_open_date_picker' && mounted) {
      final range = await showDateRangePicker(
        context: context,
        firstDate: DateTime(2020),
        lastDate: DateTime.now().add(const Duration(days: 365)),
        initialDateRange: DateTimeRange(
          start: _filtroAtivo.start,
          end: _filtroAtivo.end,
        ),
      );

      // Processar resultado do date picker
      if (range != null && mounted) {
        // Ajustar para incluir o dia inteiro
        final start = DateTime(range.start.year, range.start.month, range.start.day);
        final end = DateTime(range.end.year, range.end.month, range.end.day, 23, 59, 59, 999, 999);

        setState(() {
          _filtroAtivo = FiltroTempo.personalizado(
            start: start,
            end: end,
          );
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final transactionsAsync = ref.watch(transactionsListProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        title: Text(
          'Finanças',
          style: TextStyle(
            color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF1C1C1C),
          ),
        ),
        centerTitle: false,
        iconTheme: IconThemeData(
          color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF1C1C1C),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilters,
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => context.push('/finance/reports'),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/finance/settings'),
            tooltip: 'Gerenciar Contas e Categorias',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(transactionsListProvider.notifier).loadTransactions();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card de Saldo com Gradiente
              _buildBalanceCard(),

              // Botão de Análise IA (opcional)
              if (_showAIAnalysis) _buildAIAnalysisButton(),

              const SizedBox(height: 16),

              // Header Dinâmico (muda conforme o filtro)
              DynamicFilterHeader(
                filtroAtivo: _filtroAtivo,
                onFiltroChanged: (novoFiltro) {
                  setState(() {
                    _filtroAtivo = novoFiltro;

                    // Atualizar o mês selecionado se for filtro de mês
                    if (novoFiltro.tipo == IntervaloFiltro.mes) {
                      _selectedMonth = novoFiltro.start;
                    }
                  });
                },
                onHeaderTap: _showTimeFilterMenu,
                backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                selectedColor: AppColors.primary,
              ),

              const SizedBox(height: 16),

              // Campo de Busca
              _buildSearchField(),

              const SizedBox(height: 16),

              // Chips de filtro ativo
              if (_filterAccount != null || _filterType != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (_filterAccount != null)
                        Chip(
                          label: Text('Conta: $_filterAccount'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _filterAccount = null;
                            });
                          },
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          labelStyle: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      if (_filterType != null)
                        Chip(
                          label: Text(_filterType == 'income' ? 'Receitas' : 'Despesas'),
                          deleteIcon: const Icon(Icons.close, size: 18),
                          onDeleted: () {
                            setState(() {
                              _filterType = null;
                            });
                          },
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          labelStyle: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _filterAccount = null;
                            _filterType = null;
                          });
                        },
                        icon: const Icon(Icons.clear_all, size: 16),
                        label: const Text('Limpar tudo'),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.error,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 16),

              // Título "Transações Recentes"
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Transações Recentes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : AppColors.lightText,
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Lista de Transações
              transactionsAsync.when(
                data: (transactions) {
                  // Aplicar filtros
                  var filteredTransactions = transactions;

                  // Filtrar por intervalo de tempo do filtro ativo (INCLUINDO transferências na lista)
                  filteredTransactions = filteredTransactions.where((t) {
                    final transactionDate = t.date ?? DateTime.now();
                    // Usar os limites do filtro ativo (start e end)
                    return transactionDate.isAfter(_filtroAtivo.start.subtract(const Duration(microseconds: 1))) &&
                           transactionDate.isBefore(_filtroAtivo.end.add(const Duration(microseconds: 1)));
                  }).toList();

                  // Filtrar por tipo
                  if (_filterType != null) {
                    filteredTransactions = filteredTransactions
                        .where((t) => t.type == _filterType)
                        .toList();
                  }

                  // Filtrar por conta
                  if (_filterAccount != null) {
                    filteredTransactions = filteredTransactions
                        .where((t) => t.account == _filterAccount)
                        .toList();
                  }

                  if (filteredTransactions.isEmpty) {
                    return _buildEmptyState();
                  }

                  // Agrupar transações por data
                  final groups = TransactionGroupingUtils.groupTransactionsByDate(filteredTransactions);

                  return _buildGroupedTransactionsList(groups);
                },
                loading: () => const Padding(
                  padding: const EdgeInsets.all(32),
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ),
                error: (error, stack) => _buildErrorState(error),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Card de Saldo com gradiente diagonal suave - 30% mais compacto
  Widget _buildBalanceCard() {
    final transactionsAsync = ref.watch(transactionsListProvider);
    final accountsAsync = ref.watch(bankAccountsListProvider);

    return transactionsAsync.when(
      data: (transactions) {
        return accountsAsync.when(
          data: (accounts) {
            // SALDO ATUAL GLOBAL: Somatório dos saldos correntes das contas visíveis
            // (não depende do filtro de mês, considera todas as transações pagas até agora)
            final totalBalance = BalanceCalculatorService.calculateTotalBalance(
              accounts: accounts,
              allTransactions: transactions,
            );

            // TOTAIS DO PERÍODO: Entradas e saídas do mês selecionado (para mini-cards)
            final periodTotals = BalanceCalculatorService.calculatePeriodTotals(
              allTransactions: transactions,
              startDate: _filtroAtivo.start,
              endDate: _filtroAtivo.end,
            );

            final totalIncome = periodTotals['income']!;
            final totalExpense = periodTotals['expense']!;
            final balance = totalBalance; // Usar saldo global, não o do período
        final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return FadeTransition(
          opacity: _animationController,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            decoration: BoxDecoration(
              // Gradiente premium: azul profundo → preto (135deg)
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF1A2A6C), // Azul profundo (início)
                  Color(0xFF162447), // Azul escuro (meio)
                  Color(0xFF000000), // Preto (fim)
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                stops: [0.0, 0.5, 1.0],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.35), // Sombra mais profunda
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Linha 1: Título com ícone info + Saldo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Saldo Atual',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFA8B3CF), // Azul acinzentado premium
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Saldo = Receitas – Despesas'),
                            duration: Duration(seconds: 2),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                      child: Icon(
                        Icons.info_outline,
                        size: 14,
                        color: const Color(0xFFA8B3CF).withOpacity(0.7), // Tom combinando
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: balance),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Text(
                      currencyFormat.format(value),
                      style: const TextStyle(
                        fontSize: 32, // Maior destaque
                        fontWeight: FontWeight.w700, // Mais peso
                        color: Colors.white, // Branco puro
                        height: 1.2,
                        letterSpacing: -0.5,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Linha 2: Chips translúcidos de receitas e despesas
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Chip de Receitas (verde premium translúcido)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4ADE80).withOpacity(0.15), // Verde premium translúcido
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '↑ ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF4ADE80), // Verde premium
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            currencyFormat.format(totalIncome),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF4ADE80), // Verde premium
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Chip de Despesas (vermelho suave translúcido)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF87171).withOpacity(0.15), // Vermelho suave translúcido
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            '↓ ',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFF87171), // Vermelho suave
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            currencyFormat.format(totalExpense),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFF87171), // Vermelho suave
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
          },
          loading: () {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return Container(
              height: 90,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(AppColors.primary),
                ),
              ),
            );
          },
          error: (_, __) => const SizedBox.shrink(),
        );
      },
      loading: () {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: 90,
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        );
      },
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Botão de Análise IA - Formato chip compacto (36-40px)
  Widget _buildAIAnalysisButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recommendationsAsync = ref.watch(recommendationsProvider);

    return recommendationsAsync.when(
      data: (recommendations) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () => context.push('/ai/recommendations'),
            borderRadius: BorderRadius.circular(8),
            splashColor: Colors.transparent,
            highlightColor: (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFEAEAEA)).withOpacity(0.3),
            child: Container(
              height: 38,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Color(0xFF00E5FF),
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      recommendations.isEmpty
                          ? 'Gerar recomendações de IA personalizadas'
                          : recommendations.first.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: isDark ? const Color(0xFFD0D0D0) : const Color(0xFF3C3C3C),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isDark ? const Color(0xFF6E6E6E) : const Color(0xFF9E9E9E),
                  ),
                ],
              ),
            ),
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// Campo de busca moderno
  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final isLight = theme.brightness == Brightness.light;

          return Container(
            height: 44,
            decoration: BoxDecoration(
              color: isLight ? Colors.white : const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isLight ? const Color(0xFFE0E0E0) : const Color(0xFF2A2A2A),
              ),
            ),
            child: Builder(
              builder: (context) {

            print('🔍 [SearchField] Build chamado');
            print('🔍 [SearchField] Brightness: ${theme.brightness}');
            print('🔍 [SearchField] isLight: $isLight');
            print('🔍 [SearchField] Cor do texto que será aplicada: ${isLight ? "0xFF000000 (PRETO)" : "0xFFEDEDED (BRANCO)"}');
            print('🔍 [SearchField] AppColors.textPrimary: ${AppColors.textPrimary}');

            final textStyle = TextStyle(
              fontSize: 14,
              color: isLight ? const Color(0xFF000000) : const Color(0xFFEDEDED),
              fontWeight: FontWeight.w500,
            );

            print('🔍 [SearchField] TextStyle criado - cor: ${textStyle.color}');

            return TextField(
              controller: _searchController,
              style: textStyle,
              cursorColor: const Color(0xFF0072FF),
              decoration: InputDecoration(
                hintText: 'Buscar transações…',
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isLight ? const Color(0xFF6B6B6B) : const Color(0xFFB0B0B0),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  size: 18,
                  color: isLight ? const Color(0xFF6B6B6B) : const Color(0xFF9E9E9E),
                ),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(
                          Icons.clear,
                          size: 18,
                          color: isLight ? const Color(0xFF6B6B6B) : const Color(0xFF9E9E9E),
                        ),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              onChanged: (value) {
                print('🔍 [SearchField] onChanged chamado - valor: "$value"');
                _performSearch(value);
              },
            );
          },
        ),
          );
        },
      ),
    );
  }

  /// Fecha qualquer swipe aberto
  void _closeOpenedSwipe() {
    if (_openedSwipeId != null && _swipeKeys.containsKey(_openedSwipeId)) {
      _swipeKeys[_openedSwipeId]?.currentState?.close();
      _openedSwipeId = null;
    }
  }

  /// Chamado quando um swipe é aberto
  void _onSwipeOpened(String transactionId) {
    // Fechar o swipe anterior se houver
    if (_openedSwipeId != null && _openedSwipeId != transactionId) {
      _closeOpenedSwipe();
    }
    _openedSwipeId = transactionId;
  }

  /// Alterna o status de pagamento da transação (atualização otimista)
  Future<void> _toggleTransactionPaidStatus(TransactionModel transaction) async {
    final newIsPaid = !transaction.isPaid;
    final newPaidAt = newIsPaid ? DateTime.now() : null;

    print('📝 [TransactionsPage] Alterando status de pagamento - isPaid: $newIsPaid');

    // Atualização otimista
    final updatedTransaction = transaction.copyWith(
      isPaid: newIsPaid,
      paidAt: newPaidAt,
    );

    try {
      // Atualizar no provider
      await ref.read(transactionsListProvider.notifier).updateTransaction(updatedTransaction);

      // Feedback visual
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newIsPaid ? 'Marcado como pago' : 'Marcado como não pago',
              style: const TextStyle(fontSize: 14),
            ),
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      // Rollback em caso de erro
      print('❌ [TransactionsPage] Erro ao atualizar status: $error');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Falha ao atualizar status. Tente novamente',
              style: TextStyle(fontSize: 14),
            ),
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  /// Navega para a tela de edição da transação
  void _editTransaction(TransactionModel transaction) {
    context.push('/finance/edit/${transaction.id}');
  }

  /// Exclui a transação com opção de desfazer
  Future<void> _deleteTransaction(TransactionModel transaction) async {
    // Backup para desfazer
    final backup = transaction;

    // Remover otimisticamente
    await ref.read(transactionsListProvider.notifier).deleteTransaction(transaction.id);

    if (!mounted) return;

    // Mostrar snackbar com opção de desfazer
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          'Transação excluída',
          style: TextStyle(fontSize: 14),
        ),
        duration: const Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Desfazer',
          onPressed: () async {
            // Restaurar transação
            try {
              await ref.read(transactionsListProvider.notifier).createTransaction(backup);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Transação restaurada',
                      style: TextStyle(fontSize: 14),
                    ),
                    duration: Duration(milliseconds: 1500),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } catch (error) {
              print('❌ [TransactionsPage] Erro ao restaurar transação: $error');
            }
          },
        ),
      ),
    );
  }

  /// Linha de transação plana e densa (56-60px) - Estilo premium
  Widget _buildTransactionCard(TransactionModel transaction, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isIncome = transaction.type == 'income';
    final isTransfer = transaction.type == 'transfer';

    // Cores premium para valores
    final amountColor = isTransfer
        ? AppColors.primary
        : isIncome
            ? const Color(0xFF06C46B) // Verde premium
            : const Color(0xFFE53935); // Vermelho premium

    final icon = isTransfer ? Icons.swap_horiz : _getCategoryIcon(transaction.category);
    final categoryColor = _getCategoryColor(transaction.category);
    final isPaid = transaction.paymentStatus == 'paid';

    // Criar ou obter key para o swipe
    if (!_swipeKeys.containsKey(transaction.id)) {
      _swipeKeys[transaction.id] = GlobalKey<SwipeableTransactionCardState>();
    }

    final cardContent = InkWell(
      onTap: () => _showTransactionDetailModal(transaction),
      splashColor: (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F0F0)).withOpacity(0.4),
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Ícone circular da categoria com status de pagamento
            Stack(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: categoryColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: categoryColor,
                  ),
                ),
                // Indicador de status (pago/pendente)
                if (!isPaid && !isTransfer)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF121212) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFF9800),
                          width: 2,
                        ),
                      ),
                    ),
                  )
                else if (isPaid && !isTransfer)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF121212) : Colors.white,
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Informações da transação
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Descrição
                  Text(
                    transaction.description ?? 'Sem descrição',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF212121),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  // Categoria • Conta • Data
                  Text(
                    _buildSubtitle(transaction),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8E8E93),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Valor e status de pagamento alinhados à direita
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Valor
                Text(
                  isTransfer
                      ? currencyFormat.format(transaction.amount)
                      : '${isIncome ? '+' : '–'}${currencyFormat.format(transaction.amount)}',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: amountColor,
                  ),
                ),
                const SizedBox(height: 2),
                // Status de pagamento (pago/não pago/recebido/não recebido)
                Text(
                  DateFormatter.getPaymentStatusText(transaction.type, transaction.isPaid),
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF8E8E93),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    // Envolver com SwipeableTransactionCard
    return SwipeableTransactionCard(
      key: _swipeKeys[transaction.id],
      isPaid: transaction.isPaid,
      onTogglePaid: () => _toggleTransactionPaidStatus(transaction),
      onEdit: () => _editTransaction(transaction),
      onDelete: () => _deleteTransaction(transaction),
      onOpen: () => _onSwipeOpened(transaction.id),
      onClose: () {
        if (_openedSwipeId == transaction.id) {
          _openedSwipeId = null;
        }
      },
      child: cardContent,
    );
  }

  /// Constrói lista agrupada de transações com sticky headers
  Widget _buildGroupedTransactionsList(List<TransactionGroup> groups) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        // Fechar swipe aberto ao rolar
        if (notification is ScrollUpdateNotification) {
          _closeOpenedSwipe();
        }
        return false;
      },
      child: ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 100),
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header do grupo (data)
            TransactionDateHeader(
              label: group.label,
              isDark: isDark,
            ),

            // Transações do grupo
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: group.transactions.length,
              separatorBuilder: (context, index) {
                return Divider(
                  height: 1,
                  thickness: 1,
                  color: isDark ? const Color(0xFF2C2C2C) : const Color(0xFFEAEAEA),
                );
              },
              itemBuilder: (context, index) {
                final transaction = group.transactions[index];
                return _buildTransactionCard(transaction, index);
              },
            ),

            // Espaçamento entre grupos
            const SizedBox(height: 16),
          ],
        );
      },
      ),
    );
  }

  /// Modal de detalhes da transação (60% da tela)
  void _showTransactionDetailModal(TransactionModel transaction) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy');
    final isIncome = transaction.type == 'income';
    final amountColor = isIncome ? const Color(0xFF43A047) : const Color(0xFFE53935);
    final icon = _getCategoryIcon(transaction.category);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Barra de arrastar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Botões de ação fixos no topo
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Detalhes da Transação',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF1C1C1C),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.attach_file, size: 20),
                          color: AppColors.primary,
                          tooltip: 'Anexar',
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/finance/edit/${transaction.id}');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          color: AppColors.primary,
                          tooltip: 'Editar',
                          onPressed: () {
                            Navigator.pop(context);
                            context.push('/finance/edit/${transaction.id}');
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, size: 20),
                          color: AppColors.error,
                          tooltip: 'Excluir',
                          onPressed: () {
                            Navigator.pop(context);
                            _confirmDelete(transaction.id);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              // Conteúdo rolável
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Ícone e descrição
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            icon,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                transaction.description ?? 'Sem descrição',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF1C1C1C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                transaction.category ?? 'Sem categoria',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF757575),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Valor
                    _buildDetailRow(
                      'Valor',
                      '${isIncome ? '+' : '–'}${currencyFormat.format(transaction.amount)}',
                      valueColor: amountColor,
                      valueWeight: FontWeight.w700,
                    ),

                    const Divider(height: 32),

                    // Conta bancária
                    if (transaction.account != null)
                      _buildDetailRow('Conta', transaction.account!),

                    // Data
                    _buildDetailRow(
                      'Data',
                      dateFormat.format(transaction.date ?? DateTime.now()),
                    ),

                    // Categoria
                    _buildDetailRow(
                      'Categoria',
                      transaction.category ?? 'Sem categoria',
                    ),

                    const Divider(height: 32),

                    // Observações (editável)
                    Text(
                      'Observações',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Nenhuma observação adicionada',
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? const Color(0xFF8A8A8E) : const Color(0xFF9E9E9E),
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Anexos
                    Text(
                      'Anexos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF1C1C1C),
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (transaction.attachments == null || transaction.attachments!.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Nenhum anexo',
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark ? const Color(0xFF8A8A8E) : const Color(0xFF9E9E9E),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      )
                    else
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: transaction.attachments!
                            .map((url) => _buildAttachmentThumbnail(url))
                            .toList(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Widget auxiliar para exibir linha de detalhe
  Widget _buildDetailRow(
    String label,
    String value, {
    Color? valueColor,
    FontWeight? valueWeight,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF757575),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: valueWeight ?? FontWeight.w600,
              color: valueColor ?? (isDark ? const Color(0xFFEDEDED) : const Color(0xFF1C1C1C)),
            ),
          ),
        ],
      ),
    );
  }

  /// Estado vazio
  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF1E1E1E)
                  : const Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Você ainda não tem transações registradas.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Toque em + Nova Transação para começar.',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Estado de erro
  Widget _buildErrorState(Object error) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(32),
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
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 13,
              color: theme.textTheme.bodyMedium?.color?.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              ref.read(transactionsListProvider.notifier).loadTransactions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Tentar Novamente'),
          ),
        ],
      ),
    );
  }

  /// Botão flutuante com sombra
  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: FloatingActionButton.extended(
        heroTag: 'transactions_page_fab',
        onPressed: () => context.push('/finance/add'),
        backgroundColor: AppColors.primary,
        elevation: 0,
        icon: const Icon(Icons.add, color: Colors.white, size: 22),
        label: const Text(
          'Nova Transação',
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  /// Bottom sheet de filtros
  void _showFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Filtrar por',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF1C1C1C),
                ),
              ),
              const SizedBox(height: 16),
              _buildFilterOption('Todos', null),
              _buildFilterOption('Somente Receitas', 'income'),
              _buildFilterOption('Somente Despesas', 'expense'),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterOption(String label, String? type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = _filterType == type;

    return InkWell(
      onTap: () {
        setState(() {
          _filterType = type;
        });
        Navigator.pop(context);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: isSelected ? AppColors.primary : (isDark ? const Color(0xFFB0B0B0) : const Color(0xFF9E9E9E)),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : (isDark ? const Color(0xFFEDEDED) : const Color(0xFF1C1C1C)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) {
    ref.read(transactionsListProvider.notifier).loadTransactions(
          searchQuery: query.isEmpty ? null : query,
        );
  }

  Future<void> _confirmDelete(String id) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        title: Text(
          'Excluir Transação',
          style: TextStyle(color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF1C1C1C)),
        ),
        content: Text(
          'Tem certeza que deseja excluir esta transação?',
          style: TextStyle(color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF757575)),
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

    if (confirmed == true && mounted) {
      final success = await ref
          .read(transactionsListProvider.notifier)
          .deleteTransaction(id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error_outline,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                Text(
                  success
                      ? '✅ Transação excluída com sucesso!'
                      : 'Erro ao excluir transação',
                ),
              ],
            ),
            backgroundColor: success ? AppColors.success : AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    }
  }

  /// Monta o subtítulo: "Categoria • Conta" ou "Origem → Destino" para transferências
  String _buildSubtitle(TransactionModel transaction) {
    // Para transferências, mostrar origem → destino
    if (transaction.type == 'transfer') {
      final origem = transaction.account ?? 'Origem';
      final destino = transaction.destinationAccount ?? 'Destino';
      return '$origem → $destino';
    }

    // Para receitas/despesas normais
    final categoryName = transaction.category ?? 'Sem categoria';
    final accountName = transaction.account;

    if (accountName != null && accountName.isNotEmpty) {
      return '$categoryName • $accountName';
    }
    return categoryName;
  }

  /// Thumbnail de anexo no modal
  Widget _buildAttachmentThumbnail(String url) {
    return GestureDetector(
      onTap: () => _viewAttachment(url),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFE0E0E0)),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            children: [
              Image.network(
                url,
                fit: BoxFit.cover,
                width: 80,
                height: 80,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFF5F5F5),
                  child: const Icon(
                    Icons.broken_image,
                    color: Color(0xFF9E9E9E),
                    size: 32,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: const Color(0xFFF5F5F5),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),
              // Ícone de visualizar
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.visibility,
                    size: 12,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Visualizar anexo em fullscreen
  void _viewAttachment(String url) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.black,
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color(0xFFF5F5F5),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image, size: 64, color: Color(0xFF9E9E9E)),
                        SizedBox(height: 16),
                        Text(
                          'Erro ao carregar imagem',
                          style: TextStyle(color: Color(0xFF9E9E9E)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 32),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Retorna a cor da categoria
  Color _getCategoryColor(String? category) {
    switch (category?.toLowerCase()) {
      case 'alimentação':
        return const Color(0xFFFF6B6B);
      case 'transporte':
        return const Color(0xFF4ECDC4);
      case 'moradia':
        return const Color(0xFF95E1D3);
      case 'saúde':
        return const Color(0xFFFF8B94);
      case 'educação':
        return const Color(0xFF5F9DF7);
      case 'lazer':
        return const Color(0xFFFFA07A);
      case 'vestuário':
        return const Color(0xFFDDA15E);
      case 'salário':
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
}
