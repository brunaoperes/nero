import 'package:freezed_annotation/freezed_annotation.dart';

part 'synced_transaction_model.freezed.dart';
part 'synced_transaction_model.g.dart';

/// Modelo de transação sincronizada do Open Finance
@freezed
class SyncedTransactionModel with _$SyncedTransactionModel {
  const factory SyncedTransactionModel({
    required String id,
    required String accountId,
    required String pluggyTransactionId,
    required String description,
    required double amount,
    required DateTime date,
    required String type, // income, expense
    String? categoryId,
    String? categorySuggestion,
    double? categoryConfidence,
    @Default('pending') String status, // pending, posted
    DateTime? syncedAt,
    DateTime? createdAt,
  }) = _SyncedTransactionModel;

  factory SyncedTransactionModel.fromJson(Map<String, dynamic> json) =>
      _$SyncedTransactionModelFromJson(json);
}
