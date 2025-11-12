import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../providers/task_providers.dart';

class TaskFilterBottomSheet extends ConsumerWidget {
  const TaskFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusFilter = ref.watch(taskStatusFilterProvider);
    final originFilter = ref.watch(taskOriginFilterProvider);
    final priorityFilter = ref.watch(taskPriorityFilterProvider);

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
                'Filtros',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              TextButton(
                onPressed: () {
                  // Limpar todos os filtros
                  ref.read(taskStatusFilterProvider.notifier).state = null;
                  ref.read(taskOriginFilterProvider.notifier).state = null;
                  ref.read(taskPriorityFilterProvider.notifier).state = null;
                  ref.read(tasksListProvider.notifier).loadTasks();
                  Navigator.of(context).pop();
                },
                child: const Text('Limpar todos'),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Status
          const Text(
            'Status',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Todas',
                selected: statusFilter == null,
                onTap: () {
                  ref.read(taskStatusFilterProvider.notifier).state = null;
                },
              ),
              _FilterChip(
                label: 'Pendentes',
                selected: statusFilter == 'pending',
                onTap: () {
                  ref.read(taskStatusFilterProvider.notifier).state = 'pending';
                },
              ),
              _FilterChip(
                label: 'Concluídas',
                selected: statusFilter == 'completed',
                onTap: () {
                  ref.read(taskStatusFilterProvider.notifier).state = 'completed';
                },
              ),
              _FilterChip(
                label: 'Atrasadas',
                selected: statusFilter == 'overdue',
                onTap: () {
                  ref.read(taskStatusFilterProvider.notifier).state = 'overdue';
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Origem
          const Text(
            'Origem',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Todas',
                selected: originFilter == null,
                onTap: () {
                  ref.read(taskOriginFilterProvider.notifier).state = null;
                },
              ),
              _FilterChip(
                label: 'Pessoal',
                selected: originFilter == 'personal',
                onTap: () {
                  ref.read(taskOriginFilterProvider.notifier).state = 'personal';
                },
              ),
              _FilterChip(
                label: 'Empresa',
                selected: originFilter == 'company',
                onTap: () {
                  ref.read(taskOriginFilterProvider.notifier).state = 'company';
                },
              ),
              _FilterChip(
                label: 'IA',
                selected: originFilter == 'ai',
                onTap: () {
                  ref.read(taskOriginFilterProvider.notifier).state = 'ai';
                },
              ),
              _FilterChip(
                label: 'Recorrente',
                selected: originFilter == 'recurring',
                onTap: () {
                  ref.read(taskOriginFilterProvider.notifier).state = 'recurring';
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Prioridade
          const Text(
            'Prioridade',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Todas',
                selected: priorityFilter == null,
                onTap: () {
                  ref.read(taskPriorityFilterProvider.notifier).state = null;
                },
              ),
              _FilterChip(
                label: 'Alta',
                selected: priorityFilter == 'high',
                color: Colors.red,
                onTap: () {
                  ref.read(taskPriorityFilterProvider.notifier).state = 'high';
                },
              ),
              _FilterChip(
                label: 'Média',
                selected: priorityFilter == 'medium',
                color: Colors.orange,
                onTap: () {
                  ref.read(taskPriorityFilterProvider.notifier).state = 'medium';
                },
              ),
              _FilterChip(
                label: 'Baixa',
                selected: priorityFilter == 'low',
                color: Colors.green,
                onTap: () {
                  ref.read(taskPriorityFilterProvider.notifier).state = 'low';
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Botão aplicar
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                ref.read(tasksListProvider.notifier).loadTasks(
                  status: statusFilter,
                  origin: originFilter,
                  priority: priorityFilter,
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Aplicar Filtros',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? color;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final chipColor = color ?? AppColors.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? chipColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? chipColor : AppColors.textSecondary.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? chipColor : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
