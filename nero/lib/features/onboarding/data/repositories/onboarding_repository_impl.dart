import '../../../../core/services/supabase_service.dart';

/// Implementação do repositório de onboarding
class OnboardingRepositoryImpl {
  final _supabaseClient = SupabaseService.client;

  Future<void> completeOnboarding({
    String? wakeUpTime,
    String? workStartTime,
    String? workEndTime,
    required bool hasCompany,
    required bool entrepreneurMode,
    String? companyName,
  }) async {
    final userId = SupabaseService.currentUser?.id;
    if (userId == null) {
      throw Exception('Usuário não autenticado');
    }

    try {
      // Atualizar dados do usuário
      await _supabaseClient.from('users').update({
        'wake_up_time': wakeUpTime,
        'work_start_time': workStartTime,
        'work_end_time': workEndTime,
        'has_company': hasCompany,
        'entrepreneur_mode': entrepreneurMode,
        'onboarding_completed': true,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', userId);

      // Se possui empresa, criar registro
      if (hasCompany && companyName != null && companyName.isNotEmpty) {
        await _supabaseClient.from('companies').insert({
          'user_id': userId,
          'name': companyName,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Registrar log de auditoria
      await _supabaseClient.from('audit_logs').insert({
        'user_id': userId,
        'action': 'completed_onboarding',
        'payload': {
          'entrepreneur_mode': entrepreneurMode,
          'has_company': hasCompany,
        },
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('Erro ao completar onboarding: $e');
    }
  }
}
