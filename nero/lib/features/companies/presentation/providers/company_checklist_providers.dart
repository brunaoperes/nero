import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/company_checklist_model.dart';
import '../../data/datasources/company_checklist_datasource.dart';

// ==========================================
// DATASOURCES
// ==========================================

final companyChecklistDatasourceProvider = Provider<CompanyChecklistDatasource>((ref) {
  return CompanyChecklistDatasource(
    supabaseClient: SupabaseService.client,
  );
});

// ==========================================
// PROVIDERS
// ==========================================

/// Provider para checklists de uma empresa
final companyChecklistsProvider =
    FutureProvider.family<List<CompanyChecklistModel>, String>((ref, companyId) async {
  final datasource = ref.watch(companyChecklistDatasourceProvider);
  return await datasource.getChecklists(companyId: companyId);
});

/// Provider para checklists pendentes
final pendingChecklistsProvider =
    FutureProvider.family<List<CompanyChecklistModel>, String>((ref, companyId) async {
  final datasource = ref.watch(companyChecklistDatasourceProvider);
  return await datasource.getChecklists(companyId: companyId, isCompleted: false);
});

/// Provider para criar checklist
final createChecklistProvider = Provider((ref) {
  final datasource = ref.watch(companyChecklistDatasourceProvider);
  return (CompanyChecklistModel checklist) async {
    await datasource.createChecklist(checklist);
    ref.invalidate(companyChecklistsProvider);
  };
});

/// Provider para atualizar checklist
final updateChecklistProvider = Provider((ref) {
  final datasource = ref.watch(companyChecklistDatasourceProvider);
  return (CompanyChecklistModel checklist) async {
    await datasource.updateChecklist(checklist);
    ref.invalidate(companyChecklistsProvider);
  };
});

/// Provider para criar checklists MEI automáticos
final createMEIChecklistsProvider = Provider((ref) {
  final datasource = ref.watch(companyChecklistDatasourceProvider);
  return (String companyId, String userId) async {
    await datasource.createMEIChecklists(companyId, userId);
    ref.invalidate(companyChecklistsProvider);
  };
});
