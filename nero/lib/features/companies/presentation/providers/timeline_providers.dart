import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/company_action_model.dart';
import '../../data/datasources/company_action_datasource.dart';

final actionDatasourceProvider = Provider<CompanyActionDatasource>((ref) {
  return CompanyActionDatasource(supabaseClient: SupabaseService.client);
});

final companyActionsProvider =
    FutureProvider.family<List<CompanyActionModel>, String>((ref, companyId) async {
  final datasource = ref.watch(actionDatasourceProvider);
  return await datasource.getCompanyActions(companyId: companyId, limit: 100);
});
