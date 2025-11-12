import '../../../../shared/models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

/// UseCase para atualizar transação
class UpdateTransaction {
  final TransactionRepository _repository;

  UpdateTransaction(this._repository);

  Future<TransactionModel> call(TransactionModel transaction) async {
    return await _repository.updateTransaction(transaction);
  }
}
