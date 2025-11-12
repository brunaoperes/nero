import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/task_model.dart';

/// Datasource para operações remotas de tarefas
class TaskRemoteDatasource {
  final SupabaseClient _supabaseClient;

  TaskRemoteDatasource({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  /// Busca todas as tarefas do usuário
  Future<List<TaskModel>> getTasks({
    String? status,
    String? origin,
    String? priority,
    String? companyId,
    DateTime? startDate,
    DateTime? endDate,
    String? searchQuery,
    String? sortBy,
    bool ascending = true,
  }) async {
    try {
      var query = _supabaseClient
          .from('tasks')
          .select()
          .eq('user_id', _supabaseClient.auth.currentUser!.id);

      // Filtros
      if (companyId != null) {
        query = query.eq('company_id', companyId);
      }

      if (status != null) {
        if (status == 'completed') {
          query = query.eq('is_completed', true);
        } else if (status == 'pending') {
          query = query.eq('is_completed', false);
        } else if (status == 'overdue') {
          query = query
              .eq('is_completed', false)
              .lt('due_date', DateTime.now().toIso8601String());
        }
      }

      if (origin != null) {
        query = query.eq('origin', origin);
      }

      if (priority != null) {
        query = query.eq('priority', priority);
      }

      if (startDate != null) {
        query = query.gte('due_date', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('due_date', endDate.toIso8601String());
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or('title.ilike.%$searchQuery%,description.ilike.%$searchQuery%');
      }

      // Executar query antes de ordenar
      final response = await query;

      // Ordenar os resultados em memória
      List<TaskModel> tasks = (response as List)
          .map((json) => _convertPriorityToString(json))
          .map((json) => TaskModel.fromJson(json))
          .toList();

      // Aplicar ordenação
      if (sortBy != null) {
        tasks.sort((a, b) {
          dynamic aValue, bValue;
          switch (sortBy) {
            case 'due_date':
              aValue = a.dueDate;
              bValue = b.dueDate;
              break;
            case 'priority':
              aValue = a.priority;
              bValue = b.priority;
              break;
            case 'title':
              aValue = a.title;
              bValue = b.title;
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
        // Ordenação padrão: pendentes primeiro, depois por data
        tasks.sort((a, b) {
          // Primeiro por status (pendentes primeiro)
          if (a.isCompleted != b.isCompleted) {
            return a.isCompleted ? 1 : -1;
          }
          // Depois por data
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      }

      return tasks;
    } catch (e) {
      throw Exception('Erro ao buscar tarefas: $e');
    }
  }

  /// Busca tarefa por ID
  Future<TaskModel> getTaskById(String id) async {
    try {
      final response = await _supabaseClient
          .from('tasks')
          .select()
          .eq('id', id)
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      return TaskModel.fromJson(_convertPriorityToString(response));
    } catch (e) {
      throw Exception('Erro ao buscar tarefa: $e');
    }
  }

  /// Cria nova tarefa
  Future<TaskModel> createTask(TaskModel task) async {
    try {
      print('[TaskRemoteDatasource] 🔵 Iniciando criação de tarefa...');
      print('[TaskRemoteDatasource] 📝 Dados originais: ${task.toJson()}');

      // Remove campos gerados automaticamente pelo banco
      final taskData = task.toJson();
      taskData.remove('id'); // UUID gerado pelo banco
      taskData.remove('created_at'); // DEFAULT NOW()
      taskData.remove('updated_at'); // DEFAULT NOW()

      // Remove campos que não existem no banco (migrations não aplicadas)
      taskData.remove('recurrence_type');
      taskData.remove('location_name');
      taskData.remove('latitude');
      taskData.remove('longitude');

      print('[TaskRemoteDatasource] 🗑️  Campos removidos: id, created_at, updated_at, recurrence_type, location_name, latitude, longitude');

      // Converte priority de string para int (banco espera INTEGER)
      // 'low' → 1, 'medium' → 2, 'high' → 3
      if (taskData['priority'] != null) {
        final priorityStr = taskData['priority'] as String;
        final priorityInt = _priorityToInt(priorityStr);
        taskData['priority'] = priorityInt;
        print('[TaskRemoteDatasource] 🔄 Priority convertida: "$priorityStr" → $priorityInt');
      }

      print('[TaskRemoteDatasource] 📤 Enviando para Supabase: $taskData');

      final response = await _supabaseClient
          .from('tasks')
          .insert(taskData)
          .select()
          .single();

      print('[TaskRemoteDatasource] ✅ Tarefa criada com sucesso! Response: $response');

      return TaskModel.fromJson(_convertPriorityToString(response));
    } catch (e, stack) {
      print('[TaskRemoteDatasource] ❌ ERRO ao criar tarefa: $e');
      print('[TaskRemoteDatasource] 📚 Stack trace: $stack');
      throw Exception('Erro ao criar tarefa: $e');
    }
  }

  /// Converte string de prioridade para inteiro
  int _priorityToInt(String priority) {
    switch (priority.toLowerCase()) {
      case 'low':
        return 1;
      case 'medium':
        return 2;
      case 'high':
        return 3;
      default:
        return 2; // medium por padrão
    }
  }

  /// Converte inteiro de prioridade para string
  String _priorityToString(int priority) {
    switch (priority) {
      case 1:
        return 'low';
      case 3:
        return 'high';
      default:
        return 'medium';
    }
  }

  /// Converte o campo priority de int para string no JSON
  Map<String, dynamic> _convertPriorityToString(Map<String, dynamic> json) {
    if (json['priority'] != null && json['priority'] is int) {
      json['priority'] = _priorityToString(json['priority'] as int);
    }
    return json;
  }

  /// Atualiza tarefa existente
  Future<TaskModel> updateTask(TaskModel task) async {
    try {
      final taskData = task.toJson();

      // Remove campos que não existem no banco (migrations não aplicadas)
      taskData.remove('recurrence_type');
      taskData.remove('location_name');
      taskData.remove('latitude');
      taskData.remove('longitude');

      // Converte priority de string para int
      if (taskData['priority'] != null) {
        final priorityStr = taskData['priority'] as String;
        taskData['priority'] = _priorityToInt(priorityStr);
      }

      final response = await _supabaseClient
          .from('tasks')
          .update(taskData)
          .eq('id', task.id)
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .select()
          .single();

      return TaskModel.fromJson(_convertPriorityToString(response));
    } catch (e) {
      throw Exception('Erro ao atualizar tarefa: $e');
    }
  }

  /// Deleta tarefa
  Future<void> deleteTask(String id) async {
    try {
      await _supabaseClient
          .from('tasks')
          .delete()
          .eq('id', id)
          .eq('user_id', _supabaseClient.auth.currentUser!.id);
    } catch (e) {
      throw Exception('Erro ao deletar tarefa: $e');
    }
  }

  /// Marca tarefa como concluída ou não concluída
  Future<TaskModel> toggleTaskCompletion(String id, bool isCompleted) async {
    try {
      final response = await _supabaseClient
          .from('tasks')
          .update({
            'is_completed': isCompleted,
            'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', id)
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .select()
          .single();

      return TaskModel.fromJson(_convertPriorityToString(response));
    } catch (e) {
      throw Exception('Erro ao atualizar status da tarefa: $e');
    }
  }

  /// Busca tarefas de hoje
  Future<List<TaskModel>> getTodayTasks() async {
    try {
      print('[TaskRemoteDatasource] 🔵 Buscando tarefas de hoje...');

      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      print('[TaskRemoteDatasource] 📅 Data de hoje: $now');
      print('[TaskRemoteDatasource] 📅 Início do dia: $startOfDay');
      print('[TaskRemoteDatasource] 📅 Fim do dia: $endOfDay');

      final response = await _supabaseClient
          .from('tasks')
          .select()
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .gte('due_date', startOfDay.toIso8601String())
          .lte('due_date', endOfDay.toIso8601String())
          .order('due_date', ascending: true);

      print('[TaskRemoteDatasource] 📦 Response bruto: $response');
      print('[TaskRemoteDatasource] 📊 Total de tarefas de hoje: ${(response as List).length}');

      final tasks = (response as List)
          .map((json) => _convertPriorityToString(json))
          .map((json) => TaskModel.fromJson(json))
          .toList();

      print('[TaskRemoteDatasource] ✅ Tarefas processadas: ${tasks.length}');
      for (var task in tasks) {
        print('[TaskRemoteDatasource] 📝 - ${task.title} (due: ${task.dueDate})');
      }

      return tasks;
    } catch (e, stack) {
      print('[TaskRemoteDatasource] ❌ ERRO ao buscar tarefas de hoje: $e');
      print('[TaskRemoteDatasource] 📚 Stack: $stack');
      throw Exception('Erro ao buscar tarefas de hoje: $e');
    }
  }

  /// Busca tarefas atrasadas
  Future<List<TaskModel>> getOverdueTasks() async {
    try {
      final response = await _supabaseClient
          .from('tasks')
          .select()
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .eq('is_completed', false)
          .lt('due_date', DateTime.now().toIso8601String())
          .order('due_date', ascending: true);

      return (response as List)
          .map((json) => _convertPriorityToString(json))
          .map((json) => TaskModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar tarefas atrasadas: $e');
    }
  }

  /// Cria tarefa recorrente
  Future<TaskModel> createRecurringTask(TaskModel task) async {
    try {
      // Remove campos gerados automaticamente pelo banco
      final taskData = task.toJson();
      taskData.remove('id'); // UUID gerado pelo banco
      taskData.remove('created_at'); // DEFAULT NOW()
      taskData.remove('updated_at'); // DEFAULT NOW()

      // Remove campos que não existem no banco (migrations não aplicadas)
      taskData.remove('recurrence_type');
      taskData.remove('location_name');
      taskData.remove('latitude');
      taskData.remove('longitude');

      // Converte priority de string para int
      if (taskData['priority'] != null) {
        final priorityStr = taskData['priority'] as String;
        taskData['priority'] = _priorityToInt(priorityStr);
      }

      // A tarefa recorrente é criada normalmente
      // A recorrência será gerenciada por um job no backend ou cloud function
      final response = await _supabaseClient
          .from('tasks')
          .insert(taskData)
          .select()
          .single();

      return TaskModel.fromJson(_convertPriorityToString(response));
    } catch (e) {
      throw Exception('Erro ao criar tarefa recorrente: $e');
    }
  }

  /// Busca estatísticas de tarefas do usuário
  Future<Map<String, dynamic>> getTaskStats() async {
    try {
      final userId = _supabaseClient.auth.currentUser!.id;

      // Busca todas as tarefas
      final allTasks = await _supabaseClient
          .from('tasks')
          .select()
          .eq('user_id', userId);

      final tasks = (allTasks as List)
          .map((json) => _convertPriorityToString(json))
          .map((json) => TaskModel.fromJson(json))
          .toList();

      final total = tasks.length;
      final completed = tasks.where((t) => t.isCompleted).length;
      final pending = tasks.where((t) => !t.isCompleted).length;
      final overdue = tasks.where((t) =>
        !t.isCompleted &&
        t.dueDate != null &&
        t.dueDate!.isBefore(DateTime.now())
      ).length;

      return {
        'total': total,
        'completed': completed,
        'pending': pending,
        'overdue': overdue,
        'completion_rate': total > 0 ? (completed / total * 100).round() : 0,
      };
    } catch (e) {
      throw Exception('Erro ao buscar estatísticas: $e');
    }
  }
}
