// ===== CÓDIGO COMPLETO PARA SUBSTITUIR NO settings_management_page.dart =====

// 1. MÉTODO _showEditBankAccountDialog (substituir linhas 301-386)
void _showEditBankAccountDialog(
  BuildContext context,
  WidgetRef ref,
  BankAccountModel account,
) {
  final nameController = TextEditingController(text: account.name);
  final balanceController = TextEditingController(text: account.balance.toStringAsFixed(2));

  // Estados para novos campos
  bool isHiddenBalance = account.isHiddenBalance;
  String accountType = account.accountType;
  String iconKey = account.iconKey;
  BankInfo selectedBank = BankIcons.getBankInfo(iconKey);

  showDialog(
    context: context,
    builder: (dialogContext) => StatefulBuilder(
      builder: (context, setState) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return AlertDialog(
          title: const Text('Editar Conta'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome da conta
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome da Conta',
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Saldo
                  TextField(
                    controller: balanceController,
                    decoration: const InputDecoration(
                      labelText: 'Saldo',
                      prefixText: 'R\$ ',
                    ),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: 20),

                  // Seletor de ícone
                  Text(
                    'Ícone da conta',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () async {
                      final result = await BankIconPickerBottomSheet.show(
                        dialogContext,
                        currentIconKey: iconKey,
                      );
                      if (result != null) {
                        setState(() {
                          selectedBank = result;
                          iconKey = result.key;
                        });
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: selectedBank.color.withOpacity(0.1),
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
                            selectedBank.icon,
                            style: const TextStyle(fontSize: 32),
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
                  Text(
                    'Tipo de conta',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Pessoa Física'),
                          subtitle: const Text('PF'),
                          value: 'pf',
                          groupValue: accountType,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => accountType = value);
                            }
                          },
                          activeColor: AppColors.primary,
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Pessoa Jurídica'),
                          subtitle: const Text('PJ'),
                          value: 'pj',
                          groupValue: accountType,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => accountType = value);
                            }
                          ),
                          activeColor: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Switch: Esconder saldo
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Esconder saldo desta conta',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimary
                                      : const Color(0xFF1C1C1C),
                                ),
                              ),
                            ),
                            Switch(
                              value: isHiddenBalance,
                              onChanged: (value) {
                                setState(() => isHiddenBalance = value);
                              },
                              activeColor: AppColors.primary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Quando ativado, o saldo não aparece e não é somado no total',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondary
                                : const Color(0xFF5F5F5F),
                          ),
                        ),
                      ],
                    ),
                  ),
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
                );

                final success = await ref
                    .read(bankAccountsListProvider.notifier)
                    .updateBankAccount(updatedAccount);

                if (context.mounted) {
                  Navigator.pop(context);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Conta atualizada com sucesso!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Erro ao atualizar conta'),
                        backgroundColor: AppColors.error,
                      ),
                    );
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

// 2. MÉTODO _buildBankAccountCard ATUALIZADO (substituir linhas 134-200)
Widget _buildBankAccountCard(
  BuildContext context,
  WidgetRef ref,
  BankAccountModel account,
  bool isDark,
) {
  final bankInfo = BankIcons.getBankInfo(account.iconKey);

  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isDark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFE0E0E0),
      ),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.all(16),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: bankInfo.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            bankInfo.icon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              account.name,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.textPrimary : AppColors.lightText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          // Chip PF/PJ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: account.accountType == 'pj'
                  ? AppColors.primary.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              account.accountType.toUpperCase(),
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: account.accountType == 'pj'
                    ? AppColors.primary
                    : Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(
        account.isHiddenBalance
            ? '● ● ● ● ● ●'
            : 'R\$ ${account.balance.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 12,
          color: isDark ? AppColors.textSecondary : AppColors.lightTextSecondary,
        ),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20),
            color: AppColors.primary,
            onPressed: () => _showEditBankAccountDialog(context, ref, account),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20),
            color: AppColors.error,
            onPressed: () => _confirmDeleteBankAccount(context, ref, account),
          ),
        ],
      ),
    ),
  );
}

// 3. ATUALIZAR MÉTODO DE ADICIONAR CONTA (_showAddBankAccountDialog)
// Buscar no arquivo e adicionar os mesmos campos aos defaults:
//   isHiddenBalance: false,
//   accountType: 'pf',
//   iconKey: 'generic',

// 4. Para atualizar o cálculo do saldo total (em finance_page ou dashboard):
// Buscar onde está sendo feito o cálculo de soma das contas e filtrar:
//   final totalBalance = accounts
//       .where((account) => !account.isHiddenBalance)  // <-- Adicionar este filtro
//       .fold<double>(0, (sum, account) => sum + account.balance);
