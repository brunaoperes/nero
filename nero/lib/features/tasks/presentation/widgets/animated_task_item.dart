import 'package:flutter/material.dart';

/// Widget que adiciona animação de remoção (fade + colapso vertical) ao item de tarefa
///
/// Quando [isRemoving] é true, o item faz fade out e colapsa verticalmente
/// em 220ms com curva easeOut, dando feedback visual profissional.
class AnimatedTaskItem extends StatefulWidget {
  final Widget child;
  final bool isRemoving;
  final VoidCallback? onRemovalComplete;

  const AnimatedTaskItem({
    super.key,
    required this.child,
    this.isRemoving = false,
    this.onRemovalComplete,
  });

  @override
  State<AnimatedTaskItem> createState() => _AnimatedTaskItemState();
}

class _AnimatedTaskItemState extends State<AnimatedTaskItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _sizeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );

    // Animação de opacidade (fade out)
    _opacityAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Animação de tamanho (colapso vertical)
    _sizeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));

    // Listener para chamar callback quando animação terminar
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        widget.onRemovalComplete?.call();
      }
    });
  }

  @override
  void didUpdateWidget(AnimatedTaskItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Se mudou para isRemoving = true, inicia animação
    if (widget.isRemoving && !oldWidget.isRemoving) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _sizeAnimation,
      axisAlignment: -1.0, // Colapsa do topo
      child: FadeTransition(
        opacity: _opacityAnimation,
        child: widget.child,
      ),
    );
  }
}
