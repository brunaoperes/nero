import '../repositories/transaction_repository.dart';

/// UseCase para deletar transação
class DeleteTransaction {
  final TransactionRepository _repository;

  DeleteTransaction(this._repository);

  Future<void> call(String id) async {
    return await _repository.deleteTransaction(id);
  }
}
