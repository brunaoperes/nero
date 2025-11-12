import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../shared/models/bank_account_model.dart';

/// Datasource para operações remotas de contas bancárias
class BankAccountRemoteDatasource {
  final SupabaseClient _supabaseClient;

  BankAccountRemoteDatasource({
    required SupabaseClient supabaseClient,
  }) : _supabaseClient = supabaseClient;

  /// Busca todas as contas bancárias do usuário
  Future<List<BankAccountModel>> getBankAccounts({
    bool? isActive,
  }) async {
    try {
      var query = _supabaseClient
          .from('bank_accounts')
          .select()
          .eq('user_id', _supabaseClient.auth.currentUser!.id);

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      final response = await query.order('created_at', ascending: false);

      return (response as List)
          .map((json) => BankAccountModel.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Erro ao buscar contas bancárias: $e');
    }
  }

  /// Busca conta bancária por ID
  Future<BankAccountModel> getBankAccountById(String id) async {
    try {
      final response = await _supabaseClient
          .from('bank_accounts')
          .select()
          .eq('id', id)
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .single();

      return BankAccountModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao buscar conta bancária: $e');
    }
  }

  /// Cria nova conta bancária
  Future<BankAccountModel> createBankAccount(BankAccountModel account) async {
    try {
      // Prepara dados para inserção (remove id vazio e usa user_id autenticado)
      final data = {
        'user_id': _supabaseClient.auth.currentUser!.id,
        'name': account.name,
        'balance': account.balance,
        'opening_balance': account.openingBalance,
        'color': account.color,
        'icon': account.icon,
        'icon_key': account.iconKey,
        'account_type': account.accountType,
        'is_hidden_balance': account.isHiddenBalance,
        'is_active': account.isActive,
      };

      final response = await _supabaseClient
          .from('bank_accounts')
          .insert(data)
          .select()
          .single();

      return BankAccountModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao criar conta bancária: $e');
    }
  }

  /// Atualiza conta bancária existente
  Future<BankAccountModel> updateBankAccount(BankAccountModel account) async {
    try {
      final response = await _supabaseClient
          .from('bank_accounts')
          .update(account.toJson())
          .eq('id', account.id)
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .select()
          .single();

      return BankAccountModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar conta bancária: $e');
    }
  }

  /// Deleta conta bancária
  Future<void> deleteBankAccount(String id) async {
    try {
      await _supabaseClient
          .from('bank_accounts')
          .delete()
          .eq('id', id)
          .eq('user_id', _supabaseClient.auth.currentUser!.id);
    } catch (e) {
      throw Exception('Erro ao deletar conta bancária: $e');
    }
  }

  /// Calcula o saldo total de todas as contas ativas (excluindo contas com saldo escondido)
  Future<double> getTotalBalance() async {
    try {
      final accounts = await getBankAccounts(isActive: true);
      return accounts
          .where((account) => !account.isHiddenBalance)
          .fold<double>(0, (sum, account) => sum + account.balance);
    } catch (e) {
      throw Exception('Erro ao calcular saldo total: $e');
    }
  }

  /// Atualiza o saldo de uma conta
  Future<BankAccountModel> updateBalance(String id, double newBalance) async {
    try {
      final response = await _supabaseClient
          .from('bank_accounts')
          .update({'balance': newBalance, 'updated_at': DateTime.now().toIso8601String()})
          .eq('id', id)
          .eq('user_id', _supabaseClient.auth.currentUser!.id)
          .select()
          .single();

      return BankAccountModel.fromJson(response);
    } catch (e) {
      throw Exception('Erro ao atualizar saldo: $e');
    }
  }
}
