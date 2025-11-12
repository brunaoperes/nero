# 🏢 MÓDULO DE EMPRESAS - CÓDIGO COMPLETO

**Instruções**: Copie cada seção de código para o arquivo indicado.

---

## 📄 DATASOURCE (700+ linhas)

**Arquivo**: `lib/features/company/data/datasources/company_remote_datasource.dart`

```dart
// lib/features/company/data/datasources/company_remote_datasource.dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/client_model.dart';
import '../models/company_model.dart';
import '../models/contract_model.dart';
import '../models/project_model.dart';

class CompanyRemoteDatasource {
  final SupabaseClient _supabase;

  CompanyRemoteDatasource(this._supabase);

  // ========== COMPANIES ==========

  Future<List<CompanyModel>> getCompanies(String userId) async {
    try {
      final response = await _supabase
          .from('companies')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => CompanyModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar empresas: $e');
    }
  }

  Future<CompanyModel?> getCompanyById(String id) async {
    try {
      final response = await _supabase
          .from('companies')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return CompanyModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar empresa: $e');
    }
  }

  Future<List<CompanyModel>> getActiveCompanies(String userId) async {
    try {
      final response = await _supabase
          .from('companies')
          .select()
          .eq('user_id', userId)
          .eq('status', 'active')
          .order('name');

      return (response as List)
          .map((json) => CompanyModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar empresas ativas: $e');
    }
  }

  Future<void> createCompany(CompanyModel company) async {
    try {
      await _supabase.from('companies').insert(company.toJson());
    } catch (e) {
      throw Exception('Erro ao criar empresa: $e');
    }
  }

  Future<void> updateCompany(CompanyModel company) async {
    try {
      await _supabase
          .from('companies')
          .update(company.toJson())
          .eq('id', company.id);
    } catch (e) {
      throw Exception('Erro ao atualizar empresa: $e');
    }
  }

  Future<void> deleteCompany(String id) async {
    try {
      await _supabase.from('companies').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar empresa: $e');
    }
  }

  // ========== CLIENTS ==========

  Future<List<ClientModel>> getClients(String companyId) async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .eq('company_id', companyId)
          .order('name');

      return (response as List)
          .map((json) => ClientModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar clientes: $e');
    }
  }

  Future<ClientModel?> getClientById(String id) async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return ClientModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar cliente: $e');
    }
  }

  Future<List<ClientModel>> getActiveClients(String companyId) async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .eq('company_id', companyId)
          .eq('status', 'active')
          .order('name');

      return (response as List)
          .map((json) => ClientModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar clientes ativos: $e');
    }
  }

  Future<List<ClientModel>> getClientsByStatus(
    String companyId,
    String status,
  ) async {
    try {
      final response = await _supabase
          .from('clients')
          .select()
          .eq('company_id', companyId)
          .eq('status', status)
          .order('name');

      return (response as List)
          .map((json) => ClientModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar clientes por status: $e');
    }
  }

  Future<void> createClient(ClientModel client) async {
    try {
      await _supabase.from('clients').insert(client.toJson());
    } catch (e) {
      throw Exception('Erro ao criar cliente: $e');
    }
  }

  Future<void> updateClient(ClientModel client) async {
    try {
      await _supabase
          .from('clients')
          .update(client.toJson())
          .eq('id', client.id);
    } catch (e) {
      throw Exception('Erro ao atualizar cliente: $e');
    }
  }

  Future<void> deleteClient(String id) async {
    try {
      await _supabase.from('clients').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar cliente: $e');
    }
  }

  // ========== CONTRACTS ==========

  Future<List<ContractModel>> getContracts(String companyId) async {
    try {
      final response = await _supabase
          .from('contracts')
          .select()
          .eq('company_id', companyId)
          .order('start_date', ascending: false);

      return (response as List)
          .map((json) => ContractModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar contratos: $e');
    }
  }

  Future<List<ContractModel>> getContractsByClient(String clientId) async {
    try {
      final response = await _supabase
          .from('contracts')
          .select()
          .eq('client_id', clientId)
          .order('start_date', ascending: false);

      return (response as List)
          .map((json) => ContractModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar contratos do cliente: $e');
    }
  }

  Future<List<ContractModel>> getActiveContracts(String companyId) async {
    try {
      final response = await _supabase
          .from('contracts')
          .select()
          .eq('company_id', companyId)
          .eq('status', 'active')
          .order('start_date', ascending: false);

      return (response as List)
          .map((json) => ContractModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar contratos ativos: $e');
    }
  }

  Future<List<ContractModel>> getContractsByStatus(
    String companyId,
    String status,
  ) async {
    try {
      final response = await _supabase
          .from('contracts')
          .select()
          .eq('company_id', companyId)
          .eq('status', status)
          .order('start_date', ascending: false);

      return (response as List)
          .map((json) => ContractModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar contratos por status: $e');
    }
  }

  Future<void> createContract(ContractModel contract) async {
    try {
      await _supabase.from('contracts').insert(contract.toJson());
    } catch (e) {
      throw Exception('Erro ao criar contrato: $e');
    }
  }

  Future<void> updateContract(ContractModel contract) async {
    try {
      await _supabase
          .from('contracts')
          .update(contract.toJson())
          .eq('id', contract.id);
    } catch (e) {
      throw Exception('Erro ao atualizar contrato: $e');
    }
  }

  Future<void> deleteContract(String id) async {
    try {
      await _supabase.from('contracts').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar contrato: $e');
    }
  }

  // ========== PROJECTS ==========

  Future<List<ProjectModel>> getProjects(String companyId) async {
    try {
      final response = await _supabase
          .from('projects')
          .select()
          .eq('company_id', companyId)
          .order('start_date', ascending: false);

      return (response as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar projetos: $e');
    }
  }

  Future<List<ProjectModel>> getProjectsByClient(String clientId) async {
    try {
      final response = await _supabase
          .from('projects')
          .select()
          .eq('client_id', clientId)
          .order('start_date', ascending: false);

      return (response as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar projetos do cliente: $e');
    }
  }

  Future<List<ProjectModel>> getActiveProjects(String companyId) async {
    try {
      final response = await _supabase
          .from('projects')
          .select()
          .eq('company_id', companyId)
          .eq('status', 'inProgress')
          .order('deadline');

      return (response as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar projetos ativos: $e');
    }
  }

  Future<List<ProjectModel>> getProjectsByStatus(
    String companyId,
    String status,
  ) async {
    try {
      final response = await _supabase
          .from('projects')
          .select()
          .eq('company_id', companyId)
          .eq('status', status)
          .order('start_date', ascending: false);

      return (response as List)
          .map((json) => ProjectModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar projetos por status: $e');
    }
  }

  Future<void> createProject(ProjectModel project) async {
    try {
      await _supabase.from('projects').insert(project.toJson());
    } catch (e) {
      throw Exception('Erro ao criar projeto: $e');
    }
  }

  Future<void> updateProject(ProjectModel project) async {
    try {
      await _supabase
          .from('projects')
          .update(project.toJson())
          .eq('id', project.id);
    } catch (e) {
      throw Exception('Erro ao atualizar projeto: $e');
    }
  }

  Future<void> deleteProject(String id) async {
    try {
      await _supabase.from('projects').delete().eq('id', id);
    } catch (e) {
      throw Exception('Erro ao deletar projeto: $e');
    }
  }

  // ========== ANALYTICS ==========

  Future<Map<String, dynamic>> getCompanySummary(String companyId) async {
    try {
      // Buscar estatísticas da empresa
      final clientsResponse = await _supabase
          .from('clients')
          .select('id, total_revenue, status')
          .eq('company_id', companyId);

      final contractsResponse = await _supabase
          .from('contracts')
          .select('value, paid_amount, status')
          .eq('company_id', companyId);

      final projectsResponse = await _supabase
          .from('projects')
          .select('budget, actual_cost, status')
          .eq('company_id', companyId);

      final clients = clientsResponse as List;
      final contracts = contractsResponse as List;
      final projects = projectsResponse as List;

      // Calcular métricas
      final activeClients =
          clients.where((c) => c['status'] == 'active').length;
      final totalClients = clients.length;

      final activeContracts =
          contracts.where((c) => c['status'] == 'active').length;
      final totalContractValue = contracts.fold<double>(
        0,
        (sum, c) => sum + (c['value'] as num).toDouble(),
      );
      final totalPaidAmount = contracts.fold<double>(
        0,
        (sum, c) => sum + ((c['paid_amount'] as num?) ?? 0).toDouble(),
      );

      final activeProjects =
          projects.where((p) => p['status'] == 'inProgress').length;
      final totalProjects = projects.length;

      return {
        'totalClients': totalClients,
        'activeClients': activeClients,
        'totalContracts': contracts.length,
        'activeContracts': activeContracts,
        'totalContractValue': totalContractValue,
        'totalPaidAmount': totalPaidAmount,
        'pendingAmount': totalContractValue - totalPaidAmount,
        'totalProjects': totalProjects,
        'activeProjects': activeProjects,
        'completedProjects':
            projects.where((p) => p['status'] == 'completed').length,
      };
    } catch (e) {
      throw Exception('Erro ao buscar resumo da empresa: $e');
    }
  }

  Future<double> getTotalContractRevenue(String companyId) async {
    try {
      final response = await _supabase
          .from('contracts')
          .select('value')
          .eq('company_id', companyId);

      final contracts = response as List;
      return contracts.fold<double>(
        0,
        (sum, c) => sum + (c['value'] as num).toDouble(),
      );
    } catch (e) {
      throw Exception('Erro ao calcular receita total: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTopClientsByRevenue(
    String companyId, {
    int limit = 5,
  }) async {
    try {
      final response = await _supabase
          .from('clients')
          .select('id, name, total_revenue')
          .eq('company_id', companyId)
          .not('total_revenue', 'is', null)
          .order('total_revenue', ascending: false)
          .limit(limit);

      return (response as List).cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Erro ao buscar top clientes: $e');
    }
  }
}
```

---

## 📄 REPOSITORY IMPLEMENTATION

**Arquivo**: `lib/features/company/data/repositories/company_repository_impl.dart`

```dart
// lib/features/company/data/repositories/company_repository_impl.dart
import 'package:uuid/uuid.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/entities/contract_entity.dart';
import '../../domain/entities/project_entity.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_datasource.dart';
import '../models/client_model.dart';
import '../models/company_model.dart';
import '../models/contract_model.dart';
import '../models/project_model.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDatasource _datasource;
  final _uuid = const Uuid();

  CompanyRepositoryImpl(this._datasource);

  // ===== COMPANIES =====

  @override
  Future<List<CompanyEntity>> getCompanies(String userId) async {
    final models = await _datasource.getCompanies(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<CompanyEntity?> getCompanyById(String id) async {
    final model = await _datasource.getCompanyById(id);
    return model?.toEntity();
  }

  @override
  Future<List<CompanyEntity>> getActiveCompanies(String userId) async {
    final models = await _datasource.getActiveCompanies(userId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createCompany(CompanyEntity company) async {
    final model = CompanyModel.fromEntity(
      company.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    await _datasource.createCompany(model);
  }

  @override
  Future<void> updateCompany(CompanyEntity company) async {
    final model = CompanyModel.fromEntity(
      company.copyWith(updatedAt: DateTime.now()),
    );
    await _datasource.updateCompany(model);
  }

  @override
  Future<void> deleteCompany(String id) async {
    await _datasource.deleteCompany(id);
  }

  // ===== CLIENTS =====

  @override
  Future<List<ClientEntity>> getClients(String companyId) async {
    final models = await _datasource.getClients(companyId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<ClientEntity?> getClientById(String id) async {
    final model = await _datasource.getClientById(id);
    return model?.toEntity();
  }

  @override
  Future<List<ClientEntity>> getActiveClients(String companyId) async {
    final models = await _datasource.getActiveClients(companyId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ClientEntity>> getClientsByStatus(
    String companyId,
    ClientStatus status,
  ) async {
    final models = await _datasource.getClientsByStatus(
      companyId,
      status.toJson(),
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createClient(ClientEntity client) async {
    final model = ClientModel.fromEntity(
      client.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    await _datasource.createClient(model);
  }

  @override
  Future<void> updateClient(ClientEntity client) async {
    final model = ClientModel.fromEntity(
      client.copyWith(updatedAt: DateTime.now()),
    );
    await _datasource.updateClient(model);
  }

  @override
  Future<void> deleteClient(String id) async {
    await _datasource.deleteClient(id);
  }

  // ===== CONTRACTS =====

  @override
  Future<List<ContractEntity>> getContracts(String companyId) async {
    final models = await _datasource.getContracts(companyId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ContractEntity>> getContractsByClient(String clientId) async {
    final models = await _datasource.getContractsByClient(clientId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ContractEntity>> getActiveContracts(String companyId) async {
    final models = await _datasource.getActiveContracts(companyId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ContractEntity>> getContractsByStatus(
    String companyId,
    ContractStatus status,
  ) async {
    final models = await _datasource.getContractsByStatus(
      companyId,
      status.toJson(),
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createContract(ContractEntity contract) async {
    final model = ContractModel.fromEntity(
      contract.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    await _datasource.createContract(model);
  }

  @override
  Future<void> updateContract(ContractEntity contract) async {
    final model = ContractModel.fromEntity(
      contract.copyWith(updatedAt: DateTime.now()),
    );
    await _datasource.updateContract(model);
  }

  @override
  Future<void> deleteContract(String id) async {
    await _datasource.deleteContract(id);
  }

  // ===== PROJECTS =====

  @override
  Future<List<ProjectEntity>> getProjects(String companyId) async {
    final models = await _datasource.getProjects(companyId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ProjectEntity>> getProjectsByClient(String clientId) async {
    final models = await _datasource.getProjectsByClient(clientId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ProjectEntity>> getActiveProjects(String companyId) async {
    final models = await _datasource.getActiveProjects(companyId);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<ProjectEntity>> getProjectsByStatus(
    String companyId,
    ProjectStatus status,
  ) async {
    final models = await _datasource.getProjectsByStatus(
      companyId,
      status.toJson(),
    );
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> createProject(ProjectEntity project) async {
    final model = ProjectModel.fromEntity(
      project.copyWith(
        id: _uuid.v4(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    await _datasource.createProject(model);
  }

  @override
  Future<void> updateProject(ProjectEntity project) async {
    final model = ProjectModel.fromEntity(
      project.copyWith(updatedAt: DateTime.now()),
    );
    await _datasource.updateProject(model);
  }

  @override
  Future<void> deleteProject(String id) async {
    await _datasource.deleteProject(id);
  }

  // ===== ANALYTICS =====

  @override
  Future<Map<String, dynamic>> getCompanySummary(String companyId) async {
    return await _datasource.getCompanySummary(companyId);
  }

  @override
  Future<double> getTotalContractRevenue(String companyId) async {
    return await _datasource.getTotalContractRevenue(companyId);
  }

  @override
  Future<List<Map<String, dynamic>>> getTopClientsByRevenue(
    String companyId, {
    int limit = 5,
  }) async {
    return await _datasource.getTopClientsByRevenue(companyId, limit: limit);
  }
}
```

---

Continue no próximo arquivo `COMPANY_MODULE_PROVIDERS.md` para providers e SQL...
