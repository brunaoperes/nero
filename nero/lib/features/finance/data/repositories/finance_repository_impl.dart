import 'package:uuid/uuid.dart';
import '../../domain/entities/budget_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/financial_goal_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_remote_datasource.dart';

/// Implementação do repositório de finanças
class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceRemoteDatasource _datasource;
  final Uuid _uuid = const Uuid();

  FinanceRepositoryImpl(this._datasource);

  // ==================== TRANSACTIONS ====================

  @override
  Future<List<TransactionEntity>> getTransactions(String userId) async {
    final models = await _datasource.getTransactions(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByPeriod({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final models = await _datasource.getTransactionsByPeriod(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByCategory({
    required String userId,
    required String categoryId,
  }) async {
    final models = await _datasource.getTransactionsByCategory(
      userId: userId,
      categoryId: categoryId,
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<TransactionEntity>> getTransactionsByType({
    required String userId,
    required TransactionType type,
  }) async {
    final models = await _datasource.getTransactionsByType(
      userId: userId,
      type: type.toJson(),
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<TransactionEntity> createTransaction(
      TransactionEntity transaction) async {
    final data = {
      'id': _uuid.v4(),
      'user_id': transaction.userId,
      'title': transaction.title,
      'amount': transaction.amount,
      'type': transaction.type.toJson(),
      'category_id': transaction.categoryId,
      'date': transaction.date.toIso8601String(),
      'description': transaction.description,
      'company_id': transaction.companyId,
      'is_recurring': transaction.isRecurring,
      'recurrence_pattern': transaction.recurrencePattern,
      'next_recurrence_date': transaction.nextRecurrenceDate?.toIso8601String(),
      'ai_category_suggestion': transaction.aiCategorySuggestion,
      'ai_category_confirmed': transaction.aiCategoryConfirmed,
      'attachment_url': transaction.attachmentUrl,
      'metadata': transaction.metadata,
    };

    final model = await _datasource.createTransaction(data);
    return model.toEntity();
  }

  @override
  Future<TransactionEntity> updateTransaction(
      TransactionEntity transaction) async {
    final data = {
      'title': transaction.title,
      'amount': transaction.amount,
      'type': transaction.type.toJson(),
      'category_id': transaction.categoryId,
      'date': transaction.date.toIso8601String(),
      'description': transaction.description,
      'company_id': transaction.companyId,
      'is_recurring': transaction.isRecurring,
      'recurrence_pattern': transaction.recurrencePattern,
      'next_recurrence_date': transaction.nextRecurrenceDate?.toIso8601String(),
      'ai_category_suggestion': transaction.aiCategorySuggestion,
      'ai_category_confirmed': transaction.aiCategoryConfirmed,
      'attachment_url': transaction.attachmentUrl,
      'metadata': transaction.metadata,
    };

    final model = await _datasource.updateTransaction(transaction.id, data);
    return model.toEntity();
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _datasource.deleteTransaction(id);
  }

  // ==================== CATEGORIES ====================

  @override
  Future<List<CategoryEntity>> getCategories(String userId) async {
    final models = await _datasource.getCategories(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<CategoryEntity>> getCategoriesByType(CategoryType type) async {
    final models = await _datasource.getCategoriesByType(type.toJson());
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CategoryEntity> createCategory(CategoryEntity category) async {
    final data = {
      'id': _uuid.v4(),
      'name': category.name,
      'icon': category.icon,
      'color': category.color,
      'type': category.type.toJson(),
      'is_default': false,
      'user_id': category.userId,
    };

    final model = await _datasource.createCategory(data);
    return model.toEntity();
  }

  @override
  Future<CategoryEntity> updateCategory(CategoryEntity category) async {
    final data = {
      'name': category.name,
      'icon': category.icon,
      'color': category.color,
      'type': category.type.toJson(),
    };

    final model = await _datasource.updateCategory(category.id, data);
    return model.toEntity();
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _datasource.deleteCategory(id);
  }

  // ==================== BUDGETS ====================

  @override
  Future<List<BudgetEntity>> getBudgets(String userId) async {
    final models = await _datasource.getBudgets(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<BudgetEntity>> getActiveBudgets(String userId) async {
    final models = await _datasource.getActiveBudgets(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<BudgetEntity> createBudget(BudgetEntity budget) async {
    final data = {
      'id': _uuid.v4(),
      'user_id': budget.userId,
      'category_id': budget.categoryId,
      'limit_amount': budget.limitAmount,
      'period': budget.period.toJson(),
      'start_date': budget.startDate.toIso8601String(),
      'end_date': budget.endDate?.toIso8601String(),
      'is_active': budget.isActive,
      'alert_threshold': budget.alertThreshold,
    };

    final model = await _datasource.createBudget(data);
    return model.toEntity();
  }

  @override
  Future<BudgetEntity> updateBudget(BudgetEntity budget) async {
    final data = {
      'category_id': budget.categoryId,
      'limit_amount': budget.limitAmount,
      'period': budget.period.toJson(),
      'start_date': budget.startDate.toIso8601String(),
      'end_date': budget.endDate?.toIso8601String(),
      'is_active': budget.isActive,
      'alert_threshold': budget.alertThreshold,
    };

    final model = await _datasource.updateBudget(budget.id, data);
    return model.toEntity();
  }

  @override
  Future<void> deleteBudget(String id) async {
    await _datasource.deleteBudget(id);
  }

  // ==================== FINANCIAL GOALS ====================

  @override
  Future<List<FinancialGoalEntity>> getFinancialGoals(String userId) async {
    final models = await _datasource.getFinancialGoals(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<FinancialGoalEntity>> getActiveGoals(String userId) async {
    final models = await _datasource.getActiveGoals(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<FinancialGoalEntity> createFinancialGoal(
      FinancialGoalEntity goal) async {
    final data = {
      'id': _uuid.v4(),
      'user_id': goal.userId,
      'name': goal.name,
      'target_amount': goal.targetAmount,
      'current_amount': goal.currentAmount,
      'target_date': goal.targetDate.toIso8601String(),
      'description': goal.description,
      'icon': goal.icon,
      'color': goal.color,
      'status': goal.status.toJson(),
    };

    final model = await _datasource.createFinancialGoal(data);
    return model.toEntity();
  }

  @override
  Future<FinancialGoalEntity> updateFinancialGoal(
      FinancialGoalEntity goal) async {
    final data = {
      'name': goal.name,
      'target_amount': goal.targetAmount,
      'current_amount': goal.currentAmount,
      'target_date': goal.targetDate.toIso8601String(),
      'description': goal.description,
      'icon': goal.icon,
      'color': goal.color,
      'status': goal.status.toJson(),
      'achieved_date': goal.achievedDate?.toIso8601String(),
    };

    final model = await _datasource.updateFinancialGoal(goal.id, data);
    return model.toEntity();
  }

  @override
  Future<void> deleteFinancialGoal(String id) async {
    await _datasource.deleteFinancialGoal(id);
  }

  // ==================== ANALYTICS ====================

  @override
  Future<Map<String, double>> getFinancialSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _datasource.getFinancialSummary(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }

  @override
  Future<Map<String, double>> getExpensesByCategory({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return await _datasource.getExpensesByCategory(
      userId: userId,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
