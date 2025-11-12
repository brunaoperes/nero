import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/ai_service.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../data/datasources/transaction_remote_datasource.dart';
import '../../data/repositories/transaction_repository_impl.dart';
import '../../data/repositories/transaction_suggestions_repository.dart';
import '../../domain/models/time_filter_model.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/usecases/confirm_category.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_transaction_stats.dart';
import '../../domain/usecases/get_transactions.dart';
import '../../domain/usecases/update_transaction.dart';

// ==========================================
// DATASOURCES
// ==========================================

final transactionRemoteDatasourceProvider = Provider<TransactionRemoteDatasource>((ref) {
  return TransactionRemoteDatasource(
    supabaseClient: SupabaseService.client,
  );
});

// ==========================================
// AI SERVICE
// ==========================================

/// Provider do serviço de IA (categorização automática)
final aiServiceProvider = Provider<AIService>((ref) {
  return AIService();
});

// ==========================================
// REPOSITORIES
// ==========================================

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  return TransactionRepositoryImpl(
    remoteDatasource: ref.watch(transactionRemoteDatasourceProvider),
  );
});

/// Provider do repositório de sugestões de transações (autocomplete)
final transactionSuggestionsRepositoryProvider = Provider<TransactionSuggestionsRepository>((ref) {
  return TransactionSuggestionsRepository();
});

// ==========================================
// USECASES
// ==========================================

final getTransactionsUseCaseProvider = Provider<GetTransactions>((ref) {
  return GetTransactions(ref.watch(transactionRepositoryProvider));
});

final createTransactionUseCaseProvider = Provider<CreateTransaction>((ref) {
  return CreateTransaction(ref.watch(transactionRepositoryProvider));
});

final updateTransactionUseCaseProvider = Provider<UpdateTransaction>((ref) {
  return UpdateTransaction(ref.watch(transactionRepositoryProvider));
});

final deleteTransactionUseCaseProvider = Provider<DeleteTransaction>((ref) {
  return DeleteTransaction(ref.watch(transactionRepositoryProvider));
});

final confirmCategoryUseCaseProvider = Provider<ConfirmCategory>((ref) {
  return ConfirmCategory(ref.watch(transactionRepositoryProvider));
});

final getTransactionStatsUseCaseProvider = Provider<GetTransactionStats>((ref) {
  return GetTransactionStats(ref.watch(transactionRepositoryProvider));
});

// ==========================================
// STATE PROVIDERS
// ==========================================

/// Provider para lista de transações
final transactionsListProvider = StateNotifierProvider<TransactionsListNotifier, AsyncValue<List<TransactionModel>>>((ref) {
  return TransactionsListNotifier(ref);
});

/// Notifier para gerenciar lista de transações
class TransactionsListNotifier extends StateNotifier<AsyncValue<List<TransactionModel>>> {
  final Ref _ref;

  TransactionsListNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadTransactions();
  }

  /// Carrega todas as transações
  Future<void> loadTransactions({
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
    // IMPORTANTE: NÃO usar AsyncValue.loading() para evitar flash/rebuild
    // Mantém dados atuais enquanto carrega novos

    try {
      final getTransactions = _ref.read(getTransactionsUseCaseProvider);
      final transactions = await getTransactions(
        type: type,
        category: category,
        startDate: startDate,
        endDate: endDate,
        companyId: companyId,
        source: source,
        searchQuery: searchQuery,
        sortBy: sortBy,
        ascending: ascending,
      );

      state = AsyncValue.data(transactions);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Cria nova transação
  Future<bool> createTransaction(TransactionModel transaction) async {
    try {
      final createTransaction = _ref.read(createTransactionUseCaseProvider);
      await createTransaction(transaction);
      await loadTransactions(); // Recarrega a lista
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Atualiza transação
  Future<bool> updateTransaction(TransactionModel transaction) async {
    try {
      final updateTransaction = _ref.read(updateTransactionUseCaseProvider);
      await updateTransaction(transaction);
      await loadTransactions(); // Recarrega a lista
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Deleta transação
  Future<bool> deleteTransaction(String id) async {
    try {
      final deleteTransaction = _ref.read(deleteTransactionUseCaseProvider);
      await deleteTransaction(id);
      await loadTransactions(); // Recarrega a lista
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Confirma categoria sugerida pela IA
  Future<bool> confirmCategory(String id, String category) async {
    try {
      final confirmCategory = _ref.read(confirmCategoryUseCaseProvider);
      await confirmCategory(id, category);
      await loadTransactions(); // Recarrega a lista
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Busca a última transação com a mesma descrição
  TransactionModel? getLastTransactionByDescription(String description) {
    if (description.trim().isEmpty) return null;

    final transactionsData = state.value;
    if (transactionsData == null || transactionsData.isEmpty) return null;

    // Filtra transações com descrição igual (case-insensitive)
    final matches = transactionsData.where((t) {
      final transactionDesc = t.description?.trim().toLowerCase() ?? '';
      final searchDesc = description.trim().toLowerCase();
      return transactionDesc == searchDesc;
    }).toList();

    if (matches.isEmpty) return null;

    // Ordena por data de criação (mais recente primeiro)
    matches.sort((a, b) {
      final dateA = a.createdAt ?? DateTime(2020);
      final dateB = b.createdAt ?? DateTime(2020);
      return dateB.compareTo(dateA);
    });

    return matches.first;
  }
}

// ==========================================
// FILTROS E BUSCA
// ==========================================

/// Provider para filtro de tipo (income/expense)
final transactionTypeFilterProvider = StateProvider<String?>((ref) => null);

/// Provider para filtro de categoria
final transactionCategoryFilterProvider = StateProvider<String?>((ref) => null);

/// Provider para filtro de data inicial
final transactionStartDateFilterProvider = StateProvider<DateTime?>((ref) => null);

/// Provider para filtro de data final
final transactionEndDateFilterProvider = StateProvider<DateTime?>((ref) => null);

/// Provider para busca
final transactionSearchQueryProvider = StateProvider<String?>((ref) => null);

/// Provider para ordenação
final transactionSortByProvider = StateProvider<String?>((ref) => 'date');

/// Provider para direção da ordenação
final transactionSortAscendingProvider = StateProvider<bool>((ref) => false);

// ==========================================
// TRANSAÇÕES DO MÊS ATUAL
// ==========================================

/// Provider para transações do mês atual
final currentMonthTransactionsProvider = FutureProvider<List<TransactionModel>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return await repository.getCurrentMonthTransactions();
});

// ==========================================
// ESTATÍSTICAS
// ==========================================

/// Provider para estatísticas de transações
final transactionStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final repository = ref.watch(transactionRepositoryProvider);
  return await repository.getTransactionStats();
});

/// Provider para resumo de receitas e despesas
final incomeExpenseSummaryProvider = FutureProvider.family<Map<String, double>, DateRangeParams>(
  (ref, params) async {
    final repository = ref.watch(transactionRepositoryProvider);
    return await repository.getIncomeExpenseSummary(
      startDate: params.startDate,
      endDate: params.endDate,
      companyId: params.companyId,
    );
  },
);

/// Provider para transações por categoria
final transactionsByCategoryProvider = FutureProvider.family<Map<String, double>, CategoryParams>(
  (ref, params) async {
    final repository = ref.watch(transactionRepositoryProvider);
    return await repository.getTransactionsByCategory(
      type: params.type,
      startDate: params.startDate,
      endDate: params.endDate,
      companyId: params.companyId,
    );
  },
);

// ==========================================
// PARAMS CLASSES
// ==========================================

/// Classe de parâmetros para filtro por data
class DateRangeParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? companyId;

  DateRangeParams({
    this.startDate,
    this.endDate,
    this.companyId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DateRangeParams &&
          runtimeType == other.runtimeType &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          companyId == other.companyId;

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode ^ companyId.hashCode;
}

/// Classe de parâmetros para filtro por categoria
class CategoryParams {
  final String? type;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? companyId;

  CategoryParams({
    this.type,
    this.startDate,
    this.endDate,
    this.companyId,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryParams &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          startDate == other.startDate &&
          endDate == other.endDate &&
          companyId == other.companyId;

  @override
  int get hashCode =>
      type.hashCode ^ startDate.hashCode ^ endDate.hashCode ^ companyId.hashCode;
}
