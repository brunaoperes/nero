import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/company_checklist_model.dart';
import '../../data/datasources/company_checklist_datasource.dart';

final checklistDatasourceProvider = Provider<CompanyChecklistDatasource>((ref) {
  return CompanyChecklistDatasource(supabaseClient: SupabaseService.client);
});

final companyChecklistsProvider =
    FutureProvider.family<List<CompanyChecklistModel>, String>((ref, companyId) async {
  final datasource = ref.watch(checklistDatasourceProvider);
  return await datasource.getChecklists(companyId: companyId);
});
