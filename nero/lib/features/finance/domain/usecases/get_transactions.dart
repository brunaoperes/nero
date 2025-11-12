import '../../../../shared/models/transaction_model.dart';
import '../repositories/transaction_repository.dart';

/// UseCase para buscar transações com filtros
class GetTransactions {
  final TransactionRepository _repository;

  GetTransactions(this._repository);

  Future<List<TransactionModel>> call({
    String? type,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
    String? source,
    String? searchQuery,
    String? sortBy,
    bool ascending = false,
  }) async {
    return await _repository.getTransactions(
      type: type,
      category: category,
      startDate: startDate,
      endDate: endDate,
      companyId: companyId,
      source: source,
      searchQuery: searchQuery,
      sortBy: sortBy,
      ascending: ascending,
    );
  }
}
