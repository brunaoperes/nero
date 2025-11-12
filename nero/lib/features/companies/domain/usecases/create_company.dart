import '../../../../shared/models/company_model.dart';
import '../repositories/company_repository.dart';

class CreateCompany {
  final CompanyRepository _repository;

  CreateCompany(this._repository);

  Future<CompanyModel> call(CompanyModel company) async {
    return await _repository.createCompany(company);
  }
}
