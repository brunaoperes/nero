import '../repositories/bank_account_repository.dart';

/// UseCase para deletar conta bancária
class DeleteBankAccount {
  final BankAccountRepository _repository;

  DeleteBankAccount(this._repository);

  Future<void> call(String id) async {
    return await _repository.deleteBankAccount(id);
  }
}
