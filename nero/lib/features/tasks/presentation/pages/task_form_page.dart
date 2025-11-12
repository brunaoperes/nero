import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/presentation/main_shell.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/task_model.dart';
import '../providers/task_providers.dart';

class TaskFormPage extends ConsumerStatefulWidget {
  final TaskModel? task; // Se null, está criando; se não null, está editando
  final String? initialCompanyId; // Empresa pré-selecionada ao criar tarefa

  const TaskFormPage({
    super.key,
    this.task,
    this.initialCompanyId,
  });

  @override
  ConsumerState<TaskFormPage> createState() => _TaskFormPageState();
}

class _TaskFormPageState extends ConsumerState<TaskFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _selectedOrigin = 'personal';
  String _selectedPriority = 'medium';
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  String? _recurrenceType;
  String? _selectedCompanyId; // Para quando origem for empresa
  bool _isLoading = false;

  // Lista mockada de empresas (depois virá do banco)
  final List<Map<String, String>> _companies = [
    {'id': '1', 'name': 'Empresa A'},
    {'id': '2', 'name': 'Empresa B'},
    {'id': '3', 'name': 'Empresa C'},
  ];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedOrigin = widget.task!.origin;
      _selectedPriority = widget.task!.priority ?? 'medium';
      _selectedDueDate = widget.task!.dueDate;
      _recurrenceType = widget.task!.recurrenceType;
      _selectedCompanyId = widget.task!.companyId;

      if (_selectedDueDate != null) {
        _selectedDueTime = TimeOfDay(
          hour: _selectedDueDate!.hour,
          minute: _selectedDueDate!.minute,
        );
      }
    } else if (widget.initialCompanyId != null) {
      // Se tem companyId inicial, configura origem como empresa
      _selectedCompanyId = widget.initialCompanyId;
      _selectedOrigin = 'company';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.darkSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDueDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.darkSurface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDueTime = picked;
        _selectedDueDate ??= DateTime.now();
        _selectedDueDate = DateTime(
          _selectedDueDate!.year,
          _selectedDueDate!.month,
          _selectedDueDate!.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.currentUser!.id;

      final task = TaskModel(
        id: widget.task?.id ?? '',
        userId: userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        origin: _selectedOrigin,
        priority: _selectedPriority,
        dueDate: _selectedDueDate,
        isCompleted: widget.task?.isCompleted ?? false,
        completedAt: widget.task?.completedAt,
        recurrenceType: _recurrenceType,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (widget.task == null) {
        success = await ref.read(tasksListProvider.notifier).createTask(task);
      } else {
        success = await ref.read(tasksListProvider.notifier).updateTask(task);
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.task == null
                    ? 'Tarefa criada com sucesso!'
                    : 'Tarefa atualizada com sucesso!',
              ),
              backgroundColor: const Color(0xFF009E0F),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao salvar tarefa'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(0xFFEAEAEA)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.task == null ? 'Nova Tarefa' : 'Editar Tarefa',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(0xFFEAEAEA),
            fontFamily: 'Poppins',
          ),
        ),
        centerTitle: false,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título *
                  TextFormField(
                    controller: _titleController,
                    style: const TextStyle(
                      color: Color(0xFFEAEAEA),
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Título *',
                      hintText: 'Ex.: Ligar para fornecedor',
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'O título é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Descrição
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(
                      color: Color(0xFFEAEAEA),
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Detalhes da tarefa…',
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Origem
                  const Text(
                    'Origem',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEAEAEA),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _SegmentedButton(
                          label: 'Pessoal',
                          selected: _selectedOrigin == 'personal',
                          onTap: () => setState(() {
                            _selectedOrigin = 'personal';
                            _selectedCompanyId = null;
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SegmentedButton(
                          label: 'Empresa',
                          selected: _selectedOrigin == 'company',
                          onTap: () => setState(() => _selectedOrigin = 'company'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _SegmentedButton(
                          label: 'Recorrente',
                          selected: _selectedOrigin == 'recurring',
                          onTap: () => setState(() {
                            _selectedOrigin = 'recurring';
                            _selectedCompanyId = null;
                          }),
                        ),
                      ),
                    ],
                  ),

                  // Dropdown de empresas (se origem for empresa)
                  if (_selectedOrigin == 'company') ...[
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: _selectedCompanyId,
                      decoration: InputDecoration(
                        labelText: 'Selecione a empresa',
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF3A3A3A)),
                        ),
                      ),
                      dropdownColor: AppColors.darkSurface,
                      style: const TextStyle(
                        color: Color(0xFFEAEAEA),
                        fontSize: 14,
                        fontFamily: 'Inter',
                      ),
                      items: _companies.map((company) {
                        return DropdownMenuItem(
                          value: company['id'],
                          child: Text(company['name']!),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _selectedCompanyId = value);
                      },
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Prioridade
                  const Text(
                    'Prioridade',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEAEAEA),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _PriorityButton(
                          label: 'Baixa',
                          selected: _selectedPriority == 'low',
                          color: const Color(0xFF9E9E9E), // Cinza suave
                          onTap: () => setState(() => _selectedPriority = 'low'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PriorityButton(
                          label: 'Média',
                          selected: _selectedPriority == 'medium',
                          color: const Color(0xFFFFD700), // Dourado
                          onTap: () => setState(() => _selectedPriority = 'medium'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _PriorityButton(
                          label: 'Alta',
                          selected: _selectedPriority == 'high',
                          color: const Color(0xFFFF5252), // Vermelho suave
                          onTap: () => setState(() => _selectedPriority = 'high'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'A prioridade ajuda a IA a organizar suas sugestões.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontFamily: 'Inter',
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Data e Horário
                  const Text(
                    'Data e Horário',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFEAEAEA),
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectDate,
                          icon: const Icon(Icons.calendar_today_outlined, size: 18),
                          label: Text(
                            _selectedDueDate == null
                                ? 'Selecionar data'
                                : DateFormat('dd/MM/yyyy').format(_selectedDueDate!),
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEAEAEA),
                            side: const BorderSide(color: Color(0xFF3A3A3A)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _selectTime,
                          icon: const Icon(Icons.access_time_outlined, size: 18),
                          label: Text(
                            _selectedDueTime == null
                                ? 'Horário'
                                : _selectedDueTime!.format(context),
                            style: const TextStyle(fontSize: 13),
                          ),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: const Color(0xFFEAEAEA),
                            side: const BorderSide(color: Color(0xFF3A3A3A)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Se você não informar data/horário, a tarefa entra para hoje.',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary.withOpacity(0.7),
                      fontFamily: 'Inter',
                    ),
                  ),

                  if (_selectedDueDate != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _selectedDueDate = null;
                          _selectedDueTime = null;
                        });
                      },
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Remover data'),
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFFF5252),
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Recorrência (se origem for recorrente)
                  if (_selectedOrigin == 'recurring') ...[
                    const Text(
                      'Recorrência',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFEAEAEA),
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _RecurrenceChip(
                          label: 'Nenhuma',
                          selected: _recurrenceType == null,
                          onTap: () => setState(() => _recurrenceType = null),
                        ),
                        _RecurrenceChip(
                          label: 'Diária',
                          selected: _recurrenceType == 'daily',
                          onTap: () => setState(() => _recurrenceType = 'daily'),
                        ),
                        _RecurrenceChip(
                          label: 'Semanal',
                          selected: _recurrenceType == 'weekly',
                          onTap: () => setState(() => _recurrenceType = 'weekly'),
                        ),
                        _RecurrenceChip(
                          label: 'Mensal',
                          selected: _recurrenceType == 'monthly',
                          onTap: () => setState(() => _recurrenceType = 'monthly'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Botão Criar/Salvar
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveTask,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0072FF), // Azul elétrico
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              widget.task == null ? 'Criar Tarefa' : 'Salvar Alterações',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Widget de botão segmentado para Origem
class _SegmentedButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentedButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFF3A3A3A),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? AppColors.primary : AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}

// Widget de botão de prioridade
class _PriorityButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _PriorityButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.2) : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? color : const Color(0xFF3A3A3A),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected ? color : AppColors.textSecondary,
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}

// Widget de chip de recorrência
class _RecurrenceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _RecurrenceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : const Color(0xFF3A3A3A),
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? AppColors.primary : AppColors.textSecondary,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
