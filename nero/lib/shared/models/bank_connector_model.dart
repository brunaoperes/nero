import 'package:freezed_annotation/freezed_annotation.dart';

part 'bank_connector_model.freezed.dart';
part 'bank_connector_model.g.dart';

/// Modelo de conector bancário (instituição financeira disponível no Pluggy)
@freezed
class BankConnectorModel with _$BankConnectorModel {
  const factory BankConnectorModel({
    required int id,
    required String name,
    required String institutionUrl,
    required String imageUrl,
    required String primaryColor,
    required String type,
    required String country,
    required bool hasMFA,
    required ConnectorHealth health,
    List<CredentialField>? credentials,
  }) = _BankConnectorModel;

  factory BankConnectorModel.fromJson(Map<String, dynamic> json) =>
      _$BankConnectorModelFromJson(json);
}

/// Saúde/status do conector
@freezed
class ConnectorHealth with _$ConnectorHealth {
  const factory ConnectorHealth({
    required String status, // ONLINE, OFFLINE, UNSTABLE
    String? stage,
  }) = _ConnectorHealth;

  factory ConnectorHealth.fromJson(Map<String, dynamic> json) =>
      _$ConnectorHealthFromJson(json);
}

/// Campo de credencial para conectar ao banco
@freezed
class CredentialField with _$CredentialField {
  const factory CredentialField({
    required String label,
    required String name,
    required String type, // text, password, number
    String? placeholder,
    String? validation,
    String? validationMessage,
    @Default(false) bool optional,
  }) = _CredentialField;

  factory CredentialField.fromJson(Map<String, dynamic> json) =>
      _$CredentialFieldFromJson(json);
}
