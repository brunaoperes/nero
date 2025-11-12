import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

/// Serviço para integração com OpenAI ChatGPT
/// Usado para sugestões inteligentes de tarefas
class OpenAIService {
  // API Key do OpenAI - IMPORTANTE: Mover para variáveis de ambiente em produção
  static const String _apiKey = 'SUA_API_KEY_AQUI'; // TODO: Configurar no .env
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';
  static const String _model = 'gpt-3.5-turbo'; // ou 'gpt-4' para melhor qualidade

  /// Sugere título, prioridade e data para uma tarefa baseado no contexto fornecido
  ///
  /// [context] - Contexto opcional que o usuário forneceu (ex: descrição inicial)
  /// Retorna um TaskSuggestion com título, prioridade e data sugeridos
  static Future<TaskSuggestion> suggestTask({String? context}) async {
    try {
      // Construir o prompt para o ChatGPT
      final prompt = _buildPrompt(context);

      // Fazer chamada à API do OpenAI
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'model': _model,
          'messages': [
            {
              'role': 'system',
              'content': '''Você é um assistente de produtividade do app Nero.
Sua função é sugerir título, prioridade e data para tarefas baseado no contexto fornecido pelo usuário.

Regras:
- Título: máximo 60 caracteres, conciso e acionável
- Prioridade: "low", "medium" ou "high"
- Data: formato ISO 8601 (YYYY-MM-DDTHH:mm:ss) ou "today", "tomorrow", "next_week"
- Se o contexto estiver vazio, sugira uma tarefa genérica útil

Retorne APENAS um JSON válido neste formato:
{
  "title": "título da tarefa",
  "priority": "medium",
  "dueDate": "2025-11-10T09:00:00",
  "reasoning": "breve explicação da sugestão"
}'''
            },
            {
              'role': 'user',
              'content': prompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 200,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'] as String;

        // Parse a resposta JSON do ChatGPT
        final suggestion = jsonDecode(content);

        return TaskSuggestion(
          title: suggestion['title'] as String,
          priority: suggestion['priority'] as String,
          dueDate: _parseDueDate(suggestion['dueDate'] as String),
          reasoning: suggestion['reasoning'] as String? ?? '',
        );
      } else if (response.statusCode == 401) {
        throw Exception(
            'API Key inválida. Configure a chave da OpenAI no arquivo openai_service.dart');
      } else if (response.statusCode == 429) {
        throw Exception('Limite de requisições excedido. Tente novamente mais tarde.');
      } else {
        throw Exception('Erro ao chamar API OpenAI: ${response.statusCode}');
      }
    } catch (e) {
      // Em caso de erro, retornar uma sugestão padrão
      debugPrint('Erro ao sugerir tarefa com IA: $e');

      // Se for erro de API key, lançar exceção específica
      if (e.toString().contains('API Key')) {
        rethrow;
      }

      // Caso contrário, retornar sugestão padrão
      return _getDefaultSuggestion(context);
    }
  }

  /// Constrói o prompt para o ChatGPT baseado no contexto
  static String _buildPrompt(String? context) {
    if (context == null || context.trim().isEmpty) {
      return 'Sugira uma tarefa útil para hoje que ajude com produtividade pessoal.';
    }

    return '''Contexto fornecido pelo usuário: "$context"

Com base neste contexto, sugira:
1. Um título claro e acionável para a tarefa
2. A prioridade adequada (low, medium ou high)
3. Uma data/hora apropriada para conclusão''';
  }

  /// Parse a data sugerida pelo ChatGPT
  static DateTime _parseDueDate(String dateStr) {
    try {
      // Casos especiais
      switch (dateStr.toLowerCase()) {
        case 'today':
          return DateTime.now().add(const Duration(hours: 2));
        case 'tomorrow':
          return DateTime.now().add(const Duration(days: 1));
        case 'next_week':
          return DateTime.now().add(const Duration(days: 7));
        default:
          // Tentar parse ISO 8601
          return DateTime.parse(dateStr);
      }
    } catch (e) {
      // Fallback: 2 horas a partir de agora
      return DateTime.now().add(const Duration(hours: 2));
    }
  }

  /// Retorna uma sugestão padrão quando a IA falha
  static TaskSuggestion _getDefaultSuggestion(String? context) {
    // Sugestões padrão baseadas em palavras-chave no contexto
    if (context != null) {
      final lowerContext = context.toLowerCase();

      if (lowerContext.contains('reunião') || lowerContext.contains('meeting')) {
        return TaskSuggestion(
          title: 'Preparar reunião',
          priority: 'high',
          dueDate: DateTime.now().add(const Duration(hours: 2)),
          reasoning: 'Sugestão padrão baseada em palavras-chave',
        );
      } else if (lowerContext.contains('email')) {
        return TaskSuggestion(
          title: 'Responder emails importantes',
          priority: 'medium',
          dueDate: DateTime.now().add(const Duration(hours: 1)),
          reasoning: 'Sugestão padrão baseada em palavras-chave',
        );
      } else if (lowerContext.contains('relatório') || lowerContext.contains('report')) {
        return TaskSuggestion(
          title: 'Finalizar relatório',
          priority: 'high',
          dueDate: DateTime.now().add(const Duration(hours: 4)),
          reasoning: 'Sugestão padrão baseada em palavras-chave',
        );
      }
    }

    // Sugestão genérica padrão
    return TaskSuggestion(
      title: 'Revisar tarefas do dia',
      priority: 'medium',
      dueDate: DateTime.now().add(const Duration(hours: 2)),
      reasoning: 'Sugestão padrão genérica',
    );
  }

  /// Valida se a API Key está configurada
  static bool isConfigured() {
    return _apiKey != 'SUA_API_KEY_AQUI' && _apiKey.isNotEmpty;
  }
}

/// Modelo de sugestão de tarefa retornado pela IA
class TaskSuggestion {
  final String title;
  final String priority; // 'low', 'medium', 'high'
  final DateTime dueDate;
  final String reasoning; // Explicação da IA sobre a sugestão

  TaskSuggestion({
    required this.title,
    required this.priority,
    required this.dueDate,
    this.reasoning = '',
  });

  /// Retorna o TimeOfDay extraído da dueDate
  TimeOfDay get dueTime => TimeOfDay.fromDateTime(dueDate);

  @override
  String toString() {
    return 'TaskSuggestion(title: $title, priority: $priority, dueDate: $dueDate)';
  }
}
