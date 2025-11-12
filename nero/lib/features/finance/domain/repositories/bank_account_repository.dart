import '../../../../shared/models/bank_account_model.dart';

/// Interface do repositório de contas bancárias
abstract class BankAccountRepository {
  /// Busca todas as contas bancárias do usuário
  Future<List<BankAccountModel>> getBankAccounts({bool? isActive});

  /// Busca conta bancária por ID
  Future<BankAccountModel> getBankAccountById(String id);

  /// Cria nova conta bancária
  Future<BankAccountModel> createBankAccount(BankAccountModel account);

  /// Atualiza conta bancária existente
  Future<BankAccountModel> updateBankAccount(BankAccountModel account);

  /// Deleta conta bancária
  Future<void> deleteBankAccount(String id);

  /// Calcula o saldo total de todas as contas ativas
  Future<double> getTotalBalance();

  /// Atualiza o saldo de uma conta
  Future<BankAccountModel> updateBalance(String id, double newBalance);
}
