import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/meeting_model.dart';

class MeetingDatasource {
  final SupabaseClient _supabaseClient;

  MeetingDatasource({required SupabaseClient supabaseClient})
      : _supabaseClient = supabaseClient;

  Future<List<MeetingModel>> getMeetings({required String companyId, int limit = 10}) async {
    try {
      var query = _supabaseClient.from('meetings').select();
      query = query.eq('company_id', companyId);
      query = query.eq('is_completed', false);
      query = query.gte('start_at', DateTime.now().toIso8601String());

      final response = await query
          .order('start_at', ascending: true)
          .limit(limit);

      return (response as List)
          .map((json) => MeetingModel.fromJson({
                ...json,
                'company_id': json['company_id'],
                'user_id': json['user_id'],
                'start_at': json['start_at'],
                'end_at': json['end_at'],
                'is_completed': json['is_completed'],
                'created_at': json['created_at'],
                'updated_at': json['updated_at'],
              }))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar reuniões: $e');
    }
  }

  Future<MeetingModel> createMeeting(MeetingModel meeting) async {
    try {
      final response = await _supabaseClient
          .from('meetings')
          .insert({
            'user_id': meeting.userId,
            'company_id': meeting.companyId,
            'title': meeting.title,
            'description': meeting.description,
            'location': meeting.location,
            'start_at': meeting.startAt.toIso8601String(),
            'end_at': meeting.endAt.toIso8601String(),
            'participants': meeting.participants,
            'is_completed': meeting.isCompleted,
            'metadata': {},
          })
          .select()
          .single();

      return MeetingModel.fromJson({
        ...response,
        'company_id': response['company_id'],
        'user_id': response['user_id'],
        'start_at': response['start_at'],
        'end_at': response['end_at'],
        'is_completed': response['is_completed'],
        'created_at': response['created_at'],
        'updated_at': response['updated_at'],
      });
    } catch (e) {
      throw Exception('Erro ao criar reunião: $e');
    }
  }

  Future<MeetingModel> updateMeeting(MeetingModel meeting) async {
    try {
      final response = await _supabaseClient
          .from('meetings')
          .update({
            'title': meeting.title,
            'description': meeting.description,
            'location': meeting.location,
            'start_at': meeting.startAt.toIso8601String(),
            'end_at': meeting.endAt.toIso8601String(),
            'participants': meeting.participants,
            'is_completed': meeting.isCompleted,
            'completed_at': meeting.completedAt?.toIso8601String(),
          })
          .eq('id', meeting.id)
          .select()
          .single();

      return MeetingModel.fromJson({
        ...response,
        'company_id': response['company_id'],
        'user_id': response['user_id'],
        'start_at': response['start_at'],
        'end_at': response['end_at'],
        'is_completed': response['is_completed'],
        'created_at': response['created_at'],
        'updated_at': response['updated_at'],
      });
    } catch (e) {
      throw Exception('Erro ao atualizar reunião: $e');
    }
  }

  Future<void> deleteMeeting(String id) async {
    try {
      await _supabaseClient.from('meetings').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar reunião: $e');
    }
  }
}
