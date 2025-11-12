import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../domain/models/time_filter_model.dart';
import 'month_selector_widget.dart';

/// Widget de header dinâmico que muda conforme o tipo de filtro ativo
class DynamicFilterHeader extends StatelessWidget {
  final FiltroTempo filtroAtivo;
  final Function(FiltroTempo) onFiltroChanged;
  final VoidCallback? onHeaderTap;
  final Color? backgroundColor;
  final Color? selectedColor;

  const DynamicFilterHeader({
    super.key,
    required this.filtroAtivo,
    required this.onFiltroChanged,
    this.onHeaderTap,
    this.backgroundColor,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    // AnimatedSwitcher para transição suave entre diferentes tipos de header
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        );
      },
      child: _buildHeaderForFilterType(context),
    );
  }

  Widget _buildHeaderForFilterType(BuildContext context) {
    switch (filtroAtivo.tipo) {
      case IntervaloFiltro.hoje:
        return DaySelectorWidget(
          key: const ValueKey('day_selector'),
          currentDate: filtroAtivo.start,
          onDateChanged: (newDate) {
            // Criar filtro para o dia específico selecionado
            final start = DateTime(newDate.year, newDate.month, newDate.day);
            final end = DateTime(newDate.year, newDate.month, newDate.day, 23, 59, 59, 999, 999);
            onFiltroChanged(FiltroTempo(
              tipo: IntervaloFiltro.hoje,
              start: start,
              end: end,
            ));
          },
          onHeaderTap: onHeaderTap,
          backgroundColor: backgroundColor,
          selectedColor: selectedColor,
        );

      case IntervaloFiltro.anoAtual:
        return YearSelectorWidget(
          key: const ValueKey('year_selector'),
          currentYear: filtroAtivo.start.year,
          onYearChanged: (newYear) {
            // Criar filtro para o ano específico selecionado
            final start = DateTime(newYear, 1, 1); // 01/01 00:00:00
            final end = DateTime(newYear, 12, 31, 23, 59, 59, 999, 999); // 31/12 23:59:59.999999
            onFiltroChanged(FiltroTempo(
              tipo: IntervaloFiltro.anoAtual,
              start: start,
              end: end,
            ));
          },
          onHeaderTap: onHeaderTap,
          backgroundColor: backgroundColor,
          selectedColor: selectedColor,
        );

      case IntervaloFiltro.ult7:
      case IntervaloFiltro.ult30:
      case IntervaloFiltro.personalizado:
        return ChipFilterWidget(
          key: ValueKey('chip_${filtroAtivo.tipo}'),
          filtro: filtroAtivo,
          onClear: () {
            // Voltar para mês atual
            final now = DateTime.now();
            onFiltroChanged(FiltroTempo.mes(now));
          },
          onTap: onHeaderTap,
          backgroundColor: backgroundColor,
        );

      case IntervaloFiltro.mes:
      default:
        return MonthSelectorWidget(
          key: const ValueKey('month_selector'),
          initialMonth: filtroAtivo.start,
          onMonthChanged: (newMonth) {
            onFiltroChanged(FiltroTempo.mes(newMonth));
          },
          onMonthTap: onHeaderTap,
          filtroAtivo: filtroAtivo,
          backgroundColor: backgroundColor,
          selectedColor: selectedColor,
        );
    }
  }
}

/// Seletor de dias: Ontem | Hoje | Amanhã
class DaySelectorWidget extends StatefulWidget {
  final DateTime currentDate;
  final Function(DateTime) onDateChanged;
  final VoidCallback? onHeaderTap;
  final Color? backgroundColor;
  final Color? selectedColor;

  const DaySelectorWidget({
    super.key,
    required this.currentDate,
    required this.onDateChanged,
    this.onHeaderTap,
    this.backgroundColor,
    this.selectedColor,
  });

  @override
  State<DaySelectorWidget> createState() => _DaySelectorWidgetState();
}

class _DaySelectorWidgetState extends State<DaySelectorWidget> {
  late PageController _pageController;
  static const int _kCenterPage = 10000;
  late int _currentPage;

  @override
  void initState() {
    super.initState();
    _currentPage = _kCenterPage;
    _pageController = PageController(
      initialPage: _kCenterPage,
      viewportFraction: 1 / 3,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _dateFromOffset(int offset) {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day + offset);
  }

  String _formatDayLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final targetDate = DateTime(date.year, date.month, date.day);

    final diff = targetDate.difference(today).inDays;

    if (diff == 0) return 'Hoje';
    if (diff == -1) return 'Ontem';
    if (diff == 1) return 'Amanhã';

    // Para dias mais distantes, mostrar data curta
    return DateFormat('dd/MM', 'pt_BR').format(date);
  }

  void _previousDay() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextDay() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = widget.selectedColor ?? AppColors.primary;
    final backgroundColor = widget.backgroundColor ?? (isDark ? const Color(0xFF1C1C1E) : Colors.white);

    return Container(
      height: 48,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Seta esquerda
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousDay,
            color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF212121),
            iconSize: 24,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            tooltip: 'Ir para dia anterior',
          ),

          // Carrossel com 3 dias
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const PageScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });

                final newDate = _dateFromOffset(index - _kCenterPage);
                widget.onDateChanged(newDate);
              },
              itemBuilder: (context, index) {
                final date = _dateFromOffset(index - _kCenterPage);
                final isSelected = index == _currentPage;

                return Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (isSelected) {
                        widget.onHeaderTap?.call();
                      } else {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOut,
                        );
                      }
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
                          Text(
                            _formatDayLabel(date),
                            key: ValueKey('${date.year}-${date.month}-${date.day}'),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
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
            onPressed: _nextDay,
            color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF212121),
            iconSize: 24,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            tooltip: 'Ir para próximo dia',
          ),
        ],
      ),
    );
  }
}

/// Seletor de anos: Ano anterior | Ano atual | Próximo ano
class YearSelectorWidget extends StatefulWidget {
  final int currentYear;
  final Function(int) onYearChanged;
  final VoidCallback? onHeaderTap;
  final Color? backgroundColor;
  final Color? selectedColor;

  const YearSelectorWidget({
    super.key,
    required this.currentYear,
    required this.onYearChanged,
    this.onHeaderTap,
    this.backgroundColor,
    this.selectedColor,
  });

  @override
  State<YearSelectorWidget> createState() => _YearSelectorWidgetState();
}

class _YearSelectorWidgetState extends State<YearSelectorWidget> {
  late PageController _pageController;
  static const int _kCenterPage = 10000;
  late int _currentPage;
  late int _referenceYear;

  @override
  void initState() {
    super.initState();
    _referenceYear = widget.currentYear;
    _currentPage = _kCenterPage;
    _pageController = PageController(
      initialPage: _kCenterPage,
      viewportFraction: 1 / 3,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _yearFromOffset(int offset) {
    return _referenceYear + offset;
  }

  void _previousYear() {
    if (_pageController.hasClients) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  void _nextYear() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedColor = widget.selectedColor ?? AppColors.primary;
    final backgroundColor = widget.backgroundColor ?? (isDark ? const Color(0xFF1C1C1E) : Colors.white);

    return Container(
      height: 48,
      color: backgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Seta esquerda
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousYear,
            color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF212121),
            iconSize: 24,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            tooltip: 'Ir para ano anterior',
          ),

          // Carrossel com 3 anos
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const PageScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });

                final newYear = _yearFromOffset(index - _kCenterPage);
                widget.onYearChanged(newYear);
              },
              itemBuilder: (context, index) {
                final year = _yearFromOffset(index - _kCenterPage);
                final isSelected = index == _currentPage;

                return Center(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      if (isSelected) {
                        widget.onHeaderTap?.call();
                      } else {
                        _pageController.animateToPage(
                          index,
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeInOut,
                        );
                      }
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
                          Text(
                            year.toString(),
                            key: ValueKey('year-$year'),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
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
            onPressed: _nextYear,
            color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF212121),
            iconSize: 24,
            splashRadius: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
            tooltip: 'Ir para próximo ano',
          ),
        ],
      ),
    );
  }
}

/// Widget de chip único para filtros 7d/30d/personalizado
class ChipFilterWidget extends StatelessWidget {
  final FiltroTempo filtro;
  final VoidCallback onClear;
  final VoidCallback? onTap;
  final Color? backgroundColor;

  const ChipFilterWidget({
    super.key,
    required this.filtro,
    required this.onClear,
    this.onTap,
    this.backgroundColor,
  });

  String _getChipLabel() {
    final dateFormat = DateFormat('dd/MM/yy', 'pt_BR');

    switch (filtro.tipo) {
      case IntervaloFiltro.ult7:
        return 'Últimos 7 dias (${dateFormat.format(filtro.start)}–${dateFormat.format(filtro.end)})';
      case IntervaloFiltro.ult30:
        return 'Últimos 30 dias (${dateFormat.format(filtro.start)}–${dateFormat.format(filtro.end)})';
      case IntervaloFiltro.personalizado:
        return 'Período: ${dateFormat.format(filtro.start)}–${dateFormat.format(filtro.end)}';
      default:
        return 'Filtro customizado';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 48,
      color: backgroundColor ?? (isDark ? const Color(0xFF1C1C1E) : Colors.white),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.filter_list,
                size: 16,
                color: AppColors.primary,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  _getChipLabel(),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                    fontFamily: 'Inter',
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onClear,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
