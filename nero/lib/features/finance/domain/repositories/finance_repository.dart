import '../entities/budget_entity.dart';
import '../entities/category_entity.dart';
import '../entities/financial_goal_entity.dart';
import '../entities/transaction_entity.dart';

/// Interface do repositório de finanças
abstract class FinanceRepository {
  // ==================== TRANSACTIONS ====================

  /// Busca todas as transações do usuário
  Future<List<TransactionEntity>> getTransactions(String userId);

  /// Busca transações por período
  Future<List<TransactionEntity>> getTransactionsByPeriod({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Busca transações por categoria
  Future<List<TransactionEntity>> getTransactionsByCategory({
    required String userId,
    required String categoryId,
  });

  /// Busca transações por tipo (receita ou despesa)
  Future<List<TransactionEntity>> getTransactionsByType({
    required String userId,
    required TransactionType type,
  });

  /// Cria uma nova transação
  Future<TransactionEntity> createTransaction(TransactionEntity transaction);

  /// Atualiza uma transação
  Future<TransactionEntity> updateTransaction(TransactionEntity transaction);

  /// Deleta uma transação
  Future<void> deleteTransaction(String id);

  // ==================== CATEGORIES ====================

  /// Busca todas as categorias (padrão + customizadas)
  Future<List<CategoryEntity>> getCategories(String userId);

  /// Busca categorias por tipo
  Future<List<CategoryEntity>> getCategoriesByType(CategoryType type);

  /// Cria uma categoria customizada
  Future<CategoryEntity> createCategory(CategoryEntity category);

  /// Atualiza uma categoria
  Future<CategoryEntity> updateCategory(CategoryEntity category);

  /// Deleta uma categoria (apenas customizadas)
  Future<void> deleteCategory(String id);

  // ==================== BUDGETS ====================

  /// Busca todos os orçamentos do usuário
  Future<List<BudgetEntity>> getBudgets(String userId);

  /// Busca orçamentos ativos
  Future<List<BudgetEntity>> getActiveBudgets(String userId);

  /// Cria um novo orçamento
  Future<BudgetEntity> createBudget(BudgetEntity budget);

  /// Atualiza um orçamento
  Future<BudgetEntity> updateBudget(BudgetEntity budget);

  /// Deleta um orçamento
  Future<void> deleteBudget(String id);

  // ==================== FINANCIAL GOALS ====================

  /// Busca todas as metas do usuário
  Future<List<FinancialGoalEntity>> getFinancialGoals(String userId);

  /// Busca metas ativas
  Future<List<FinancialGoalEntity>> getActiveGoals(String userId);

  /// Cria uma nova meta
  Future<FinancialGoalEntity> createFinancialGoal(FinancialGoalEntity goal);

  /// Atualiza uma meta
  Future<FinancialGoalEntity> updateFinancialGoal(FinancialGoalEntity goal);

  /// Deleta uma meta
  Future<void> deleteFinancialGoal(String id);

  // ==================== ANALYTICS ====================

  /// Calcula total de receitas e despesas de um período
  Future<Map<String, double>> getFinancialSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Calcula gastos por categoria
  Future<Map<String, double>> getExpensesByCategory({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });
}
