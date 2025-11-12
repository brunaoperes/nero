import 'package:freezed_annotation/freezed_annotation.dart';

part 'bank_account_model.freezed.dart';
part 'bank_account_model.g.dart';

/// Modelo de conta bancária
@freezed
class BankAccountModel with _$BankAccountModel {
  const factory BankAccountModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String name,
    required double balance,
    @JsonKey(name: 'opening_balance') @Default(0.0) double openingBalance, // Saldo de abertura
    String? color,
    String? icon,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'is_hidden_balance') @Default(false) bool isHiddenBalance,
    @JsonKey(name: 'account_type') @Default('pf') String accountType,
    @JsonKey(name: 'icon_key') @Default('generic') String iconKey,
    @JsonKey(name: 'created_at') DateTime? createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
  }) = _BankAccountModel;

  factory BankAccountModel.fromJson(Map<String, dynamic> json) =>
      _$BankAccountModelFromJson(json);
}
