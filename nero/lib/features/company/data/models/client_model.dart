// lib/features/company/data/models/client_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/client_entity.dart';

part 'client_model.freezed.dart';
part 'client_model.g.dart';

@freezed
class ClientModel with _$ClientModel {
  const factory ClientModel({
    required String id,
    required String userId,
    required String companyId,
    required String name,
    String? email,
    String? phone,
    required String type,
    String? cpfCnpj,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? notes,
    required String status,
    DateTime? firstContactDate,
    double? totalRevenue,
    int? projectCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _ClientModel;

  factory ClientModel.fromJson(Map<String, dynamic> json) =>
      _$ClientModelFromJson(json);

  factory ClientModel.fromEntity(ClientEntity entity) {
    return ClientModel(
      id: entity.id,
      userId: entity.userId,
      companyId: entity.companyId,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      type: entity.type.toJson(),
      cpfCnpj: entity.cpfCnpj,
      address: entity.address,
      city: entity.city,
      state: entity.state,
      zipCode: entity.zipCode,
      notes: entity.notes,
      status: entity.status.toJson(),
      firstContactDate: entity.firstContactDate,
      totalRevenue: entity.totalRevenue,
      projectCount: entity.projectCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

extension ClientModelExtension on ClientModel {
  ClientEntity toEntity() {
    return ClientEntity(
      id: id,
      userId: userId,
      companyId: companyId,
      name: name,
      email: email,
      phone: phone,
      type: ClientTypeExtension.fromJson(type),
      cpfCnpj: cpfCnpj,
      address: address,
      city: city,
      state: state,
      zipCode: zipCode,
      notes: notes,
      status: ClientStatusExtension.fromJson(status),
      firstContactDate: firstContactDate,
      totalRevenue: totalRevenue,
      projectCount: projectCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
