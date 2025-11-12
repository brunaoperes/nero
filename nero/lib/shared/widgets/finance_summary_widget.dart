import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/config/app_colors.dart';

/// Widget de resumo financeiro com cards coloridos
class FinanceSummaryWidget extends StatelessWidget {
  final double income;
  final double expenses;
  final String period;

  const FinanceSummaryWidget({
    super.key,
    required this.income,
    required this.expenses,
    required this.period,
  });

  @override
  Widget build(BuildContext context) {
    final balance = income - expenses;
    final currencyFormatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.darkBorder.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header com período
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_outlined,
                size: 20,
                color: AppColors.textSecondary.withOpacity(0.8),
              ),
              const SizedBox(width: 8),
              Text(
                period,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary.withOpacity(0.8),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Cards de valores
          Row(
            children: [
              // Receitas - Verde
              Expanded(
                child: _buildValueCard(
                  label: 'Receitas',
                  value: currencyFormatter.format(income),
                  icon: Icons.trending_up,
                  backgroundColor: const Color(0xFFE6FFE6),
                  textColor: const Color(0xFF009E0F),
                  borderColor: const Color(0xFFE0E0E0),
                ),
              ),
              const SizedBox(width: 12),

              // Despesas - Rosa
              Expanded(
                child: _buildValueCard(
                  label: 'Despesas',
                  value: currencyFormatter.format(expenses),
                  icon: Icons.trending_down,
                  backgroundColor: const Color(0xFFFFE6E6),
                  textColor: const Color(0xFFD32F2F),
                  borderColor: const Color(0xFFE0E0E0),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Saldo - Neutro
          _buildValueCard(
            label: 'Saldo',
            value: currencyFormatter.format(balance),
            icon: balance >= 0
                ? Icons.account_balance_outlined
                : Icons.warning_amber_outlined,
            backgroundColor: AppColors.darkBackground,
            textColor: balance >= 0
                ? const Color(0xFF009E0F)
                : const Color(0xFFD32F2F),
            borderColor: const Color(0xFFE0E0E0),
            isLarge: true,
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard({
    required String label,
    required String value,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
    required Color borderColor,
    bool isLarge = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isLarge ? 14 : 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: borderColor,
          width: 1,
        ),
      ),
      child: isLarge
          ? Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: textColor,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textColor.withOpacity(0.8),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      icon,
                      size: 16,
                      color: textColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: textColor.withOpacity(0.8),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
    );
  }
}
