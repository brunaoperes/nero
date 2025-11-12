import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/config/app_colors.dart';

/// Widget que envolve um card de transação com gesto de swipe para revelar ações
///
/// Comportamento:
/// - Swipe para esquerda revela 3 ações: Joia (Pago/Não pago), Editar, Excluir
/// - Abertura parcial a partir de 16px
/// - Threshold de acionamento rápido: 600 px/s
/// - Inércia/elasticidade ao soltar antes do threshold
/// - Fechamento automático ao tocar fora
/// - Apenas um item aberto por vez
class SwipeableTransactionCard extends StatefulWidget {
  final Widget child;
  final bool isPaid;
  final VoidCallback onTogglePaid;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onOpen;
  final VoidCallback? onClose;

  const SwipeableTransactionCard({
    super.key,
    required this.child,
    required this.isPaid,
    required this.onTogglePaid,
    required this.onEdit,
    required this.onDelete,
    this.onOpen,
    this.onClose,
  });

  @override
  State<SwipeableTransactionCard> createState() => SwipeableTransactionCardState();
}

class SwipeableTransactionCardState extends State<SwipeableTransactionCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  double _dragExtent = 0.0;
  static const double _minSwipeDistance = 16.0; // Peek mínimo
  static const double _maxSwipeDistance = 200.0; // Abertura completa
  static const double _actionWidth = 70.0; // Largura de cada ação
  static const double _velocityThreshold = 600.0; // Velocidade para auto-complete

  bool _isDragging = false;
  double _initialDragX = 0.0;
  double _initialDragY = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-_maxSwipeDistance / 100, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Fecha o swipe programaticamente
  void close() {
    _controller.reverse();
    widget.onClose?.call();
  }

  /// Abre o swipe programaticamente
  void open() {
    _controller.forward();
    widget.onOpen?.call();
  }

  void _handleDragStart(DragStartDetails details) {
    _initialDragX = details.globalPosition.dx;
    _initialDragY = details.globalPosition.dy;
    _isDragging = false; // Só ativar depois de confirmar que é horizontal
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final deltaX = details.globalPosition.dx - _initialDragX;
    final deltaY = details.globalPosition.dy - _initialDragY;

    // Se ainda não confirmou que é drag horizontal, verificar ângulo
    if (!_isDragging) {
      // Calcular ângulo do movimento
      final angle = (deltaY.abs() / (deltaX.abs() + 0.001)) * 57.2958; // rad to deg

      // Se o ângulo for > 25°, priorizar scroll vertical (não é swipe)
      if (angle > 25 && deltaY.abs() > 10) {
        return; // Deixar o scroll vertical funcionar
      }

      // Se movimento horizontal significativo, ativar swipe
      if (deltaX.abs() > 10) {
        _isDragging = true;
      }
    }

    if (!_isDragging) return;

    final delta = details.primaryDelta ?? 0.0;

    // Apenas permite arrastar para esquerda (valores negativos)
    if (delta < 0 || _dragExtent < 0) {
      setState(() {
        _dragExtent += delta;
        // Limitar entre 0 e -maxSwipeDistance
        _dragExtent = _dragExtent.clamp(-_maxSwipeDistance, 0.0);
      });
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isDragging) return;
    _isDragging = false;

    final velocity = details.primaryVelocity ?? 0.0;

    // Se a velocidade for alta o suficiente, completar a abertura
    if (velocity < -_velocityThreshold) {
      _openSwipe();
      return;
    }

    // Se a velocidade for alta no sentido contrário, fechar
    if (velocity > _velocityThreshold) {
      _closeSwipe();
      return;
    }

    // Caso contrário, decidir baseado na posição
    if (_dragExtent.abs() > _maxSwipeDistance / 3) {
      _openSwipe();
    } else {
      _closeSwipe();
    }
  }

  void _openSwipe() {
    setState(() {
      _dragExtent = -_maxSwipeDistance;
    });
    widget.onOpen?.call();

    // Haptic feedback leve
    HapticFeedback.lightImpact();
  }

  void _closeSwipe() {
    setState(() {
      _dragExtent = 0.0;
    });
    widget.onClose?.call();
  }

  void _handleAction(VoidCallback action) {
    // Fechar o swipe
    _closeSwipe();

    // Executar a ação após pequeno delay para animação
    Future.delayed(const Duration(milliseconds: 150), action);

    // Haptic feedback
    HapticFeedback.mediumImpact();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRect(
      child: GestureDetector(
        onHorizontalDragStart: _handleDragStart,
        onHorizontalDragUpdate: _handleDragUpdate,
        onHorizontalDragEnd: _handleDragEnd,
        child: Stack(
          children: [
            // Action tray (background) - SEMPRE POSICIONADO À DIREITA, FORA DA TELA
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Ação 1: Joia (Pago/Não pago)
                  _buildAction(
                    icon: widget.isPaid
                        ? Icons.thumb_up_rounded
                        : Icons.thumb_down_rounded,
                    color: widget.isPaid
                        ? (isDark ? AppColors.primary : const Color(0xFF4CAF50))
                        : const Color(0xFFE53935),
                    label: widget.isPaid ? 'Pago' : 'Não pago',
                    onTap: () => _handleAction(widget.onTogglePaid),
                  ),

                  // Ação 2: Editar
                  _buildAction(
                    icon: Icons.edit_rounded,
                    color: const Color(0xFF2196F3),
                    label: 'Editar',
                    onTap: () => _handleAction(widget.onEdit),
                  ),

                  // Ação 3: Excluir
                  _buildAction(
                    icon: Icons.delete_rounded,
                    color: const Color(0xFFE53935),
                    label: 'Excluir',
                    onTap: () => _handleAction(widget.onDelete),
                  ),
                ],
              ),
            ),

            // Card principal (foreground) - DESLIZA SOBRE AS AÇÕES
            AnimatedContainer(
              duration: _isDragging
                  ? Duration.zero
                  : const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              transform: Matrix4.translationValues(_dragExtent, 0, 0),
              child: Container(
                color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAction({
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: _actionWidth,
        color: color.withOpacity(0.1),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
