import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/company_checklist_model.dart';
import '../../../../shared/models/company_model.dart';
import '../providers/checklist_providers.dart';

class CompanyChecklistsPage extends ConsumerStatefulWidget {
  final CompanyModel company;

  const CompanyChecklistsPage({
    super.key,
    required this.company,
  });

  @override
  ConsumerState<CompanyChecklistsPage> createState() => _CompanyChecklistsPageState();
}

class _CompanyChecklistsPageState extends ConsumerState<CompanyChecklistsPage> {
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final checklistsAsync = ref.watch(companyChecklistsProvider(widget.company.id));

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101010) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF101010) : const Color(0xFFFAFAFA),
        elevation: 0,
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
              'Checklists',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                fontFamily: 'Poppins',
              ),
            ),
            Text(
              widget.company.name,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.add_circle,
              color: Color(0xFF0072FF),
              size: 28,
            ),
            onPressed: () {
              // TODO: Navegar para tela de criação de checklist
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Funcionalidade de criar checklist em desenvolvimento'),
                  backgroundColor: Color(0xFF0072FF),
                ),
              );
            },
            tooltip: 'Novo Checklist',
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.filter_list,
              color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
            ),
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
              ),
            ),
            onSelected: (value) {
              setState(() {
                _selectedType = value == 'all' ? null : value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(
                      Icons.list_alt,
                      color: _selectedType == null ? const Color(0xFF0072FF) : (isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F)),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Todos',
                      style: TextStyle(
                        color: _selectedType == null ? const Color(0xFF0072FF) : (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C)),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'mei',
                child: Row(
                  children: [
                    Icon(
                      Icons.business,
                      color: _selectedType == 'mei' ? const Color(0xFFFFD700) : (isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F)),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'MEI',
                      style: TextStyle(
                        color: _selectedType == 'mei' ? const Color(0xFFFFD700) : (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C)),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'monthly',
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month,
                      color: _selectedType == 'monthly' ? const Color(0xFF0072FF) : (isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F)),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Mensal',
                      style: TextStyle(
                        color: _selectedType == 'monthly' ? const Color(0xFF0072FF) : (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C)),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'annual',
                child: Row(
                  children: [
                    Icon(
                      Icons.event,
                      color: _selectedType == 'annual' ? const Color(0xFF9C27B0) : (isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F)),
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Anual',
                      style: TextStyle(
                        color: _selectedType == 'annual' ? const Color(0xFF9C27B0) : (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C)),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: checklistsAsync.when(
        data: (checklists) {
          // Filtrar por tipo se selecionado
          final filteredChecklists = _selectedType != null
              ? checklists.where((c) => c.type == _selectedType).toList()
              : checklists;

          if (filteredChecklists.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.checklist,
                    size: 64,
                    color: const Color(0xFF0072FF).withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _selectedType != null
                        ? 'Nenhum checklist deste tipo'
                        : 'Nenhum checklist encontrado',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Clique no botão + para criar um novo checklist',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navegar para tela de criação de checklist
                    },
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text('Novo Checklist'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0072FF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(companyChecklistsProvider(widget.company.id));
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredChecklists.length,
              itemBuilder: (context, index) {
                return _ChecklistCard(
                  checklist: filteredChecklists[index],
                  isDark: isDark,
                  onToggleItem: (itemId) => _toggleChecklistItem(
                    filteredChecklists[index],
                    itemId,
                  ),
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
                color: isDark ? const Color(0xFFFF6B6B) : const Color(0xFFC62828),
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar checklists',
                style: TextStyle(
                  color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: TextStyle(
                  color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  ref.invalidate(companyChecklistsProvider(widget.company.id));
                },
                child: const Text(
                  'Tentar novamente',
                  style: TextStyle(color: Color(0xFF0072FF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _toggleChecklistItem(
    CompanyChecklistModel checklist,
    String itemId,
  ) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    try {
      final updatedItems = checklist.items.map((item) {
        if (item.id == itemId) {
          return item.copyWith(completed: !item.completed);
        }
        return item;
      }).toList();

      final completedCount = updatedItems.where((item) => item.completed).length;
      final isAllCompleted = completedCount == updatedItems.length;

      final updatedChecklist = checklist.copyWith(
        items: updatedItems,
        isCompleted: isAllCompleted,
        completedAt: isAllCompleted ? DateTime.now() : null,
      );

      final datasource = ref.read(checklistDatasourceProvider);
      await datasource.updateChecklist(updatedChecklist);

      ref.invalidate(companyChecklistsProvider(widget.company.id));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar item: $e'),
            backgroundColor: isDark ? const Color(0xFFFF6B6B) : const Color(0xFFC62828),
          ),
        );
      }
    }
  }
}

class _ChecklistCard extends StatelessWidget {
  final CompanyChecklistModel checklist;
  final bool isDark;
  final Function(String) onToggleItem;

  const _ChecklistCard({
    required this.checklist,
    required this.isDark,
    required this.onToggleItem,
  });

  Color _getTypeColor() {
    switch (checklist.type) {
      case 'mei':
        return const Color(0xFFFFD700);
      case 'monthly':
        return const Color(0xFF0072FF);
      case 'annual':
        return const Color(0xFF9C27B0);
      default:
        return const Color(0xFF616161);
    }
  }

  String _getTypeLabel() {
    switch (checklist.type) {
      case 'mei':
        return 'MEI';
      case 'monthly':
        return 'Mensal';
      case 'annual':
        return 'Anual';
      case 'custom':
        return 'Personalizado';
      default:
        return checklist.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = checklist.items.where((item) => item.completed).length;
    final totalCount = checklist.items.length;
    final progress = totalCount > 0 ? completedCount / totalCount : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _getTypeColor().withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getTypeColor().withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getTypeLabel(),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _getTypeColor(),
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (checklist.dueDate != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 12,
                              color: isDark
                                  ? const Color(0xFFBDBDBD)
                                  : const Color(0xFF5F5F5F),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              DateFormat('dd/MM/yyyy').format(checklist.dueDate!),
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark
                                    ? const Color(0xFFBDBDBD)
                                    : const Color(0xFF5F5F5F),
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  checklist.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                    fontFamily: 'Poppins',
                  ),
                ),
                if (checklist.description != null && checklist.description!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    checklist.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFFBDBDBD)
                          : const Color(0xFF5F5F5F),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: isDark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFE0E0E0),
                          valueColor: AlwaysStoppedAnimation<Color>(_getTypeColor()),
                          minHeight: 8,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '$completedCount/$totalCount',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _getTypeColor(),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
          ),
          // Items
          ...checklist.items.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isLast = index == checklist.items.length - 1;

            return InkWell(
              onTap: () => onToggleItem(item.id),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  border: isLast
                      ? null
                      : Border(
                          bottom: BorderSide(
                            color: isDark
                                ? const Color(0xFF2A2A2A).withOpacity(0.5)
                                : const Color(0xFFE0E0E0).withOpacity(0.5),
                            width: 0.5,
                          ),
                        ),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.completed
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: item.completed
                          ? _getTypeColor()
                          : (isDark
                              ? const Color(0xFF616161)
                              : const Color(0xFFBDBDBD)),
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        item.title,
                        style: TextStyle(
                          fontSize: 14,
                          color: item.completed
                              ? (isDark
                                  ? const Color(0xFF757575)
                                  : const Color(0xFF9E9E9E))
                              : (isDark
                                  ? const Color(0xFFFFFFFF)
                                  : const Color(0xFF1C1C1C)),
                          decoration: item.completed
                              ? TextDecoration.lineThrough
                              : null,
                          fontFamily: 'Inter',
                          fontWeight: item.completed
                              ? FontWeight.w400
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
