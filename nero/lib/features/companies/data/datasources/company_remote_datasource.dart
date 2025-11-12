import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/utils/app_logger.dart';
import '../../../../shared/models/company_model.dart';

class CompanyRemoteDatasource {
  final SupabaseClient _supabaseClient;

  CompanyRemoteDatasource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  /// Busca todas as empresas do usuário
  Future<List<CompanyModel>> getCompanies({
    bool? isActive,
    String? type,
  }) async {
    try {
      var query = _supabaseClient.from('companies').select();

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      if (type != null) {
        query = query.eq('type', type);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => CompanyModel.fromJson({
                ...json,
                'user_id': json['user_id'],
                'logo_url': json['logo_url'],
                'is_active': json['is_active'],
                'created_at': json['created_at'],
                'updated_at': json['updated_at'],
              }))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar empresas: $e');
    }
  }

  /// Busca uma empresa por ID
  Future<CompanyModel?> getCompanyById(String id) async {
    try {
      final response = await _supabaseClient
          .from('companies')
          .select()
          .eq('id', id)
          .single();

      return CompanyModel.fromJson({
        ...response,
        'user_id': response['user_id'],
        'logo_url': response['logo_url'],
        'is_active': response['is_active'],
        'created_at': response['created_at'],
        'updated_at': response['updated_at'],
      });
    } catch (e) {
      return null;
    }
  }

  /// Cria uma nova empresa
  Future<CompanyModel> createCompany(CompanyModel company) async {
    try {
      AppLogger.info('Tentando criar empresa', data: {
        'name': company.name,
        'userId': company.userId,
        'type': company.type,
      });

      final payload = {
        'user_id': company.userId,
        'name': company.name,
        'description': company.description,
        'type': company.type,
        'cnpj': company.cnpj,
        'logo_url': company.logoUrl,
        'is_active': company.isActive,
        'metadata': company.metadata ?? {},
      };

      AppLogger.debug('Payload da empresa', data: payload);

      final response = await _supabaseClient
          .from('companies')
          .insert(payload)
          .select()
          .single();

      AppLogger.info('Empresa criada com sucesso', data: {'id': response['id']});

      return CompanyModel.fromJson({
        ...response,
        'user_id': response['user_id'],
        'logo_url': response['logo_url'],
        'is_active': response['is_active'],
        'created_at': response['created_at'],
        'updated_at': response['updated_at'],
      });
    } catch (e, stack) {
      AppLogger.error('Erro ao criar empresa', error: e, stackTrace: stack, data: {
        'errorType': e.runtimeType.toString(),
        'isPostgrestException': e.toString().contains('PostgrestException'),
      });

      throw Exception('Erro ao criar empresa: $e');
    }
  }

  /// Atualiza uma empresa
  Future<CompanyModel> updateCompany(CompanyModel company) async {
    try {
      final response = await _supabaseClient
          .from('companies')
          .update({
            'name': company.name,
            'description': company.description,
            'type': company.type,
            'cnpj': company.cnpj,
            'logo_url': company.logoUrl,
            'is_active': company.isActive,
            'metadata': company.metadata ?? {},
          })
          .eq('id', company.id)
          .select()
          .single();

      return CompanyModel.fromJson({
        ...response,
        'user_id': response['user_id'],
        'logo_url': response['logo_url'],
        'is_active': response['is_active'],
        'created_at': response['created_at'],
        'updated_at': response['updated_at'],
      });
    } catch (e) {
      throw Exception('Erro ao atualizar empresa: $e');
    }
  }

  /// Deleta uma empresa
  Future<void> deleteCompany(String id) async {
    try {
      await _supabaseClient.from('companies').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar empresa: $e');
    }
  }

  /// Busca estatísticas da empresa
  Future<Map<String, dynamic>> getCompanyStats(String companyId) async {
    try {
      // Buscar tarefas da empresa
      final tasksResponse = await _supabaseClient
          .from('tasks')
          .select()
          .eq('company_id', companyId);

      final tasks = tasksResponse as List;
      final totalTasks = tasks.length;
      final completedTasks = tasks.where((t) => t['is_completed'] == true).length;
      final pendingTasks = totalTasks - completedTasks;

      // Buscar reuniões da empresa
      final meetingsResponse = await _supabaseClient
          .from('meetings')
          .select()
          .eq('company_id', companyId);

      final meetings = meetingsResponse as List;
      final totalMeetings = meetings.length;
      final upcomingMeetings = meetings
          .where((m) =>
              m['is_completed'] == false &&
              DateTime.parse(m['start_at']).isAfter(DateTime.now()))
          .length;

      return {
        'total_tasks': totalTasks,
        'completed_tasks': completedTasks,
        'pending_tasks': pendingTasks,
        'total_meetings': totalMeetings,
        'upcoming_meetings': upcomingMeetings,
      };
    } catch (e) {
      throw Exception('Erro ao buscar estatísticas: $e');
    }
  }
}
