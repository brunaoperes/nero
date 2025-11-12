import '../../../../shared/models/bank_account_model.dart';
import '../repositories/bank_account_repository.dart';

/// UseCase para buscar contas bancárias
class GetBankAccounts {
  final BankAccountRepository _repository;

  GetBankAccounts(this._repository);

  Future<List<BankAccountModel>> call({bool? isActive}) async {
    return await _repository.getBankAccounts(isActive: isActive);
  }
}
