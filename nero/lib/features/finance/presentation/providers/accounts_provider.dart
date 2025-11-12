import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Provider para gerenciar contas/bancos
final accountsProvider = StateNotifierProvider<AccountsNotifier, List<String>>((ref) {
  return AccountsNotifier();
});

/// Notifier para gerenciar contas/bancos
class AccountsNotifier extends StateNotifier<List<String>> {
  static const String _key = 'user_accounts';
  static const List<String> _defaultAccounts = [
    'Carteira / Dinheiro',
    'Nubank',
    'Itaú',
    'Bradesco',
    'Caixa',
    'Santander',
    'PicPay',
  ];

  AccountsNotifier() : super(_defaultAccounts) {
    _loadAccounts();
  }

  /// Carrega contas do SharedPreferences
  Future<void> _loadAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_key);
      if (saved != null && saved.isNotEmpty) {
        state = saved;
      }
    } catch (e) {
      print('[AccountsNotifier] Erro ao carregar contas: $e');
    }
  }

  /// Salva contas no SharedPreferences
  Future<void> _saveAccounts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, state);
    } catch (e) {
      print('[AccountsNotifier] Erro ao salvar contas: $e');
    }
  }

  /// Adiciona uma nova conta
  Future<void> addAccount(String account) async {
    if (account.trim().isEmpty) return;
    if (state.contains(account.trim())) return;

    state = [...state, account.trim()];
    await _saveAccounts();
  }

  /// Remove uma conta
  Future<void> removeAccount(String account) async {
    state = state.where((a) => a != account).toList();
    await _saveAccounts();
  }

  /// Edita uma conta
  Future<void> editAccount(String oldAccount, String newAccount) async {
    if (newAccount.trim().isEmpty) return;
    if (state.contains(newAccount.trim()) && oldAccount != newAccount) return;

    final index = state.indexOf(oldAccount);
    if (index == -1) return;

    final newList = [...state];
    newList[index] = newAccount.trim();
    state = newList;
    await _saveAccounts();
  }

  /// Restaura contas padrão
  Future<void> restoreDefaults() async {
    state = _defaultAccounts;
    await _saveAccounts();
  }
}
