import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/company_action_model.dart';
import '../../../../shared/models/company_model.dart';
import '../providers/timeline_providers.dart';

class CompanyTimelinePage extends ConsumerWidget {
  final CompanyModel company;

  const CompanyTimelinePage({
    super.key,
    required this.company,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionsAsync = ref.watch(companyActionsProvider(company.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101010) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF101010) : const Color(0xFFFAFAFA),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Timeline de Atividades',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              company.name,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ),
      body: actionsAsync.when(
        data: (actions) {
          if (actions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timeline,
                    size: 64,
                    color: const Color(0xFF0072FF).withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma atividade registrada',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'As atividades da empresa aparecerão aqui',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            color: const Color(0xFF0072FF),
            onRefresh: () async {
              ref.invalidate(companyActionsProvider(company.id));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                final isLast = index == actions.length - 1;

                return _TimelineItem(
                  action: action,
                  isLast: isLast,
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF0072FF)),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: const Color(0xFFE53935).withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar timeline',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tente novamente',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  ref.invalidate(companyActionsProvider(company.id));
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Recarregar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0072FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  elevation: isDark ? 0 : 2,
                  shadowColor: const Color(0xFF0072FF).withOpacity(0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
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

class _TimelineItem extends StatelessWidget {
  final CompanyActionModel action;
  final bool isLast;

  const _TimelineItem({
    required this.action,
    required this.isLast,
  });

  // Cores baseadas no status: azul (novo), verde (concluído), vermelho (cancelado)
  Color _getStatusColor() {
    final type = action.actionType.toLowerCase();

    // Verde para ações concluídas
    if (type.contains('completed') || type.contains('finished')) {
      return const Color(0xFF4CAF50); // Verde
    }

    // Vermelho para ações canceladas ou deletadas
    if (type.contains('canceled') || type.contains('cancelled') ||
        type.contains('deleted') || type.contains('removed')) {
      return const Color(0xFFE53935); // Vermelho
    }

    // Azul para novas ações e ações em progresso
    return const Color(0xFF0072FF); // Azul
  }

  IconData _getActionIcon() {
    final type = action.actionType.toLowerCase();

    // Ícones para tarefas
    if (type.contains('task')) {
      if (type.contains('completed')) return Icons.task_alt;
      if (type.contains('created')) return Icons.add_task;
      return Icons.check_circle_outline;
    }

    // Ícones para reuniões
    if (type.contains('meeting')) {
      if (type.contains('completed')) return Icons.event_available;
      if (type.contains('scheduled')) return Icons.event;
      if (type.contains('canceled')) return Icons.event_busy;
      return Icons.event_note;
    }

    // Ícones para checklists
    if (type.contains('checklist')) {
      if (type.contains('completed')) return Icons.check_circle;
      return Icons.checklist;
    }

    // Ícones para empresa
    if (type.contains('company')) {
      if (type.contains('updated')) return Icons.edit;
      if (type.contains('created')) return Icons.business;
      return Icons.business_center;
    }

    // Ícone padrão
    return Icons.circle;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'agora';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return 'há $minutes min';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return 'há $hours hora${hours > 1 ? 's' : ''}';
    } else if (difference.inDays == 1) {
      return 'ontem';
    } else if (difference.inDays < 7) {
      return 'há ${difference.inDays} dias';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }

  String _getFullDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy • HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final statusColor = _getStatusColor();
    final icon = _getActionIcon();

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline vertical com ponto colorido
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: statusColor,
                    width: 2.5,
                  ),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: statusColor,
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2.5,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          statusColor.withOpacity(0.5),
                          (isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0))
                              .withOpacity(0.3),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 20),

          // Card de conteúdo
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 28),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                  width: 1,
                ),
                boxShadow: isDark
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                          spreadRadius: 1,
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título e tempo relativo
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          action.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFFFFFFF)
                                : const Color(0xFF1C1C1C),
                            fontFamily: 'Poppins',
                            height: 1.3,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _formatDate(action.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // Data e hora completa
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: isDark
                            ? const Color(0xFF757575)
                            : const Color(0xFF8C8C8C),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _getFullDateTime(action.createdAt),
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? const Color(0xFFBDBDBD)
                              : const Color(0xFF5F5F5F),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),

                  // Descrição (se existir)
                  if (action.description != null &&
                      action.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF101010)
                            : const Color(0xFFFAFAFA),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFE0E0E0),
                          width: 0.5,
                        ),
                      ),
                      child: Text(
                        action.description!,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? const Color(0xFFBDBDBD)
                              : const Color(0xFF5F5F5F),
                          fontFamily: 'Inter',
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
