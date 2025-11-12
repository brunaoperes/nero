import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/constants/bank_icons.dart';
import '../../../../core/widgets/bank_logo.dart';
import '../../../../shared/models/bank_account_model.dart';
import '../../../../shared/widgets/account_card_widget.dart';
import '../providers/bank_account_providers.dart';
import '../providers/finance_providers.dart';
import '../../domain/entities/category_entity.dart';
import '../widgets/bank_icon_picker_bottom_sheet.dart';

/// Página de gerenciamento de contas bancárias e categorias
class SettingsManagementPage extends ConsumerStatefulWidget {
  const SettingsManagementPage({super.key});

  @override
  ConsumerState<SettingsManagementPage> createState() =>
      _SettingsManagementPageState();
}

class _SettingsManagementPageState
    extends ConsumerState<SettingsManagementPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _bankAccountsTabKey = GlobalKey<_BankAccountsTabState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? AppColors.textPrimary : AppColors.lightIcon,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Gerenciar',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textPrimary : AppColors.lightText,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Column(
            children: [
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.primary,
                indicatorWeight: 3,
                labelColor: AppColors.primary,
                labelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
                unselectedLabelColor: isDark
                    ? AppColors.textSecondary
                    : AppColors.lightTextSecondary,
                unselectedLabelStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
                tabs: const [
                  Tab(text: 'Contas Bancárias'),
                  Tab(text: 'Categorias'),
                ],
              ),
            ],
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BankAccountsTab(key: _bankAccountsTabKey),
          _CategoriesTab(),
        ],
      ),
      floatingActionButton: _tabController.index == 0
          ? FloatingActionButton(
              onPressed: () {
                _bankAccountsTabKey.currentState?._showAddBankAccountDialog(context, ref);
              },
              backgroundColor: const Color(0xFF007BFF),
              elevation: 4,
              child: const Icon(
                Icons.add,
                size: 24,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

}

/// Aba de gerenciamento de contas bancárias
class _BankAccountsTab extends ConsumerStatefulWidget {
  const _BankAccountsTab({super.key});

  @override
  ConsumerState<_BankAccountsTab> createState() => _BankAccountsTabState();
}

class _BankAccountsTabState extends ConsumerState<_BankAccountsTab> {
  bool _hideAllBalances = false;
  List<BankAccountModel>? _localAccounts; // Dados locais que controlam a UI

  @override
  void initState() {
    super.initState();
    // Carregar dados iniciais
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accounts = ref.read(bankAccountsListProvider).value;
      if (accounts != null && mounted) {
        setState(() {
          _localAccounts = accounts..sort((a, b) => a.name.compareTo(b.name));
          _hideAllBalances = accounts.every((a) => a.isHiddenBalance);
        });
      }
    });
  }

  /// Alterna a visibilidade de TODAS as contas de uma vez
  Future<void> _toggleAllBalancesVisibility() async {
    if (_localAccounts == null) return;

    final newVisibility = !_hideAllBalances;

    // 1. Atualizar UI IMEDIATAMENTE com dados locais (mantendo ordem alfabética)
    setState(() {
      _hideAllBalances = newVisibility;
      _localAccounts = (_localAccounts!.map((account) {
        return account.copyWith(isHiddenBalance: newVisibility);
      }).toList())..sort((a, b) => a.name.compareTo(b.name));
    });

    // 2. Atualizar banco de dados em background (sem await)
    Future.microtask(() async {
      try {
        await Future.wait(
          _localAccounts!.map((account) {
            return ref.read(bankAccountsListProvider.notifier).updateBankAccount(account);
          }).toList(),
        );

        // 3. Recarregar dados do servidor silenciosamente
        ref.invalidate(bankAccountsListProvider);

        // 4. Aguardar um frame e atualizar dados locais com dados do servidor
        await Future.delayed(const Duration(milliseconds: 100));
        final freshAccounts = ref.read(bankAccountsListProvider).value;
        if (freshAccounts != null && mounted) {
          setState(() {
            _localAccounts = freshAccounts..sort((a, b) => a.name.compareTo(b.name));
          });
        }
      } catch (e) {
        debugPrint('Erro ao atualizar visibilidade: $e');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Se ainda não temos dados locais, buscar do provider
    if (_localAccounts == null) {
      final accountsAsync = ref.watch(bankAccountsListProvider);
      return accountsAsync.when(
        data: (accounts) {
          // Inicializar dados locais (ordenados alfabeticamente)
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _localAccounts = accounts..sort((a, b) => a.name.compareTo(b.name));
                _hideAllBalances = accounts.every((a) => a.isHiddenBalance);
              });
            }
          });

          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(AppColors.primary),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        error: (error, _) => Center(
          child: Text('Erro ao carregar contas: $error'),
        ),
      );
    }

    // Usar dados locais para renderizar (nunca pisca!)
    final displayAccounts = _localAccounts!;

    if (displayAccounts.isEmpty) {
      return _buildEmptyState(
        context,
        isDark,
        'Nenhuma conta cadastrada',
        'Adicione suas contas bancárias para começar',
        Icons.account_balance_wallet,
        () => _showAddBankAccountDialog(context, ref),
      );
    }

    return Column(
      children: [
        // SUBHEADER PREMIUM - Minhas Contas + Contador + Toggle Global
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : const Color(0xFFFAFAFA),
            border: Border(
              bottom: BorderSide(
                color: isDark
                    ? const Color(0xFF2A2A2A).withOpacity(0.3)
                    : const Color(0xFFE0E0E0).withOpacity(0.5),
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              // Título + Contador
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Minhas Contas',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                        fontFamily: 'Inter',
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Contador de contas
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${displayAccounts.length}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Toggle Global de Visibilidade (design premium)
              _VisibilityToggleButton(
                isHidden: _hideAllBalances,
                onTap: _toggleAllBalancesVisibility,
                isDark: isDark,
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: displayAccounts.length,
            itemBuilder: (context, index) {
              final account = displayAccounts[index];

              // Animação de fade-in com atraso progressivo
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 300 + (index * 50)),
                tween: Tween(begin: 0.0, end: 1.0),
                curve: Curves.easeOut,
                builder: (context, value, child) {
                  return Opacity(
                    opacity: value,
                    child: Transform.translate(
                      offset: Offset(0, 20 * (1 - value)),
                      child: child,
                    ),
                  );
                },
                child: _buildBankAccountCard(context, ref, account, isDark),
              );
            },
          ),
        ),
        // FAB substituiu o botão de adicionar
      ],
    );
  }

  Widget _buildBankAccountCard(
    BuildContext context,
    WidgetRef ref,
    BankAccountModel account,
    bool isDark,
  ) {
    return AccountCardWidget(
      account: account,
      isDark: isDark,
      compactMode: false, // Modo lista completo
      onTap: () {
        // Navegar para finanças com filtro da conta
        // Usar pop + push para garantir que o extra seja recebido
        Navigator.of(context).pop(); // Fecha a tela de gerenciamento
        context.push('/finance', extra: {'accountFilter': account.name});
      },
      // onToggleVisibility removido - agora é global no topo
      onEdit: () => _showEditBankAccountDialog(context, ref, account),
      onDelete: () => _confirmDeleteBankAccount(context, ref, account),
    );
  }

  /// Alterna a visibilidade do saldo da conta
  Future<void> _toggleAccountVisibility(
    BuildContext context,
    WidgetRef ref,
    BankAccountModel account,
  ) async {
    final updatedAccount = account.copyWith(
      isHiddenBalance: !account.isHiddenBalance,
    );

    try {
      await ref.read(bankAccountsListProvider.notifier).updateBankAccount(updatedAccount);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              updatedAccount.isHiddenBalance
                  ? 'Saldo ocultado'
                  : 'Saldo visível',
              style: const TextStyle(fontSize: 14),
            ),
            duration: const Duration(milliseconds: 1500),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar conta: $error'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  Color _parseColor(String? colorHex) {
    if (colorHex == null || colorHex.isEmpty) return AppColors.primary;
    try {
      final hex = colorHex.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return AppColors.primary;
    }
  }

  void _showAddBankAccountDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final balanceController = TextEditingController(text: '0.00');
    String selectedColor = '0072FF';
    String accountType = 'pf'; // PF por padrão
    String iconKey = 'generic';
    BankInfo selectedBank = BankIcons.getBankInfo(iconKey);
    bool isHiddenBalance = false;

    // Cores pré-definidas para seleção
    final presetColors = [
      '000000', // Preto
      '8A05BE', // Roxo Nubank
      'FF7A00', // Laranja Inter
      '0B4C8C', // Azul Itaú
      'CC092F', // Vermelho Bradesco
      'EC0000', // Vermelho Santander
      '0B5CAF', // Azul Caixa
      'FDD835', // Amarelo BB
      '11C76F', // Verde PicPay
      '009EE3', // Azul Mercado Pago
      '4CAF50', // Verde
      '9C27B0', // Roxo
      'FF9800', // Laranja
      'F44336', // Vermelho
      '2196F3', // Azul
      '009688', // Teal
      '607D8B', // Cinza Azulado
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return AlertDialog(
            title: Center(
              child: Text(
                'Adicionar Conta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                ),
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome da conta
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 20,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nome da Conta',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Nubank, Bradesco',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Saldo Inicial
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 20,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Saldo Inicial',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: balanceController,
                      decoration: InputDecoration(
                        prefixText: 'R\$ ',
                        hintText: '0,00',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 20),

                    // Seletor de ícone
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 20,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ícone da conta',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final result = await BankIconPickerBottomSheet.show(
                          dialogContext,
                          currentIconKey: iconKey,
                        );
                        if (result != null) {
                          setDialogState(() {
                            selectedBank = result;
                            iconKey = result.key;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF3A3A3A)
                                : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Row(
                          children: [
                            BankLogo(
                              bankInfo: selectedBank,
                              size: 40,
                              borderRadius: 8,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedBank.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : const Color(0xFF1C1C1C),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: isDark
                                  ? AppColors.textSecondary
                                  : const Color(0xFF5F5F5F),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tipo de conta (PF/PJ)
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 20,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tipo de conta',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => accountType = 'pf'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: accountType == 'pf'
                                    ? AppColors.primary
                                    : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: accountType == 'pf'
                                      ? AppColors.primary
                                      : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0)),
                                  width: accountType == 'pf' ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Pessoa Física',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: accountType == 'pf'
                                          ? Colors.white
                                          : (isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C)),
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'PF',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: accountType == 'pf'
                                          ? Colors.white.withOpacity(0.8)
                                          : (isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => accountType = 'pj'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: accountType == 'pj'
                                    ? AppColors.primary
                                    : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: accountType == 'pj'
                                      ? AppColors.primary
                                      : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0)),
                                  width: accountType == 'pj' ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Pessoa Jurídica',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: accountType == 'pj'
                                          ? Colors.white
                                          : (isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C)),
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'PJ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: accountType == 'pj'
                                          ? Colors.white.withOpacity(0.8)
                                          : (isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Switch: Esconder saldo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Esconder saldo desta conta',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : const Color(0xFF1C1C1C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Não aparece e não é somado no total',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.textSecondary
                                      : const Color(0xFF5F5F5F),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isHiddenBalance,
                          onChanged: (value) {
                            setDialogState(() => isHiddenBalance = value);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Seletor de cor
                    Row(
                      children: [
                        Icon(
                          Icons.palette,
                          size: 20,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cor da Conta',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: presetColors.map((color) {
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(int.parse('0xFF$color')),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.primary,
                                      width: 3,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(int.parse('0xFF$color')).withOpacity(0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final balance = double.tryParse(balanceController.text) ?? 0.0;

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Digite o nome da conta')),
                    );
                    return;
                  }

                  final account = BankAccountModel(
                    id: '',
                    userId: '',
                    name: name,
                    balance: balance,
                    openingBalance: balance,
                    color: '#$selectedColor', // Adiciona # antes da cor
                    icon: 'account_balance_wallet',
                    iconKey: iconKey,
                    accountType: accountType,
                    isHiddenBalance: isHiddenBalance,
                    isActive: true,
                  );

                  final success = await ref
                      .read(bankAccountsListProvider.notifier)
                      .createBankAccount(account);

                  if (!context.mounted) return;

                  // Fechar o dialog
                  Navigator.pop(context);

                  // IMPORTANTE: Executar a atualização FORA do contexto do dialog
                  // usando addPostFrameCallback para garantir que estamos no contexto da página
                  if (success) {
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      if (!mounted) return;

                      // Invalidar provider e aguardar atualização
                      ref.invalidate(bankAccountsListProvider);

                      // Aguardar múltiplos frames para garantir que o provider recarregou
                      await Future.delayed(const Duration(milliseconds: 300));

                      if (!mounted) return;

                      // Buscar dados atualizados do provider
                      final asyncValue = ref.read(bankAccountsListProvider);
                      asyncValue.whenData((accounts) {
                        if (mounted) {
                          setState(() {
                            _localAccounts = List<BankAccountModel>.from(accounts)
                              ..sort((a, b) => a.name.compareTo(b.name));
                          });
                        }
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Conta adicionada com sucesso!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao adicionar conta'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: const Text('Adicionar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditBankAccountDialog(
    BuildContext context,
    WidgetRef ref,
    BankAccountModel account,
  ) {
    final nameController = TextEditingController(text: account.name);
    final balanceController =
        TextEditingController(text: account.balance.toStringAsFixed(2));

    // Estados para novos campos
    bool isHiddenBalance = account.isHiddenBalance;
    String accountType = account.accountType;
    String iconKey = account.iconKey;
    BankInfo selectedBank = BankIcons.getBankInfo(iconKey);
    // Remove o # da cor ao inicializar (se existir)
    String selectedColor = (account.color ?? '0072FF').replaceFirst('#', '');

    // Cores pré-definidas para seleção
    final presetColors = [
      '000000', // Preto
      '8A05BE', // Roxo Nubank
      'FF7A00', // Laranja Inter
      '0B4C8C', // Azul Itaú
      'CC092F', // Vermelho Bradesco
      'EC0000', // Vermelho Santander
      '0B5CAF', // Azul Caixa
      'FDD835', // Amarelo BB
      '11C76F', // Verde PicPay
      '009EE3', // Azul Mercado Pago
      '4CAF50', // Verde
      '9C27B0', // Roxo
      'FF9800', // Laranja
      'F44336', // Vermelho
      '2196F3', // Azul
      '009688', // Teal
      '607D8B', // Cinza Azulado
    ];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return AlertDialog(
            title: Center(
              child: Text(
                'Editar Conta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                ),
              ),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
            content: SingleChildScrollView(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome da conta
                    Row(
                      children: [
                        Icon(
                          Icons.account_balance_wallet,
                          size: 20,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Nome da Conta',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: 'Ex: Nubank',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Saldo
                    Row(
                      children: [
                        Icon(
                          Icons.attach_money,
                          size: 20,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Saldo',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: balanceController,
                      decoration: InputDecoration(
                        prefixText: 'R\$ ',
                        hintText: '0,00',
                        filled: true,
                        fillColor: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 20),

                    // Seletor de ícone
                    Row(
                      children: [
                        Icon(
                          Icons.business,
                          size: 20,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Ícone da conta',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () async {
                        final result = await BankIconPickerBottomSheet.show(
                          dialogContext,
                          currentIconKey: iconKey,
                        );
                        if (result != null) {
                          setDialogState(() {
                            selectedBank = result;
                            iconKey = result.key;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF3A3A3A)
                                : const Color(0xFFE0E0E0),
                          ),
                        ),
                        child: Row(
                          children: [
                            BankLogo(
                              bankInfo: selectedBank,
                              size: 40,
                              borderRadius: 8,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                selectedBank.name,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : const Color(0xFF1C1C1C),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right,
                              color: isDark
                                  ? AppColors.textSecondary
                                  : const Color(0xFF5F5F5F),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tipo de conta (PF/PJ) - Toggle Buttons
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          size: 20,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Tipo de conta',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => accountType = 'pf'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: accountType == 'pf'
                                    ? AppColors.primary
                                    : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: accountType == 'pf'
                                      ? AppColors.primary
                                      : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0)),
                                  width: accountType == 'pf' ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Pessoa Física',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: accountType == 'pf'
                                          ? Colors.white
                                          : (isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C)),
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'PF',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: accountType == 'pf'
                                          ? Colors.white.withOpacity(0.8)
                                          : (isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setDialogState(() => accountType = 'pj'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color: accountType == 'pj'
                                    ? AppColors.primary
                                    : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5)),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: accountType == 'pj'
                                      ? AppColors.primary
                                      : (isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0)),
                                  width: accountType == 'pj' ? 2 : 1,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Pessoa Jurídica',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: accountType == 'pj'
                                          ? Colors.white
                                          : (isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C)),
                                    ),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'PJ',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: accountType == 'pj'
                                          ? Colors.white.withOpacity(0.8)
                                          : (isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Switch: Esconder saldo - Versão elegante
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Esconder saldo desta conta',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : const Color(0xFF1C1C1C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Não aparece e não é somado no total',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isDark
                                      ? AppColors.textSecondary
                                      : const Color(0xFF5F5F5F),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isHiddenBalance,
                          onChanged: (value) {
                            setDialogState(() => isHiddenBalance = value);
                          },
                          activeColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Seletor de cor
                    Row(
                      children: [
                        Icon(
                          Icons.palette,
                          size: 20,
                          color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Cor da Conta',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: presetColors.map((color) {
                        final isSelected = selectedColor == color;
                        return GestureDetector(
                          onTap: () {
                            setDialogState(() {
                              selectedColor = color;
                            });
                          },
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(int.parse('0xFF$color')),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.primary,
                                      width: 3,
                                    )
                                  : null,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(int.parse('0xFF$color')).withOpacity(0.4),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 20,
                                  )
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  final balance = double.tryParse(balanceController.text) ?? account.balance;

                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Digite o nome da conta')),
                    );
                    return;
                  }

                  final updatedAccount = account.copyWith(
                    name: name,
                    balance: balance,
                    isHiddenBalance: isHiddenBalance,
                    accountType: accountType,
                    iconKey: iconKey,
                    color: '#$selectedColor',
                  );

                  final success = await ref
                      .read(bankAccountsListProvider.notifier)
                      .updateBankAccount(updatedAccount);

                  if (!context.mounted) return;

                  // Fechar o dialog
                  Navigator.pop(context);

                  // IMPORTANTE: Executar a atualização FORA do contexto do dialog
                  // usando addPostFrameCallback para garantir que estamos no contexto da página
                  if (success) {
                    WidgetsBinding.instance.addPostFrameCallback((_) async {
                      if (!mounted) return;

                      ref.invalidate(bankAccountsListProvider);
                      await Future.delayed(const Duration(milliseconds: 300));

                      if (!mounted) return;

                      final asyncValue = ref.read(bankAccountsListProvider);
                      asyncValue.when(
                        data: (accounts) {
                          if (mounted) {
                            setState(() {
                              _localAccounts = List<BankAccountModel>.from(accounts)
                                ..sort((a, b) => a.name.compareTo(b.name));
                            });
                          }
                        },
                        loading: () {},
                        error: (e, s) {},
                      );

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Conta atualizada com sucesso!'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      }
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao atualizar conta'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteBankAccount(
    BuildContext context,
    WidgetRef ref,
    BankAccountModel account,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Conta'),
        content: Text(
          'Tem certeza que deseja excluir a conta "${account.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(bankAccountsListProvider.notifier)
                  .deleteBankAccount(account.id);

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  // Aguardar um pequeno delay
                  await Future.delayed(const Duration(milliseconds: 200));

                  // Atualizar dados locais com os novos dados do servidor
                  final freshAccounts = ref.read(bankAccountsListProvider).value;
                  if (freshAccounts != null && mounted) {
                    setState(() {
                      _localAccounts = freshAccounts..sort((a, b) => a.name.compareTo(b.name));
                    });
                  }

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Conta excluída com sucesso!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Erro ao excluir conta'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }
}

/// Aba de gerenciamento de categorias
class _CategoriesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return _buildEmptyState(
            context,
            isDark,
            'Nenhuma categoria cadastrada',
            'As categorias padrão serão carregadas automaticamente',
            Icons.category,
            null,
          );
        }

        // Separar por tipo
        final incomeCategories = categories
            .where((c) => c.type == CategoryType.income || c.type == CategoryType.both)
            .toList();
        final expenseCategories = categories
            .where((c) => c.type == CategoryType.expense || c.type == CategoryType.both)
            .toList();

        return Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categorias de Receita',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...incomeCategories.map((category) =>
                        _buildCategoryCard(context, ref, category, isDark)),
                    const SizedBox(height: 24),
                    Text(
                      'Categorias de Despesa',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimary : AppColors.lightText,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...expenseCategories.map((category) =>
                        _buildCategoryCard(context, ref, category, isDark)),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
            _buildAddButton(
              context,
              isDark,
              'Adicionar Categoria',
              Icons.add,
              () => _showAddCategoryDialog(context, ref),
            ),
          ],
        );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(AppColors.primary),
        ),
      ),
      error: (error, _) => Center(
        child: Text('Erro ao carregar categorias: $error'),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    String selectedIcon = '📦';
    String selectedColor = '0072FF';
    CategoryType selectedType = CategoryType.expense;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return AlertDialog(
            title: const Text('Adicionar Categoria'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nome
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Categoria',
                      hintText: 'Ex: Viagens, Pets, Academia',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Seletor de ícone (emoji)
                  Row(
                    children: [
                      const Text('Ícone: '),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final icon = await _showIconPicker(context);
                          if (icon != null) {
                            setDialogState(() => selectedIcon = icon);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            selectedIcon,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tipo de categoria
                  Row(
                    children: [
                      const Text('Tipo: '),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<CategoryType>(
                          value: selectedType,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: CategoryType.income,
                              child: Text('Receita'),
                            ),
                            DropdownMenuItem(
                              value: CategoryType.expense,
                              child: Text('Despesa'),
                            ),
                            DropdownMenuItem(
                              value: CategoryType.both,
                              child: Text('Ambos'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => selectedType = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Digite o nome da categoria')),
                    );
                    return;
                  }

                  final now = DateTime.now();
                  final userId = Supabase.instance.client.auth.currentUser?.id ?? '';
                  final category = CategoryEntity(
                    id: '',
                    userId: userId,
                    name: name,
                    icon: selectedIcon,
                    color: selectedColor,
                    type: selectedType,
                    description: null,
                    isDefault: false,
                    createdAt: now,
                    updatedAt: now,
                  );

                  final success = await ref
                      .read(categoryControllerProvider.notifier)
                      .createCategory(category);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Categoria adicionada com sucesso!'
                              : 'Erro ao adicionar categoria',
                        ),
                        backgroundColor: success ? AppColors.success : AppColors.error,
                      ),
                    );
                    if (success) {
                      // Recarregar as categorias
                      ref.invalidate(categoriesProvider);
                    }
                  }
                },
                child: const Text('Adicionar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, WidgetRef ref, CategoryEntity category) {
    final nameController = TextEditingController(text: category.name);
    String selectedIcon = category.icon;
    CategoryType selectedType = category.type;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) {
          final isDark = Theme.of(context).brightness == Brightness.dark;

          return AlertDialog(
            title: const Text('Editar Categoria'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Nome
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Categoria',
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Seletor de ícone (emoji)
                  Row(
                    children: [
                      const Text('Ícone: '),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () async {
                          final icon = await _showIconPicker(context);
                          if (icon != null) {
                            setDialogState(() => selectedIcon = icon);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.primary),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            selectedIcon,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Tipo de categoria
                  Row(
                    children: [
                      const Text('Tipo: '),
                      const SizedBox(width: 8),
                      Expanded(
                        child: DropdownButton<CategoryType>(
                          value: selectedType,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: CategoryType.income,
                              child: Text('Receita'),
                            ),
                            DropdownMenuItem(
                              value: CategoryType.expense,
                              child: Text('Despesa'),
                            ),
                            DropdownMenuItem(
                              value: CategoryType.both,
                              child: Text('Ambos'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() => selectedType = value);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final name = nameController.text.trim();
                  if (name.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Digite o nome da categoria')),
                    );
                    return;
                  }

                  final updatedCategory = category.copyWith(
                    name: name,
                    icon: selectedIcon,
                    type: selectedType,
                    updatedAt: DateTime.now(),
                  );

                  final success = await ref
                      .read(categoryControllerProvider.notifier)
                      .updateCategory(updatedCategory);

                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Categoria atualizada com sucesso!'
                              : 'Erro ao atualizar categoria',
                        ),
                        backgroundColor: success ? AppColors.success : AppColors.error,
                      ),
                    );
                    if (success) {
                      // Recarregar as categorias
                      ref.invalidate(categoriesProvider);
                    }
                  }
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _confirmDeleteCategory(BuildContext context, WidgetRef ref, CategoryEntity category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Categoria'),
        content: Text(
          'Tem certeza que deseja excluir a categoria "${category.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              final success = await ref
                  .read(categoryControllerProvider.notifier)
                  .deleteCategory(category.id);

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? 'Categoria excluída com sucesso!'
                          : 'Erro ao excluir categoria',
                    ),
                    backgroundColor: success ? AppColors.success : AppColors.error,
                  ),
                );
                if (success) {
                  // Recarregar as categorias
                  ref.invalidate(categoriesProvider);
                }
              }
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
  }

  Future<String?> _showIconPicker(BuildContext context) async {
    // Lista de emojis comuns para categorias
    final emojis = [
      '🍔', '🍕', '🍜', '☕', '🚗', '✈️', '🏠', '💊', '📚', '🎮',
      '👕', '💰', '💼', '📱', '🎬', '🏃', '🐕', '🎵', '🛒', '🎁',
      '💡', '🔧', '🌳', '🚌', '🏥', '⚽', '🎨', '📦', '🍷', '🌮',
    ];

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Escolher Ícone'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              childAspectRatio: 1,
            ),
            itemCount: emojis.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () => Navigator.pop(context, emojis[index]),
                child: Center(
                  child: Text(
                    emojis[index],
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    WidgetRef ref,
    CategoryEntity category,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark
              ? const Color(0xFF2A2A2A)
              : const Color(0xFFE0E0E0),
        ),
      ),
      child: Row(
        children: [
          Text(
            category.icon,
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              category.name,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textPrimary : AppColors.lightText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (category.isDefault)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Padrão',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          // Botões de ação (apenas para categorias customizadas)
          if (!category.isDefault) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              color: AppColors.primary,
              onPressed: () => _showEditCategoryDialog(context, ref, category),
            ),
            IconButton(
              icon: const Icon(Icons.delete, size: 20),
              color: AppColors.error,
              onPressed: () => _confirmDeleteCategory(context, ref, category),
            ),
          ],
        ],
      ),
    );
  }
}

Widget _buildEmptyState(
  BuildContext context,
  bool isDark,
  String title,
  String subtitle,
  IconData icon,
  VoidCallback? onAdd,
) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: isDark
                ? AppColors.textSecondary.withOpacity(0.3)
                : AppColors.lightTextSecondary.withOpacity(0.3),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColors.lightText,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: isDark
                  ? AppColors.textSecondary
                  : AppColors.lightTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          if (onAdd != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Adicionar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    ),
  );
}

/// Widget de toggle de visibilidade global com animação premium
class _VisibilityToggleButton extends StatefulWidget {
  final bool isHidden;
  final VoidCallback onTap;
  final bool isDark;

  const _VisibilityToggleButton({
    required this.isHidden,
    required this.onTap,
    required this.isDark,
  });

  @override
  State<_VisibilityToggleButton> createState() => _VisibilityToggleButtonState();
}

class _VisibilityToggleButtonState extends State<_VisibilityToggleButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.isHidden
          ? 'Mostrar todos os saldos'
          : 'Ocultar todos os saldos',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.92 : 1.0,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 80),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isPressed
                  ? AppColors.primary.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 120),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: animation,
                    child: child,
                  ),
                );
              },
              child: Icon(
                widget.isHidden
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                key: ValueKey(widget.isHidden),
                color: widget.isDark
                    ? AppColors.textSecondary
                    : const Color(0xFF5F5F5F),
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão CTA premium "Adicionar Conta" com animação de hover
Widget _buildAddButton(
  BuildContext context,
  bool isDark,
  String label,
  IconData icon,
  VoidCallback onPressed,
) {
  return Container(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
    decoration: BoxDecoration(
      color: isDark ? AppColors.darkSurface : Colors.white,
      border: Border(
        top: BorderSide(
          color: isDark
              ? const Color(0xFF2A2A2A).withOpacity(0.3)
              : const Color(0xFFE0E0E0).withOpacity(0.5),
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -2),
        ),
      ],
    ),
    child: SafeArea(
      child: _PremiumAddButton(
        label: label,
        icon: icon,
        onPressed: onPressed,
      ),
    ),
  );
}

/// Widget interno do botão com microanimação de hover
class _PremiumAddButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _PremiumAddButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  State<_PremiumAddButton> createState() => _PremiumAddButtonState();
}

class _PremiumAddButtonState extends State<_PremiumAddButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          height: 54,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: _isPressed
                  ? [
                      AppColors.primary.withOpacity(0.85),
                      AppColors.primary.withOpacity(0.70),
                    ]
                  : [
                      AppColors.primary,
                      AppColors.primary.withOpacity(0.85),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: _isPressed
                ? []
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                color: Colors.white,
                size: 22,
              ),
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Inter',
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
