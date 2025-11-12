import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nero/core/utils/app_logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/finance_alert_service.dart';
import '../../data/datasources/finance_remote_datasource.dart';
import '../../data/repositories/finance_repository_impl.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/financial_goal_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/finance_repository.dart';

// ===== SERVIÇOS =====

/// Provider para FinanceAlertService
final financeAlertServiceProvider = Provider<FinanceAlertService>((ref) {
  return FinanceAlertService();
});

// ===== DATA LAYER =====

/// Provider para FinanceRemoteDatasource
final financeRemoteDatasourceProvider = Provider<FinanceRemoteDatasource>((ref) {
  final supabase = Supabase.instance.client;
  return FinanceRemoteDatasource(supabase);
});

/// Provider para FinanceRepository
final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final datasource = ref.read(financeRemoteDatasourceProvider);
  return FinanceRepositoryImpl(datasource);
});

// ===== STATE PROVIDERS =====

/// Provider para lista de transações
final transactionsProvider =
    FutureProvider.autoDispose<List<TransactionEntity>>((ref) async {
  final repository = ref.read(financeRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    throw Exception('Usuário não autenticado');
  }

  return await repository.getTransactions(userId);
});

/// Provider para transações de um período específico
final transactionsByPeriodProvider = FutureProvider.autoDispose
    .family<List<TransactionEntity>, DateRange>((ref, period) async {
  final repository = ref.read(financeRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    throw Exception('Usuário não autenticado');
  }

  return await repository.getTransactionsByPeriod(
    userId: userId,
    startDate: period.startDate,
    endDate: period.endDate,
  );
});

/// Provider para categorias
final categoriesProvider =
    FutureProvider.autoDispose<List<CategoryEntity>>((ref) async {
  final repository = ref.read(financeRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    throw Exception('Usuário não autenticado');
  }

  return await repository.getCategories(userId);
});

/// Provider para categorias por tipo
final categoriesByTypeProvider = FutureProvider.autoDispose
    .family<List<CategoryEntity>, CategoryType>((ref, type) async {
  final repository = ref.read(financeRepositoryProvider);
  return await repository.getCategoriesByType(type);
});

/// Provider para orçamentos
final budgetsProvider =
    FutureProvider.autoDispose<List<BudgetEntity>>((ref) async {
  final repository = ref.read(financeRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    throw Exception('Usuário não autenticado');
  }

  return await repository.getBudgets(userId);
});

/// Provider para orçamentos ativos
final activeBudgetsProvider =
    FutureProvider.autoDispose<List<BudgetEntity>>((ref) async {
  final repository = ref.read(financeRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    throw Exception('Usuário não autenticado');
  }

  return await repository.getActiveBudgets(userId);
});

/// Provider para metas financeiras
final financialGoalsProvider =
    FutureProvider.autoDispose<List<FinancialGoalEntity>>((ref) async {
  final repository = ref.read(financeRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    throw Exception('Usuário não autenticado');
  }

  return await repository.getFinancialGoals(userId);
});

/// Provider para metas ativas
final activeGoalsProvider =
    FutureProvider.autoDispose<List<FinancialGoalEntity>>((ref) async {
  final repository = ref.read(financeRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    throw Exception('Usuário não autenticado');
  }

  return await repository.getActiveGoals(userId);
});

/// Provider para resumo financeiro
final financialSummaryProvider = FutureProvider.autoDispose
    .family<Map<String, double>, DateRange>((ref, period) async {
  final repository = ref.read(financeRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    throw Exception('Usuário não autenticado');
  }

  return await repository.getFinancialSummary(
    userId: userId,
    startDate: period.startDate,
    endDate: period.endDate,
  );
});

/// Provider para gastos por categoria
final expensesByCategoryProvider = FutureProvider.autoDispose
    .family<Map<String, double>, DateRange>((ref, period) async {
  final repository = ref.read(financeRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;

  if (userId == null) {
    throw Exception('Usuário não autenticado');
  }

  return await repository.getExpensesByCategory(
    userId: userId,
    startDate: period.startDate,
    endDate: period.endDate,
  );
});

// ===== CONTROLLERS =====

/// Controller para gerenciar transações
class TransactionController extends StateNotifier<AsyncValue<void>> {
  final FinanceRepository _repository;
  final FinanceAlertService _alertService;
  final String _userId;

  TransactionController(this._repository, this._alertService, this._userId)
      : super(const AsyncValue.data(null));

  /// Cria uma nova transação
  Future<void> createTransaction(TransactionEntity transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createTransaction(transaction);

      // Verificar e disparar alertas financeiros
      if (transaction.type == TransactionType.expense) {
        await _checkAndTriggerAlerts(transaction);
      }
    });
  }

  /// Atualiza uma transação
  Future<void> updateTransaction(TransactionEntity transaction) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateTransaction(transaction);

      // Verificar e disparar alertas financeiros
      if (transaction.type == TransactionType.expense) {
        await _checkAndTriggerAlerts(transaction);
      }
    });
  }

  /// Deleta uma transação
  Future<void> deleteTransaction(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteTransaction(id);
    });
  }

  /// Verifica e dispara alertas financeiros
  Future<void> _checkAndTriggerAlerts(TransactionEntity transaction) async {
    try {
      // Obter resumo financeiro do mês atual
      final now = DateTime.now();
      final startDate = DateTime(now.year, now.month, 1);
      final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final summary = await _repository.getFinancialSummary(
        userId: _userId,
        startDate: startDate,
        endDate: endDate,
      );

      final income = summary['income'] ?? 0.0;
      final expense = summary['expense'] ?? 0.0;

      // Alerta de gastos altos (se gastou mais de 80% da receita)
      if (income > 0 && expense > income * 0.8) {
        await _alertService.sendHighSpendingAlert(
          amount: expense,
          category: 'Geral',
          averageAmount: income * 0.8,
        );
      }

      // Obter orçamentos ativos e verificar se algum foi excedido
      final budgets = await _repository.getActiveBudgets(_userId);

      for (final budget in budgets) {
        // Verificar se esta transação pertence à categoria do orçamento
        if (budget.categoryId == transaction.categoryId) {
          final currentAmt = budget.currentAmount ?? 0.0;
          final limitAmt = budget.limitAmount ?? 0.0;
          final alertThresh = budget.alertThreshold ?? 0.0;

          if (limitAmt > 0) {
            final percentage = (currentAmt / limitAmt) * 100;

            // Alerta se ultrapassou o limite
            if (currentAmt > limitAmt) {
              await _alertService.sendBudgetExceededAlert(
                category: transaction.categoryId, // TODO: Usar nome da categoria
                budgetLimit: limitAmt,
                currentAmount: currentAmt,
              );
            }
            // Alerta se está próximo do limite (threshold)
            else if (percentage >= alertThresh) {
              await _alertService.sendBudgetWarningAlert(
                category: transaction.categoryId, // TODO: Usar nome da categoria
                budgetLimit: limitAmt,
                currentAmount: currentAmt,
                warningThreshold: alertThresh / 100,
              );
            }
          }
        }
      }

      // Obter metas ativas e verificar progresso
      final goals = await _repository.getActiveGoals(_userId);

      for (final goal in goals) {
        final percentage = (goal.currentAmount / goal.targetAmount) * 100;

        // Alerta se alcançou a meta
        if (goal.currentAmount >= goal.targetAmount &&
            goal.status == GoalStatus.active) {
          await _alertService.sendGoalAchievedAlert(
            goalName: goal.name,
            goalAmount: goal.targetAmount,
          );
        }
        // Alerta de progresso (a cada 25%)
        else if (percentage >= 25 && percentage < 50) {
          await _alertService.sendGoalProgressAlert(
            goalName: goal.name,
            goalAmount: goal.targetAmount,
            currentAmount: goal.currentAmount,
            progressThreshold: 0.25,
          );
        }
      }
    } catch (e) {
      // Silenciosamente falhar para não bloquear a criação da transação
      AppLogger.error('Erro ao verificar alertas financeiros', error: e);
    }
  }
}

/// Provider para TransactionController
final transactionControllerProvider =
    StateNotifierProvider<TransactionController, AsyncValue<void>>((ref) {
  final repository = ref.read(financeRepositoryProvider);
  final alertService = ref.read(financeAlertServiceProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return TransactionController(repository, alertService, userId);
});

/// Controller para gerenciar orçamentos
class BudgetController extends StateNotifier<AsyncValue<void>> {
  final FinanceRepository _repository;

  BudgetController(this._repository, String userId)
      : super(const AsyncValue.data(null));

  /// Cria um novo orçamento
  Future<void> createBudget(BudgetEntity budget) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createBudget(budget);
    });
  }

  /// Atualiza um orçamento
  Future<void> updateBudget(BudgetEntity budget) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateBudget(budget);
    });
  }

  /// Deleta um orçamento
  Future<void> deleteBudget(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteBudget(id);
    });
  }
}

/// Provider para BudgetController
final budgetControllerProvider =
    StateNotifierProvider<BudgetController, AsyncValue<void>>((ref) {
  final repository = ref.read(financeRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return BudgetController(repository, userId);
});

/// Controller para gerenciar metas
class GoalController extends StateNotifier<AsyncValue<void>> {
  final FinanceRepository _repository;

  GoalController(this._repository, String userId)
      : super(const AsyncValue.data(null));

  /// Cria uma nova meta
  Future<void> createGoal(FinancialGoalEntity goal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.createFinancialGoal(goal);
    });
  }

  /// Atualiza uma meta
  Future<void> updateGoal(FinancialGoalEntity goal) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.updateFinancialGoal(goal);
    });
  }

  /// Deleta uma meta
  Future<void> deleteGoal(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _repository.deleteFinancialGoal(id);
    });
  }

  /// Adiciona valor a uma meta
  Future<void> addToGoal(FinancialGoalEntity goal, double amount) async {
    final updatedGoal = FinancialGoalEntity(
      id: goal.id,
      userId: goal.userId,
      name: goal.name,
      targetAmount: goal.targetAmount,
      currentAmount: goal.currentAmount + amount,
      targetDate: goal.targetDate,
      description: goal.description,
      icon: goal.icon,
      color: goal.color,
      status: goal.currentAmount + amount >= goal.targetAmount
          ? GoalStatus.achieved
          : GoalStatus.active,
      achievedDate: goal.currentAmount + amount >= goal.targetAmount
          ? DateTime.now()
          : null,
      createdAt: goal.createdAt,
      updatedAt: DateTime.now(),
    );

    await updateGoal(updatedGoal);
  }
}

/// Provider para GoalController
final goalControllerProvider =
    StateNotifierProvider<GoalController, AsyncValue<void>>((ref) {
  final repository = ref.read(financeRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return GoalController(repository, userId);
});

/// Controller para gerenciar categorias
class CategoryController extends StateNotifier<AsyncValue<void>> {
  final FinanceRepository _repository;

  CategoryController(this._repository, String userId)
      : super(const AsyncValue.data(null));

  /// Cria uma nova categoria
  Future<bool> createCategory(CategoryEntity category) async {
    state = const AsyncValue.loading();
    try {
      state = await AsyncValue.guard(() async {
        await _repository.createCategory(category);
      });
      return !state.hasError;
    } catch (e) {
      AppLogger.error('Erro ao criar categoria', error: e);
      return false;
    }
  }

  /// Atualiza uma categoria
  Future<bool> updateCategory(CategoryEntity category) async {
    state = const AsyncValue.loading();
    try {
      state = await AsyncValue.guard(() async {
        await _repository.updateCategory(category);
      });
      return !state.hasError;
    } catch (e) {
      AppLogger.error('Erro ao atualizar categoria', error: e);
      return false;
    }
  }

  /// Deleta uma categoria
  Future<bool> deleteCategory(String id) async {
    state = const AsyncValue.loading();
    try {
      state = await AsyncValue.guard(() async {
        await _repository.deleteCategory(id);
      });
      return !state.hasError;
    } catch (e) {
      AppLogger.error('Erro ao deletar categoria', error: e);
      return false;
    }
  }
}

/// Provider para CategoryController
final categoryControllerProvider =
    StateNotifierProvider<CategoryController, AsyncValue<void>>((ref) {
  final repository = ref.read(financeRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
  return CategoryController(repository, userId);
});

// ===== CLASSES AUXILIARES =====

/// Classe para representar um intervalo de datas
class DateRange {
  final DateTime startDate;
  final DateTime endDate;

  DateRange({
    required this.startDate,
    required this.endDate,
  });

  /// Cria um DateRange para o mês atual
  factory DateRange.currentMonth() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, 1);
    final endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    return DateRange(startDate: startDate, endDate: endDate);
  }

  /// Cria um DateRange para o mês anterior
  factory DateRange.lastMonth() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month - 1, 1);
    final endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
    return DateRange(startDate: startDate, endDate: endDate);
  }

  /// Cria um DateRange para os últimos 30 dias
  factory DateRange.last30Days() {
    final now = DateTime.now();
    final startDate = now.subtract(const Duration(days: 30));
    return DateRange(startDate: startDate, endDate: now);
  }

  /// Cria um DateRange para o ano atual
  factory DateRange.currentYear() {
    final now = DateTime.now();
    final startDate = DateTime(now.year, 1, 1);
    final endDate = DateTime(now.year, 12, 31, 23, 59, 59);
    return DateRange(startDate: startDate, endDate: endDate);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRange &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode;
}
