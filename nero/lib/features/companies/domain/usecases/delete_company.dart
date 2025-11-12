import '../repositories/company_repository.dart';

class DeleteCompany {
  final CompanyRepository _repository;

  DeleteCompany(this._repository);

  Future<void> call(String id) async {
    return await _repository.deleteCompany(id);
  }
}
