import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/company_checklist_model.dart';
import '../providers/company_checklist_providers.dart';

class CompanyChecklistWidget extends ConsumerWidget {
  final String companyId;

  const CompanyChecklistWidget({
    super.key,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final checklistsAsync = ref.watch(pendingChecklistsProvider(companyId));

    return checklistsAsync.when(
      data: (checklists) {
        if (checklists.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.checklist_outlined,
                    size: 48,
                    color: (isDark
                            ? AppColors.textSecondary
                            : AppColors.lightTextSecondary)
                        .withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhum checklist pendente',
                    style: TextStyle(
                      fontSize: 14,
                      color: (isDark
                              ? AppColors.textSecondary
                              : AppColors.lightTextSecondary)
                          .withOpacity(0.7),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Column(
          children: checklists.map((checklist) {
            return _ChecklistCard(checklist: checklist);
          }).toList(),
        );
      },
      loading: () => const Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      ),
      error: (error, stack) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Text(
              'Erro ao carregar checklists',
              style: TextStyle(
                fontSize: 14,
                color: (isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary)
                    .withOpacity(0.7),
                fontFamily: 'Inter',
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  final CompanyChecklistModel checklist;

  const _ChecklistCard({
    required this.checklist,
  });

  Color _getTypeColor(String type) {
    switch (type) {
      case 'mei':
        return const Color(0xFFFFD700);
      case 'monthly':
        return AppColors.primary;
      case 'annual':
        return const Color(0xFF9C27B0);
      default:
        return AppColors.textSecondary;
    }
  }

  String _getTypeLabel(String type) {
    switch (type) {
      case 'mei':
        return 'MEI';
      case 'monthly':
        return 'Mensal';
      case 'annual':
        return 'Anual';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getTypeColor(checklist.type);
    final completedItems = checklist.items.where((item) => item.completed).length;
    final totalItems = checklist.items.length;
    final progress = totalItems > 0 ? completedItems / totalItems : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBackground : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  _getTypeLabel(checklist.type),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '$completedItems/$totalItems',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Título
          Text(
            checklist.title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimary : AppColors.lightText,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 8),

          // Barra de progresso
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: color.withOpacity(0.15),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 12),

          // Itens do checklist
          ...checklist.items.take(3).map((item) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  Icon(
                    item.completed
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 18,
                    color: item.completed
                        ? color
                        : (isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary)
                            .withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 12,
                        color: item.completed
                            ? (isDark
                                    ? AppColors.textSecondary
                                    : AppColors.lightTextSecondary)
                                .withOpacity(0.7)
                            : (isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary),
                        fontFamily: 'Inter',
                        decoration: item.completed
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),

          if (checklist.items.length > 3) ...[
            const SizedBox(height: 4),
            Text(
              '+${checklist.items.length - 3} itens',
              style: TextStyle(
                fontSize: 11,
                color: (isDark
                        ? AppColors.textSecondary
                        : AppColors.lightTextSecondary)
                    .withOpacity(0.6),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ],
      ),
    );
  }
}
