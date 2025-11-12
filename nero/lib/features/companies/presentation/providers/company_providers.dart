import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/company_model.dart';
import '../../data/datasources/company_remote_datasource.dart';
import '../../data/repositories/company_repository_impl.dart';
import '../../domain/repositories/company_repository.dart';
import '../../domain/usecases/create_company.dart';
import '../../domain/usecases/delete_company.dart';
import '../../domain/usecases/get_companies.dart';
import '../../domain/usecases/update_company.dart';

// ==========================================
// DATASOURCES
// ==========================================

final companyRemoteDatasourceProvider = Provider<CompanyRemoteDatasource>((ref) {
  return CompanyRemoteDatasource(
    supabaseClient: SupabaseService.client,
  );
});

// ==========================================
// REPOSITORIES
// ==========================================

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyRepositoryImpl(
    remoteDatasource: ref.watch(companyRemoteDatasourceProvider),
  );
});

// ==========================================
// USECASES
// ==========================================

final getCompaniesUseCaseProvider = Provider<GetCompanies>((ref) {
  return GetCompanies(ref.watch(companyRepositoryProvider));
});

final createCompanyUseCaseProvider = Provider<CreateCompany>((ref) {
  return CreateCompany(ref.watch(companyRepositoryProvider));
});

final updateCompanyUseCaseProvider = Provider<UpdateCompany>((ref) {
  return UpdateCompany(ref.watch(companyRepositoryProvider));
});

final deleteCompanyUseCaseProvider = Provider<DeleteCompany>((ref) {
  return DeleteCompany(ref.watch(companyRepositoryProvider));
});

// ==========================================
// STATE PROVIDERS
// ==========================================

/// Provider para lista de empresas
final companiesListProvider =
    StateNotifierProvider<CompaniesListNotifier, AsyncValue<List<CompanyModel>>>((ref) {
  return CompaniesListNotifier(ref);
});

/// Notifier para gerenciar lista de empresas
class CompaniesListNotifier extends StateNotifier<AsyncValue<List<CompanyModel>>> {
  final Ref _ref;

  CompaniesListNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadCompanies();
  }

  /// Carrega todas as empresas
  Future<void> loadCompanies({bool? isActive, String? type}) async {
    state = const AsyncValue.loading();
    try {
      final getCompanies = _ref.read(getCompaniesUseCaseProvider);
      final companies = await getCompanies(isActive: isActive, type: type);
      state = AsyncValue.data(companies);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Cria nova empresa
  Future<bool> createCompany(CompanyModel company) async {
    try {
      final createCompany = _ref.read(createCompanyUseCaseProvider);
      await createCompany(company);
      await loadCompanies();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Atualiza empresa
  Future<bool> updateCompany(CompanyModel company) async {
    try {
      final updateCompany = _ref.read(updateCompanyUseCaseProvider);
      await updateCompany(company);
      await loadCompanies();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Deleta empresa
  Future<bool> deleteCompany(String id) async {
    try {
      final deleteCompany = _ref.read(deleteCompanyUseCaseProvider);
      await deleteCompany(id);
      await loadCompanies();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// ==========================================
// FILTROS
// ==========================================

/// Provider para filtro de status (ativa/inativa)
final companyActiveFilterProvider = StateProvider<bool?>((ref) => null);

/// Provider para filtro de tipo
final companyTypeFilterProvider = StateProvider<String?>((ref) => null);

// ==========================================
// ESTATÍSTICAS
// ==========================================

/// Provider para estatísticas de uma empresa
final companyStatsProvider =
    FutureProvider.family<Map<String, dynamic>, String>((ref, companyId) async {
  final repository = ref.watch(companyRepositoryProvider);
  return await repository.getCompanyStats(companyId);
});
