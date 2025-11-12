import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/company_model.dart';

/// Provider de lista de empresas
/// TODO: Integrar com repository real quando estiver disponível
final companiesProvider = StateProvider<List<CompanyModel>>((ref) {
  // Por enquanto retorna lista vazia
  // Depois você pode integrar com o repository/usecase real
  return [];
});

/// Provider de empresas filtradas
final filteredCompaniesProvider = Provider<List<CompanyModel>>((ref) {
  final companies = ref.watch(companiesProvider);
  // TODO: Aplicar filtros quando implementado
  return companies;
});

/// Provider de empresas ativas
final activeCompaniesProvider = Provider<List<CompanyModel>>((ref) {
  final companies = ref.watch(companiesProvider);
  return companies.where((c) => c.isActive).toList();
});

/// Provider para estatísticas de empresas
final companyStatsProvider = Provider<Map<String, int>>((ref) {
  final companies = ref.watch(companiesProvider);

  return {
    'total': companies.length,
    'active': companies.where((c) => c.isActive).length,
    'inactive': companies.where((c) => !c.isActive).length,
  };
});
