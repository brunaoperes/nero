import '../repositories/transaction_repository.dart';

/// UseCase para buscar estatísticas de transações
class GetTransactionStats {
  final TransactionRepository _repository;

  GetTransactionStats(this._repository);

  Future<Map<String, dynamic>> call({
    DateTime? startDate,
    DateTime? endDate,
    String? companyId,
  }) async {
    return await _repository.getTransactionStats(
      startDate: startDate,
      endDate: endDate,
      companyId: companyId,
    );
  }
}
