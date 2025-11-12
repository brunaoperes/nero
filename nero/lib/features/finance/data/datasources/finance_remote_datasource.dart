import 'package:logger/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/budget_model.dart';
import '../models/category_model.dart';
import '../models/financial_goal_model.dart';
import '../models/transaction_model.dart';

/// Datasource responsável por buscar dados financeiros do Supabase
class FinanceRemoteDatasource {
  final SupabaseClient _supabase;
  final Logger _logger = Logger();

  FinanceRemoteDatasource(this._supabase);

  // ==================== TRANSACTIONS ====================

  /// Busca todas as transações do usuário
  Future<List<TransactionModel>> getTransactions(String userId) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select('*')
          .eq('user_id', userId)
          .order('date', ascending: false);

      _logger.d('Transações obtidas: ${response.length}');

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e('Erro ao buscar transações', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Busca transações por período
  Future<List<TransactionModel>> getTransactionsByPeriod({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select('*')
          .eq('user_id', userId)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date', ascending: false);

      _logger.d('Transações do período: ${response.length}');

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e('Erro ao buscar transações por período',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Busca transações por categoria
  Future<List<TransactionModel>> getTransactionsByCategory({
    required String userId,
    required String categoryId,
  }) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select('*')
          .eq('user_id', userId)
          .eq('category_id', categoryId)
          .order('date', ascending: false);

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e('Erro ao buscar transações por categoria',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Busca transações por tipo (receita ou despesa)
  Future<List<TransactionModel>> getTransactionsByType({
    required String userId,
    required String type,
  }) async {
    try {
      final response = await _supabase
          .from('transactions')
          .select('*')
          .eq('user_id', userId)
          .eq('type', type)
          .order('date', ascending: false);

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e('Erro ao buscar transações por tipo',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Cria uma nova transação
  Future<TransactionModel> createTransaction(
      Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('transactions')
          .insert(data)
          .select()
          .single();

      _logger.d('Transação criada: ${response['id']}');

      return TransactionModel.fromJson(response);
    } catch (e, stack) {
      _logger.e('Erro ao criar transação', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Atualiza uma transação
  Future<TransactionModel> updateTransaction(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _supabase
          .from('transactions')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      _logger.d('Transação atualizada: $id');

      return TransactionModel.fromJson(response);
    } catch (e, stack) {
      _logger.e('Erro ao atualizar transação', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Deleta uma transação
  Future<void> deleteTransaction(String id) async {
    try {
      await _supabase.from('transactions').delete().eq('id', id);

      _logger.d('Transação deletada: $id');
    } catch (e, stack) {
      _logger.e('Erro ao deletar transação', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // ==================== CATEGORIES ====================

  /// Busca todas as categorias (padrão + customizadas do usuário)
  Future<List<CategoryModel>> getCategories(String userId) async {
    try {
      final response = await _supabase
          .from('categories')
          .select('*')
          .or('is_default.eq.true,user_id.eq.$userId')
          .order('name');

      _logger.d('Categorias obtidas: ${response.length}');

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e('Erro ao buscar categorias', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Busca categorias por tipo (income, expense, both)
  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    try {
      final response = await _supabase
          .from('categories')
          .select('*')
          .or('type.eq.$type,type.eq.both')
          .order('name');

      return (response as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e('Erro ao buscar categorias por tipo',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Cria uma nova categoria customizada
  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('categories')
          .insert(data)
          .select()
          .single();

      _logger.d('Categoria criada: ${response['id']}');

      return CategoryModel.fromJson(response);
    } catch (e, stack) {
      _logger.e('Erro ao criar categoria', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Atualiza uma categoria
  Future<CategoryModel> updateCategory(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _supabase
          .from('categories')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      _logger.d('Categoria atualizada: $id');

      return CategoryModel.fromJson(response);
    } catch (e, stack) {
      _logger.e('Erro ao atualizar categoria', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Deleta uma categoria (apenas customizadas)
  Future<void> deleteCategory(String id) async {
    try {
      await _supabase
          .from('categories')
          .delete()
          .eq('id', id)
          .eq('is_default', false);

      _logger.d('Categoria deletada: $id');
    } catch (e, stack) {
      _logger.e('Erro ao deletar categoria', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // ==================== BUDGETS ====================

  /// Busca todos os orçamentos do usuário
  Future<List<BudgetModel>> getBudgets(String userId) async {
    try {
      final response = await _supabase
          .from('budgets')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _logger.d('Orçamentos obtidos: ${response.length}');

      return (response as List)
          .map((json) => BudgetModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e('Erro ao buscar orçamentos', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Busca orçamentos ativos
  Future<List<BudgetModel>> getActiveBudgets(String userId) async {
    try {
      final response = await _supabase
          .from('budgets')
          .select('*')
          .eq('user_id', userId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => BudgetModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e('Erro ao buscar orçamentos ativos',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Cria um novo orçamento
  Future<BudgetModel> createBudget(Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('budgets')
          .insert(data)
          .select()
          .single();

      _logger.d('Orçamento criado: ${response['id']}');

      return BudgetModel.fromJson(response);
    } catch (e, stack) {
      _logger.e('Erro ao criar orçamento', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Atualiza um orçamento
  Future<BudgetModel> updateBudget(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _supabase
          .from('budgets')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      _logger.d('Orçamento atualizado: $id');

      return BudgetModel.fromJson(response);
    } catch (e, stack) {
      _logger.e('Erro ao atualizar orçamento', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Deleta um orçamento
  Future<void> deleteBudget(String id) async {
    try {
      await _supabase.from('budgets').delete().eq('id', id);

      _logger.d('Orçamento deletado: $id');
    } catch (e, stack) {
      _logger.e('Erro ao deletar orçamento', error: e, stackTrace: stack);
      rethrow;
    }
  }

  // ==================== FINANCIAL GOALS ====================

  /// Busca todas as metas do usuário
  Future<List<FinancialGoalModel>> getFinancialGoals(String userId) async {
    try {
      final response = await _supabase
          .from('financial_goals')
          .select('*')
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      _logger.d('Metas financeiras obtidas: ${response.length}');

      return (response as List)
          .map((json) => FinancialGoalModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e('Erro ao buscar metas financeiras',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Busca metas ativas
  Future<List<FinancialGoalModel>> getActiveGoals(String userId) async {
    try {
      final response = await _supabase
          .from('financial_goals')
          .select('*')
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('target_date');

      return (response as List)
          .map((json) => FinancialGoalModel.fromJson(json))
          .toList();
    } catch (e, stack) {
      _logger.e('Erro ao buscar metas ativas', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Cria uma nova meta
  Future<FinancialGoalModel> createFinancialGoal(
      Map<String, dynamic> data) async {
    try {
      final response = await _supabase
          .from('financial_goals')
          .insert(data)
          .select()
          .single();

      _logger.d('Meta financeira criada: ${response['id']}');

      return FinancialGoalModel.fromJson(response);
    } catch (e, stack) {
      _logger.e('Erro ao criar meta financeira', error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Atualiza uma meta
  Future<FinancialGoalModel> updateFinancialGoal(
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _supabase
          .from('financial_goals')
          .update(data)
          .eq('id', id)
          .select()
          .single();

      _logger.d('Meta financeira atualizada: $id');

      return FinancialGoalModel.fromJson(response);
    } catch (e, stack) {
      _logger.e('Erro ao atualizar meta financeira',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Deleta uma meta
  Future<void> deleteFinancialGoal(String id) async {
    try {
      await _supabase.from('financial_goals').delete().eq('id', id);

      _logger.d('Meta financeira deletada: $id');
    } catch (e, stack) {
      _logger.e('Erro ao deletar meta financeira',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  // ==================== ANALYTICS ====================

  /// Calcula total de receitas e despesas de um período
  Future<Map<String, double>> getFinancialSummary({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactions = await getTransactionsByPeriod(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      double totalIncome = 0;
      double totalExpense = 0;

      for (final transaction in transactions) {
        if (transaction.type == 'income') {
          totalIncome += transaction.amount;
        } else {
          totalExpense += transaction.amount;
        }
      }

      return {
        'income': totalIncome,
        'expense': totalExpense,
        'balance': totalIncome - totalExpense,
      };
    } catch (e, stack) {
      _logger.e('Erro ao calcular resumo financeiro',
          error: e, stackTrace: stack);
      rethrow;
    }
  }

  /// Calcula gastos por categoria
  Future<Map<String, double>> getExpensesByCategory({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      final transactions = await getTransactionsByPeriod(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );

      final Map<String, double> categoryTotals = {};

      for (final transaction in transactions) {
        if (transaction.type == 'expense') {
          categoryTotals[transaction.categoryId] =
              (categoryTotals[transaction.categoryId] ?? 0) +
                  transaction.amount;
        }
      }

      return categoryTotals;
    } catch (e, stack) {
      _logger.e('Erro ao calcular gastos por categoria',
          error: e, stackTrace: stack);
      rethrow;
    }
  }
}
