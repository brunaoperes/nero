import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/company_action_model.dart';
import '../../data/datasources/company_action_datasource.dart';

// ==========================================
// DATASOURCES
// ==========================================

final companyActionDatasourceProvider = Provider<CompanyActionDatasource>((ref) {
  return CompanyActionDatasource(
    supabaseClient: SupabaseService.client,
  );
});

// ==========================================
// PROVIDERS
// ==========================================

/// Provider para ações de uma empresa
final companyActionsProvider =
    FutureProvider.family<List<CompanyActionModel>, String>((ref, companyId) async {
  final datasource = ref.watch(companyActionDatasourceProvider);
  return await datasource.getCompanyActions(companyId: companyId, limit: 50);
});

/// Provider para criar ação
final createCompanyActionProvider = Provider((ref) {
  final datasource = ref.watch(companyActionDatasourceProvider);
  return (CompanyActionModel action) async {
    await datasource.createAction(action);
    // Invalida o provider para recarregar
    ref.invalidate(companyActionsProvider);
  };
});
