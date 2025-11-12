import '../../../../shared/models/bank_account_model.dart';
import '../../domain/repositories/bank_account_repository.dart';
import '../datasources/bank_account_remote_datasource.dart';

/// Implementação do repositório de contas bancárias
class BankAccountRepositoryImpl implements BankAccountRepository {
  final BankAccountRemoteDatasource _remoteDatasource;

  BankAccountRepositoryImpl({
    required BankAccountRemoteDatasource remoteDatasource,
  }) : _remoteDatasource = remoteDatasource;

  @override
  Future<List<BankAccountModel>> getBankAccounts({bool? isActive}) async {
    return await _remoteDatasource.getBankAccounts(isActive: isActive);
  }

  @override
  Future<BankAccountModel> getBankAccountById(String id) async {
    return await _remoteDatasource.getBankAccountById(id);
  }

  @override
  Future<BankAccountModel> createBankAccount(BankAccountModel account) async {
    return await _remoteDatasource.createBankAccount(account);
  }

  @override
  Future<BankAccountModel> updateBankAccount(BankAccountModel account) async {
    return await _remoteDatasource.updateBankAccount(account);
  }

  @override
  Future<void> deleteBankAccount(String id) async {
    return await _remoteDatasource.deleteBankAccount(id);
  }

  @override
  Future<double> getTotalBalance() async {
    return await _remoteDatasource.getTotalBalance();
  }

  @override
  Future<BankAccountModel> updateBalance(String id, double newBalance) async {
    return await _remoteDatasource.updateBalance(id, newBalance);
  }
}
