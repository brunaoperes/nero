import '../../../../shared/models/bank_account_model.dart';
import '../repositories/bank_account_repository.dart';

/// UseCase para atualizar conta bancária
class UpdateBankAccount {
  final BankAccountRepository _repository;

  UpdateBankAccount(this._repository);

  Future<BankAccountModel> call(BankAccountModel account) async {
    return await _repository.updateBankAccount(account);
  }
}
