// lib/features/company/presentation/providers/company_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/company_remote_datasource.dart';
import '../../data/repositories/company_repository_impl.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/entities/contract_entity.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/company_repository.dart';

// ===== DATA LAYER =====

final companyDatasourceProvider = Provider<CompanyRemoteDatasource>((ref) {
  return CompanyRemoteDatasource(Supabase.instance.client);
});

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyRepositoryImpl(ref.read(companyDatasourceProvider));
});

// ===== COMPANIES =====

final companiesProvider = FutureProvider.autoDispose<List<CompanyEntity>>((ref) async {
  final repository = ref.read(companyRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) throw Exception('Usuário não autenticado');
  return await repository.getCompanies(userId);
});

final activeCompaniesProvider = FutureProvider.autoDispose<List<CompanyEntity>>((ref) async {
  final repository = ref.read(companyRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) throw Exception('Usuário não autenticado');
  return await repository.getActiveCompanies(userId);
});

final companyByIdProvider = FutureProvider.autoDispose.family<CompanyEntity?, String>((ref, id) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getCompanyById(id);
});

// ===== CLIENTS =====

final clientsProvider = FutureProvider.autoDispose.family<List<ClientEntity>, String>((ref, companyId) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getClients(companyId);
});

final activeClientsProvider = FutureProvider.autoDispose.family<List<ClientEntity>, String>((ref, companyId) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getActiveClients(companyId);
});

final clientsByStatusProvider = FutureProvider.autoDispose.family<List<ClientEntity>, ({String companyId, ClientStatus status})>((ref, params) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getClientsByStatus(params.companyId, params.status);
});

final clientByIdProvider = FutureProvider.autoDispose.family<ClientEntity?, String>((ref, id) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getClientById(id);
});

// ===== CONTRACTS =====

final contractsProvider = FutureProvider.autoDispose.family<List<ContractEntity>, String>((ref, companyId) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getContracts(companyId);
});

final contractsByClientProvider = FutureProvider.autoDispose.family<List<ContractEntity>, String>((ref, clientId) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getContractsByClient(clientId);
});

final activeContractsProvider = FutureProvider.autoDispose.family<List<ContractEntity>, String>((ref, companyId) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getActiveContracts(companyId);
});

final contractsByStatusProvider = FutureProvider.autoDispose.family<List<ContractEntity>, ({String companyId, ContractStatus status})>((ref, params) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getContractsByStatus(params.companyId, params.status);
});

// ===== PROJECTS =====

final projectsProvider = FutureProvider.autoDispose.family<List<ProjectEntity>, String>((ref, companyId) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getProjects(companyId);
});

final projectsByClientProvider = FutureProvider.autoDispose.family<List<ProjectEntity>, String>((ref, clientId) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getProjectsByClient(clientId);
});

final activeProjectsProvider = FutureProvider.autoDispose.family<List<ProjectEntity>, String>((ref, companyId) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getActiveProjects(companyId);
});

final projectsByStatusProvider = FutureProvider.autoDispose.family<List<ProjectEntity>, ({String companyId, ProjectStatus status})>((ref, params) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getProjectsByStatus(params.companyId, params.status);
});

// ===== ANALYTICS =====

final companySummaryProvider = FutureProvider.autoDispose.family<Map<String, dynamic>, String>((ref, companyId) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getCompanySummary(companyId);
});

final totalContractRevenueProvider = FutureProvider.autoDispose.family<double, String>((ref, companyId) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getTotalContractRevenue(companyId);
});

final topClientsByRevenueProvider = FutureProvider.autoDispose.family<List<Map<String, dynamic>>, String>((ref, companyId) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getTopClientsByRevenue(companyId, limit: 5);
});

// ===== CONTROLLERS =====

class CompanyController extends StateNotifier<AsyncValue<void>> {
  final CompanyRepository _repository;

  CompanyController(this._repository) : super(const AsyncValue.data(null));

  Future<void> createCompany(CompanyEntity company) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.createCompany(company));
  }

  Future<void> updateCompany(CompanyEntity company) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateCompany(company));
  }

  Future<void> deleteCompany(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteCompany(id));
  }
}

final companyControllerProvider = StateNotifierProvider<CompanyController, AsyncValue<void>>((ref) {
  return CompanyController(ref.read(companyRepositoryProvider));
});

class ClientController extends StateNotifier<AsyncValue<void>> {
  final CompanyRepository _repository;

  ClientController(this._repository) : super(const AsyncValue.data(null));

  Future<void> createClient(ClientEntity client) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.createClient(client));
  }

  Future<void> updateClient(ClientEntity client) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateClient(client));
  }

  Future<void> deleteClient(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteClient(id));
  }
}

final clientControllerProvider = StateNotifierProvider<ClientController, AsyncValue<void>>((ref) {
  return ClientController(ref.read(companyRepositoryProvider));
});

class ContractController extends StateNotifier<AsyncValue<void>> {
  final CompanyRepository _repository;

  ContractController(this._repository) : super(const AsyncValue.data(null));

  Future<void> createContract(ContractEntity contract) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.createContract(contract));
  }

  Future<void> updateContract(ContractEntity contract) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateContract(contract));
  }

  Future<void> deleteContract(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteContract(id));
  }
}

final contractControllerProvider = StateNotifierProvider<ContractController, AsyncValue<void>>((ref) {
  return ContractController(ref.read(companyRepositoryProvider));
});

class ProjectController extends StateNotifier<AsyncValue<void>> {
  final CompanyRepository _repository;

  ProjectController(this._repository) : super(const AsyncValue.data(null));

  Future<void> createProject(ProjectEntity project) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.createProject(project));
  }

  Future<void> updateProject(ProjectEntity project) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateProject(project));
  }

  Future<void> deleteProject(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteProject(id));
  }
}

final projectControllerProvider = StateNotifierProvider<ProjectController, AsyncValue<void>>((ref) {
  return ProjectController(ref.read(companyRepositoryProvider));
});

// ===== SELECTED COMPANY STATE =====

final selectedCompanyIdProvider = StateProvider<String?>((ref) => null);
