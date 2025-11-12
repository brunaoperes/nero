// lib/features/company/domain/entities/client_entity.dart

/// Entidade que representa um cliente
class ClientEntity {
  final String id;
  final String userId;
  final String companyId; // Empresa associada
  final String name;
  final String? email;
  final String? phone;
  final ClientType type;
  final String? cpfCnpj;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? notes;
  final ClientStatus status;
  final DateTime? firstContactDate;
  final double? totalRevenue; // Total de receita gerada
  final int? projectCount; // Quantidade de projetos
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClientEntity({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.name,
    this.email,
    this.phone,
    required this.type,
    this.cpfCnpj,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.notes,
    required this.status,
    this.firstContactDate,
    this.totalRevenue,
    this.projectCount,
    required this.createdAt,
    required this.updatedAt,
  });

  ClientEntity copyWith({
    String? id,
    String? userId,
    String? companyId,
    String? name,
    String? email,
    String? phone,
    ClientType? type,
    String? cpfCnpj,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? notes,
    ClientStatus? status,
    DateTime? firstContactDate,
    double? totalRevenue,
    int? projectCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      type: type ?? this.type,
      cpfCnpj: cpfCnpj ?? this.cpfCnpj,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      firstContactDate: firstContactDate ?? this.firstContactDate,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      projectCount: projectCount ?? this.projectCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Tipo de cliente
enum ClientType {
  individual, // Pessoa Física
  company,    // Pessoa Jurídica
}

extension ClientTypeExtension on ClientType {
  String get displayName {
    switch (this) {
      case ClientType.individual:
        return 'Pessoa Física';
      case ClientType.company:
        return 'Pessoa Jurídica';
    }
  }

  String toJson() {
    return toString().split('.').last;
  }

  static ClientType fromJson(String json) {
    return ClientType.values.firstWhere(
      (e) => e.toJson() == json,
      orElse: () => ClientType.individual,
    );
  }
}

/// Status do cliente
enum ClientStatus {
  active,    // Ativo
  inactive,  // Inativo
  prospect,  // Prospecto
  archived,  // Arquivado
}

extension ClientStatusExtension on ClientStatus {
  String get displayName {
    switch (this) {
      case ClientStatus.active:
        return 'Ativo';
      case ClientStatus.inactive:
        return 'Inativo';
      case ClientStatus.prospect:
        return 'Prospecto';
      case ClientStatus.archived:
        return 'Arquivado';
    }
  }

  String toJson() {
    return toString().split('.').last;
  }

  static ClientStatus fromJson(String json) {
    return ClientStatus.values.firstWhere(
      (e) => e.toJson() == json,
      orElse: () => ClientStatus.active,
    );
  }
}
