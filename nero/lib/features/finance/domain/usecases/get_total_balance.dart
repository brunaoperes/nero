import '../repositories/bank_account_repository.dart';

/// UseCase para obter saldo total de todas as contas
class GetTotalBalance {
  final BankAccountRepository _repository;

  GetTotalBalance(this._repository);

  Future<double> call() async {
    return await _repository.getTotalBalance();
  }
}
