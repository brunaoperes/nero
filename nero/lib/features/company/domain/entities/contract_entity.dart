// lib/features/company/domain/entities/contract_entity.dart

/// Entidade que representa um contrato
class ContractEntity {
  final String id;
  final String userId;
  final String companyId;
  final String clientId;
  final String title;
  final String? description;
  final double value;
  final ContractType type;
  final ContractStatus status;
  final DateTime startDate;
  final DateTime? endDate;
  final PaymentFrequency paymentFrequency;
  final int? installments;
  final double? paidAmount;
  final String? attachmentUrl; // URL do contrato assinado
  final DateTime? signedDate;
  final String? notes;
  final bool autoRenew;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ContractEntity({
    required this.id,
    required this.userId,
    required this.companyId,
    required this.clientId,
    required this.title,
    this.description,
    required this.value,
    required this.type,
    required this.status,
    required this.startDate,
    this.endDate,
    required this.paymentFrequency,
    this.installments,
    this.paidAmount,
    this.attachmentUrl,
    this.signedDate,
    this.notes,
    required this.autoRenew,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Calcula o valor pendente
  double get pendingAmount => value - (paidAmount ?? 0);

  /// Verifica se o contrato está próximo do vencimento (30 dias)
  bool get isNearExpiration {
    if (endDate == null) return false;
    final daysUntilExpiration = endDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiration > 0 && daysUntilExpiration <= 30;
  }

  /// Verifica se o contrato expirou
  bool get isExpired {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!);
  }

  ContractEntity copyWith({
    String? id,
    String? userId,
    String? companyId,
    String? clientId,
    String? title,
    String? description,
    double? value,
    ContractType? type,
    ContractStatus? status,
    DateTime? startDate,
    DateTime? endDate,
    PaymentFrequency? paymentFrequency,
    int? installments,
    double? paidAmount,
    String? attachmentUrl,
    DateTime? signedDate,
    String? notes,
    bool? autoRenew,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ContractEntity(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      companyId: companyId ?? this.companyId,
      clientId: clientId ?? this.clientId,
      title: title ?? this.title,
      description: description ?? this.description,
      value: value ?? this.value,
      type: type ?? this.type,
      status: status ?? this.status,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      paymentFrequency: paymentFrequency ?? this.paymentFrequency,
      installments: installments ?? this.installments,
      paidAmount: paidAmount ?? this.paidAmount,
      attachmentUrl: attachmentUrl ?? this.attachmentUrl,
      signedDate: signedDate ?? this.signedDate,
      notes: notes ?? this.notes,
      autoRenew: autoRenew ?? this.autoRenew,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Tipo de contrato
enum ContractType {
  service,      // Prestação de serviço
  product,      // Venda de produto
  subscription, // Assinatura/Recorrente
  consulting,   // Consultoria
  maintenance,  // Manutenção
  other,        // Outro
}

extension ContractTypeExtension on ContractType {
  String get displayName {
    switch (this) {
      case ContractType.service:
        return 'Serviço';
      case ContractType.product:
        return 'Produto';
      case ContractType.subscription:
        return 'Assinatura';
      case ContractType.consulting:
        return 'Consultoria';
      case ContractType.maintenance:
        return 'Manutenção';
      case ContractType.other:
        return 'Outro';
    }
  }

  String toJson() {
    return toString().split('.').last;
  }

  static ContractType fromJson(String json) {
    return ContractType.values.firstWhere(
      (e) => e.toJson() == json,
      orElse: () => ContractType.service,
    );
  }
}

/// Status do contrato
enum ContractStatus {
  draft,      // Rascunho
  pending,    // Pendente de assinatura
  active,     // Ativo
  completed,  // Concluído
  cancelled,  // Cancelado
  expired,    // Expirado
}

extension ContractStatusExtension on ContractStatus {
  String get displayName {
    switch (this) {
      case ContractStatus.draft:
        return 'Rascunho';
      case ContractStatus.pending:
        return 'Pendente';
      case ContractStatus.active:
        return 'Ativo';
      case ContractStatus.completed:
        return 'Concluído';
      case ContractStatus.cancelled:
        return 'Cancelado';
      case ContractStatus.expired:
        return 'Expirado';
    }
  }

  String toJson() {
    return toString().split('.').last;
  }

  static ContractStatus fromJson(String json) {
    return ContractStatus.values.firstWhere(
      (e) => e.toJson() == json,
      orElse: () => ContractStatus.draft,
    );
  }
}

/// Frequência de pagamento
enum PaymentFrequency {
  once,      // Uma vez
  monthly,   // Mensal
  quarterly, // Trimestral
  semiannual,// Semestral
  annual,    // Anual
}

extension PaymentFrequencyExtension on PaymentFrequency {
  String get displayName {
    switch (this) {
      case PaymentFrequency.once:
        return 'Pagamento Único';
      case PaymentFrequency.monthly:
        return 'Mensal';
      case PaymentFrequency.quarterly:
        return 'Trimestral';
      case PaymentFrequency.semiannual:
        return 'Semestral';
      case PaymentFrequency.annual:
        return 'Anual';
    }
  }

  String toJson() {
    return toString().split('.').last;
  }

  static PaymentFrequency fromJson(String json) {
    return PaymentFrequency.values.firstWhere(
      (e) => e.toJson() == json,
      orElse: () => PaymentFrequency.once,
    );
  }
}
