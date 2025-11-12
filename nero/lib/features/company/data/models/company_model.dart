// lib/features/company/data/models/company_model.dart
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/company_entity.dart';

part 'company_model.freezed.dart';
part 'company_model.g.dart';

@freezed
class CompanyModel with _$CompanyModel {
  const factory CompanyModel({
    required String id,
    required String userId,
    required String name,
    String? cnpj,
    String? email,
    String? phone,
    String? website,
    String? description,
    required String type,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? logo,
    required String status,
    required DateTime foundedDate,
    double? monthlyRevenue,
    int? employeeCount,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _CompanyModel;

  factory CompanyModel.fromJson(Map<String, dynamic> json) =>
      _$CompanyModelFromJson(json);

  factory CompanyModel.fromEntity(CompanyEntity entity) {
    return CompanyModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      cnpj: entity.cnpj,
      email: entity.email,
      phone: entity.phone,
      website: entity.website,
      description: entity.description,
      type: entity.type.toJson(),
      address: entity.address,
      city: entity.city,
      state: entity.state,
      zipCode: entity.zipCode,
      logo: entity.logo,
      status: entity.status.toJson(),
      foundedDate: entity.foundedDate,
      monthlyRevenue: entity.monthlyRevenue,
      employeeCount: entity.employeeCount,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}

extension CompanyModelExtension on CompanyModel {
  CompanyEntity toEntity() {
    return CompanyEntity(
      id: id,
      userId: userId,
      name: name,
      cnpj: cnpj,
      email: email,
      phone: phone,
      website: website,
      description: description,
      type: CompanyTypeExtension.fromJson(type),
      address: address,
      city: city,
      state: state,
      zipCode: zipCode,
      logo: logo,
      status: CompanyStatusExtension.fromJson(status),
      foundedDate: foundedDate,
      monthlyRevenue: monthlyRevenue,
      employeeCount: employeeCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
