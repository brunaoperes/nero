import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/company_action_model.dart';

class CompanyActionDatasource {
  final SupabaseClient _supabaseClient;

  CompanyActionDatasource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  /// Busca ações de uma empresa
  Future<List<CompanyActionModel>> getCompanyActions({
    required String companyId,
    int limit = 50,
  }) async {
    try {
      final response = await _supabaseClient
          .from('company_actions')
          .select()
          .eq('company_id', companyId)
          .order('created_at', ascending: false)
          .limit(limit);

      return (response as List)
          .map((json) => CompanyActionModel.fromJson({
                ...json,
                'company_id': json['company_id'],
                'user_id': json['user_id'],
                'action_type': json['action_type'],
                'related_id': json['related_id'],
                'related_type': json['related_type'],
                'created_at': json['created_at'],
              }))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar ações: $e');
    }
  }

  /// Cria uma nova ação
  Future<CompanyActionModel> createAction(CompanyActionModel action) async {
    try {
      final response = await _supabaseClient
          .from('company_actions')
          .insert({
            'company_id': action.companyId,
            'user_id': action.userId,
            'action_type': action.actionType,
            'title': action.title,
            'description': action.description,
            'related_id': action.relatedId,
            'related_type': action.relatedType,
            'metadata': action.metadata ?? {},
          })
          .select()
          .single();

      return CompanyActionModel.fromJson({
        ...response,
        'company_id': response['company_id'],
        'user_id': response['user_id'],
        'action_type': response['action_type'],
        'related_id': response['related_id'],
        'related_type': response['related_type'],
        'created_at': response['created_at'],
      });
    } catch (e) {
      throw Exception('Erro ao criar ação: $e');
    }
  }

  /// Deleta uma ação
  Future<void> deleteAction(String id) async {
    try {
      await _supabaseClient.from('company_actions').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar ação: $e');
    }
  }
}
