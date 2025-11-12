import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/meeting_model.dart';
import '../../data/datasources/meeting_datasource.dart';

final meetingDatasourceProvider = Provider<MeetingDatasource>((ref) {
  return MeetingDatasource(supabaseClient: SupabaseService.client);
});

final upcomingMeetingsProvider =
    FutureProvider.family<List<MeetingModel>, String>((ref, companyId) async {
  final datasource = ref.watch(meetingDatasourceProvider);
  return await datasource.getMeetings(companyId: companyId, limit: 5);
});
