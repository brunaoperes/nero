import '../../../../shared/models/company_model.dart';

abstract class CompanyRepository {
  Future<List<CompanyModel>> getCompanies({bool? isActive, String? type});
  Future<CompanyModel?> getCompanyById(String id);
  Future<CompanyModel> createCompany(CompanyModel company);
  Future<CompanyModel> updateCompany(CompanyModel company);
  Future<void> deleteCompany(String id);
  Future<Map<String, dynamic>> getCompanyStats(String companyId);
}
