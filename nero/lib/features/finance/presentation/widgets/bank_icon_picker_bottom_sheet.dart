import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/constants/bank_icons.dart';
import '../../../../core/widgets/bank_logo.dart';

/// Bottom sheet para seleção de ícone de banco
class BankIconPickerBottomSheet extends StatelessWidget {
  final String? currentIconKey;
  final Function(BankInfo) onIconSelected;

  const BankIconPickerBottomSheet({
    super.key,
    this.currentIconKey,
    required this.onIconSelected,
  });

  static Future<BankInfo?> show(
    BuildContext context, {
    String? currentIconKey,
  }) async {
    return await showModalBottomSheet<BankInfo>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BankIconPickerBottomSheet(
        currentIconKey: currentIconKey,
        onIconSelected: (bank) => Navigator.of(context).pop(bank),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Escolher ícone da conta',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimary : const Color(0xFF1C1C1C),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.close,
                  color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
                ),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Grid de ícones
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.6,
            ),
            child: GridView.builder(
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.0,
              ),
              itemCount: BankIcons.banks.length,
              itemBuilder: (context, index) {
                final bank = BankIcons.banks[index];
                final isSelected = bank.key == currentIconKey;

                return _buildBankOption(context, bank, isSelected, isDark);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBankOption(
    BuildContext context,
    BankInfo bank,
    bool isSelected,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: () => onIconSelected(bank),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? bank.color
                : isDark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFE0E0E0),
            width: isSelected ? 3 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BankLogo(
              bankInfo: bank,
              size: 48,
              borderRadius: 10,
            ),
            const SizedBox(height: 8),
            Text(
              bank.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isDark ? AppColors.textSecondary : const Color(0xFF5F5F5F),
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
