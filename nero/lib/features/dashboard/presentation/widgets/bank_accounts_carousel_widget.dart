import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/bank_account_model.dart';

/// Widget de grade de contas bancárias para o Dashboard (3 colunas)
class BankAccountsCarouselWidget extends StatelessWidget {
  final List<BankAccountModel> accounts;
  final bool isDark;
  final VoidCallback? onViewAll;

  const BankAccountsCarouselWidget({
    super.key,
    required this.accounts,
    required this.isDark,
    this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (accounts.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header com título e botão "Ver todas"
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Minhas Contas',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              if (onViewAll != null)
                TextButton(
                  onPressed: onViewAll,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Ver todas',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // Grid de 3 colunas
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.3, // Proporção para cards mais compactos
            ),
            itemCount: accounts.length,
            itemBuilder: (context, index) {
              final account = accounts[index];
              return TweenAnimationBuilder<double>(
                duration: Duration(milliseconds: 400 + (index * 100)),
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
                child: _BankAccountCard(
                  account: account,
                  isDark: isDark,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkCard : AppColors.lightCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.grey300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.account_balance_wallet_outlined,
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Nenhuma conta cadastrada',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              ),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                child: const Text(
                  'Adicionar',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Card individual de conta bancária (premium, compacto)
class _BankAccountCard extends StatefulWidget {
  final BankAccountModel account;
  final bool isDark;

  const _BankAccountCard({
    required this.account,
    required this.isDark,
  });

  @override
  State<_BankAccountCard> createState() => _BankAccountCardState();
}

class _BankAccountCardState extends State<_BankAccountCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');

    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: () {
        // Navegar para transações com filtro da conta
        context.push('/finance', extra: {'accountFilter': widget.account.name});
      },
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: _getGradient(),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: _getColor().withOpacity(0.08),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Linha superior: Ícone e nome
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Icon(
                      _getBankIcon(),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _getAbbreviatedName(widget.account.name),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              // Linha inferior: Valor
              Text(
                widget.account.isHiddenBalance ? 'R\$ •••' : formatter.format(widget.account.balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                  height: 1.1,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Retorna o ícone do banco baseado no iconKey
  IconData _getBankIcon() {
    switch (widget.account.iconKey.toLowerCase()) {
      case 'nubank':
        return Icons.account_balance;
      case 'inter':
        return Icons.account_balance;
      case 'itau':
        return Icons.account_balance;
      case 'bradesco':
        return Icons.account_balance;
      case 'santander':
        return Icons.account_balance;
      case 'caixa':
        return Icons.account_balance;
      case 'bb':
      case 'banco_do_brasil':
        return Icons.account_balance;
      case 'picpay':
        return Icons.account_balance_wallet;
      case 'mercadopago':
        return Icons.account_balance_wallet;
      case 'cash':
      case 'dinheiro':
        return Icons.payments;
      case 'credit':
      case 'credito':
        return Icons.credit_card;
      default:
        return Icons.account_balance_wallet;
    }
  }

  /// Retorna a cor do gradiente baseado no iconKey ou color
  Color _getColor() {
    // Se tem cor personalizada, usar ela
    if (widget.account.color != null && widget.account.color!.isNotEmpty) {
      try {
        return Color(int.parse(widget.account.color!.replaceFirst('#', '0xFF')));
      } catch (_) {
        // Se falhar ao parsear, usar cor padrão
      }
    }

    // Cores baseadas no banco com gradientes premium
    switch (widget.account.iconKey.toLowerCase()) {
      case 'nubank':
        return const Color(0xFFA845D9); // Roxo Nubank mais vibrante
      case 'inter':
        return const Color(0xFFFF9800); // Laranja Inter
      case 'itau':
        return const Color(0xFFFF9800); // Laranja Itaú
      case 'bradesco':
        return const Color(0xFFCC092F); // Vermelho Bradesco
      case 'santander':
        return const Color(0xFFEC0000); // Vermelho Santander
      case 'caixa':
        return const Color(0xFF0B5CAF); // Azul Caixa
      case 'bb':
      case 'banco_do_brasil':
        return const Color(0xFFFDD835); // Amarelo BB
      case 'picpay':
        return const Color(0xFF11C76F); // Verde PicPay
      case 'mercadopago':
        return const Color(0xFF009EE3); // Azul Mercado Pago
      case 'cash':
      case 'dinheiro':
      case 'carteira':
        return const Color(0xFF38B26D); // Verde carteira
      case 'poupanca':
      case 'poupança':
        return const Color(0xFF3DA2FF); // Azul poupança
      case 'credit':
      case 'credito':
        return const Color(0xFF9C27B0); // Roxo cartão de crédito
      default:
        return AppColors.primary;
    }
  }

  /// Retorna o gradiente premium baseado na cor principal
  LinearGradient _getGradient() {
    final color = _getColor();

    // Calcula uma cor mais escura para criar o gradiente
    final darkerColor = Color.fromRGBO(
      (color.red * 0.8).toInt(),
      (color.green * 0.8).toInt(),
      (color.blue * 0.8).toInt(),
      1.0,
    );

    return LinearGradient(
      colors: [color, darkerColor],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Abrevia o nome do banco para caber no card
  String _getAbbreviatedName(String name) {
    if (name.length <= 10) return name;

    // Lista de palavras comuns para remover
    final wordsToRemove = ['Banco', 'Conta', 'Corrente', 'Poupança', 'do', 'da', 'de'];

    var abbreviated = name;
    for (final word in wordsToRemove) {
      abbreviated = abbreviated.replaceAll(RegExp(word, caseSensitive: false), '').trim();
    }

    // Se ainda for muito grande, truncar
    if (abbreviated.length > 10) {
      abbreviated = abbreviated.substring(0, 10);
    }

    return abbreviated;
  }
}
