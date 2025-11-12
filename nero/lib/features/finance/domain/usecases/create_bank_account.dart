import '../../../../shared/models/bank_account_model.dart';
import '../repositories/bank_account_repository.dart';

/// UseCase para criar conta bancária
class CreateBankAccount {
  final BankAccountRepository _repository;

  CreateBankAccount(this._repository);

  Future<BankAccountModel> call(BankAccountModel account) async {
    return await _repository.createBankAccount(account);
  }
}
