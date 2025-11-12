import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../constants/app_constants.dart';

/// Modelo de resposta de categorização de transação
class TransactionCategorizationResponse {
  final String category;
  final double confidence;
  final String reasoning;

  TransactionCategorizationResponse({
    required this.category,
    required this.confidence,
    required this.reasoning,
  });

  factory TransactionCategorizationResponse.fromJson(Map<String, dynamic> json) {
    return TransactionCategorizationResponse(
      category: json['category'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      reasoning: json['reasoning'] as String,
    );
  }
}

/// Modelo de recomendação de IA
class AIRecommendation {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String description;
  final String priority;
  final double confidence;
  final int score;
  final bool isRead;
  final bool isDismissed;
  final String? actionTaken;
  final DateTime? actionTakenAt;
  final Map<String, dynamic>? metadata;
  final DateTime? expiresAt;
  final DateTime createdAt;

  AIRecommendation({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    required this.priority,
    required this.confidence,
    required this.score,
    required this.isRead,
    required this.isDismissed,
    this.actionTaken,
    this.actionTakenAt,
    this.metadata,
    this.expiresAt,
    required this.createdAt,
  });

  factory AIRecommendation.fromJson(Map<String, dynamic> json) {
    return AIRecommendation(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      priority: json['priority'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      score: json['score'] as int? ?? 0,
      isRead: json['is_read'] as bool,
      isDismissed: json['is_dismissed'] as bool,
      actionTaken: json['action_taken'] as String?,
      actionTakenAt: json['action_taken_at'] != null
          ? DateTime.parse(json['action_taken_at'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  // Helpers
  bool get isAccepted => actionTaken == 'accepted';
  bool get isRejected => actionTaken == 'rejected';
  bool get isCompleted => actionTaken == 'completed';
  bool get isIgnored => actionTaken == 'ignored';
  bool get hasAction => actionTaken != null;

  Color getPriorityColor() {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData getTypeIcon() {
    switch (type) {
      case 'task':
        return Icons.task_alt;
      case 'financial':
        return Icons.attach_money;
      case 'productivity':
        return Icons.trending_up;
      case 'alert':
        return Icons.warning_amber;
      default:
        return Icons.lightbulb_outline;
    }
  }
}

/// Modelo de resposta de recomendações
class RecommendationsResponse {
  final List<AIRecommendation> recommendations;
  final List<String> insights;

  RecommendationsResponse({
    required this.recommendations,
    required this.insights,
  });

  factory RecommendationsResponse.fromJson(Map<String, dynamic> json) {
    return RecommendationsResponse(
      recommendations: (json['recommendations'] as List)
          .map((r) => AIRecommendation.fromJson(r as Map<String, dynamic>))
          .toList(),
      insights: (json['insights'] as List).map((i) => i as String).toList(),
    );
  }
}

/// Modelo de estatísticas de recomendações
class RecommendationStats {
  final int total;
  final int unread;
  final int dismissed;
  final int accepted;
  final int completed;
  final int rejected;
  final Map<String, int> byType;
  final Map<String, int> byPriority;

  RecommendationStats({
    required this.total,
    required this.unread,
    required this.dismissed,
    required this.accepted,
    required this.completed,
    required this.rejected,
    required this.byType,
    required this.byPriority,
  });

  factory RecommendationStats.fromJson(Map<String, dynamic> json) {
    return RecommendationStats(
      total: json['total'] as int? ?? 0,
      unread: json['unread'] as int? ?? 0,
      dismissed: json['dismissed'] as int? ?? 0,
      accepted: json['accepted'] as int? ?? 0,
      completed: json['completed'] as int? ?? 0,
      rejected: json['rejected'] as int? ?? 0,
      byType: Map<String, int>.from(json['byType'] as Map? ?? {}),
      byPriority: Map<String, int>.from(json['byPriority'] as Map? ?? {}),
    );
  }
}

/// Exceção personalizada para erros da API de IA
class AIServiceException implements Exception {
  final String message;
  final int? statusCode;

  AIServiceException(this.message, [this.statusCode]);

  @override
  String toString() => 'AIServiceException: $message (Status: $statusCode)';
}

/// Serviço de integração com o backend de IA (Node.js + OpenAI)
class AIService {
  final String baseUrl;
  final String apiKey;

  AIService({
    String? baseUrl,
    String? apiKey,
  })  : baseUrl = baseUrl ?? AppConstants.backendApiUrl,
        apiKey = apiKey ?? AppConstants.backendApiKey;

  /// Headers padrão para requisições autenticadas
  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
      };

  /// Categoriza uma transação usando GPT-4
  Future<TransactionCategorizationResponse> categorizeTransaction({
    required String description,
    required double amount,
    required String type,
    required String userId,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/ai/categorize-transaction');

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'description': description,
          'amount': amount,
          'type': type,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonData['success'] == true) {
          return TransactionCategorizationResponse.fromJson(
            jsonData['data'] as Map<String, dynamic>,
          );
        } else {
          throw AIServiceException(
            jsonData['error'] as String? ?? 'Erro desconhecido',
            response.statusCode,
          );
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        throw AIServiceException('API Key inválida ou ausente', response.statusCode);
      } else {
        final error = jsonDecode(response.body)['error'] as String? ?? 'Erro ao categorizar transação';
        throw AIServiceException(error, response.statusCode);
      }
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('Erro ao conectar com o servidor de IA: $e');
    }
  }

  /// Categoriza múltiplas transações em lote
  Future<List<TransactionCategorizationResponse>> categorizeBatch({
    required List<Map<String, dynamic>> transactions,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/ai/categorize-batch');

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode({
          'transactions': transactions,
        }),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonData['success'] == true) {
          final data = jsonData['data'] as List;
          return data
              .map((item) => TransactionCategorizationResponse.fromJson(
                    item as Map<String, dynamic>,
                  ))
              .toList();
        } else {
          throw AIServiceException(
            jsonData['error'] as String? ?? 'Erro desconhecido',
            response.statusCode,
          );
        }
      } else {
        final error = jsonDecode(response.body)['error'] as String? ?? 'Erro ao categorizar lote';
        throw AIServiceException(error, response.statusCode);
      }
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('Erro ao conectar com o servidor de IA: $e');
    }
  }

  /// Gera recomendações personalizadas para o usuário
  Future<RecommendationsResponse> generateRecommendations({
    required String userId,
    Map<String, dynamic>? context,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/ai/recommendations');

      final body = <String, dynamic>{
        'user_id': userId,
      };

      if (context != null) {
        body['context'] = context;
      }

      final response = await http.post(
        url,
        headers: _headers,
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonData['success'] == true) {
          return RecommendationsResponse.fromJson(
            jsonData['data'] as Map<String, dynamic>,
          );
        } else {
          throw AIServiceException(
            jsonData['error'] as String? ?? 'Erro desconhecido',
            response.statusCode,
          );
        }
      } else {
        final error = jsonDecode(response.body)['error'] as String? ?? 'Erro ao gerar recomendações';
        throw AIServiceException(error, response.statusCode);
      }
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('Erro ao conectar com o servidor de IA: $e');
    }
  }

  /// Busca recomendações do usuário
  Future<List<AIRecommendation>> getUserRecommendations({
    required String userId,
    int? limit,
    bool includeRead = false,
    bool includeDismissed = false,
    String? type,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (limit != null) queryParams['limit'] = limit.toString();
      queryParams['includeRead'] = includeRead.toString();
      queryParams['includeDismissed'] = includeDismissed.toString();
      if (type != null) queryParams['type'] = type;

      final url = Uri.parse('$baseUrl/ai/recommendations/$userId')
          .replace(queryParameters: queryParams);

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonData['success'] == true) {
          final data = jsonData['data'] as List;
          return data
              .map((item) => AIRecommendation.fromJson(item as Map<String, dynamic>))
              .toList();
        } else {
          throw AIServiceException(
            jsonData['error'] as String? ?? 'Erro desconhecido',
            response.statusCode,
          );
        }
      } else {
        final error = jsonDecode(response.body)['error'] as String? ??
            'Erro ao buscar recomendações';
        throw AIServiceException(error, response.statusCode);
      }
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('Erro ao conectar com o servidor de IA: $e');
    }
  }

  /// Marca recomendação como lida
  Future<bool> markAsRead(String recommendationId, String userId) async {
    try {
      final url = Uri.parse('$baseUrl/ai/recommendations/$recommendationId/read');

      final response = await http.patch(
        url,
        headers: _headers,
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonData['success'] == true;
      } else {
        throw AIServiceException(
          'Erro ao marcar como lida',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('Erro ao conectar com o servidor de IA: $e');
    }
  }

  /// Aceita uma recomendação
  Future<bool> acceptRecommendation(String recommendationId, String userId) async {
    try {
      final url = Uri.parse('$baseUrl/ai/recommendations/$recommendationId/accept');

      final response = await http.patch(
        url,
        headers: _headers,
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonData['success'] == true;
      } else {
        throw AIServiceException(
          'Erro ao aceitar recomendação',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('Erro ao conectar com o servidor de IA: $e');
    }
  }

  /// Rejeita uma recomendação
  Future<bool> rejectRecommendation(String recommendationId, String userId) async {
    try {
      final url = Uri.parse('$baseUrl/ai/recommendations/$recommendationId/reject');

      final response = await http.patch(
        url,
        headers: _headers,
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonData['success'] == true;
      } else {
        throw AIServiceException(
          'Erro ao rejeitar recomendação',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('Erro ao conectar com o servidor de IA: $e');
    }
  }

  /// Marca recomendação como completada
  Future<bool> completeRecommendation(String recommendationId, String userId) async {
    try {
      final url = Uri.parse('$baseUrl/ai/recommendations/$recommendationId/complete');

      final response = await http.patch(
        url,
        headers: _headers,
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonData['success'] == true;
      } else {
        throw AIServiceException(
          'Erro ao completar recomendação',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('Erro ao conectar com o servidor de IA: $e');
    }
  }

  /// Dispensa uma recomendação
  Future<bool> dismissRecommendation(String recommendationId, String userId) async {
    try {
      final url = Uri.parse('$baseUrl/ai/recommendations/$recommendationId/dismiss');

      final response = await http.patch(
        url,
        headers: _headers,
        body: jsonEncode({'user_id': userId}),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;
        return jsonData['success'] == true;
      } else {
        throw AIServiceException(
          'Erro ao dispensar recomendação',
          response.statusCode,
        );
      }
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('Erro ao conectar com o servidor de IA: $e');
    }
  }

  /// Obtém estatísticas de recomendações
  Future<RecommendationStats> getRecommendationStats(String userId) async {
    try {
      final url = Uri.parse('$baseUrl/ai/recommendations/$userId/stats');

      final response = await http.get(url, headers: _headers);

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body) as Map<String, dynamic>;

        if (jsonData['success'] == true) {
          return RecommendationStats.fromJson(
            jsonData['data'] as Map<String, dynamic>,
          );
        } else {
          throw AIServiceException(
            jsonData['error'] as String? ?? 'Erro desconhecido',
            response.statusCode,
          );
        }
      } else {
        final error = jsonDecode(response.body)['error'] as String? ??
            'Erro ao buscar estatísticas';
        throw AIServiceException(error, response.statusCode);
      }
    } catch (e) {
      if (e is AIServiceException) rethrow;
      throw AIServiceException('Erro ao conectar com o servidor de IA: $e');
    }
  }

  /// Verifica o status do backend de IA
  Future<bool> checkHealth() async {
    try {
      final url = Uri.parse('${baseUrl.replaceAll('/api', '')}/health');

      final response = await http.get(url);

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
