import '../../../../shared/models/company_model.dart';
import '../repositories/company_repository.dart';

class UpdateCompany {
  final CompanyRepository _repository;

  UpdateCompany(this._repository);

  Future<CompanyModel> call(CompanyModel company) async {
    return await _repository.updateCompany(company);
  }
}
