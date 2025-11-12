import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../providers/task_providers.dart';

class TaskSortBottomSheet extends ConsumerWidget {
  const TaskSortBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sortBy = ref.watch(taskSortByProvider);
    final ascending = ref.watch(taskSortAscendingProvider);

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Ordenar por',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                  fontFamily: 'Poppins',
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Ordenar por Data de Vencimento
          _SortOption(
            icon: Icons.event_outlined,
            title: 'Data de Vencimento',
            subtitle: 'Mais próximas primeiro',
            selected: sortBy == 'due_date' && ascending,
            onTap: () {
              ref.read(taskSortByProvider.notifier).state = 'due_date';
              ref.read(taskSortAscendingProvider.notifier).state = true;
            },
          ),
          const SizedBox(height: 8),

          _SortOption(
            icon: Icons.event_outlined,
            title: 'Data de Vencimento',
            subtitle: 'Mais distantes primeiro',
            selected: sortBy == 'due_date' && !ascending,
            onTap: () {
              ref.read(taskSortByProvider.notifier).state = 'due_date';
              ref.read(taskSortAscendingProvider.notifier).state = false;
            },
          ),
          const SizedBox(height: 16),

          // Ordenar por Prioridade
          _SortOption(
            icon: Icons.flag_outlined,
            title: 'Prioridade',
            subtitle: 'Alta → Baixa',
            selected: sortBy == 'priority' && !ascending,
            onTap: () {
              ref.read(taskSortByProvider.notifier).state = 'priority';
              ref.read(taskSortAscendingProvider.notifier).state = false;
            },
          ),
          const SizedBox(height: 8),

          _SortOption(
            icon: Icons.flag_outlined,
            title: 'Prioridade',
            subtitle: 'Baixa → Alta',
            selected: sortBy == 'priority' && ascending,
            onTap: () {
              ref.read(taskSortByProvider.notifier).state = 'priority';
              ref.read(taskSortAscendingProvider.notifier).state = true;
            },
          ),
          const SizedBox(height: 16),

          // Ordenar por Título
          _SortOption(
            icon: Icons.sort_by_alpha_outlined,
            title: 'Título',
            subtitle: 'A → Z',
            selected: sortBy == 'title' && ascending,
            onTap: () {
              ref.read(taskSortByProvider.notifier).state = 'title';
              ref.read(taskSortAscendingProvider.notifier).state = true;
            },
          ),
          const SizedBox(height: 8),

          _SortOption(
            icon: Icons.sort_by_alpha_outlined,
            title: 'Título',
            subtitle: 'Z → A',
            selected: sortBy == 'title' && !ascending,
            onTap: () {
              ref.read(taskSortByProvider.notifier).state = 'title';
              ref.read(taskSortAscendingProvider.notifier).state = false;
            },
          ),
          const SizedBox(height: 16),

          // Ordenar por Data de Criação
          _SortOption(
            icon: Icons.schedule_outlined,
            title: 'Data de Criação',
            subtitle: 'Mais recentes primeiro',
            selected: sortBy == 'created_at' && !ascending,
            onTap: () {
              ref.read(taskSortByProvider.notifier).state = 'created_at';
              ref.read(taskSortAscendingProvider.notifier).state = false;
            },
          ),
          const SizedBox(height: 8),

          _SortOption(
            icon: Icons.schedule_outlined,
            title: 'Data de Criação',
            subtitle: 'Mais antigas primeiro',
            selected: sortBy == 'created_at' && ascending,
            onTap: () {
              ref.read(taskSortByProvider.notifier).state = 'created_at';
              ref.read(taskSortAscendingProvider.notifier).state = true;
            },
          ),
          const SizedBox(height: 24),

          // Botão aplicar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(tasksListProvider.notifier).loadTasks(
                  sortBy: sortBy,
                  ascending: ascending,
                  status: ref.read(taskStatusFilterProvider),
                  origin: ref.read(taskOriginFilterProvider),
                  priority: ref.read(taskPriorityFilterProvider),
                  searchQuery: ref.read(taskSearchQueryProvider),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Aplicar Ordenação',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SortOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _SortOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withOpacity(0.15)
              : AppColors.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : const Color(0xFF3A3A3A),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle,
                size: 20,
                color: AppColors.primary,
              ),
          ],
        ),
      ),
    );
  }
}
