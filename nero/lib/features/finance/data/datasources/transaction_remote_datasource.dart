import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/transaction_model.dart';

/// Datasource para operações remotas de transações financeiras
class TransactionRemoteDatasource {
  final SupabaseClient _supabaseClient;

  TransactionRemoteDatasource({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  /// Busca todas as transações do usuário
  Future<List<TransactionModel>> getTransactions({
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
    String? source,
    String? searchQuery,
    String? sortBy,
    bool ascending = false,
  }) async {
    try {
      var query = _supabaseClient
          .from('transactions')
          .select()
          .eq('user_id', _supabaseClient.auth.currentUser!.id);

      // Filtros
      if (type != null) {
        query = query.eq('type', type);
      }

      if (category != null) {
        query = query.eq('category', category);
      }

      if (companyId != null) {
        query = query.eq('company_id', companyId);
      }

      if (source != null) {
        query = query.eq('source', source);
      }

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String());
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('description.ilike.%$searchQuery%,category.ilike.%$searchQuery%');
      }

      // Executar query
      final response = await query;

      // Converter para modelos
      List<TransactionModel> transactions = (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();

      // Aplicar ordenação
      if (sortBy != null) {
        transactions.sort((a, b) {
          dynamic aValue, bValue;
          switch (sortBy) {
            case 'date':
              aValue = a.date;
              bValue = b.date;
              break;
            case 'amount':
              aValue = a.amount;
              bValue = b.amount;
              break;
            case 'category':
              aValue = a.category;
              bValue = b.category;
              break;
            default:
              return 0;
          }

          if (aValue == null && bValue == null) return 0;
          if (aValue == null) return 1;
          if (bValue == null) return -1;

          int comparison = Comparable.compare(aValue as Comparable, bValue as Comparable);
          return ascending ? comparison : -comparison;
        });
      } else {
        // Ordenação padrão: mais recentes primeiro
        transactions.sort((a, b) {
          if (a.date == null && b.date == null) return 0;
          if (a.date == null) return 1;
          if (b.date == null) return -1;
          return b.date!.compareTo(a.date!);
        });
      }

      return transactions;
    } catch (e) {
      throw Exception('Erro ao buscar transações: $e');
    }
  }

  /// Busca transação por ID
  Future<TransactionModel> getTransactionById(String id) async {
    try {
      final response = await _supabaseClient
          .from('transactions')
          .select()
          .eq('id', id)
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      return TransactionModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar transação: $e');
    }
  }

  /// Cria nova transação
  Future<TransactionModel> createTransaction(TransactionModel transaction) async {
    try {
      final jsonData = transaction.toJson();

      // Remove campos que não existem na tabela do Supabase
      jsonData.remove('attachments');

      final response = await _supabaseClient
          .from('transactions')
          .insert(jsonData)
          .select()
          .single();

      return TransactionModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar transação: $e');
    }
  }

  /// Atualiza transação existente
  Future<TransactionModel> updateTransaction(TransactionModel transaction) async {
    try {
      final jsonData = transaction.toJson();

      // Remove campos que não existem na tabela do Supabase
      jsonData.remove('attachments');

      final response = await _supabaseClient
          .from('transactions')
          .update(jsonData)
          .eq('id', transaction.id)
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .select()
          .single();

      return TransactionModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar transação: $e');
    }
  }

  /// Deleta transação
  Future<void> deleteTransaction(String id) async {
    try {
      await _supabaseClient
          .from('transactions')
          .delete()
          .eq('id', id)
          .eq('user_id', _supabaseClient.auth.currentUser!.id);
    } catch (e) {
      throw Exception('Erro ao deletar transação: $e');
    }
  }

  /// Confirma categoria sugerida pela IA
  Future<TransactionModel> confirmCategory(String id, String category) async {
    try {
      final response = await _supabaseClient
          .from('transactions')
          .update({
            'category': category,
            'category_confirmed': true,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .select()
          .single();

      return TransactionModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao confirmar categoria: $e');
    }
  }

  /// Busca transações do mês atual
  Future<List<TransactionModel>> getCurrentMonthTransactions() async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);
      final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

      final response = await _supabaseClient
          .from('transactions')
          .select()
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .gte('date', startOfMonth.toIso8601String())
          .lte('date', endOfMonth.toIso8601String())
          .order('date', ascending: false);

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar transações do mês: $e');
    }
  }

  /// Busca estatísticas de transações
  Future<Map<String, dynamic>> getTransactionStats({
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser!.id;

      var query = _supabaseClient
          .from('transactions')
          .select()
          .eq('user_id', userId);

      if (companyId != null) {
        query = query.eq('company_id', companyId);
      }

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String());
      }

      final response = await query;
      final transactions = (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();

      final totalIncome = transactions
          .where((t) => t.type == 'income')
          .fold<double>(0, (sum, t) => sum + t.amount);

      final totalExpense = transactions
          .where((t) => t.type == 'expense')
          .fold<double>(0, (sum, t) => sum + t.amount);

      final balance = totalIncome - totalExpense;

      return {
        'total_transactions': transactions.length,
        'total_income': totalIncome,
        'total_expense': totalExpense,
        'balance': balance,
        'income_count': transactions.where((t) => t.type == 'income').length,
        'expense_count': transactions.where((t) => t.type == 'expense').length,
      };
    } catch (e) {
      throw Exception('Erro ao buscar estatísticas: $e');
    }
  }

  /// Busca total de receitas e despesas
  Future<Map<String, double>> getIncomeExpenseSummary({
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
  }) async {
    try {
      final stats = await getTransactionStats(
        startDate: startDate,
        endDate: endDate,
        companyId: companyId,
      );

      return {
        'income': stats['total_income'] as double,
        'expense': stats['total_expense'] as double,
        'balance': stats['balance'] as double,
      };
    } catch (e) {
      throw Exception('Erro ao buscar resumo financeiro: $e');
    }
  }

  /// Busca transações por categoria
  Future<Map<String, double>> getTransactionsByCategory({
    String? type,
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
  }) async {
    try {
      final userId = _supabaseClient.auth.currentUser!.id;

      var query = _supabaseClient
          .from('transactions')
          .select()
          .eq('user_id', userId);

      if (type != null) {
        query = query.eq('type', type);
      }

      if (companyId != null) {
        query = query.eq('company_id', companyId);
      }

      if (startDate != null) {
        query = query.gte('date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('date', endDate.toIso8601String());
      }

      final response = await query;
      final transactions = (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();

      // Agrupar por categoria
      final Map<String, double> categoryTotals = {};
      for (var transaction in transactions) {
        final category = transaction.category ?? 'Sem Categoria';
        categoryTotals[category] = (categoryTotals[category] ?? 0) + transaction.amount;
      }

      return categoryTotals;
    } catch (e) {
      throw Exception('Erro ao buscar transações por categoria: $e');
    }
  }
}
