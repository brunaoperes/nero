import '../../../../shared/models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

/// UseCase para confirmar categoria sugerida pela IA
class ConfirmCategory {
  final TransactionRepository _repository;

  ConfirmCategory(this._repository);

  Future<TransactionModel> call(String id, String category) async {
    return await _repository.confirmCategory(id, category);
  }
}
