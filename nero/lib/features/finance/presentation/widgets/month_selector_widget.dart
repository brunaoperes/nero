import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../domain/models/time_filter_model.dart';

/// Widget de seleção de mês com 3 meses visíveis e rolagem infinita - Modelo Organize
class MonthSelectorWidget extends StatefulWidget {
  final DateTime initialMonth;
  final Function(DateTime) onMonthChanged;
  final FiltroTempo? filtroAtivo;
  final Function()? onMonthTap; // Toque simples para abrir menu de filtros
  final Color? backgroundColor;
  final Color? selectedColor;

  const MonthSelectorWidget({
    super.key,
    required this.initialMonth,
    required this.onMonthChanged,
    this.filtroAtivo,
    this.onMonthTap,
    this.backgroundColor,
    this.selectedColor,
  });

  @override
  State<MonthSelectorWidget> createState() => _MonthSelectorWidgetState();
}

class _MonthSelectorWidgetState extends State<MonthSelectorWidget> {
  late PageController _pageController;

  // Offset grande para simular scroll infinito
  static const int _kCenterPage = 10000;

  // Página corrente (só atualiza no onPageChanged, não durante scroll)
  late int _currentPage;

  // IMPORTANTE: salvar initialMonth fixo como ponto de referência
  // Não pode mudar durante a vida do widget!
  late DateTime _referenceMonth;

  @override
  void initState() {
    super.initState();
    print('📅 [MonthSelector] initState() chamado');
    print('📅 [MonthSelector] initialMonth: ${widget.initialMonth}');
    print('📅 [MonthSelector] onMonthTap fornecido? ${widget.onMonthTap != null}');
    print('📅 [MonthSelector] filtroAtivo: ${widget.filtroAtivo?.tipo}');

    _referenceMonth = widget.initialMonth; // Salva cópia fixa
    _currentPage = _kCenterPage;
    _pageController = PageController(
      initialPage: _kCenterPage,
      viewportFraction: 1 / 3, // 3 meses visíveis
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Calcula o mês a partir do offset relativo ao centro
  /// IMPORTANTE: usa _referenceMonth (fixo), não widget.initialMonth (que muda)
  DateTime _monthFromOffset(int offset) {
    final baseYear = _referenceMonth.year;
    final baseMonth = _referenceMonth.month;

    // DateTime lida com overflow de mês automaticamente
    return DateTime(baseYear, baseMonth + offset, 1);
  }

  /// Retorna o mês selecionado atualmente
  DateTime get _selectedMonth => _monthFromOffset(_currentPage - _kCenterPage);

  /// Formata o label do mês (ex: "Nov.", "Dez.")
  String _formatMonthLabel(DateTime date) {
    final monthName = DateFormat('MMM', 'pt_BR').format(date);
    // Capitalizar primeira letra
    return monthName[0].toUpperCase() + monthName.substring(1);
  }

  /// Navega para o mês anterior
  void _previousMonth() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  /// Navega para o próximo mês
  void _nextMonth() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedColor = widget.selectedColor ?? AppColors.primary;
    final backgroundColor = widget.backgroundColor ?? Colors.white;

    return Container(
      height: 48,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Seta esquerda
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
            color: const Color(0xFF212121),
            iconSize: 24,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),

          // Carrossel com 3 meses visíveis
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const PageScrollPhysics(), // Scroll ativado para navegação fluida
              itemCount: _kCenterPage * 2 + 1, // Limite para prevenir overflow
              // SÓ atualiza estado quando o scroll TERMINA (snap)
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });

                // Notifica parent apenas após snap completo
                final newMonth = _monthFromOffset(index - _kCenterPage);
                widget.onMonthChanged(newMonth);
              },
              itemBuilder: (context, index) {
                final date = _monthFromOffset(index - _kCenterPage);
                final isSelected = index == _currentPage;

                return Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      print('📅 [MonthSelector] Toque detectado!');
                      print('📅 [MonthSelector] Index clicado: $index');
                      print('📅 [MonthSelector] Index atual (_currentPage): $_currentPage');
                      print('📅 [MonthSelector] É o mês selecionado? $isSelected');
                      print('📅 [MonthSelector] Data do mês: ${_formatMonthLabel(date)}');
                      print('📅 [MonthSelector] onMonthTap é null? ${widget.onMonthTap == null}');

                      if (isSelected) {
                        // Toque no mês CENTRAL → abre menu de filtros
                        print('📅 [MonthSelector] ✅ Mês CENTRAL clicado - abrindo menu de filtros');
                        widget.onMonthTap?.call();
                        print('📅 [MonthSelector] onMonthTap() chamado');
                      } else {
                        // Toque em mês ADJACENTE → navega para aquele mês
                        print('📅 [MonthSelector] ➡️ Mês ADJACENTE clicado - navegando para index $index');
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOut,
                        );
                      }
                      print('📅 [MonthSelector] ═══════════════════════════════════════');
                    },
                    child: AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      style: TextStyle(
                        fontSize: isSelected ? 15 : 13,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: isSelected ? selectedColor : const Color(0xFF9E9E9E),
                        letterSpacing: 0.2,
                        fontFamily: 'Inter',
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatMonthLabel(date),
                                key: ValueKey('${date.year}-${date.month}'),
                                textAlign: TextAlign.center,
                              ),
                              // Badge de filtro ativo
                              if (isSelected && widget.filtroAtivo != null && widget.filtroAtivo!.badgeLabel.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    widget.filtroAtivo!.badgeLabel,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          // Underline para o mês selecionado
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeInOut,
                            width: isSelected ? 30 : 0,
                            height: 2,
                            decoration: BoxDecoration(
                              color: isSelected ? selectedColor : Colors.transparent,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Seta direita
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: _nextMonth,
            color: const Color(0xFF212121),
            iconSize: 24,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }
}
