import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/presentation/main_shell.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../tasks/presentation/pages/task_form_page_v2.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../finance/presentation/providers/bank_account_providers.dart';
import '../../../finance/presentation/providers/transaction_providers.dart';
import '../../../../core/services/balance_calculator_service.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/ai_smart_card.dart';
import '../widgets/tasks_progress_widget.dart';
import '../widgets/finance_chart_widget.dart';
import '../widgets/speed_dial_fab.dart';
import '../widgets/bank_accounts_carousel_widget.dart';

/// Dashboard V2 - Versão aprimorada com novo design
class DashboardPageV2 extends ConsumerStatefulWidget {
  const DashboardPageV2({super.key});

  @override
  ConsumerState<DashboardPageV2> createState() => _DashboardPageV2State();
}

class _DashboardPageV2State extends ConsumerState<DashboardPageV2>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  final GlobalKey _speedDialKey = GlobalKey();

  // Dados de exemplo - substituir com dados reais dos providers
  final String _userName = 'Bruno';
  final bool _hasNotifications = true;
  final bool _hasUserData = true; // Mudar para false quando não houver dados suficientes

  final List<DailyFinance> _weeklyData = [
    const DailyFinance(dayLabel: 'Seg', income: 1200, expenses: 450),
    const DailyFinance(dayLabel: 'Ter', income: 800, expenses: 600),
    const DailyFinance(dayLabel: 'Qua', income: 1500, expenses: 400),
    const DailyFinance(dayLabel: 'Qui', income: 950, expenses: 700),
    const DailyFinance(dayLabel: 'Sex', income: 1800, expenses: 500),
    const DailyFinance(dayLabel: 'Sáb', income: 300, expenses: 200),
    const DailyFinance(dayLabel: 'Dom', income: 150, expenses: 100),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void deactivate() {
    // Fecha o FAB quando o usuário muda de aba
    final state = _speedDialKey.currentState;
    if (state != null && state is State) {
      // Chama o método close() se existir
      (state as dynamic).close();
    }
    super.deactivate();
  }

  void _onScroll() {
    if (_scrollController.offset > 20 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 20 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    AppLogger.debug('Dashboard build iniciado');

    final isDark = ref.watch(themeProvider) == ThemeMode.dark;

    // Buscar tarefas de hoje do provider real
    final todayTasksAsync = ref.watch(todayTasksProvider);

    print('[DashboardPageV2] 🔵 Estado do todayTasksProvider: ${todayTasksAsync.runtimeType}');

    // Converter TaskModel para TaskItem para manter compatibilidade com o widget
    final tasks = todayTasksAsync.when(
      data: (taskModels) {
        print('[DashboardPageV2] ✅ Tarefas carregadas: ${taskModels.length}');
        return taskModels.map((task) {
          print('[DashboardPageV2] 📝 - ${task.title} (completed: ${task.isCompleted}, priority: ${task.priority})');
          return TaskItem(
            id: task.id,
            title: task.title,
            completed: task.isCompleted,
            priority: _convertPriority(task.priority),
          );
        }).toList();
      },
      loading: () {
        print('[DashboardPageV2] ⏳ Carregando tarefas...');
        return <TaskItem>[];
      },
      error: (error, stack) {
        print('[DashboardPageV2] ❌ Erro ao carregar tarefas: $error');
        print('[DashboardPageV2] 📚 Stack: $stack');
        return <TaskItem>[];
      },
    );

    final completedTasks = tasks.where((t) => t.completed).length;

    // Calcular altura do header dinamicamente
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final headerHeight = statusBarHeight + 12 + 48 + 16; // top padding + avatar height + bottom padding

    AppLogger.debug('SafeArea padding top', data: {'paddingTop': statusBarHeight});
    AppLogger.debug('Layout metrics', data: {
      'headerHeight': headerHeight,
      'screenHeight': MediaQuery.of(context).size.height,
      'screenWidth': MediaQuery.of(context).size.width,
    });

    // Validar se scroll controller está inicializado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppLogger.debug('Scroll controller state', data: {
        'hasClients': _scrollController.hasClients,
        'offset': _scrollController.hasClients ? _scrollController.offset : null,
      });
    });

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Stack(
        children: [
          // Conteúdo principal
          RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.primary,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Espaço para o header (calculado dinamicamente)
                SliverToBoxAdapter(
                  child: SizedBox(height: headerHeight + 8),
                ),

                // Conteúdo
                SliverToBoxAdapter(
                  child: Builder(
                    builder: (context) {
                      AppLogger.debug('Content body renderizado');
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        final renderBox = context.findRenderObject() as RenderBox?;
                        if (renderBox != null) {
                          AppLogger.debug('Content body size', data: {'size': renderBox.size.toString()});
                        }
                      });

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 8),

                          // ==================== SEÇÃO 1: FOCO DO DIA ====================
                          _buildSectionTitle('Foco do Dia', isDark),
                          const SizedBox(height: 12),

                          // Card de IA inteligente com animação
                          Builder(
                            builder: (context) {
                              AppLogger.debug('InsightCard sendo renderizado');
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final renderBox = context.findRenderObject() as RenderBox?;
                                if (renderBox != null) {
                                  AppLogger.debug('InsightCard layout', data: {
                                    'size': renderBox.size.toString(),
                                    'position': renderBox.localToGlobal(Offset.zero).toString(),
                                  });
                                }
                              });

                              return TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 600),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: AiSmartCardWrapper(
                                  hasUserData: _hasUserData,
                                  suggestion:
                                      'Você gastou 23% a mais em "Alimentação" esta semana. Considere ajustar seu orçamento.',
                                  category: 'Insight Financeiro',
                                  icon: Icons.lightbulb,
                                  isDark: isDark,
                                  onTap: () => _showAiDetails(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 20),

                          // Widget de tarefas com animação
                          Builder(
                            builder: (context) {
                              AppLogger.debug('TaskCard sendo renderizado');
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final renderBox = context.findRenderObject() as RenderBox?;
                                if (renderBox != null) {
                                  AppLogger.debug('TaskCard layout', data: {
                                    'size': renderBox.size.toString(),
                                    'position': renderBox.localToGlobal(Offset.zero).toString(),
                                  });
                                }
                              });

                              return TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 700),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  child: TasksProgressWidget(
                                    completedTasks: completedTasks,
                                    totalTasks: tasks.length,
                                    recentTasks: tasks,
                                    onViewAll: () => _navigateToTasks(),
                                    isDark: isDark,
                                  ),
                                ),
                              );
                            },
                          ),

                          const SizedBox(height: 32),

                          // ==================== SEÇÃO 2: FINANÇAS ====================
                          _buildSectionTitle('💰 Finanças', isDark),
                          const SizedBox(height: 12),

                          // Widget financeiro com gráfico e animação
                          Builder(
                            builder: (context) {
                              AppLogger.debug('FinanceCard sendo renderizado');
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                final renderBox = context.findRenderObject() as RenderBox?;
                                if (renderBox != null) {
                                  AppLogger.debug('FinanceCard layout', data: {
                                    'size': renderBox.size.toString(),
                                    'position': renderBox.localToGlobal(Offset.zero).toString(),
                                  });
                                }
                              });

                              // Buscar contas bancárias e transações
                              final accountsAsync = ref.watch(bankAccountsListProvider);
                              final transactionsAsync = ref.watch(transactionsListProvider);

                              return accountsAsync.when(
                                data: (accounts) {
                                  return transactionsAsync.when(
                                    data: (transactions) {
                                      // Calcular saldo corrente usando BalanceCalculatorService
                                      final balance = BalanceCalculatorService.calculateTotalBalance(
                                        accounts: accounts,
                                        allTransactions: transactions,
                                      );

                                      // Calcular receitas e despesas PAGAS
                                      final income = transactions
                                          .where((t) => t.type == 'income' && t.isPaid)
                                          .fold<double>(0, (sum, t) => sum + t.amount);

                                      final expenses = transactions
                                          .where((t) => t.type == 'expense' && t.isPaid)
                                          .fold<double>(0, (sum, t) => sum + t.amount);

                                      print('📊 [Dashboard] Saldo: R\$ $balance | Receitas: R\$ $income | Despesas: R\$ $expenses');

                                      return TweenAnimationBuilder<double>(
                                        duration: const Duration(milliseconds: 800),
                                        tween: Tween(begin: 0.0, end: 1.0),
                                        curve: Curves.easeOut,
                                        builder: (context, value, child) {
                                          return Opacity(
                                            opacity: value,
                                            child: Transform.translate(
                                              offset: Offset(0, 20 * (1 - value)),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: FinanceChartWidget(
                                            balance: balance,
                                            income: income,
                                            expenses: expenses,
                                            weeklyData: _weeklyData,
                                            onViewDetails: () => _navigateToFinances(),
                                            isDark: isDark,
                                          ),
                                        ),
                                      );
                                    },
                                    loading: () => const Center(child: CircularProgressIndicator()),
                                    error: (error, stack) {
                                      print('❌ [Dashboard] Erro ao carregar transações: $error');
                                      return TweenAnimationBuilder<double>(
                                        duration: const Duration(milliseconds: 800),
                                        tween: Tween(begin: 0.0, end: 1.0),
                                        curve: Curves.easeOut,
                                        builder: (context, value, child) {
                                          return Opacity(
                                            opacity: value,
                                            child: Transform.translate(
                                              offset: Offset(0, 20 * (1 - value)),
                                              child: child,
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 20),
                                          child: FinanceChartWidget(
                                            balance: 0.0,
                                            income: 0.0,
                                            expenses: 0.0,
                                            weeklyData: _weeklyData,
                                            onViewDetails: () => _navigateToFinances(),
                                            isDark: isDark,
                                          ),
                                        ),
                                      );
                                    },
                                  );
                                },
                                loading: () => const Center(child: CircularProgressIndicator()),
                                error: (error, stack) {
                                  print('❌ [Dashboard] Erro ao carregar contas: $error');
                                  return const Center(child: CircularProgressIndicator());
                                },
                              );
                            },
                          ),

                      const SizedBox(height: 24),

                      // ==================== SEÇÃO 3: CONTAS BANCÁRIAS ====================
                      Builder(
                        builder: (context) {
                          final bankAccountsAsync = ref.watch(bankAccountsListProvider);

                          return bankAccountsAsync.when(
                            data: (accounts) {
                              // Filtrar apenas contas ativas
                              final activeAccounts = accounts.where((a) => a.isActive).toList();

                              return TweenAnimationBuilder<double>(
                                duration: const Duration(milliseconds: 900),
                                tween: Tween(begin: 0.0, end: 1.0),
                                curve: Curves.easeOut,
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(0, 20 * (1 - value)),
                                      child: child,
                                    ),
                                  );
                                },
                                child: BankAccountsCarouselWidget(
                                  accounts: activeAccounts,
                                  isDark: isDark,
                                  onViewAll: () => context.push('/finance/settings'),
                                ),
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),

                      const SizedBox(height: 32),

                      // ==================== SEÇÃO 4: INSIGHTS DA IA ====================
                      _buildSectionTitle('Insights da IA', isDark),
                      const SizedBox(height: 12),

                      // Chips de insights (versão compacta)
                      _buildInsightsChips(isDark),

                          const SizedBox(height: 100), // Espaço para o FAB
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // Header fixo com blur
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Builder(
              builder: (context) {
                AppLogger.debug('Header renderizado (Positioned)');
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  final renderBox = context.findRenderObject() as RenderBox?;
                  if (renderBox != null) {
                    AppLogger.debug('Header layout', data: {
                      'size': renderBox.size.toString(),
                      'height': renderBox.size.height,
                      'position': 'top: 0, left: 0, right: 0',
                    });
                  }
                });

                return DashboardHeader(
                  userName: _userName,
                  hasNotifications: _hasNotifications,
                  onNotificationTap: () => _showNotifications(),
                  isScrolled: _isScrolled,
                );
              },
            ),
          ),

          // Speed Dial FAB
          Positioned(
            bottom: 20,
            right: 20,
            child: SpeedDialFAB(
              key: _speedDialKey,
              isDark: isDark,
              onAddTask: () => _addTask(),
              onAddTransaction: () => _addTransaction(),
              onAddCompany: () => _addCompany(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 24,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.lightText,
            ),
          ),
        ],
      ),
    );
  }

  /// Chips compactos de insights da IA (altura reduzida para 60px)
  Widget _buildInsightsChips(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildInsightChip(
            '💸 Padrão de Gastos',
            'Você gasta mais às sextas. Planeje-se melhor.',
            AppColors.info,
            isDark,
          ),
          const SizedBox(height: 10),
          _buildInsightChip(
            '🏦 Meta de Economia',
            'Faltam R\$ 500 para atingir a meta mensal.',
            AppColors.success,
            isDark,
          ),
          const SizedBox(height: 10),
          _buildInsightChip(
            '📈 Produtividade',
            'Você completa mais tarefas pela manhã.',
            AppColors.warning,
            isDark,
          ),
        ],
      ),
    );
  }

  /// Chip individual de insight (versão compacta - sem altura fixa)
  Widget _buildInsightChip(
    String title,
    String description,
    Color color,
    bool isDark,
  ) {
    return Container(
      // Removida altura fixa para evitar overflow
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), // Ajustado de 10 para 12
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 36, // Reduzido de 40 para 36
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min, // Adicionado
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                    fontFamily: 'Poppins',
                    height: 1.2, // Adicionado para controle de altura de linha
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    fontFamily: 'Inter',
                    height: 1.2, // Adicionado para controle de altura de linha
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8), // Adicionado espaçamento
          Icon(
            Icons.arrow_forward_ios,
            size: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ],
      ),
    );
  }

  // Converte prioridade do banco (low/medium/high) para português (Baixa/Média/Alta)
  String? _convertPriority(String? priority) {
    if (priority == null) return null;
    switch (priority.toLowerCase()) {
      case 'low':
        return 'Baixa';
      case 'medium':
        return 'Média';
      case 'high':
        return 'Alta';
      default:
        return priority;
    }
  }

  // Métodos de ação
  Future<void> _onRefresh() async {
    print('[DashboardPageV2] 🔄 Refresh solicitado');
    // Invalida os providers para forçar reload
    ref.invalidate(todayTasksProvider);
    ref.invalidate(totalBalanceProvider);
    ref.invalidate(transactionsListProvider);
    ref.invalidate(bankAccountsListProvider);
    await Future.delayed(const Duration(milliseconds: 500));
    print('[DashboardPageV2] ✅ Refresh concluído');
  }

  void _showNotifications() {
    // TODO: Navegar para notificações
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Abrindo notificações...')),
    );
  }

  void _showAiDetails() {
    // Navegar para página de recomendações da IA
    context.push('/ai/recommendations');
  }

  void _navigateToTasks() {
    // Navegar para aba de tarefas no bottom navigation
    context.go('/tasks');
  }

  void _navigateToFinances() {
    // Navegar para aba de finanças no bottom navigation
    context.go('/finance');
  }

  void _addTask() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TaskFormPageV2(),
      ),
    );
  }

  void _addTransaction() {
    // Navegar para página de adicionar transação
    context.push('/finance/transactions/new');
  }

  void _addCompany() {
    // Navegar para página de adicionar empresa
    context.push('/companies/new');
  }

}
