import '../../../../shared/models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

/// UseCase para criar transação
class CreateTransaction {
  final TransactionRepository _repository;

  CreateTransaction(this._repository);

  Future<TransactionModel> call(TransactionModel transaction) async {
    return await _repository.createTransaction(transaction);
  }
}
