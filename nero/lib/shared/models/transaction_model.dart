import 'package:freezed_annotation/freezed_annotation.dart';

part 'transaction_model.freezed.dart';
part 'transaction_model.g.dart';

/// Modelo de transação financeira do Nero
@freezed
class TransactionModel with _$TransactionModel {
  const factory TransactionModel({
    required String id,
    required String userId,
    required double amount,
    required String type, // income, expense, transfer
    String? category,
    String? suggestedCategory,
    double? categoryConfidence, // 0.0 a 1.0 (80% = 0.8)
    @Default(false) bool categoryConfirmed,
    String? description,
    String? account, // Conta/Banco associado à transação (ou conta de origem para transferências)
    String? destinationAccount, // Conta de destino (apenas para transferências)
    @Default('paid') String paymentStatus, // paid, pending (legacy - migrar para is_paid)
    @Default(true) bool isPaid, // true = joia para cima (pago); false = joia para baixo (não pago)
    DateTime? paidAt, // Data/hora efetiva do pagamento/recebimento (null se isPaid = false)
    String? transferId, // ID para vincular as duas movimentações de uma transferência
    DateTime? date,
    String? companyId,
    String? source, // pluggy, manual, etc
    String? externalId,
    Map<String, dynamic>? metadata,
    List<String>? attachments, // URLs dos anexos no Supabase Storage
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _TransactionModel;

  factory TransactionModel.fromJson(Map<String, dynamic> json) =>
      _$TransactionModelFromJson(json);
}
