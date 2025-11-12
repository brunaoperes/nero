import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../shared/models/company_action_model.dart';
import '../providers/company_action_providers.dart';

class CompanyTimelineWidget extends ConsumerWidget {
  final String companyId;
  final int limit;

  const CompanyTimelineWidget({
    super.key,
    required this.companyId,
    this.limit = 10,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actionsAsync = ref.watch(companyActionsProvider(companyId));

    return actionsAsync.when(
      data: (actions) {
        if (actions.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.timeline_outlined,
                    size: 48,
                    color: (isDark
                            ? AppColors.textSecondary
                            : AppColors.lightTextSecondary)
                        .withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhuma atividade ainda',
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

        final displayActions = actions.take(limit).toList();

        return Column(
          children: displayActions.asMap().entries.map((entry) {
            final index = entry.key;
            final action = entry.value;
            final isLast = index == displayActions.length - 1;

            return _TimelineItem(
              action: action,
              isLast: isLast,
            );
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
              'Erro ao carregar timeline',
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

class _TimelineItem extends StatelessWidget {
  final CompanyActionModel action;
  final bool isLast;

  const _TimelineItem({
    required this.action,
    required this.isLast,
  });

  IconData _getIcon(String actionType) {
    switch (actionType) {
      case 'task_created':
        return Icons.add_task;
      case 'task_completed':
        return Icons.check_circle;
      case 'meeting_scheduled':
        return Icons.event;
      case 'meeting_completed':
        return Icons.event_available;
      case 'checklist_completed':
        return Icons.checklist;
      case 'company_created':
        return Icons.business;
      case 'company_updated':
        return Icons.edit;
      default:
        return Icons.circle;
    }
  }

  Color _getColor(String actionType) {
    switch (actionType) {
      case 'task_created':
        return AppColors.primary;
      case 'task_completed':
        return const Color(0xFF009E0F);
      case 'meeting_scheduled':
        return const Color(0xFF9C27B0);
      case 'meeting_completed':
        return const Color(0xFF4CAF50);
      case 'checklist_completed':
        return const Color(0xFFFFD700);
      case 'company_created':
      case 'company_updated':
        return AppColors.secondary;
      default:
        return AppColors.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = _getColor(action.actionType);
    final icon = _getIcon(action.actionType);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color.withOpacity(0.5),
                    width: 2,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: color,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: (isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder)
                        .withOpacity(0.3),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textPrimary : AppColors.lightText,
                      fontFamily: 'Inter',
                    ),
                  ),
                  if (action.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      action.description!,
                      style: TextStyle(
                        fontSize: 13,
                        color: (isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary)
                            .withOpacity(0.8),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    _formatDate(action.createdAt),
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Agora';
    } else if (difference.inHours < 1) {
      return 'Há ${difference.inMinutes} min';
    } else if (difference.inDays < 1) {
      return 'Há ${difference.inHours}h';
    } else if (difference.inDays == 1) {
      return 'Ontem';
    } else if (difference.inDays < 7) {
      return 'Há ${difference.inDays} dias';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
