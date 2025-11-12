import 'package:flutter/material.dart';
import '../../../../core/config/app_colors.dart';

/// Speed Dial FAB - Menu de ações rápidas expansível
class SpeedDialFAB extends StatefulWidget {
  final VoidCallback? onAddTask;
  final VoidCallback? onAddTransaction;
  final VoidCallback? onAddCompany;
  final bool isDark;

  const SpeedDialFAB({
    super.key,
    this.onAddTask,
    this.onAddTransaction,
    this.onAddCompany,
    this.isDark = true,
  });

  @override
  State<SpeedDialFAB> createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotateAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 0.125, // 45 degrees (1/8 of a full rotation)
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    // Adiciona observer para detectar mudanças no ciclo de vida do app
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Fecha o menu quando o app perde foco
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _close();
    }
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    if (_isExpanded) {
      setState(() {
        _isExpanded = false;
        _controller.reverse();
      });
    }
  }

  /// Método público para fechar o menu programaticamente
  void close() {
    _close();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      height: 300,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          // Overlay escuro quando expandido
          if (_isExpanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggle,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),

          // Opções do menu
          ..._buildSpeedDialOptions(),

          // FAB Principal
          FloatingActionButton(
            heroTag: 'speed_dial_main_fab',
            onPressed: _toggle,
            backgroundColor: AppColors.primary,
            elevation: 6,
            child: AnimatedBuilder(
              animation: _rotateAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotateAnimation.value * 3.14159 * 2,
                  child: Icon(
                    _isExpanded ? Icons.close : Icons.add,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildSpeedDialOptions() {
    final options = [
      SpeedDialOption(
        icon: Icons.task_alt,
        label: 'Nova Tarefa',
        color: AppColors.primary,
        onTap: () {
          _toggle();
          widget.onAddTask?.call();
        },
      ),
      SpeedDialOption(
        icon: Icons.attach_money,
        label: 'Nova Transação',
        color: AppColors.success,
        onTap: () {
          _toggle();
          widget.onAddTransaction?.call();
        },
      ),
      SpeedDialOption(
        icon: Icons.business,
        label: 'Nova Empresa',
        color: AppColors.secondary,
        onTap: () {
          _toggle();
          widget.onAddCompany?.call();
        },
      ),
    ];

    return List.generate(options.length, (index) {
      final option = options[index];
      final distance = 70.0 * (index + 1);

      return AnimatedBuilder(
        animation: _expandAnimation,
        builder: (context, child) {
          final offset = distance * _expandAnimation.value;
          final opacity = _expandAnimation.value;

          return Positioned(
            bottom: offset,
            right: 0,
            child: Opacity(
              opacity: opacity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Label
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: widget.isDark
                          ? AppColors.darkCard
                          : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Text(
                      option.label,
                      style: TextStyle(
                        color: widget.isDark
                            ? AppColors.darkText
                            : AppColors.lightText,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // FAB da opção
                  FloatingActionButton.small(
                    heroTag: option.label,
                    onPressed: option.onTap,
                    backgroundColor: option.color,
                    elevation: 4,
                    child: Icon(
                      option.icon,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

/// Modelo de opção do Speed Dial
class SpeedDialOption {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const SpeedDialOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
