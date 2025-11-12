import '../../../../shared/models/company_model.dart';
import '../repositories/company_repository.dart';

class GetCompanies {
  final CompanyRepository _repository;

  GetCompanies(this._repository);

  Future<List<CompanyModel>> call({bool? isActive, String? type}) async {
    return await _repository.getCompanies(isActive: isActive, type: type);
  }
}
