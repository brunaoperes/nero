import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/config/app_text_styles.dart';

/// Página de configurações de notificações
class NotificationSettingsPage extends ConsumerStatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  ConsumerState<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState
    extends ConsumerState<NotificationSettingsPage> {
  // Configurações de notificações
  bool _taskRemindersEnabled = true;
  bool _financeAlertsEnabled = true;
  bool _meetingRemindersEnabled = true;
  bool _aiRecommendationsEnabled = true;
  bool _dailySummaryEnabled = true;
  int _defaultReminderMinutes = 15;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _taskRemindersEnabled =
          prefs.getBool('task_reminders_enabled') ?? true;
      _financeAlertsEnabled =
          prefs.getBool('finance_alerts_enabled') ?? true;
      _meetingRemindersEnabled =
          prefs.getBool('meeting_reminders_enabled') ?? true;
      _aiRecommendationsEnabled =
          prefs.getBool('ai_recommendations_enabled') ?? true;
      _dailySummaryEnabled =
          prefs.getBool('daily_summary_enabled') ?? true;
      _defaultReminderMinutes =
          prefs.getInt('default_reminder_minutes') ?? 15;
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightBackground,
      appBar: AppBar(
        backgroundColor: AppColors.lightBackground,
        elevation: 0,
        title: Text(
          'Configurações de Notificações',
          style: AppTextStyles.headingH2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Seção: Tipos de Notificações
          _buildSectionHeader('Tipos de Notificações'),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.task_alt,
            iconColor: AppColors.primary,
            title: 'Lembretes de Tarefas',
            subtitle: 'Receba lembretes das suas tarefas agendadas',
            value: _taskRemindersEnabled,
            onChanged: (value) {
              setState(() => _taskRemindersEnabled = value);
              _saveSetting('task_reminders_enabled', value);
            },
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.attach_money,
            iconColor: AppColors.warning,
            title: 'Alertas Financeiros',
            subtitle: 'Notificações sobre gastos e orçamentos',
            value: _financeAlertsEnabled,
            onChanged: (value) {
              setState(() => _financeAlertsEnabled = value);
              _saveSetting('finance_alerts_enabled', value);
            },
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.event,
            iconColor: AppColors.accent,
            title: 'Lembretes de Reuniões',
            subtitle: 'Seja avisado antes das reuniões',
            value: _meetingRemindersEnabled,
            onChanged: (value) {
              setState(() => _meetingRemindersEnabled = value);
              _saveSetting('meeting_reminders_enabled', value);
            },
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.lightbulb_outline,
            iconColor: AppColors.success,
            title: 'Recomendações da IA',
            subtitle: 'Sugestões personalizadas do assistente',
            value: _aiRecommendationsEnabled,
            onChanged: (value) {
              setState(() => _aiRecommendationsEnabled = value);
              _saveSetting('ai_recommendations_enabled', value);
            },
          ),
          const SizedBox(height: 12),
          _buildSettingCard(
            icon: Icons.summarize,
            iconColor: AppColors.info,
            title: 'Resumo Diário',
            subtitle: 'Receba um resumo do dia às 20h',
            value: _dailySummaryEnabled,
            onChanged: (value) {
              setState(() => _dailySummaryEnabled = value);
              _saveSetting('daily_summary_enabled', value);
            },
          ),

          const SizedBox(height: 32),

          // Seção: Tempo de Lembrete Padrão
          _buildSectionHeader('Tempo de Lembrete Padrão'),
          const SizedBox(height: 12),
          _buildReminderTimeCard(),

          const SizedBox(height: 32),

          // Seção: Ações
          _buildSectionHeader('Ações'),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.refresh,
            title: 'Testar Notificação',
            onTap: () async {
              // TODO: Enviar notificação de teste
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notificação de teste enviada!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
          const SizedBox(height: 12),
          _buildActionButton(
            icon: Icons.delete_sweep,
            title: 'Limpar Notificações Lidas',
            onTap: () async {
              // TODO: Limpar notificações lidas
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notificações lidas removidas!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildSettingCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildReminderTimeCard() {
    final options = [5, 10, 15, 30, 60]; // minutos

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lembrar com antecedência de:',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((minutes) {
              final isSelected = _defaultReminderMinutes == minutes;
              return ChoiceChip(
                label: Text(_formatMinutes(minutes)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _defaultReminderMinutes = minutes);
                    _saveSetting('default_reminder_minutes', minutes);
                  }
                },
                selectedColor: AppColors.primary,
                backgroundColor: AppColors.lightBackground,
                labelStyle: AppTextStyles.bodySmall.copyWith(
                  color: isSelected
                      ? Colors.white
                      : AppColors.textPrimary,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  String _formatMinutes(int minutes) {
    if (minutes < 60) {
      return '$minutes min';
    } else {
      final hours = minutes ~/ 60;
      return '$hours hora${hours > 1 ? "s" : ""}';
    }
  }
}
