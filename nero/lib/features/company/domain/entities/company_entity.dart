// lib/features/company/domain/entities/company_entity.dart

/// Entidade que representa uma empresa/negócio
class CompanyEntity {
  final String id;
  final String userId;
  final String name;
  final String? cnpj;
  final String? email;
  final String? phone;
  final String? website;
  final String? description;
  final CompanyType type;
  final String? address;
  final String? city;
  final String? state;
  final String? zipCode;
  final String? logo; // URL do logo
  final CompanyStatus status;
  final DateTime foundedDate;
  final double? monthlyRevenue;
  final int? employeeCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CompanyEntity({
    required this.id,
    required this.userId,
    required this.name,
    this.cnpj,
    this.email,
    this.phone,
    this.website,
    this.description,
    required this.type,
    this.address,
    this.city,
    this.state,
    this.zipCode,
    this.logo,
    required this.status,
    required this.foundedDate,
    this.monthlyRevenue,
    this.employeeCount,
    required this.createdAt,
    required this.updatedAt,
  });

  CompanyEntity copyWith({
    String? id,
    String? userId,
    String? name,
    String? cnpj,
    String? email,
    String? phone,
    String? website,
    String? description,
    CompanyType? type,
    String? address,
    String? city,
    String? state,
    String? zipCode,
    String? logo,
    CompanyStatus? status,
    DateTime? foundedDate,
    double? monthlyRevenue,
    int? employeeCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CompanyEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      cnpj: cnpj ?? this.cnpj,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      website: website ?? this.website,
      description: description ?? this.description,
      type: type ?? this.type,
      address: address ?? this.address,
      city: city ?? this.city,
      state: state ?? this.state,
      zipCode: zipCode ?? this.zipCode,
      logo: logo ?? this.logo,
      status: status ?? this.status,
      foundedDate: foundedDate ?? this.foundedDate,
      monthlyRevenue: monthlyRevenue ?? this.monthlyRevenue,
      employeeCount: employeeCount ?? this.employeeCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Tipo de empresa
enum CompanyType {
  mei,          // Microempreendedor Individual
  eireli,       // Empresa Individual de Responsabilidade Limitada
  ltda,         // Sociedade Limitada
  sa,           // Sociedade Anônima
  epp,          // Empresa de Pequeno Porte
  individual,   // Empresário Individual
  startup,      // Startup
  freelancer,   // Freelancer
  other,        // Outro
}

extension CompanyTypeExtension on CompanyType {
  String get displayName {
    switch (this) {
      case CompanyType.mei:
        return 'MEI';
      case CompanyType.eireli:
        return 'EIRELI';
      case CompanyType.ltda:
        return 'LTDA';
      case CompanyType.sa:
        return 'S.A.';
      case CompanyType.epp:
        return 'EPP';
      case CompanyType.individual:
        return 'Individual';
      case CompanyType.startup:
        return 'Startup';
      case CompanyType.freelancer:
        return 'Freelancer';
      case CompanyType.other:
        return 'Outro';
    }
  }

  String toJson() {
    return toString().split('.').last;
  }

  static CompanyType fromJson(String json) {
    return CompanyType.values.firstWhere(
      (e) => e.toJson() == json,
      orElse: () => CompanyType.other,
    );
  }
}

/// Status da empresa
enum CompanyStatus {
  active,   // Ativa
  inactive, // Inativa
  pending,  // Pendente
  archived, // Arquivada
}

extension CompanyStatusExtension on CompanyStatus {
  String get displayName {
    switch (this) {
      case CompanyStatus.active:
        return 'Ativa';
      case CompanyStatus.inactive:
        return 'Inativa';
      case CompanyStatus.pending:
        return 'Pendente';
      case CompanyStatus.archived:
        return 'Arquivada';
    }
  }

  String toJson() {
    return toString().split('.').last;
  }

  static CompanyStatus fromJson(String json) {
    return CompanyStatus.values.firstWhere(
      (e) => e.toJson() == json,
      orElse: () => CompanyStatus.active,
    );
  }
}
