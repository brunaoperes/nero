import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/utils/string_utils.dart';
import '../../../../shared/models/transaction_model.dart';
import '../../domain/models/transaction_suggestion_model.dart';

/// Repositório para buscar sugestões inteligentes de transações
class TransactionSuggestionsRepository {
  static const int _maxSuggestions = 5;
  static const double _minSimilarityThreshold = 0.3; // 30% de similaridade mínima

  /// Verifica se a descrição casa com a query usando tokenização rigorosa
  ///
  /// Regras:
  /// 1. O primeiro token da query deve ser prefixo da descrição
  /// 2. Todos os tokens da query devem aparecer na descrição (AND)
  /// 3. Match case-insensitive e sem acentos
  bool _matchesWithTokens(String normalizedDesc, String normalizedQuery) {
    // Tokenizar por espaços
    final queryTokens = normalizedQuery.trim().split(RegExp(r'\s+'));
    if (queryTokens.isEmpty) return false;

    // Primeiro token deve ser prefixo
    if (!normalizedDesc.startsWith(queryTokens[0])) {
      return false;
    }

    // Todos os tokens devem aparecer (AND)
    return queryTokens.every((token) => normalizedDesc.contains(token));
  }

  /// Busca sugestões de transações baseadas em uma query
  ///
  /// Aplica busca fuzzy (tolerante a erros) e retorna até [_maxSuggestions]
  /// resultados ordenados por score de match e recência.
  ///
  /// [type] - Filtrar por tipo: 'expense', 'income', ou 'transfer'
  /// Se [type] for 'transfer', retorna lista vazia (não há sugestões para transferências)
  Future<List<TransactionSuggestion>> searchSuggestions(
    String query, {
    String? type,
  }) async {
    if (query.trim().isEmpty) {
      return [];
    }

    // Não mostrar sugestões para transferências
    if (type == 'transfer') {
      return [];
    }

    final normalizedQuery = normalizeForSearch(query);

    // Buscar todas as transações do Hive
    final box = Hive.box('transactions');
    final allTransactions = box.values
        .map((json) => TransactionModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .where((t) {
          // Filtrar por tipo se especificado
          if (type != null && type.isNotEmpty) {
            return t.type == type;
          }
          return true;
        })
        .toList();

    // Map para agrupar por descrição normalizada (evitar duplicatas)
    final Map<String, _TransactionGroup> groups = {};

    for (final transaction in allTransactions) {
      if (transaction.description == null || transaction.description!.isEmpty) {
        continue;
      }

      final normalizedDesc = normalizeForSearch(transaction.description!);

      // Calcular score de match usando tokenização rigorosa
      double score = 0.0;

      // 1. Match rigoroso com todos os tokens (AND) - PRIORIDADE
      if (_matchesWithTokens(normalizedDesc, normalizedQuery)) {
        // Score baseado em quão próximo está do início
        if (normalizedDesc == normalizedQuery) {
          score = 1.0; // Match exato
        } else if (normalizedDesc.startsWith(normalizedQuery)) {
          score = 0.95; // Prefixo exato
        } else {
          score = 0.85; // Todos os tokens presentes
        }
      }
      // 2. Fallback: similaridade fuzzy apenas se for query de 1 token
      else if (normalizedQuery.split(RegExp(r'\s+')).length == 1) {
        final similarity = similarityScore(normalizedDesc, normalizedQuery);
        if (similarity >= _minSimilarityThreshold) {
          score = similarity * 0.6; // Peso menor para similaridade fuzzy
        }
      }

      // Ignorar se score muito baixo
      if (score < _minSimilarityThreshold) {
        continue;
      }

      // Agrupar por descrição normalizada (pegar a mais recente de cada grupo)
      if (!groups.containsKey(normalizedDesc) ||
          groups[normalizedDesc]!.transaction.date!.isBefore(transaction.date!)) {
        groups[normalizedDesc] = _TransactionGroup(
          transaction: transaction,
          score: score,
        );
      }
    }

    // Converter para lista de sugestões
    final suggestions = groups.values.map((group) {
      return TransactionSuggestion.fromTransaction(
        group.transaction,
        matchScore: group.score,
      );
    }).toList();

    // Ordenar por score (descendente) e depois por recência (descendente)
    suggestions.sort((a, b) {
      final scoreComparison = b.matchScore.compareTo(a.matchScore);
      if (scoreComparison != 0) return scoreComparison;
      return b.lastUsedAt.compareTo(a.lastUsedAt);
    });

    // Retornar top N sugestões
    return suggestions.take(_maxSuggestions).toList();
  }

  /// Busca as transações mais recentes (para fallback quando não há query)
  Future<List<TransactionSuggestion>> getRecentTransactions({int limit = 5}) async {
    final box = Hive.box('transactions');
    final allTransactions = box.values
        .map((json) => TransactionModel.fromJson(Map<String, dynamic>.from(json as Map)))
        .where((t) => t.description != null && t.description!.isNotEmpty)
        .toList();

    // Agrupar por descrição (evitar duplicatas)
    final Map<String, TransactionModel> uniqueByDescription = {};
    for (final transaction in allTransactions) {
      final normalizedDesc = normalizeForSearch(transaction.description!);
      if (!uniqueByDescription.containsKey(normalizedDesc) ||
          uniqueByDescription[normalizedDesc]!.date!.isBefore(transaction.date!)) {
        uniqueByDescription[normalizedDesc] = transaction;
      }
    }

    // Ordenar por data (mais recentes primeiro)
    final sortedTransactions = uniqueByDescription.values.toList()
      ..sort((a, b) => b.date!.compareTo(a.date!));

    // Converter para sugestões
    return sortedTransactions.take(limit).map((t) {
      return TransactionSuggestion.fromTransaction(t, matchScore: 1.0);
    }).toList();
  }
}

/// Classe auxiliar para agrupar transações com seus scores
class _TransactionGroup {
  final TransactionModel transaction;
  final double score;

  _TransactionGroup({
    required this.transaction,
    required this.score,
  });
}
