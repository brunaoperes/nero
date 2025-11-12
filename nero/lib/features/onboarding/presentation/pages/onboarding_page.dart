import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/onboarding_providers.dart';

class OnboardingPage extends ConsumerStatefulWidget {
  const OnboardingPage({super.key});

  @override
  ConsumerState<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends ConsumerState<OnboardingPage> {
  int _currentStep = 0;
  final _pageController = PageController();

  // Dados do onboarding
  TimeOfDay? _wakeUpTime;
  TimeOfDay? _workStartTime;
  TimeOfDay? _workEndTime;
  bool _hasCompany = false;
  bool _entrepreneurMode = false;
  String? _companyName;

  final _companyNameController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _companyNameController.dispose();
    super.dispose();
  }

  Future<void> _selectTime(BuildContext context, Function(TimeOfDay) onSelected) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Theme.of(context).cardColor,
              hourMinuteTextColor: AppColors.primary,
              dayPeriodTextColor: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      onSelected(time);
    }
  }

  Future<void> _completeOnboarding() async {
    final onboardingService = ref.read(onboardingServiceProvider);

    try {
      await onboardingService.completeOnboarding(
        wakeUpTime: _wakeUpTime?.format(context),
        workStartTime: _workStartTime?.format(context),
        workEndTime: _workEndTime?.format(context),
        hasCompany: _hasCompany,
        entrepreneurMode: _entrepreneurMode,
        companyName: _companyName,
      );

      if (mounted) {
        context.go(AppConstants.routeDashboard);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao completar onboarding: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _nextStep() {
    if (_currentStep < 3) {
      setState(() => _currentStep++);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.animateToPage(
        _currentStep,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuração Inicial'),
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _previousStep,
              )
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Indicador de progresso
            Padding(
              padding: const EdgeInsets.all(16),
              child: LinearProgressIndicator(
                value: (_currentStep + 1) / 4,
                backgroundColor: AppColors.grey300,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
            ),

            // Conteúdo das páginas
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildWelcomePage(theme),
                  _buildSchedulePage(theme),
                  _buildCompanyPage(theme),
                  _buildModePage(theme),
                ],
              ),
            ),

            // Botão de avançar
            Padding(
              padding: const EdgeInsets.all(24),
              child: ElevatedButton(
                onPressed: _nextStep,
                child: Text(_currentStep == 3 ? 'Finalizar' : 'Próximo'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomePage(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.waving_hand,
            size: 80,
            color: AppColors.secondary,
          ),
          const SizedBox(height: 24),
          Text(
            'Bem-vindo ao Nero!',
            style: theme.textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Vamos configurar seu assistente pessoal inteligente em apenas alguns passos.',
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSchedulePage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Sua Rotina',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Compartilhe sua rotina para que o Nero possa personalizar suas sugestões.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),

          // Horário de acordar
          _buildTimeCard(
            theme: theme,
            icon: Icons.wb_sunny_outlined,
            label: 'Que horas você acorda?',
            time: _wakeUpTime,
            onTap: () => _selectTime(context, (time) {
              setState(() => _wakeUpTime = time);
            }),
          ),
          const SizedBox(height: 16),

          // Horário de trabalho
          _buildTimeCard(
            theme: theme,
            icon: Icons.work_outline,
            label: 'Que horas começa a trabalhar?',
            time: _workStartTime,
            onTap: () => _selectTime(context, (time) {
              setState(() => _workStartTime = time);
            }),
          ),
          const SizedBox(height: 16),

          // Horário de fim de trabalho
          _buildTimeCard(
            theme: theme,
            icon: Icons.home_outlined,
            label: 'Que horas termina o trabalho?',
            time: _workEndTime,
            onTap: () => _selectTime(context, (time) {
              setState(() => _workEndTime = time);
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCompanyPage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Você é empreendedor?',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Se você possui uma empresa, podemos ajudar a gerenciá-la também.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),

          // Pergunta se tem empresa
          Card(
            child: SwitchListTile(
              title: const Text('Possuo uma empresa'),
              subtitle: const Text('Ative para gerenciar seu negócio'),
              value: _hasCompany,
              onChanged: (value) {
                setState(() {
                  _hasCompany = value;
                  if (!value) {
                    _companyName = null;
                    _companyNameController.clear();
                  }
                });
              },
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),

          // Campo de nome da empresa (se possui)
          if (_hasCompany) ...[
            Text(
              'Qual o nome da sua empresa?',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _companyNameController,
              decoration: const InputDecoration(
                labelText: 'Nome da Empresa',
                hintText: 'Ex: Minha Empresa',
                prefixIcon: Icon(Icons.business),
              ),
              onChanged: (value) {
                setState(() => _companyName = value.trim());
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildModePage(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Modo Empreendedorismo',
            style: theme.textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Ative para ter acesso a recursos exclusivos de gestão empresarial.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),

          Card(
            color: _entrepreneurMode
                ? AppColors.primary.withOpacity(0.1)
                : null,
            child: SwitchListTile(
              title: const Text('Ativar Modo Empreendedorismo'),
              subtitle: const Text(
                'Gestão de empresas, reuniões e relatórios empresariais',
              ),
              value: _entrepreneurMode,
              onChanged: (value) {
                setState(() => _entrepreneurMode = value);
              },
              activeColor: AppColors.primary,
            ),
          ),
          const SizedBox(height: 24),

          // Lista de recursos
          if (_entrepreneurMode) ...[
            Text(
              'Recursos disponíveis:',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            _buildFeatureItem(
              icon: Icons.business,
              title: 'Gestão de Empresas',
              subtitle: 'Gerencie múltiplas empresas',
            ),
            _buildFeatureItem(
              icon: Icons.task_alt,
              title: 'Tarefas Empresariais',
              subtitle: 'Tarefas específicas de cada empresa',
            ),
            _buildFeatureItem(
              icon: Icons.calendar_today,
              title: 'Reuniões',
              subtitle: 'Agende e gerencie reuniões',
            ),
            _buildFeatureItem(
              icon: Icons.assessment,
              title: 'Relatórios',
              subtitle: 'Relatórios empresariais detalhados',
            ),
            _buildFeatureItem(
              icon: Icons.timeline,
              title: 'Timeline',
              subtitle: 'Visualize ações e histórico',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeCard({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required TimeOfDay? time,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label, style: theme.textTheme.titleMedium),
                    if (time != null)
                      Text(
                        time.format(context),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.textTheme.bodySmall?.color,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
