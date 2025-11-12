import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/company_checklist_model.dart';

class CompanyChecklistDatasource {
  final SupabaseClient _supabaseClient;

  CompanyChecklistDatasource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  /// Busca checklists de uma empresa
  Future<List<CompanyChecklistModel>> getChecklists({
    required String companyId,
    bool? isCompleted,
    String? type,
  }) async {
    try {
      var query = _supabaseClient
          .from('company_checklists')
          .select();

      query = query.eq('company_id', companyId);

      if (isCompleted != null) {
        query = query.eq('is_completed', isCompleted);
      }

      if (type != null) {
        query = query.eq('type', type);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => CompanyChecklistModel.fromJson({
                ...json,
                'company_id': json['company_id'],
                'user_id': json['user_id'],
                'is_completed': json['is_completed'],
                'completed_at': json['completed_at'],
                'due_date': json['due_date'],
                'created_at': json['created_at'],
                'updated_at': json['updated_at'],
              }))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar checklists: $e');
    }
  }

  /// Cria um checklist
  Future<CompanyChecklistModel> createChecklist(CompanyChecklistModel checklist) async {
    try {
      final response = await _supabaseClient
          .from('company_checklists')
          .insert({
            'company_id': checklist.companyId,
            'user_id': checklist.userId,
            'title': checklist.title,
            'description': checklist.description,
            'type': checklist.type,
            'frequency': checklist.frequency,
            'due_date': checklist.dueDate?.toIso8601String(),
            'is_completed': checklist.isCompleted,
            'items': checklist.items.map((item) => {
              'id': item.id,
              'title': item.title,
              'completed': item.completed,
            }).toList(),
            'metadata': checklist.metadata ?? {},
          })
          .select()
          .single();

      return CompanyChecklistModel.fromJson({
        ...response,
        'company_id': response['company_id'],
        'user_id': response['user_id'],
        'is_completed': response['is_completed'],
        'completed_at': response['completed_at'],
        'due_date': response['due_date'],
        'created_at': response['created_at'],
        'updated_at': response['updated_at'],
      });
    } catch (e) {
      throw Exception('Erro ao criar checklist: $e');
    }
  }

  /// Atualiza um checklist
  Future<CompanyChecklistModel> updateChecklist(CompanyChecklistModel checklist) async {
    try {
      final response = await _supabaseClient
          .from('company_checklists')
          .update({
            'title': checklist.title,
            'description': checklist.description,
            'is_completed': checklist.isCompleted,
            'completed_at': checklist.completedAt?.toIso8601String(),
            'items': checklist.items.map((item) => {
              'id': item.id,
              'title': item.title,
              'completed': item.completed,
            }).toList(),
          })
          .eq('id', checklist.id)
          .select()
          .single();

      return CompanyChecklistModel.fromJson({
        ...response,
        'company_id': response['company_id'],
        'user_id': response['user_id'],
        'is_completed': response['is_completed'],
        'completed_at': response['completed_at'],
        'due_date': response['due_date'],
        'created_at': response['created_at'],
        'updated_at': response['updated_at'],
      });
    } catch (e) {
      throw Exception('Erro ao atualizar checklist: $e');
    }
  }

  /// Deleta um checklist
  Future<void> deleteChecklist(String id) async {
    try {
      await _supabaseClient.from('company_checklists').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar checklist: $e');
    }
  }

  /// Cria checklists automáticos para MEI
  Future<void> createMEIChecklists(String companyId, String userId) async {
    try {
      await _supabaseClient.rpc('create_mei_checklists', params: {
        'p_company_id': companyId,
        'p_user_id': userId,
      });
    } catch (e) {
      throw Exception('Erro ao criar checklists MEI: $e');
    }
  }
}
