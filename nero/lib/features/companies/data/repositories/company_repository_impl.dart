import '../../../../shared/models/company_model.dart';
import '../../domain/repositories/company_repository.dart';
import '../datasources/company_remote_datasource.dart';

class CompanyRepositoryImpl implements CompanyRepository {
  final CompanyRemoteDatasource _remoteDatasource;

  CompanyRepositoryImpl({
    required CompanyRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  @override
  Future<List<CompanyModel>> getCompanies({bool? isActive, String? type}) async {
    return await _remoteDatasource.getCompanies(isActive: isActive, type: type);
  }

  @override
  Future<CompanyModel?> getCompanyById(String id) async {
    return await _remoteDatasource.getCompanyById(id);
  }

  @override
  Future<CompanyModel> createCompany(CompanyModel company) async {
    return await _remoteDatasource.createCompany(company);
  }

  @override
  Future<CompanyModel> updateCompany(CompanyModel company) async {
    return await _remoteDatasource.updateCompany(company);
  }

  @override
  Future<void> deleteCompany(String id) async {
    return await _remoteDatasource.deleteCompany(id);
  }

  @override
  Future<Map<String, dynamic>> getCompanyStats(String companyId) async {
    return await _remoteDatasource.getCompanyStats(companyId);
  }
}
