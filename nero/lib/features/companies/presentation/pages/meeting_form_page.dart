import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/meeting_model.dart';
import '../providers/meeting_providers.dart';

class MeetingFormPage extends ConsumerStatefulWidget {
  final MeetingModel? meeting;
  final String? initialCompanyId;

  const MeetingFormPage({
    super.key,
    this.meeting,
    this.initialCompanyId,
  });

  @override
  ConsumerState<MeetingFormPage> createState() => _MeetingFormPageState();
}

class _MeetingFormPageState extends ConsumerState<MeetingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _participantsController = TextEditingController();

  DateTime? _selectedStartDate;
  TimeOfDay? _selectedStartTime;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.meeting != null) {
      _titleController.text = widget.meeting!.title;
      _descriptionController.text = widget.meeting!.description ?? '';
      _locationController.text = widget.meeting!.location ?? '';
      _participantsController.text = widget.meeting!.participants.join(', ');

      _selectedStartDate = widget.meeting!.startAt;
      _selectedStartTime = TimeOfDay(
        hour: widget.meeting!.startAt.hour,
        minute: widget.meeting!.startAt.minute,
      );

      _selectedEndDate = widget.meeting!.endAt;
      _selectedEndTime = TimeOfDay(
        hour: widget.meeting!.endAt.hour,
        minute: widget.meeting!.endAt.minute,
      );
    } else {
      // Valores padrão para nova reunião
      _selectedStartDate = DateTime.now();
      _selectedStartTime = TimeOfDay.now();
      _selectedEndDate = DateTime.now().add(const Duration(hours: 1));
      _selectedEndTime = TimeOfDay(
        hour: TimeOfDay.now().hour + 1,
        minute: TimeOfDay.now().minute,
      );
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _participantsController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF0072FF),
                    surface: Color(0xFF1A1A1A),
                    onSurface: Color(0xFFFFFFFF),
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF0072FF),
                    surface: Colors.white,
                    onSurface: Color(0xFF1C1C1C),
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
      });
    }
  }

  Future<void> _selectStartTime() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedStartTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF0072FF),
                    surface: Color(0xFF1A1A1A),
                    onSurface: Color(0xFFFFFFFF),
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF0072FF),
                    surface: Colors.white,
                    onSurface: Color(0xFF1C1C1C),
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedStartTime = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate ?? DateTime.now().add(const Duration(hours: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF0072FF),
                    surface: Color(0xFF1A1A1A),
                    onSurface: Color(0xFFFFFFFF),
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF0072FF),
                    surface: Colors.white,
                    onSurface: Color(0xFF1C1C1C),
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedEndTime ?? TimeOfDay(hour: TimeOfDay.now().hour + 1, minute: TimeOfDay.now().minute),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: isDark
                ? const ColorScheme.dark(
                    primary: Color(0xFF0072FF),
                    surface: Color(0xFF1A1A1A),
                    onSurface: Color(0xFFFFFFFF),
                  )
                : const ColorScheme.light(
                    primary: Color(0xFF0072FF),
                    surface: Colors.white,
                    onSurface: Color(0xFF1C1C1C),
                  ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedEndTime = picked;
      });
    }
  }

  Future<void> _saveMeeting() async {
    if (!_formKey.currentState!.validate()) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_selectedStartDate == null || _selectedStartTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione a data e hora de início'),
          backgroundColor: isDark ? const Color(0xFFFF6B6B) : const Color(0xFFC62828),
        ),
      );
      return;
    }

    if (_selectedEndDate == null || _selectedEndTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Selecione a data e hora de término'),
          backgroundColor: isDark ? const Color(0xFFFF6B6B) : const Color(0xFFC62828),
        ),
      );
      return;
    }

    final startDateTime = DateTime(
      _selectedStartDate!.year,
      _selectedStartDate!.month,
      _selectedStartDate!.day,
      _selectedStartTime!.hour,
      _selectedStartTime!.minute,
    );

    final endDateTime = DateTime(
      _selectedEndDate!.year,
      _selectedEndDate!.month,
      _selectedEndDate!.day,
      _selectedEndTime!.hour,
      _selectedEndTime!.minute,
    );

    if (endDateTime.isBefore(startDateTime)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Data de término deve ser após a data de início'),
          backgroundColor: isDark ? const Color(0xFFFF6B6B) : const Color(0xFFC62828),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.client.auth.currentUser!.id;
      final companyId = widget.initialCompanyId ?? widget.meeting?.companyId ?? '';

      final participants = _participantsController.text
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      final meeting = MeetingModel(
        id: widget.meeting?.id ?? const Uuid().v4(),
        userId: userId,
        companyId: companyId,
        title: _titleController.text,
        description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
        location: _locationController.text.isEmpty ? null : _locationController.text,
        startAt: startDateTime,
        endAt: endDateTime,
        participants: participants,
        isCompleted: widget.meeting?.isCompleted ?? false,
        completedAt: widget.meeting?.completedAt,
        createdAt: widget.meeting?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final datasource = ref.read(meetingDatasourceProvider);

      if (widget.meeting == null) {
        await datasource.createMeeting(meeting);
      } else {
        await datasource.updateMeeting(meeting);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Reunião salva com sucesso!'),
            backgroundColor: Color(0xFF43A047),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao salvar reunião: $e'),
            backgroundColor: isDark ? const Color(0xFFFF6B6B) : const Color(0xFFC62828),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
        title: Text(
          widget.meeting == null ? 'Nova Reunião' : 'Editar Reunião',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
            fontFamily: 'Poppins',
          ),
        ),
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF0072FF),
                  ),
                ),
              ),
            )
          else
            TextButton(
              onPressed: _saveMeeting,
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0072FF),
              ),
              child: const Text(
                'Salvar',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Título
            TextFormField(
              controller: _titleController,
              style: TextStyle(
                color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
              ),
              decoration: InputDecoration(
                labelText: 'Título *',
                hintText: 'Ex: Reunião semanal',
                labelStyle: TextStyle(
                  color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: TextStyle(
                  color: isDark ? const Color(0xFF757575) : const Color(0xFF8C8C8C),
                  fontFamily: 'Inter',
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF0072FF),
                    width: 2,
                  ),
                ),
                prefixIcon: const Icon(Icons.title, color: Color(0xFF0072FF)),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Digite o título da reunião';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Descrição
            TextFormField(
              controller: _descriptionController,
              style: TextStyle(
                color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
              ),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descrição (opcional)',
                hintText: 'Adicione detalhes sobre a reunião...',
                labelStyle: TextStyle(
                  color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: TextStyle(
                  color: isDark ? const Color(0xFF757575) : const Color(0xFF8C8C8C),
                  fontFamily: 'Inter',
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF0072FF),
                    width: 2,
                  ),
                ),
                prefixIcon: const Icon(Icons.description, color: Color(0xFF0072FF)),
              ),
            ),
            const SizedBox(height: 16),

            // Local
            TextFormField(
              controller: _locationController,
              style: TextStyle(
                color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
              ),
              decoration: InputDecoration(
                labelText: 'Local (opcional)',
                hintText: 'Ex: Sala de reuniões, Online',
                labelStyle: TextStyle(
                  color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: TextStyle(
                  color: isDark ? const Color(0xFF757575) : const Color(0xFF8C8C8C),
                  fontFamily: 'Inter',
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF0072FF),
                    width: 2,
                  ),
                ),
                prefixIcon: const Icon(Icons.location_on, color: Color(0xFF0072FF)),
              ),
            ),
            const SizedBox(height: 24),

            // Data e Hora de Início
            Text(
              'Início',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectStartDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF0072FF), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _selectedStartDate != null
                                ? DateFormat('dd/MM/yyyy').format(_selectedStartDate!)
                                : 'Selecionar data',
                            style: TextStyle(
                              color: _selectedStartDate != null
                                  ? (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C))
                                  : (isDark ? const Color(0xFF757575) : const Color(0xFF8C8C8C)),
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectStartTime,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Color(0xFF0072FF), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _selectedStartTime != null
                                ? _selectedStartTime!.format(context)
                                : 'Hora',
                            style: TextStyle(
                              color: _selectedStartTime != null
                                  ? (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C))
                                  : (isDark ? const Color(0xFF757575) : const Color(0xFF8C8C8C)),
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Data e Hora de Término
            Text(
              'Término',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _selectEndDate,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today, color: Color(0xFF0072FF), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _selectedEndDate != null
                                ? DateFormat('dd/MM/yyyy').format(_selectedEndDate!)
                                : 'Selecionar data',
                            style: TextStyle(
                              color: _selectedEndDate != null
                                  ? (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C))
                                  : (isDark ? const Color(0xFF757575) : const Color(0xFF8C8C8C)),
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectEndTime,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time, color: Color(0xFF0072FF), size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _selectedEndTime != null
                                ? _selectedEndTime!.format(context)
                                : 'Hora',
                            style: TextStyle(
                              color: _selectedEndTime != null
                                  ? (isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C))
                                  : (isDark ? const Color(0xFF757575) : const Color(0xFF8C8C8C)),
                              fontSize: 14,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Participantes
            TextFormField(
              controller: _participantsController,
              style: TextStyle(
                color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
              ),
              decoration: InputDecoration(
                labelText: 'Participantes (opcional)',
                hintText: 'João, Maria, Pedro',
                labelStyle: TextStyle(
                  color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                hintStyle: TextStyle(
                  color: isDark ? const Color(0xFF757575) : const Color(0xFF8C8C8C),
                  fontFamily: 'Inter',
                ),
                helperText: 'Separe os nomes por vírgula',
                helperStyle: TextStyle(
                  color: isDark ? const Color(0xFF757575) : const Color(0xFF8C8C8C),
                  fontSize: 12,
                  fontFamily: 'Inter',
                ),
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: Color(0xFF0072FF),
                    width: 2,
                  ),
                ),
                prefixIcon: const Icon(Icons.people, color: Color(0xFF0072FF)),
              ),
            ),

            const SizedBox(height: 32),

            // Botão Salvar
            SizedBox(
              height: 56,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveMeeting,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0072FF),
                  disabledBackgroundColor: const Color(0xFF0072FF).withOpacity(0.5),
                  foregroundColor: Colors.white,
                  elevation: isDark ? 0 : 2,
                  shadowColor: const Color(0xFF0072FF).withOpacity(0.25),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        widget.meeting == null ? 'Salvar Reunião' : 'Atualizar Reunião',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
