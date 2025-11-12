import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../domain/models/time_filter_model.dart';

/// Bottom sheet para seleção rápida de intervalo temporal
class TimeFilterBottomSheet extends ConsumerWidget {
  final FiltroTempo filtroAtual;
  final Function(FiltroTempo) onFiltroSelecionado;

  const TimeFilterBottomSheet({
    super.key,
    required this.filtroAtual,
    required this.onFiltroSelecionado,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
            // Handle indicador
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF3A3A3A) : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Título
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  const Icon(
                    Icons.filter_list,
                    size: 22,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Filtrar por período',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF1C1C1C),
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            // Opções
            _buildOption(
              context,
              icon: Icons.today,
              label: 'Hoje',
              descricao: 'Apenas transações de hoje',
              isActive: filtroAtual.tipo == IntervaloFiltro.hoje,
              onTap: () {
                Navigator.pop(context);
                onFiltroSelecionado(FiltroTempo.hoje());
              },
            ),

            _buildOption(
              context,
              icon: Icons.calendar_month,
              label: 'Mês atual',
              descricao: 'Transações do mês corrente',
              isActive: filtroAtual.tipo == IntervaloFiltro.mes &&
                  _isMesAtual(filtroAtual),
              onTap: () {
                Navigator.pop(context);
                final now = DateTime.now();
                onFiltroSelecionado(FiltroTempo.mes(now));
              },
            ),

            _buildOption(
              context,
              icon: Icons.date_range,
              label: 'Últimos 7 dias',
              descricao: 'Últimos 7 dias (incluindo hoje)',
              isActive: filtroAtual.tipo == IntervaloFiltro.ult7,
              onTap: () {
                Navigator.pop(context);
                onFiltroSelecionado(FiltroTempo.ultimos7Dias());
              },
            ),

            _buildOption(
              context,
              icon: Icons.event_note,
              label: 'Últimos 30 dias',
              descricao: 'Últimos 30 dias (incluindo hoje)',
              isActive: filtroAtual.tipo == IntervaloFiltro.ult30,
              onTap: () {
                Navigator.pop(context);
                onFiltroSelecionado(FiltroTempo.ultimos30Dias());
              },
            ),

            _buildOption(
              context,
              icon: Icons.calendar_today,
              label: 'Ano atual',
              descricao: 'Transações do ano atual (01/01 - 31/12)',
              isActive: filtroAtual.tipo == IntervaloFiltro.anoAtual,
              onTap: () {
                Navigator.pop(context);
                onFiltroSelecionado(FiltroTempo.anoAtual());
              },
            ),

            _buildOption(
              context,
              icon: Icons.edit_calendar,
              label: 'Período personalizado…',
              descricao: 'Selecione início e fim',
              isActive: filtroAtual.tipo == IntervaloFiltro.personalizado,
              onTap: () {
                // Fechar o bottom sheet e retornar sinal especial
                Navigator.pop(context, '_open_date_picker');
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
          ),
      ),
    );
  }

  Widget _buildOption(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String descricao,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.primary.withOpacity(0.12)
                    : (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF5F5F5)),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isActive ? AppColors.primary : (isDark ? const Color(0xFFB0B0B0) : const Color(0xFF5F5F5F)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive ? AppColors.primary : (isDark ? const Color(0xFFEDEDED) : const Color(0xFF1C1C1C)),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    descricao,
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? const Color(0xFFB0B0B0) : const Color(0xFF757575),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            if (isActive)
              const Icon(
                Icons.check_circle,
                size: 22,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }

  bool _isMesAtual(FiltroTempo filtro) {
    final now = DateTime.now();
    final mesAtual = DateTime(now.year, now.month, 1);
    final filtroMes = DateTime(filtro.start.year, filtro.start.month, 1);
    return mesAtual == filtroMes;
  }
}
