import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/bank_account_model.dart';
import '../../data/datasources/bank_account_remote_datasource.dart';
import '../../data/repositories/bank_account_repository_impl.dart';
import '../../domain/repositories/bank_account_repository.dart';
import '../../domain/usecases/create_bank_account.dart';
import '../../domain/usecases/delete_bank_account.dart';
import '../../domain/usecases/get_bank_accounts.dart';
import '../../domain/usecases/get_total_balance.dart';
import '../../domain/usecases/update_bank_account.dart';

// ==========================================
// DATASOURCES
// ==========================================

final bankAccountRemoteDatasourceProvider = Provider<BankAccountRemoteDatasource>((ref) {
  return BankAccountRemoteDatasource(
    supabaseClient: SupabaseService.client,
  );
});

// ==========================================
// REPOSITORIES
// ==========================================

final bankAccountRepositoryProvider = Provider<BankAccountRepository>((ref) {
  return BankAccountRepositoryImpl(
    remoteDatasource: ref.watch(bankAccountRemoteDatasourceProvider),
  );
});

// ==========================================
// USECASES
// ==========================================

final getBankAccountsUseCaseProvider = Provider<GetBankAccounts>((ref) {
  return GetBankAccounts(ref.watch(bankAccountRepositoryProvider));
});

final createBankAccountUseCaseProvider = Provider<CreateBankAccount>((ref) {
  return CreateBankAccount(ref.watch(bankAccountRepositoryProvider));
});

final updateBankAccountUseCaseProvider = Provider<UpdateBankAccount>((ref) {
  return UpdateBankAccount(ref.watch(bankAccountRepositoryProvider));
});

final deleteBankAccountUseCaseProvider = Provider<DeleteBankAccount>((ref) {
  return DeleteBankAccount(ref.watch(bankAccountRepositoryProvider));
});

final getTotalBalanceUseCaseProvider = Provider<GetTotalBalance>((ref) {
  return GetTotalBalance(ref.watch(bankAccountRepositoryProvider));
});

// ==========================================
// STATE PROVIDERS
// ==========================================

/// Provider para lista de contas bancárias
final bankAccountsListProvider = StateNotifierProvider<BankAccountsListNotifier, AsyncValue<List<BankAccountModel>>>((ref) {
  return BankAccountsListNotifier(ref);
});

/// Notifier para gerenciar lista de contas bancárias
class BankAccountsListNotifier extends StateNotifier<AsyncValue<List<BankAccountModel>>> {
  final Ref _ref;

  BankAccountsListNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadBankAccounts();
  }

  /// Carrega todas as contas bancárias
  Future<void> loadBankAccounts({bool? isActive}) async {
    state = const AsyncValue.loading();
    try {
      final getBankAccounts = _ref.read(getBankAccountsUseCaseProvider);
      final accounts = await getBankAccounts(isActive: isActive);
      state = AsyncValue.data(accounts);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Cria nova conta bancária
  Future<bool> createBankAccount(BankAccountModel account) async {
    try {
      final createBankAccount = _ref.read(createBankAccountUseCaseProvider);
      await createBankAccount(account);
      await loadBankAccounts();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Atualiza conta bancária
  Future<bool> updateBankAccount(BankAccountModel account) async {
    try {
      final updateBankAccount = _ref.read(updateBankAccountUseCaseProvider);
      await updateBankAccount(account);
      await loadBankAccounts();
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Deleta conta bancária
  Future<bool> deleteBankAccount(String id) async {
    try {
      final deleteBankAccount = _ref.read(deleteBankAccountUseCaseProvider);
      await deleteBankAccount(id);
      await loadBankAccounts();
      return true;
    } catch (e) {
      return false;
    }
  }
}

// ==========================================
// SALDO TOTAL
// ==========================================

/// Provider para saldo total de todas as contas ativas
final totalBalanceProvider = FutureProvider<double>((ref) async {
  // Invalidar quando a lista de contas mudar
  ref.watch(bankAccountsListProvider);

  final getTotalBalance = ref.watch(getTotalBalanceUseCaseProvider);
  return await getTotalBalance();
});

// ==========================================
// CONTAS ATIVAS
// ==========================================

/// Provider para apenas contas ativas
final activeBankAccountsProvider = FutureProvider<List<BankAccountModel>>((ref) async {
  final repository = ref.watch(bankAccountRepositoryProvider);
  return await repository.getBankAccounts(isActive: true);
});
