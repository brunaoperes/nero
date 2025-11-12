// lib/features/company/data/models/contract_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/contract_entity.dart';

part 'contract_model.freezed.dart';
part 'contract_model.g.dart';

@freezed
class ContractModel with _$ContractModel {
  const factory ContractModel({
    required String id,
    required String userId,
    required String companyId,
    required String clientId,
    required String title,
    String? description,
    required double value,
    required String type,
    required String status,
    required DateTime startDate,
    DateTime? endDate,
    required String paymentFrequency,
    int? installments,
    double? paidAmount,
    String? attachmentUrl,
    DateTime? signedDate,
    String? notes,
    required bool autoRenew,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ContractModel;

  factory ContractModel.fromJson(Map<String, dynamic> json) =>
      _$ContractModelFromJson(json);

  factory ContractModel.fromEntity(ContractEntity entity) {
    return ContractModel(
      id: entity.id,
      userId: entity.userId,
      companyId: entity.companyId,
      clientId: entity.clientId,
      title: entity.title,
      description: entity.description,
      value: entity.value,
      type: entity.type.toJson(),
      status: entity.status.toJson(),
      startDate: entity.startDate,
      endDate: entity.endDate,
      paymentFrequency: entity.paymentFrequency.toJson(),
      installments: entity.installments,
      paidAmount: entity.paidAmount,
      attachmentUrl: entity.attachmentUrl,
      signedDate: entity.signedDate,
      notes: entity.notes,
      autoRenew: entity.autoRenew,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

extension ContractModelExtension on ContractModel {
  ContractEntity toEntity() {
    return ContractEntity(
      id: id,
      userId: userId,
      companyId: companyId,
      clientId: clientId,
      title: title,
      description: description,
      value: value,
      type: ContractTypeExtension.fromJson(type),
      status: ContractStatusExtension.fromJson(status),
      startDate: startDate,
      endDate: endDate,
      paymentFrequency: PaymentFrequencyExtension.fromJson(paymentFrequency),
      installments: installments,
      paidAmount: paidAmount,
      attachmentUrl: attachmentUrl,
      signedDate: signedDate,
      notes: notes,
      autoRenew: autoRenew,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
