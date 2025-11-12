import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../providers/profile_provider.dart';
import '../../../finance/presentation/pages/manage_categories_accounts_page.dart';

/// Tela de Configurações
class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider) == ThemeMode.dark;
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: profileAsync.when(
        data: (profile) => _buildSettings(context, ref, profile, isDark),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Erro ao carregar configurações')),
      ),
    );
  }

  Widget _buildSettings(context, ref, profile, bool isDark) {
    final settings = profile.settings;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // APARÊNCIA
        _buildSectionTitle('Aparência', isDark),
        const SizedBox(height: 12),
        Container(
          decoration: _cardDecoration(isDark),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Tema Escuro'),
                subtitle: const Text('Alternar entre tema claro e escuro'),
                value: isDark,
                activeColor: AppColors.primary,
                onChanged: (_) => ref.read(themeProvider.notifier).toggleTheme(),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // ACESSIBILIDADE
        _buildSectionTitle('Acessibilidade', isDark),
        const SizedBox(height: 12),
        Container(
          decoration: _cardDecoration(isDark),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.info.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.accessibility, color: AppColors.info),
            ),
            title: const Text('Configurações de Acessibilidade'),
            subtitle: const Text('Alto contraste, texto grande e mais'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () => context.push('/settings/accessibility'),
          ),
        ),

        const SizedBox(height: 24),

        // FINANÇAS
        _buildSectionTitle('Finanças', isDark),
        const SizedBox(height: 12),
        Container(
          decoration: _cardDecoration(isDark),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.category, color: AppColors.primary),
            ),
            title: const Text('Categorias e Contas'),
            subtitle: const Text('Gerenciar categorias e contas bancárias'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 18),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManageCategoriesAccountsPage(),
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 24),

        // NOTIFICAÇÕES
        _buildSectionTitle('Notificações', isDark),
        const SizedBox(height: 12),
        Container(
          decoration: _cardDecoration(isDark),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Push Notifications'),
                subtitle: const Text('Receber notificações push'),
                value: settings.pushNotificationsEnabled,
                activeColor: AppColors.primary,
                onChanged: (value) => _updateSettings(
                  ref,
                  profile,
                  settings.copyWith(pushNotificationsEnabled: value),
                ),
              ),
              _buildDivider(isDark),
              SwitchListTile(
                title: const Text('Email Notifications'),
                subtitle: const Text('Receber notificações por email'),
                value: settings.emailNotificationsEnabled,
                activeColor: AppColors.primary,
                onChanged: (value) => _updateSettings(
                  ref,
                  profile,
                  settings.copyWith(emailNotificationsEnabled: value),
                ),
              ),
              _buildDivider(isDark),
              SwitchListTile(
                title: const Text('Lembretes de Tarefas'),
                subtitle: const Text('Alertas para tarefas pendentes'),
                value: settings.taskRemindersEnabled,
                activeColor: AppColors.primary,
                onChanged: (value) => _updateSettings(
                  ref,
                  profile,
                  settings.copyWith(taskRemindersEnabled: value),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),

        // PRIVACIDADE
        _buildSectionTitle('Privacidade', isDark),
        const SizedBox(height: 12),
        Container(
          decoration: _cardDecoration(isDark),
          child: Column(
            children: [
              SwitchListTile(
                title: const Text('Backup Automático'),
                subtitle: const Text('Backup diário dos seus dados'),
                value: settings.autoBackupEnabled,
                activeColor: AppColors.primary,
                onChanged: (value) => _updateSettings(
                  ref,
                  profile,
                  settings.copyWith(autoBackupEnabled: value),
                ),
              ),
              _buildDivider(isDark),
              SwitchListTile(
                title: const Text('Sincronização Automática'),
                subtitle: const Text('Sincronizar dados automaticamente'),
                value: settings.autoSyncEnabled,
                activeColor: AppColors.primary,
                onChanged: (value) => _updateSettings(
                  ref,
                  profile,
                  settings.copyWith(autoSyncEnabled: value),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
      ],
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppColors.darkCard : AppColors.lightCard,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: isDark ? AppColors.darkBorder : AppColors.grey300,
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: isDark ? AppColors.darkBorder : AppColors.grey300,
      ),
    );
  }

  void _updateSettings(ref, profile, newSettings) {
    ref.read(userProfileProvider.notifier).updateSettings(newSettings);
  }
}
