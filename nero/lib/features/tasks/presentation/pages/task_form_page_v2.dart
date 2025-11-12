import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../core/services/openai_service.dart';
import '../../../../shared/models/task_model.dart';
import '../../../companies/presentation/providers/company_providers.dart';
import '../providers/task_providers.dart';
import '../widgets/free_location_picker.dart';

/// Tela de criação/edição de tarefas - Versão 2.0 aprimorada
class TaskFormPageV2 extends ConsumerStatefulWidget {
  final TaskModel? task;
  final String? initialCompanyId;

  const TaskFormPageV2({
    super.key,
    this.task,
    this.initialCompanyId,
  });

  @override
  ConsumerState<TaskFormPageV2> createState() => _TaskFormPageV2State();
}

class _TaskFormPageV2State extends ConsumerState<TaskFormPageV2>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _scrollController = ScrollController();

  String _selectedOrigin = 'personal';
  String _selectedPriority = 'medium';
  DateTime? _selectedDueDate;
  TimeOfDay? _selectedDueTime;
  String? _recurrenceType;
  String? _selectedCompanyId;
  bool _isLoading = false;
  bool _isAiSuggesting = false;
  bool _isAllDayTask = false; // Toggle para tarefa de dia inteiro

  // Campos de localização
  String? _locationName;
  double? _latitude;
  double? _longitude;

  late AnimationController _animationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();

    // Configurar animações
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Preencher dados se estiver editando
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description ?? '';
      _selectedOrigin = widget.task!.origin;
      _selectedPriority = widget.task!.priority ?? 'medium';
      _selectedDueDate = widget.task!.dueDate;
      _recurrenceType = widget.task!.recurrenceType;
      _selectedCompanyId = widget.task!.companyId;

      // Carregar localização
      _locationName = widget.task!.locationName;
      _latitude = widget.task!.latitude;
      _longitude = widget.task!.longitude;

      if (_selectedDueDate != null) {
        // Verificar se é tarefa de dia inteiro (00:00)
        if (_selectedDueDate!.hour == 0 && _selectedDueDate!.minute == 0) {
          _isAllDayTask = true;
          _selectedDueTime = null;
        } else {
          _isAllDayTask = false;
          _selectedDueTime = TimeOfDay(
            hour: _selectedDueDate!.hour,
            minute: _selectedDueDate!.minute,
          );
        }
      }
    } else if (widget.initialCompanyId != null) {
      _selectedCompanyId = widget.initialCompanyId;
      _selectedOrigin = 'company';
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final isDark = ref.read(themeProvider) == ThemeMode.dark;
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: isDark ? AppColors.darkCard : AppColors.lightCard,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDueDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final isDark = ref.read(themeProvider) == ThemeMode.dark;
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedDueTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primary,
              surface: isDark ? AppColors.darkCard : AppColors.lightCard,
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

  Future<void> _suggestWithAI() async {
    setState(() => _isAiSuggesting = true);

    try {
      TaskSuggestion suggestion;

      // Verificar se OpenAI está configurado
      if (OpenAIService.isConfigured()) {
        // MODO REAL: Usar ChatGPT (requer API Key configurada)
        final context = _descriptionController.text.trim();
        suggestion = await OpenAIService.suggestTask(context: context);
      } else {
        // MODO DEMO: Simulação local (sem custo)
        await Future.delayed(const Duration(seconds: 2));
        suggestion = _getLocalSuggestion();
      }

      // Aplicar a sugestão nos campos
      setState(() {
        if (_titleController.text.isEmpty) {
          _titleController.text = suggestion.title;
        }
        _selectedPriority = suggestion.priority;
        _selectedDueDate = suggestion.dueDate;
        _selectedDueTime = suggestion.dueTime;
        _isAiSuggesting = false;
      });

      // Feedback ao usuário
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('✨ Tarefa sugerida pela IA!'),
              if (suggestion.reasoning.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  suggestion.reasoning,
                  style: const TextStyle(fontSize: 12, color: Colors.white70),
                ),
              ],
            ],
          ),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      setState(() => _isAiSuggesting = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao sugerir: ${e.toString()}'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  /// Gera uma sugestão local (sem usar API externa)
  /// Útil para testes e modo demo
  TaskSuggestion _getLocalSuggestion() {
    final context = _descriptionController.text.trim().toLowerCase();

    // Sugestões baseadas em palavras-chave
    if (context.contains('reunião') || context.contains('meeting')) {
      return TaskSuggestion(
        title: 'Preparar reunião semanal',
        priority: 'high',
        dueDate: DateTime.now().add(const Duration(days: 1, hours: 9)),
        reasoning: 'Reuniões geralmente requerem preparação antecipada',
      );
    } else if (context.contains('email')) {
      return TaskSuggestion(
        title: 'Responder emails pendentes',
        priority: 'medium',
        dueDate: DateTime.now().add(const Duration(hours: 2)),
        reasoning: 'Responder emails mantém a comunicação fluida',
      );
    } else if (context.contains('relatório') || context.contains('report')) {
      return TaskSuggestion(
        title: 'Finalizar relatório mensal',
        priority: 'high',
        dueDate: DateTime.now().add(const Duration(hours: 4)),
        reasoning: 'Relatórios são importantes para acompanhamento',
      );
    } else if (context.contains('treino') || context.contains('academia')) {
      return TaskSuggestion(
        title: 'Sessão de treino',
        priority: 'low',
        dueDate: DateTime.now().add(const Duration(hours: 6)),
        reasoning: 'Manter a saúde física é essencial',
      );
    }

    // Sugestão padrão
    return TaskSuggestion(
      title: _titleController.text.isEmpty ? 'Revisar tarefas do dia' : _titleController.text,
      priority: 'medium',
      dueDate: DateTime.now().add(const Duration(hours: 2)),
      reasoning: 'Sugestão baseada em padrões comuns de produtividade',
    );
  }

  Future<void> _saveTask() async {
    print('[TaskFormPageV2] 🔵 Iniciando _saveTask...');

    if (!_formKey.currentState!.validate()) {
      print('[TaskFormPageV2] ❌ Validação do formulário falhou');
      return;
    }

    // VALIDAÇÃO OBRIGATÓRIA: Empresa (se origem for empresa)
    if (_selectedOrigin == 'company' && _selectedCompanyId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(child: Text('Por favor, selecione uma empresa para esta tarefa')),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // VALIDAÇÃO OBRIGATÓRIA: Data
    if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(child: Text('Por favor, selecione uma data para a tarefa')),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // VALIDAÇÃO OBRIGATÓRIA: Horário (se não for dia inteiro)
    if (!_isAllDayTask && _selectedDueTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Expanded(child: Text('Por favor, selecione um horário ou marque "Dia inteiro"')),
            ],
          ),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    print('[TaskFormPageV2] ✅ Validação OK, iniciando salvamento...');

    _animationController.forward().then((_) => _animationController.reverse());
    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.currentUser!.id;
      print('[TaskFormPageV2] 👤 userId: $userId');

      // Construir data final com horário
      DateTime? finalDueDate;
      if (_selectedDueDate != null) {
        if (_isAllDayTask) {
          // Dia inteiro: usar 00:00
          finalDueDate = DateTime(
            _selectedDueDate!.year,
            _selectedDueDate!.month,
            _selectedDueDate!.day,
            0,
            0,
          );
        } else if (_selectedDueTime != null) {
          // Horário específico
          finalDueDate = DateTime(
            _selectedDueDate!.year,
            _selectedDueDate!.month,
            _selectedDueDate!.day,
            _selectedDueTime!.hour,
            _selectedDueTime!.minute,
          );
        }
      }

      final task = TaskModel(
        id: widget.task?.id ?? '',
        userId: userId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        origin: _selectedOrigin,
        priority: _selectedPriority,
        dueDate: finalDueDate,
        isCompleted: widget.task?.isCompleted ?? false,
        completedAt: widget.task?.completedAt,
        companyId: _selectedCompanyId,
        recurrenceType: _recurrenceType,
        // Campos de localização
        locationName: _locationName,
        latitude: _latitude,
        longitude: _longitude,
        createdAt: widget.task?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      print('[TaskFormPageV2] 📦 Tarefa criada: ${task.toJson()}');

      bool success;
      if (widget.task == null) {
        print('[TaskFormPageV2] 🆕 Criando NOVA tarefa...');
        success = await ref.read(tasksListProvider.notifier).createTask(task);
        print('[TaskFormPageV2] ${success ? "✅ Sucesso!" : "❌ Falhou!"}');
      } else {
        print('[TaskFormPageV2] 🔄 Atualizando tarefa existente...');
        success = await ref.read(tasksListProvider.notifier).updateTask(task);
        print('[TaskFormPageV2] ${success ? "✅ Sucesso!" : "❌ Falhou!"}');
      }

      if (mounted) {
        if (success) {
          // Invalidar providers para atualizar o dashboard automaticamente
          ref.invalidate(todayTasksProvider);
          ref.invalidate(tasksListProvider);

          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    widget.task == null
                        ? '✅ Tarefa criada com sucesso!'
                        : '✅ Tarefa atualizada!',
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
            ),
          );
        } else {
          throw Exception('Erro ao salvar tarefa');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Adiciona localização à tarefa usando busca gratuita (OpenStreetMap)
  Future<void> _addLocation() async {
    final isDark = ref.read(themeProvider) == ThemeMode.dark;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return FreeLocationPicker(
          isDark: isDark,
          onLocationSelected: (locationData) {
            setState(() {
              _locationName = locationData.name;
              _latitude = locationData.latitude;
              _longitude = locationData.longitude;
            });

            // Mostrar confirmação
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text('Localização adicionada: ${locationData.name}'),
                    ),
                  ],
                ),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
        );
      },
    );
  }

  /// Remove a localização
  void _removeLocation() {
    setState(() {
      _locationName = null;
      _latitude = null;
      _longitude = null;
    });
  }

  /// Abre a localização no aplicativo de mapas
  Future<void> _openInMaps() async {
    if (_locationName == null) return;

    try {
      String mapUrl;

      // Se temos coordenadas, usar para maior precisão
      if (_latitude != null && _longitude != null) {
        mapUrl = 'https://www.google.com/maps/search/?api=1&query=$_latitude,$_longitude';
      } else {
        // Caso contrário, usar o nome como query
        final query = Uri.encodeComponent(_locationName!);
        mapUrl = 'https://www.google.com/maps/search/?api=1&query=$query';
      }

      final uri = Uri.parse(mapUrl);

      // Tentar abrir no app de mapas ou navegador
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erro ao abrir mapa: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final backgroundColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final textColor = isDark ? AppColors.darkText : AppColors.lightText;
    final secondaryTextColor = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return Scaffold(
      resizeToAvoidBottomInset: true,

      // AppBar translúcido
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: AppBar(
              backgroundColor: backgroundColor.withOpacity(0.95),
              elevation: 0,
              centerTitle: true,
              leading: IconButton(
                icon: Icon(Icons.close, color: textColor),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: Text(
                widget.task == null ? 'Nova Tarefa' : 'Editar Tarefa',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                  fontFamily: 'Poppins',
                ),
              ),
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1),
                child: Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        (isDark ? AppColors.darkBorder : AppColors.grey300)
                            .withOpacity(0.5),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),

      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Conteúdo rolável
                Expanded(
                  child: SingleChildScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // TÍTULO
                        _buildTextField(
                          controller: _titleController,
                          label: 'Título',
                          hint: 'Ex: Reunião com equipe, treino matinal, estudar inglês…',
                          maxLength: 60,
                          isDark: isDark,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'O título é obrigatório';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // DESCRIÇÃO
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Descrição',
                          hint: 'Adicione detalhes, links ou lembretes para esta tarefa…',
                          maxLines: 3,
                          isDark: isDark,
                        ),
                        const SizedBox(height: 8),

                        // BOTÃO SUGERIR COM IA
                        if (widget.task == null)
                          _buildAiSuggestionButton(isDark),

                        const SizedBox(height: 20),

                        // ORIGEM
                        _buildSectionTitle('Origem', isDark),
                        const SizedBox(height: 10),
                        _buildOriginButtons(isDark),

                        // SELETOR DE EMPRESA (apenas se origem for 'company')
                        if (_selectedOrigin == 'company') ...[
                          const SizedBox(height: 12),
                          _buildCompanySelector(isDark, textColor, secondaryTextColor),
                        ],

                        const SizedBox(height: 6),
                        _buildTooltip(
                          'A origem ajuda o Nero a entender o contexto da tarefa e priorizar corretamente.',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 20),

                        // PRIORIDADE
                        _buildSectionTitle('Prioridade', isDark),
                        const SizedBox(height: 10),
                        _buildPriorityButtons(isDark),
                        const SizedBox(height: 6),
                        _buildTooltip(
                          'A prioridade ajuda a IA a organizar suas sugestões.',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 20),

                        // LOCALIZAÇÃO (OPCIONAL)
                        _buildSectionTitle('📍 Localização (opcional)', isDark),
                        const SizedBox(height: 10),
                        _buildLocationCard(isDark, textColor, secondaryTextColor),
                        const SizedBox(height: 6),
                        _buildTooltip(
                          'Adicione um local para tarefas como reuniões, visitas ou entregas.',
                          secondaryTextColor,
                        ),
                        const SizedBox(height: 20),

                        // DATA & HORÁRIO
                        _buildSectionTitle('Data & Horário', isDark),
                        const SizedBox(height: 10),
                        _buildDateTimeCard(isDark, textColor, secondaryTextColor),

                        // RECORRÊNCIA (se origem for recorrente)
                        if (_selectedOrigin == 'recurring') ...[
                          const SizedBox(height: 20),
                          _buildSectionTitle('Recorrência', isDark),
                          const SizedBox(height: 10),
                          _buildRecurrenceChips(isDark),
                        ],
                      ],
                    ),
                  ),
                ),

                // BOTÃO FIXO NO RODAPÉ
                _buildFixedButton(isDark, textColor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required bool isDark,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          style: TextStyle(
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            filled: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.grey300,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.grey300,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.error),
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildAiSuggestionButton(bool isDark) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.aiButtonBackground, // #E8F0FF
        foregroundColor: AppColors.primary, // #0072FF
        elevation: 0,
        side: BorderSide(
          color: AppColors.primary.withOpacity(0.2),
          width: 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
      icon: _isAiSuggesting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            )
          : const Icon(Icons.auto_awesome, color: AppColors.primary, size: 20),
      label: Text(
        _isAiSuggesting ? 'Gerando sugestões...' : 'Sugerir com IA',
        style: const TextStyle(
          color: AppColors.primary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
      ),
      onPressed: _isAiSuggesting ? null : _suggestWithAI,
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkText : AppColors.lightText,
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildTooltip(String text, Color color) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        color: color.withOpacity(0.8),
        fontFamily: 'Inter',
        height: 1.3,
      ),
    );
  }

  Widget _buildOriginButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _OriginButton(
            icon: Icons.person,
            label: 'Pessoal',
            selected: _selectedOrigin == 'personal',
            isDark: isDark,
            onTap: () => setState(() {
              _selectedOrigin = 'personal';
              _selectedCompanyId = null;
            }),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _OriginButton(
            icon: Icons.business,
            label: 'Empresa',
            selected: _selectedOrigin == 'company',
            isDark: isDark,
            onTap: () => setState(() => _selectedOrigin = 'company'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _OriginButton(
            icon: Icons.refresh,
            label: 'Recorrente',
            selected: _selectedOrigin == 'recurring',
            isDark: isDark,
            onTap: () => setState(() {
              _selectedOrigin = 'recurring';
              _selectedCompanyId = null;
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityButtons(bool isDark) {
    return Row(
      children: [
        Expanded(
          child: _PriorityButtonV2(
            label: 'Baixa',
            selected: _selectedPriority == 'low',
            color: AppColors.priorityLow,
            isDark: isDark,
            onTap: () => setState(() => _selectedPriority = 'low'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PriorityButtonV2(
            label: 'Média',
            selected: _selectedPriority == 'medium',
            color: AppColors.priorityMedium,
            isDark: isDark,
            onTap: () => setState(() => _selectedPriority = 'medium'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _PriorityButtonV2(
            label: 'Alta',
            selected: _selectedPriority == 'high',
            color: AppColors.priorityHigh,
            isDark: isDark,
            onTap: () => setState(() => _selectedPriority = 'high'),
          ),
        ),
      ],
    );
  }

  Widget _buildCompanySelector(bool isDark, Color textColor, Color secondaryTextColor) {
    final companiesAsync = ref.watch(companiesListProvider);

    // Se está carregando ou com erro, não mostra o campo ainda
    if (companiesAsync.isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Carregando empresas...',
              style: TextStyle(
                fontSize: 13,
                color: secondaryTextColor,
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      );
    }

    if (companiesAsync.hasError) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Erro ao carregar empresas',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.error,
            fontFamily: 'Inter',
          ),
        ),
      );
    }

    final companies = companiesAsync.value ?? [];
    final activeCompanies = companies.where((c) => c.isActive).toList();

    if (activeCompanies.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Nenhuma empresa cadastrada',
          style: TextStyle(
            fontSize: 13,
            color: secondaryTextColor,
            fontFamily: 'Inter',
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Empresa',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkText : AppColors.lightText,
            fontFamily: 'Poppins',
          ),
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkCard : AppColors.lightCard,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.grey300,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedCompanyId,
              hint: Text(
                'Selecione uma empresa',
                style: TextStyle(
                  fontSize: 14,
                  color: secondaryTextColor,
                  fontFamily: 'Inter',
                ),
              ),
              isExpanded: true,
              dropdownColor: isDark ? AppColors.darkCard : AppColors.lightCard,
              style: TextStyle(
                fontSize: 14,
                color: textColor,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
              items: activeCompanies.map((company) {
                return DropdownMenuItem<String>(
                  value: company.id,
                  child: SizedBox(
                    height: 40,
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Icon(
                            Icons.business,
                            color: AppColors.primary,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            company.name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCompanyId = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationCard(bool isDark, Color textColor, Color secondaryTextColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.grey300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_locationName == null) ...[
            // Botão para adicionar localização
            InkWell(
              onTap: _addLocation,
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.2),
                    style: BorderStyle.solid,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_location_outlined,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Adicionar Localização',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Mostrar localização adicionada
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.place,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _locationName!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: textColor,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _openInMaps,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    icon: const Icon(Icons.navigation_outlined, size: 18),
                    label: const Text(
                      'Abrir no Mapa',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _removeLocation,
                  icon: const Icon(Icons.close, size: 20),
                  color: AppColors.error,
                  tooltip: 'Remover',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withOpacity(0.1),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDateTimeCard(bool isDark, Color textColor, Color secondaryTextColor) {
    final hasDateTime = _selectedDueDate != null && (_isAllDayTask || _selectedDueTime != null);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.grey300,
        ),
      ),
      child: Column(
        children: [
          // Toggle "Dia inteiro"
          Row(
            children: [
              Icon(
                Icons.schedule,
                size: 16,
                color: secondaryTextColor,
              ),
              const SizedBox(width: 8),
              Text(
                'Dia inteiro',
                style: TextStyle(
                  fontSize: 13,
                  color: textColor,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Inter',
                ),
              ),
              const Spacer(),
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: _isAllDayTask,
                  onChanged: (value) {
                    setState(() {
                      _isAllDayTask = value;
                      if (value) {
                        // Se marcar como dia inteiro, limpar horário
                        _selectedDueTime = null;
                      }
                    });
                  },
                  activeColor: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Data
              Expanded(
                child: GestureDetector(
                  onTap: _selectDate,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    decoration: BoxDecoration(
                      color: _selectedDueDate != null
                          ? AppColors.primary.withOpacity(0.1)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _selectedDueDate != null
                            ? AppColors.primary.withOpacity(0.5)
                            : (isDark ? AppColors.darkBorder : AppColors.grey300),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 16,
                          color: _selectedDueDate != null
                              ? AppColors.primary
                              : secondaryTextColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _selectedDueDate == null
                                ? 'Data'
                                : DateFormat('dd/MM/yyyy').format(_selectedDueDate!),
                            style: TextStyle(
                              fontSize: 13,
                              color: _selectedDueDate != null
                                  ? AppColors.primary
                                  : secondaryTextColor,
                              fontWeight: _selectedDueDate != null
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Horário (escondido se "Dia inteiro" estiver marcado)
              if (!_isAllDayTask) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: GestureDetector(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                      decoration: BoxDecoration(
                        color: _selectedDueTime != null
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedDueTime != null
                              ? AppColors.primary.withOpacity(0.5)
                              : (isDark ? AppColors.darkBorder : AppColors.grey300),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.access_time,
                            size: 16,
                            color: _selectedDueTime != null
                                ? AppColors.primary
                                : secondaryTextColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _selectedDueTime == null
                                  ? 'Horário'
                                  : _selectedDueTime!.format(context),
                              style: TextStyle(
                                fontSize: 13,
                                color: _selectedDueTime != null
                                    ? AppColors.primary
                                    : secondaryTextColor,
                                fontWeight: _selectedDueTime != null
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),

          // Texto combinado
          if (hasDateTime) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.event,
                    color: AppColors.primary,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _isAllDayTask
                          ? '${DateFormat('d \'de\' MMMM \'de\' y', 'pt_BR').format(_selectedDueDate!)} (dia inteiro)'
                          : '${DateFormat('d \'de\' MMMM \'de\' y', 'pt_BR').format(_selectedDueDate!)} às ${_selectedDueTime!.format(context)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.clear, size: 16),
                    onPressed: () {
                      setState(() {
                        _selectedDueDate = null;
                        _selectedDueTime = null;
                        _isAllDayTask = false;
                      });
                    },
                    color: AppColors.error,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRecurrenceChips(bool isDark) {
    final options = [
      {'value': null, 'label': 'Nenhuma'},
      {'value': 'daily', 'label': 'Diária'},
      {'value': 'weekly', 'label': 'Semanal'},
      {'value': 'monthly', 'label': 'Mensal'},
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final selected = _recurrenceType == option['value'];
        return GestureDetector(
          onTap: () => setState(() => _recurrenceType = option['value']),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.primary.withOpacity(0.15)
                  : (isDark ? AppColors.darkCard : AppColors.lightCard),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : (isDark ? AppColors.darkBorder : AppColors.grey300),
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Text(
              option['label'] as String,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                color: selected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
                fontFamily: 'Inter',
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFixedButton(bool isDark, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackground.withOpacity(0.95)
            : AppColors.lightBackground.withOpacity(0.95),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.grey300,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: ScaleTransition(
          scale: _buttonScaleAnimation,
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _saveTask,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                shadowColor: AppColors.primary.withOpacity(0.4),
              ),
              child: _isLoading
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.white),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          widget.task == null ? 'Criando tarefa...' : 'Salvando...',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    )
                  : Text(
                      widget.task == null ? 'Salvar Tarefa' : 'Salvar Alterações',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget de botão de origem com ícone
class _OriginButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _OriginButton({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: 36,
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withOpacity(0.15)
                : (isDark ? AppColors.darkCard : AppColors.lightCard),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (isDark ? AppColors.darkBorder : AppColors.grey300),
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 14,
                color: selected
                    ? AppColors.primary
                    : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
                  color: selected
                      ? AppColors.primary
                      : (isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget de botão de prioridade V2
class _PriorityButtonV2 extends StatefulWidget {
  final String label;
  final bool selected;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const _PriorityButtonV2({
    required this.label,
    required this.selected,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_PriorityButtonV2> createState() => _PriorityButtonV2State();
}

class _PriorityButtonV2State extends State<_PriorityButtonV2>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            _controller.forward().then((_) => _controller.reverse());
            widget.onTap();
          },
          borderRadius: BorderRadius.circular(10),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            height: 36,
            decoration: BoxDecoration(
              color: widget.selected
                  ? widget.color.withOpacity(0.2)
                  : (widget.isDark ? AppColors.darkCard : AppColors.lightCard),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: widget.selected
                    ? widget.color
                    : (widget.isDark ? AppColors.darkBorder : AppColors.grey300),
                width: widget.selected ? 1.5 : 1,
              ),
            ),
            child: Center(
              child: Text(
                widget.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: widget.selected ? FontWeight.w600 : FontWeight.normal,
                  color: widget.selected
                      ? widget.color
                      : (widget.isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary),
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
