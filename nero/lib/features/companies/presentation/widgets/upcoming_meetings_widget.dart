import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../providers/meeting_providers.dart';

class UpcomingMeetingsWidget extends ConsumerWidget {
  final String companyId;

  const UpcomingMeetingsWidget({
    super.key,
    required this.companyId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meetingsAsync = ref.watch(upcomingMeetingsProvider(companyId));

    return meetingsAsync.when(
      data: (meetings) {
        if (meetings.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.event_outlined,
                    size: 48,
                    color: (isDark
                            ? AppColors.textSecondary
                            : AppColors.lightTextSecondary)
                        .withOpacity(0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Nenhuma reunião agendada',
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
          children: meetings.take(3).map((meeting) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? AppColors.darkBackground
                    : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF9C27B0).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9C27B0).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('dd').format(meeting.startAt),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9C27B0),
                            fontFamily: 'Poppins',
                          ),
                        ),
                        Text(
                          DateFormat('MMM').format(meeting.startAt).toUpperCase(),
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF9C27B0).withOpacity(0.8),
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          meeting.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? AppColors.textPrimary : AppColors.lightText,
                            fontFamily: 'Inter',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              size: 12,
                              color: (isDark
                                      ? AppColors.textSecondary
                                      : AppColors.lightTextSecondary)
                                  .withOpacity(0.6),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${DateFormat('HH:mm').format(meeting.startAt)} - ${DateFormat('HH:mm').format(meeting.endAt)}',
                              style: TextStyle(
                                fontSize: 11,
                                color: (isDark
                                        ? AppColors.textSecondary
                                        : AppColors.lightTextSecondary)
                                    .withOpacity(0.7),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
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
              'Erro ao carregar reuniões',
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
