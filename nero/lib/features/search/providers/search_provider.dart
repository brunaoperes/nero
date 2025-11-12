import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../tasks/providers/tasks_provider.dart';
import '../../finances/providers/transactions_provider.dart';
import '../../companies/providers/companies_provider.dart';

/// Tipo de resultado de busca
enum SearchResultType {
  task,
  transaction,
  company,
}

/// Resultado de busca genérico
class SearchResult {
  final String id;
  final String title;
  final String? subtitle;
  final SearchResultType type;
  final DateTime? date;
  final dynamic data;

  SearchResult({
    required this.id,
    required this.title,
    this.subtitle,
    required this.type,
    this.date,
    this.data,
  });
}

/// Provider de busca global
final searchQueryProvider = StateProvider<String>((ref) => '');

/// Provider de resultados de busca
final searchResultsProvider = Provider<List<SearchResult>>((ref) {
  final query = ref.watch(searchQueryProvider).toLowerCase().trim();

  if (query.isEmpty || query.length < 2) {
    return [];
  }

  final results = <SearchResult>[];

  // Buscar em tarefas
  final tasks = ref.watch(tasksProvider);
  for (final task in tasks) {
    if (_matchesQuery(task.title, query) ||
        (task.description != null && _matchesQuery(task.description!, query))) {
      results.add(SearchResult(
        id: task.id,
        title: task.title,
        subtitle: task.description,
        type: SearchResultType.task,
        date: task.dueDate,
        data: task,
      ));
    }
  }

  // Buscar em transações
  final transactions = ref.watch(transactionsProvider);
  for (final transaction in transactions) {
    if (_matchesQuery(transaction.description ?? '', query) ||
        (transaction.category != null && _matchesQuery(transaction.category!, query))) {
      results.add(SearchResult(
        id: transaction.id,
        title: transaction.description ?? 'Sem descrição',
        subtitle: transaction.category,
        type: SearchResultType.transaction,
        date: transaction.date,
        data: transaction,
      ));
    }
  }

  // Buscar em empresas
  final companies = ref.watch(companiesProvider);
  for (final company in companies) {
    if (_matchesQuery(company.name, query) ||
        (company.description != null && _matchesQuery(company.description!, query))) {
      results.add(SearchResult(
        id: company.id,
        title: company.name,
        subtitle: company.description,
        type: SearchResultType.company,
        date: company.createdAt,
        data: company,
      ));
    }
  }

  // Ordenar por relevância (mais recentes primeiro)
  results.sort((a, b) {
    if (a.date == null && b.date == null) return 0;
    if (a.date == null) return 1;
    if (b.date == null) return -1;
    return b.date!.compareTo(a.date!);
  });

  return results;
});

/// Resultados agrupados por tipo
final groupedSearchResultsProvider = Provider<Map<SearchResultType, List<SearchResult>>>((ref) {
  final results = ref.watch(searchResultsProvider);

  final grouped = <SearchResultType, List<SearchResult>>{
    SearchResultType.task: [],
    SearchResultType.transaction: [],
    SearchResultType.company: [],
  };

  for (final result in results) {
    grouped[result.type]!.add(result);
  }

  return grouped;
});

/// Verifica se o texto corresponde à query (fuzzy search simples)
bool _matchesQuery(String text, String query) {
  final textLower = text.toLowerCase();
  final words = query.split(' ');

  // Verifica se todas as palavras da query estão no texto
  return words.every((word) => textLower.contains(word));
}

/// Provider de histórico de buscas
final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});

/// Notifier para gerenciar histórico de buscas
class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]);

  /// Adiciona uma busca ao histórico
  void addSearch(String query) {
    if (query.isEmpty || query.length < 2) return;

    // Remove se já existe
    state = state.where((s) => s != query).toList();

    // Adiciona no início
    state = [query, ...state];

    // Limita a 10 itens
    if (state.length > 10) {
      state = state.sublist(0, 10);
    }
  }

  /// Remove uma busca do histórico
  void removeSearch(String query) {
    state = state.where((s) => s != query).toList();
  }

  /// Limpa todo o histórico
  void clearHistory() {
    state = [];
  }
}
