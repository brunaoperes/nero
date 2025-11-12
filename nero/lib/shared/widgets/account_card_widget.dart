import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/config/app_colors.dart';
import '../models/bank_account_model.dart';

/// Widget reutilizável de card de conta bancária
///
/// Pode ser usado tanto no Dashboard (modo compacto/carrossel)
/// quanto na tela de Gerenciamento (modo lista com ações)
class AccountCardWidget extends StatelessWidget {
  final BankAccountModel account;
  final bool isDark;
  final bool compactMode; // true para Dashboard, false para gerenciamento
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleVisibility;

  const AccountCardWidget({
    super.key,
    required this.account,
    required this.isDark,
    this.compactMode = false,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    if (compactMode) {
      return _buildCompactCard();
    } else {
      return _buildFullCard();
    }
  }

  /// Card compacto para Dashboard (carousel)
  Widget _buildCompactCard() {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          gradient: _getGradient(),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: _getColor().withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo/Ícone do banco
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getBankIcon(),
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                const Spacer(),
                if (!account.isActive)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Inativa',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),

            // Nome e saldo
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _getAbbreviatedName(account.name),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Inter',
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    account.isHiddenBalance ? 'R\$ •••' : formatter.format(account.balance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
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
          ],
        ),
      ),
    );
  }

  /// Card COMPACTO para tela de Gerenciamento (84-92px altura)
  Widget _buildFullCard() {
    final formatter = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$ ');

    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 120),
      tween: Tween(begin: 0.98, end: 1.0),
      curve: Curves.easeOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12), // Espaçamento entre cards
            child: Ink(
              decoration: BoxDecoration(
                gradient: _getGradient(),
                borderRadius: BorderRadius.circular(18), // Bordas suaves
                boxShadow: [
                  BoxShadow(
                    color: _getColor().withOpacity(0.12), // Sombra mais sutil
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Container(
                height: 90, // Altura fixa compacta (84-92px)
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
              // 🎯 LINHA 1: Ícone + Nome + Badge PF/PJ + Ações (no topo direito)
              Row(
                children: [
                  // Ícone do banco (24px total)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getBankIcon(),
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Nome da conta (ellipsis em uma linha)
                  Expanded(
                    child: Text(
                      account.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                        letterSpacing: -0.2,
                        height: 1.2,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Badge PF/PJ compacto
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.22),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      account.accountType.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                        letterSpacing: 0.6,
                        height: 1.0,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  // Ações: Editar e Excluir (20px, canto superior direito)
                  if (onEdit != null)
                    _CompactActionButton(
                      icon: Icons.edit_rounded,
                      onTap: onEdit!,
                      size: 20,
                      color: const Color(0xFFFFFFBB), // Branco semiopaco
                    ),

                  if (onEdit != null && onDelete != null)
                    const SizedBox(width: 4),

                  if (onDelete != null)
                    _CompactActionButton(
                      icon: Icons.delete_rounded,
                      onTap: onDelete!,
                      size: 20,
                      color: const Color(0xFFFFFFBB),
                    ),
                ],
              ),

              // 💰 LINHA 2: Saldo OU "Saldo oculto" (sem legenda adicional)
              Padding(
                padding: const EdgeInsets.only(top: 14), // Eleva o saldo para melhor posicionamento
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Text(
                    account.isHiddenBalance
                        ? 'Saldo oculto'
                        : formatter.format(account.balance),
                    key: ValueKey(account.isHiddenBalance),
                    style: TextStyle(
                      color: account.isHiddenBalance
                          ? const Color(0xFFD0D0D0)
                          : Colors.white,
                      fontSize: 18, // Aumentado de 17 para 18px
                      fontWeight: FontWeight.bold, // Mudado para bold
                      fontFamily: 'Poppins',
                      fontStyle: account.isHiddenBalance ? FontStyle.italic : FontStyle.normal,
                      height: 1.1,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
              ),
            ),
          ),
        ),
    );
  }

  /// Retorna o ícone do banco baseado no iconKey
  IconData _getBankIcon() {
    switch (account.iconKey.toLowerCase()) {
      case 'nubank':
      case 'inter':
      case 'itau':
      case 'bradesco':
      case 'santander':
      case 'caixa':
      case 'bb':
      case 'banco_do_brasil':
        return Icons.account_balance;
      case 'picpay':
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
    if (account.color != null && account.color!.isNotEmpty) {
      try {
        return Color(int.parse(account.color!.replaceFirst('#', '0xFF')));
      } catch (_) {
        // Se falhar ao parsear, usar cor padrão
      }
    }

    // Cores baseadas no banco
    switch (account.iconKey.toLowerCase()) {
      case 'nubank':
        return const Color(0xFF8A05BE); // Roxo Nubank
      case 'inter':
        return const Color(0xFFFF7A00); // Laranja Inter
      case 'itau':
        return const Color(0xFF0B4C8C); // Azul Itaú
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
        return const Color(0xFF4CAF50); // Verde dinheiro
      case 'credit':
      case 'credito':
        return const Color(0xFF9C27B0); // Roxo cartão de crédito
      default:
        return AppColors.primary;
    }
  }

  /// Retorna o gradiente baseado na cor principal
  LinearGradient _getGradient() {
    final color = _getColor();
    return LinearGradient(
      colors: [
        color,
        color.withOpacity(0.7),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  /// Abrevia o nome do banco para caber no card compacto
  String _getAbbreviatedName(String name) {
    if (name.length <= 12) return name;

    // Lista de palavras comuns para remover
    final wordsToRemove = ['Banco', 'Conta', 'Corrente', 'Poupança', 'do', 'da', 'de'];

    var abbreviated = name;
    for (final word in wordsToRemove) {
      abbreviated = abbreviated.replaceAll(RegExp(word, caseSensitive: false), '').trim();
    }

    // Se ainda for muito grande, truncar
    if (abbreviated.length > 12) {
      abbreviated = abbreviated.substring(0, 12);
    }

    return abbreviated;
  }
}

/// Widget de botão de ação com microanimação premium
class _ActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double opacity;

  const _ActionButton({
    required this.icon,
    required this.onTap,
    this.opacity = 0.9,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: _isPressed
                ? Colors.white.withOpacity(0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            widget.icon,
            size: 20,
            color: Colors.white.withOpacity(widget.opacity),
          ),
        ),
      ),
    );
  }
}

/// Widget de botão de ação COMPACTO (16-20px) para modo compacto
class _CompactActionButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;
  final double size;
  final Color color;

  const _CompactActionButton({
    required this.icon,
    required this.onTap,
    this.size = 20,
    this.color = const Color(0xFFFFFFBB), // Branco semiopaco padrão
  });

  @override
  State<_CompactActionButton> createState() => _CompactActionButtonState();
}

class _CompactActionButtonState extends State<_CompactActionButton> {
  bool _isPressed = false;
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) {
          setState(() => _isPressed = false);
          widget.onTap();
        },
        onTapCancel: () => setState(() => _isPressed = false),
        child: AnimatedScale(
          scale: _isPressed ? 0.9 : 1.0,
          duration: const Duration(milliseconds: 80),
          curve: Curves.easeOut,
          child: Container(
            padding: const EdgeInsets.all(8), // Área de toque ≥ 36px
            decoration: BoxDecoration(
              color: _isPressed
                  ? Colors.white.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              widget.icon,
              size: widget.size,
              color: _isHovered || _isPressed
                  ? Colors.white // Branco total no hover
                  : widget.color,
            ),
          ),
        ),
      ),
    );
  }
}
