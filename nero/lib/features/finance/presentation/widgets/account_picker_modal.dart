// lib/features/finance/presentation/widgets/account_picker_modal.dart
import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/bank_account_model.dart';

/// Modal Picker Premium para seleção de conta/banco (Opção C - estilo Organizze)
class AccountPickerModal extends StatefulWidget {
  final String? selectedAccountName;
  final List<BankAccountModel> accounts;
  final Function(String accountName) onAccountSelected;
  final Color Function(BankAccountModel) getBankColor;
  final IconData Function(String?) getBankIcon;
  final String title;

  const AccountPickerModal({
    super.key,
    required this.selectedAccountName,
    required this.accounts,
    required this.onAccountSelected,
    required this.getBankColor,
    required this.getBankIcon,
    this.title = 'Selecionar Conta',
  });

  @override
  State<AccountPickerModal> createState() => _AccountPickerModalState();
}

class _AccountPickerModalState extends State<AccountPickerModal> {
  late TextEditingController _searchController;
  List<BankAccountModel> _filteredAccounts = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _filteredAccounts = widget.accounts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterAccounts(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredAccounts = widget.accounts;
      } else {
        _filteredAccounts = widget.accounts
            .where((acc) => acc.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Título
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Row(
              children: [
                Text(
                  widget.title,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          // Campo de busca
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar conta...',
                prefixIcon: const Icon(Icons.search, size: 20),
                filled: true,
                fillColor: isDark ? AppColors.darkBorder.withOpacity(0.3) : const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: _filterAccounts,
            ),
          ),

          const SizedBox(height: 16),

          // Lista de contas
          Flexible(
            child: _filteredAccounts.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 48,
                          color: isDark ? Colors.white24 : Colors.black26,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma conta encontrada',
                          style: TextStyle(
                            color: isDark ? Colors.white54 : Colors.black54,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _filteredAccounts.length,
                    padding: const EdgeInsets.only(bottom: 20),
                    itemBuilder: (context, index) {
                      final account = _filteredAccounts[index];
                      final isSelected = account.name == widget.selectedAccountName;
                      final color = widget.getBankColor(account);
                      final icon = widget.getBankIcon(account.iconKey);

                      return InkWell(
                        onTap: () {
                          widget.onAccountSelected(account.name);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? (isDark ? AppColors.primary.withOpacity(0.15) : AppColors.primary.withOpacity(0.08))
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              // Ícone com background colorido
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  icon,
                                  color: color,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 16),

                              // Nome da conta
                              Expanded(
                                child: Text(
                                  account.name,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                                  ),
                                ),
                              ),

                              // Check mark se selecionado
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: AppColors.primary,
                                  size: 24,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
