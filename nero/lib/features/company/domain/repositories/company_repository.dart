// lib/features/company/domain/repositories/company_repository.dart
import '../entities/client_entity.dart';
import '../entities/company_entity.dart';
import '../entities/contract_entity.dart';
import '../entities/project_entity.dart';

/// Interface do repositório de empresas
abstract class CompanyRepository {
  // ===== COMPANIES =====
  
  /// Busca todas as empresas do usuário
  Future<List<CompanyEntity>> getCompanies(String userId);
  
  /// Busca uma empresa por ID
  Future<CompanyEntity?> getCompanyById(String id);
  
  /// Busca empresas ativas
  Future<List<CompanyEntity>> getActiveCompanies(String userId);
  
  /// Cria uma nova empresa
  Future<void> createCompany(CompanyEntity company);
  
  /// Atualiza uma empresa
  Future<void> updateCompany(CompanyEntity company);
  
  /// Deleta uma empresa
  Future<void> deleteCompany(String id);

  // ===== CLIENTS =====
  
  /// Busca todos os clientes de uma empresa
  Future<List<ClientEntity>> getClients(String companyId);
  
  /// Busca um cliente por ID
  Future<ClientEntity?> getClientById(String id);
  
  /// Busca clientes ativos
  Future<List<ClientEntity>> getActiveClients(String companyId);
  
  /// Busca clientes por status
  Future<List<ClientEntity>> getClientsByStatus(
    String companyId,
    ClientStatus status,
  );
  
  /// Cria um novo cliente
  Future<void> createClient(ClientEntity client);
  
  /// Atualiza um cliente
  Future<void> updateClient(ClientEntity client);
  
  /// Deleta um cliente
  Future<void> deleteClient(String id);

  // ===== CONTRACTS =====
  
  /// Busca todos os contratos de uma empresa
  Future<List<ContractEntity>> getContracts(String companyId);
  
  /// Busca contratos de um cliente
  Future<List<ContractEntity>> getContractsByClient(String clientId);
  
  /// Busca contratos ativos
  Future<List<ContractEntity>> getActiveContracts(String companyId);
  
  /// Busca contratos por status
  Future<List<ContractEntity>> getContractsByStatus(
    String companyId,
    ContractStatus status,
  );
  
  /// Cria um novo contrato
  Future<void> createContract(ContractEntity contract);
  
  /// Atualiza um contrato
  Future<void> updateContract(ContractEntity contract);
  
  /// Deleta um contrato
  Future<void> deleteContract(String id);

  // ===== PROJECTS =====
  
  /// Busca todos os projetos de uma empresa
  Future<List<ProjectEntity>> getProjects(String companyId);
  
  /// Busca projetos de um cliente
  Future<List<ProjectEntity>> getProjectsByClient(String clientId);
  
  /// Busca projetos ativos
  Future<List<ProjectEntity>> getActiveProjects(String companyId);
  
  /// Busca projetos por status
  Future<List<ProjectEntity>> getProjectsByStatus(
    String companyId,
    ProjectStatus status,
  );
  
  /// Cria um novo projeto
  Future<void> createProject(ProjectEntity project);
  
  /// Atualiza um projeto
  Future<void> updateProject(ProjectEntity project);
  
  /// Deleta um projeto
  Future<void> deleteProject(String id);

  // ===== ANALYTICS =====
  
  /// Calcula o resumo da empresa (receita, clientes, projetos)
  Future<Map<String, dynamic>> getCompanySummary(String companyId);
  
  /// Calcula a receita total de contratos
  Future<double> getTotalContractRevenue(String companyId);
  
  /// Busca clientes top por receita
  Future<List<Map<String, dynamic>>> getTopClientsByRevenue(
    String companyId, {
    int limit = 5,
  });
}
