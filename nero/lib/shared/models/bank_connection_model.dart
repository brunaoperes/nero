import 'package:freezed_annotation/freezed_annotation.dart';

part 'bank_connection_model.freezed.dart';
part 'bank_connection_model.g.dart';

/// Modelo de conexão bancária do usuário
@freezed
class BankConnectionModel with _$BankConnectionModel {
  const factory BankConnectionModel({
    required String id,
    required String userId,
    required String pluggyItemId,
    required int connectorId,
    required String connectorName,
    String? connectorImageUrl,
    required String status, // UPDATED, UPDATING, LOGIN_ERROR, OUTDATED
    DateTime? lastSyncAt,
    String? errorMessage,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _BankConnectionModel;

  factory BankConnectionModel.fromJson(Map<String, dynamic> json) =>
      _$BankConnectionModelFromJson(json);
}

/// Status da conexão
enum ConnectionStatus {
  updated('UPDATED'),
  updating('UPDATING'),
  loginError('LOGIN_ERROR'),
  outdated('OUTDATED');

  final String value;
  const ConnectionStatus(this.value);

  static ConnectionStatus fromString(String value) {
    return ConnectionStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ConnectionStatus.outdated,
    );
  }
}
