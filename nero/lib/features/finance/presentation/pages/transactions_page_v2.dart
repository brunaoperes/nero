import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/transaction_model.dart';
import '../providers/transaction_providers.dart';
import '../../../ai/presentation/providers/ai_providers.dart';
import '../widgets/month_selector_widget.dart';
import '../widgets/time_filter_bottom_sheet.dart';
import '../../domain/models/time_filter_model.dart';

// Provider para o mês selecionado (fonte única de verdade)
final selectedMonthProvider = StateProvider<DateTime>((ref) => DateTime.now());

// Notifier com persistência para filtro temporal
class FiltroTempoNotifier extends StateNotifier<FiltroTempo> {
  static const _storageKey = 'finance_filtro_tempo';

  FiltroTempoNotifier() : super(_defaultFiltro()) {
    _loadSavedFilter();
  }

  static FiltroTempo _defaultFiltro() {
    final now = DateTime.now();
    return FiltroTempo.mes(now);
  }

  Future<void> _loadSavedFilter() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null) {
        final json = jsonDecode(jsonString) as Map<String, dynamic>;
        state = FiltroTempo.fromJson(json);
      }
    } catch (e) {
      // Se der erro, manter o filtro padrão
    }
  }

  Future<void> setFiltro(FiltroTempo novoFiltro) async {
    state = novoFiltro;

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(novoFiltro.toJson());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      // Falha ao salvar não é crítico
    }
  }
}

// Provider para o filtro temporal ativo (com persistência)
final filtroTempoProvider = StateNotifierProvider<FiltroTempoNotifier, FiltroTempo>((ref) {
  return FiltroTempoNotifier();
});

/// Página de Finanças - Corrigida conforme modelo Organize
class TransactionsPageV2 extends ConsumerStatefulWidget {
  final String? accountFilter;

  const TransactionsPageV2({super.key, this.accountFilter});

  @override
  ConsumerState<TransactionsPageV2> createState() => _TransactionsPageV2State();
}

class _TransactionsPageV2State extends ConsumerState<TransactionsPageV2>
    with SingleTickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  late final AnimationController _animationController;

  String? _filterType;
  String? _filterAccount;
  Timer? _debounce;
  final bool _showAIAnalysis = true;

  @override
  void initState() {
    super.initState();
    _filterAccount = widget.accountFilter;
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onMonthChanged(DateTime newMonth) {
    // Atualiza provider e invalida cache de transações
    ref.read(selectedMonthProvider.notifier).state = newMonth;

    // Se estava com filtro personalizado, volta para filtro por mês
    final filtroAtual = ref.read(filtroTempoProvider);
    if (filtroAtual.tipo != IntervaloFiltro.mes) {
      ref.read(filtroTempoProvider.notifier).state = FiltroTempo.mes(newMonth);
    }

    ref.invalidate(transactionsListProvider);
  }

  void _showTimeFilterMenu() {
    print('🎯 [TimeFilter] _showTimeFilterMenu() CHAMADO!');

    final filtroAtual = ref.read(filtroTempoProvider);
    print('🎯 [TimeFilter] Filtro atual: ${filtroAtual.tipo} - ${filtroAtual.start} até ${filtroAtual.end}');
    print('🎯 [TimeFilter] Abrindo ModalBottomSheet...');

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        print('🎯 [TimeFilter] Builder do ModalBottomSheet chamado');
        return TimeFilterBottomSheet(
          filtroAtual: filtroAtual,
          onFiltroSelecionado: (novoFiltro) {
            print('🎯 [TimeFilter] Filtro selecionado: ${novoFiltro.tipo}');
            print('🎯 [TimeFilter] Período: ${novoFiltro.start} até ${novoFiltro.end}');

            // Salvar filtro com persistência
            ref.read(filtroTempoProvider.notifier).setFiltro(novoFiltro);

            // Se selecionou "Mês atual", sincronizar carrossel para o mês atual
            if (novoFiltro.tipo == IntervaloFiltro.mes) {
              final now = DateTime.now();
              final mesAtual = DateTime(now.year, now.month, 1);
              final filtroMes = DateTime(novoFiltro.start.year, novoFiltro.start.month, 1);

              print('🎯 [TimeFilter] Mês selecionado - Verificando se é o mês atual');
              print('🎯 [TimeFilter] Mês atual: $mesAtual');
              print('🎯 [TimeFilter] Filtro mês: $filtroMes');

              // Só atualizar se for realmente o mês atual
              if (mesAtual == filtroMes) {
                print('🎯 [TimeFilter] ✅ É o mês atual - sincronizando carrossel');
                ref.read(selectedMonthProvider.notifier).state = now;
              } else {
                print('🎯 [TimeFilter] ⏭️ Não é o mês atual - carrossel não será movido');
              }
            }

            // Recarregar transações com debounce de 200ms
            print('🎯 [TimeFilter] Recarregando transações (debounce 200ms)...');
            _debounce?.cancel();
            _debounce = Timer(const Duration(milliseconds: 200), () {
              print('🎯 [TimeFilter] ♻️ Invalidando transactionsListProvider');
              ref.invalidate(transactionsListProvider);
            });
            print('🎯 [TimeFilter] ═══════════════════════════════════════');
          },
        );
      },
    ).then((value) {
      print('🎯 [TimeFilter] ModalBottomSheet fechado');
    }).catchError((error) {
      print('🎯 [TimeFilter] ❌ ERRO ao abrir ModalBottomSheet: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Finanças',
          style: TextStyle(color: Color(0xFF1C1C1C)),
        ),
        centerTitle: false,
        iconTheme: const IconThemeData(color: Color(0xFF1C1C1C)),
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
          ref.invalidate(transactionsListProvider);
          await ref.read(transactionsListProvider.notifier).loadTransactions();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Card de Saldo com Gradiente (ISOLADO - não rebuilda com busca)
              const _BalanceCardWidget(),

              // Botão de Análise IA (opcional)
              if (_showAIAnalysis) _buildAIAnalysisButton(),

              const SizedBox(height: 16),

              // Seletor de Mês (COM KEY ESTÁVEL)
              Consumer(
                builder: (context, ref, child) {
                  final selectedMonth = ref.watch(selectedMonthProvider);
                  final filtroAtivo = ref.watch(filtroTempoProvider);

                  print('📅 [TransactionsPage] Construindo MonthSelectorWidget');
                  print('📅 [TransactionsPage] _showTimeFilterMenu existe? ${_showTimeFilterMenu != null}');
                  print('📅 [TransactionsPage] Tipo de _showTimeFilterMenu: ${_showTimeFilterMenu.runtimeType}');

                  return MonthSelectorWidget(
                    key: ValueKey('month_selector_${selectedMonth.month}_${selectedMonth.year}'),
                    initialMonth: selectedMonth,
                    onMonthChanged: _onMonthChanged,
                    filtroAtivo: filtroAtivo,
                    onMonthTap: () {
                      print('📅 [TransactionsPage] Wrapper onMonthTap chamado!');
                      _showTimeFilterMenu();
                    },
                    backgroundColor: Colors.white,
                    selectedColor: AppColors.primary,
                  );
                },
              ),

              const SizedBox(height: 16),

              // Campo de Busca (ISOLADO com FocusNode persistente)
              _SearchFieldWidget(
                controller: _searchController,
                focusNode: _searchFocusNode,
                onSearch: _performSearch,
              ),

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
                    color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                    letterSpacing: 0.5,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Lista de Transações (FILTRADA)
              _TransactionsListWidget(
                filterType: _filterType,
                filterAccount: _filterAccount,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  /// Botão de Análise IA
  Widget _buildAIAnalysisButton() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recommendationsAsync = ref.watch(recommendationsProvider);

    return recommendationsAsync.when(
      data: (recommendations) {
        if (recommendations.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: InkWell(
              onTap: () => context.push('/ai/recommendations'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface, // Usa cor do tema
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF00E5FF).withOpacity(0.3),
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00E5FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Color(0xFF00E5FF),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Gerar recomendações de IA personalizadas',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontSize: 13,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 14,
                      color: Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final topRecommendation = recommendations.first;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: InkWell(
            onTap: () => context.push('/ai/recommendations'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: topRecommendation.getPriorityColor().withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: topRecommendation.getPriorityColor().withOpacity(isDark ? 0.1 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: topRecommendation.getPriorityColor().withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      topRecommendation.getTypeIcon(),
                      color: topRecommendation.getPriorityColor(),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topRecommendation.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? const Color(0xFF1C1C1E) : const Color(0xFF1C1C1C),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Toque para ver todas',
                          style: TextStyle(
                            fontSize: 11,
                            color: topRecommendation.getPriorityColor(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (recommendations.length > 1)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: topRecommendation.getPriorityColor(),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '+${recommendations.length - 1}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 14,
                    color: isDark ? const Color(0xFF4A4A4A) : const Color(0xFF6B6B6B),
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

  /// Botão flutuante
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
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
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
              const Text(
                'Filtrar por',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1C1C1E), // CORRIGIDO: contraste AA
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
                : const Color(0xFF2A2A2A),
          ),
        ),
        child: Row(
          children: [
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              size: 20,
              color: isSelected ? AppColors.primary : const Color(0xFF4A4A4A),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : const Color(0xFF1C1C1E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _performSearch(String query) {
    // Debounce de 300ms
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      ref.read(transactionsListProvider.notifier).loadTransactions(
            searchQuery: query.isEmpty ? null : query,
          );
    });
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

// ==========================================
// WIDGETS ISOLADOS (sem rebuild desnecessário)
// ==========================================

/// Card de Saldo ISOLADO (não rebuilda com busca)
class _BalanceCardWidget extends ConsumerWidget {
  const _BalanceCardWidget();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsListProvider);
    final filtroTempo = ref.watch(filtroTempoProvider);

    return transactionsAsync.when(
      data: (transactions) {
        // Filtrar transações pelo período ativo (EXCLUINDO transferências)
        // Usa janela inclusiva com timezone local
        final start = filtroTempo.start;
        final end = filtroTempo.end;

        final filteredTransactions = transactions.where((t) {
          final transactionDate = t.date ?? DateTime.now();
          return transactionDate.isAfter(start.subtract(const Duration(microseconds: 1))) &&
                 transactionDate.isBefore(end.add(const Duration(microseconds: 1))) &&
                 t.type != 'transfer'; // Transferências não entram nos somatórios
        }).toList();

        double totalIncome = 0;
        double totalExpense = 0;

        for (final transaction in filteredTransactions) {
          if (transaction.type == 'income') {
            totalIncome += transaction.amount;
          } else if (transaction.type == 'expense') {
            totalExpense += transaction.amount;
          }
        }

        final balance = totalIncome - totalExpense;
        final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');

        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF0072FF), Color(0xFF00E5FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0072FF).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '💰 Saldo Atual',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
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
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.2,
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildBalanceItem(
                      '↑ Receitas',
                      totalIncome,
                      AppColors.success,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white.withOpacity(0.2),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  Expanded(
                    child: _buildBalanceItem(
                      '↓ Despesas',
                      totalExpense,
                      AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        height: 160,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E1E1E),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildBalanceItem(String label, double value, Color color) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          currencyFormat.format(value),
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}

/// Campo de busca ISOLADO (com FocusNode persistente e debounce)
class _SearchFieldWidget extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onSearch;

  const _SearchFieldWidget({
    required this.controller,
    required this.focusNode,
    required this.onSearch,
  });

  @override
  State<_SearchFieldWidget> createState() => _SearchFieldWidgetState();
}

class _SearchFieldWidgetState extends State<_SearchFieldWidget> {
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    // Atualizar botão clear baseado no texto inicial
    _showClearButton = widget.controller.text.isNotEmpty;

    // Listener para atualizar sufixo apenas quando necessário
    widget.controller.addListener(_onTextChanged);

    // Listener de foco
    widget.focusNode.addListener(_onFocusChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    widget.focusNode.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = widget.controller.text.isNotEmpty;

    // LOG: Verificar texto digitado
    if (widget.controller.text.isNotEmpty) {
      print('🔍 [SearchField] Texto digitado: "${widget.controller.text}"');
      print('🔍 [SearchField] Quantidade de caracteres: ${widget.controller.text.length}');
    }

    // Só faz setState se o estado do botão mudou
    if (_showClearButton != hasText) {
      setState(() {
        _showClearButton = hasText;
      });
    }
  }

  void _onFocusChanged() {
    // Listener de foco (reservado para futuras melhorias)
  }

  void _clearSearch() {
    widget.controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isLight = theme.brightness == Brightness.light;

    // LOGS para debug
    print('🔍 [SearchField] Build chamado');
    print('🔍 [SearchField] Brightness: ${theme.brightness}');
    print('🔍 [SearchField] isLight: $isLight');
    print('🔍 [SearchField] Cor do texto que será aplicada: ${isLight ? "0xFF000000 (PRETO)" : "0xFFEDEDED (BRANCO)"}');
    print('🔍 [SearchField] Theme.textTheme.bodyMedium.color: ${theme.textTheme.bodyMedium?.color}');

    final textStyle = isLight
        ? const TextStyle(
            color: Color(0xFF000000), // PRETO PURO no Light
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          )
        : const TextStyle(
            color: Color(0xFFEDEDED), // Branco no Dark
            fontSize: 16,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.none,
          );

    print('🔍 [SearchField] TextStyle criado - cor: ${textStyle.color}');
    print('🔍 [SearchField] InputDecoration - fillColor: ${isLight ? "0xFFFFFFFF (BRANCO)" : "0xFF1A1A1A (ESCURO)"}');
    print('🔍 [SearchField] InputDecoration - hintStyle.color: ${isLight ? "0xFF6B6B6B" : "0xFFB0B0B0"}');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        cursorColor: const Color(0xFF0072FF),
        // IMPORTANTE: Style explícito para garantir cor preta no tema Light
        style: textStyle,
        decoration: InputDecoration(
          hintText: 'Buscar transações…',
          hintStyle: isLight
              ? const TextStyle(
                  color: Color(0xFF6B6B6B),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                )
              : const TextStyle(
                  color: Color(0xFFB0B0B0),
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
          prefixIcon: Icon(
            Icons.search,
            size: 20,
            color: isLight ? const Color(0xFF6B6B6B) : const Color(0xFFB0B0B0),
          ),
          suffixIcon: _showClearButton
              ? IconButton(
                  icon: Icon(
                    Icons.clear,
                    size: 20,
                    color: isLight ? const Color(0xFF6B6B6B) : const Color(0xFFB0B0B0),
                  ),
                  onPressed: _clearSearch,
                )
              : null,
          filled: true,
          fillColor: isLight ? const Color(0xFFFFFFFF) : const Color(0xFF1A1A1A),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          enabledBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(
              color: isLight ? const Color(0xFFE0E0E0) : const Color(0xFF2A2A2A),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(
              color: isLight ? const Color(0xFFBDBDBD) : const Color(0xFF3A3A3A),
              width: 1.2,
            ),
          ),
        ),
        onChanged: (value) {
          print('🔍 [SearchField] onChanged chamado - valor: "$value"');
          widget.onSearch(value);
        },
      ),
    ).also((widget) {
      print('🔍 [SearchField] TextField construído com sucesso');
      print('🔍 [SearchField] ═══════════════════════════════════════');
    });
  }
}

// Extension helper para log
extension _WidgetLogger on Widget {
  Widget also(void Function(Widget) action) {
    action(this);
    return this;
  }
}

/// Lista de transações ISOLADA
class _TransactionsListWidget extends ConsumerWidget {
  final String? filterType;
  final String? filterAccount;

  const _TransactionsListWidget({
    this.filterType,
    this.filterAccount,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(transactionsListProvider);
    final filtroTempo = ref.watch(filtroTempoProvider);

    return transactionsAsync.when(
      data: (transactions) {
        // Usa o filtro temporal ativo (pode ser mês, hoje, 7d, 30d ou personalizado)
        final start = filtroTempo.start;
        final end = filtroTempo.end;

        var filteredTransactions = transactions.where((t) {
          final transactionDate = t.date ?? DateTime.now();
          return transactionDate.isAfter(start.subtract(const Duration(microseconds: 1))) &&
                 transactionDate.isBefore(end.add(const Duration(microseconds: 1)));
        }).toList();

        // Filtrar por tipo
        if (filterType != null) {
          filteredTransactions = filteredTransactions
              .where((t) => t.type == filterType)
              .toList();
        }

        // Filtrar por conta
        if (filterAccount != null) {
          filteredTransactions = filteredTransactions
              .where((t) => t.account == filterAccount)
              .toList();
        }

        if (filteredTransactions.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 100,
          ),
          itemCount: filteredTransactions.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final transaction = filteredTransactions[index];
            return _TransactionCard(
              key: ValueKey(transaction.id), // KEY ESTÁVEL
              transaction: transaction,
            );
          },
        );
      },
      loading: () => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
      ),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFFF5F5F5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.account_balance_wallet_outlined,
              size: 64,
              color: Color(0xFF4A4A4A), // CORRIGIDO: contraste AA
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Você ainda não tem transações registradas.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E), // CORRIGIDO: contraste AA
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          const Text(
            'Toque em + Nova Transação para começar.',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF4A4A4A), // CORRIGIDO: contraste AA
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
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
          const Text(
            'Erro ao carregar transações',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1C1C1E), // CORRIGIDO: contraste AA
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error.toString(),
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF4A4A4A), // CORRIGIDO: contraste AA
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Card de transação individual (stateless)
class _TransactionCard extends StatelessWidget {
  final TransactionModel transaction;

  const _TransactionCard({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final isIncome = transaction.type == 'income';
    final isTransfer = transaction.type == 'transfer';

    final amountColor = isTransfer
        ? AppColors.primary
        : isIncome
            ? const Color(0xFF43A047)
            : const Color(0xFFE53935);

    final icon = isTransfer
        ? Icons.swap_horiz
        : _getCategoryIcon(transaction.category);

    return InkWell(
      onTap: () => _showTransactionDetail(context, transaction),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE0E0E0),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          transaction.description ?? 'Sem descrição',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1C1C1C),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        isTransfer
                            ? currencyFormat.format(transaction.amount)
                            : '${isIncome ? '+' : '–'}${currencyFormat.format(transaction.amount)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: amountColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _buildSubtitle(transaction),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B6B6B), // CORRIGIDO: contraste AA
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _buildSubtitle(TransactionModel transaction) {
    if (transaction.type == 'transfer') {
      final origem = transaction.account ?? 'Origem';
      final destino = transaction.destinationAccount ?? 'Destino';
      return '$origem → $destino';
    }

    final categoryName = transaction.category ?? 'Sem categoria';
    final accountName = transaction.account;

    if (accountName != null && accountName.isNotEmpty) {
      return '$categoryName • $accountName';
    }
    return categoryName;
  }

  void _showTransactionDetail(BuildContext context, TransactionModel transaction) {
    context.push('/finance/transaction/${transaction.id}');
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
