import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/supabase_service.dart';
import '../../domain/models/user_profile.dart';
import '../../providers/profile_provider.dart';

/// Tela de Perfil do Usuário - Versão Nero
class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101010) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF101010) : const Color(0xFFFAFAFA),
        elevation: 0,
        title: Text(
          'Perfil',
          style: TextStyle(
            color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: false,
      ),
      body: profileAsync.when(
        data: (profile) => _buildProfileContent(context, ref, profile, isDark),
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
                'Erro ao carregar perfil',
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
              ElevatedButton(
                onPressed: () => ref.read(userProfileProvider.notifier).reload(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0072FF),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    bool isDark,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar e informações principais
          _buildUserSection(context, ref, profile, isDark),

          const SizedBox(height: 24),

          // Resumo e Atividade
          _buildSectionTitle('Resumo e Atividade', isDark),
          const SizedBox(height: 12),
          _buildActivitySummary(profile, isDark),

          const SizedBox(height: 24),

          // Conta e Configurações
          _buildSectionTitle('Conta e Configurações', isDark),
          const SizedBox(height: 12),
          _buildAccountSettings(context, ref, isDark),

          const SizedBox(height: 24),

          // Suporte e Sistema
          _buildSectionTitle('Suporte e Sistema', isDark),
          const SizedBox(height: 12),
          _buildSupportSection(context, ref, isDark),

          const SizedBox(height: 32),

          // Ações Rápidas
          _buildSectionTitle('Ações Rápidas', isDark),
          const SizedBox(height: 16),
          _buildQuickActions(context, ref, isDark),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // ========== SEÇÃO DO USUÁRIO ==========
  Widget _buildUserSection(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    bool isDark,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
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
        children: [
          // Avatar
          Center(
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFE8F0FF),
                  ),
                  child: profile.avatarUrl != null
                      ? ClipOval(
                          child: Image.network(
                            profile.avatarUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Center(
                          child: Text(
                            profile.getInitials(),
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0072FF),
                            ),
                          ),
                        ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _showAvatarOptions(context, ref),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0072FF),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Nome completo
          Text(
            profile.fullName ?? profile.getFirstName(),
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
              fontFamily: 'Poppins',
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 4),

          // Email
          Text(
            profile.email,
            style: TextStyle(
              fontSize: 14,
              color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
              fontFamily: 'Inter',
            ),
            textAlign: TextAlign.center,
          ),

          if (profile.bio != null && profile.bio!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              profile.bio!,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          const SizedBox(height: 20),

          // Campos de informação
          _buildInfoRow(
            'Telefone',
            profile.phone ?? 'Não informado',
            Icons.phone,
            isDark,
          ),

          if (profile.birthDate != null) ...[
            const SizedBox(height: 12),
            _buildInfoRow(
              'Data de Nascimento',
              DateFormat('dd/MM/yyyy').format(profile.birthDate!),
              Icons.cake,
              isDark,
            ),
          ],

          const SizedBox(height: 20),

          // Botão Editar Perfil
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () => context.push('/profile/edit'),
              icon: const Icon(Icons.edit, size: 18),
              label: const Text(
                'Editar Perfil',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Inter',
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0072FF),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF0072FF),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                fontFamily: 'Inter',
              ),
            ),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                fontFamily: 'Inter',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========== RESUMO E ATIVIDADE ==========
  Widget _buildActivitySummary(UserProfile profile, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
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
        children: [
          _buildStatItem(
            'Empresas vinculadas',
            '${profile.stats.totalCompanies}',
            Icons.business,
            const Color(0xFF9C27B0),
            isDark,
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            'Tarefas ativas',
            '${profile.stats.totalTasks - profile.stats.completedTasks}',
            Icons.task_alt,
            const Color(0xFF0072FF),
            isDark,
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            'Transações registradas',
            '${profile.stats.totalTransactions}',
            Icons.account_balance_wallet,
            const Color(0xFF43A047),
            isDark,
          ),
          const SizedBox(height: 16),
          _buildStatItem(
            'Sequência diária',
            '${profile.stats.dailyStreak} dias',
            Icons.local_fire_department,
            const Color(0xFFFF9800),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                  fontFamily: 'Inter',
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ========== CONTA E CONFIGURAÇÕES ==========
  Widget _buildAccountSettings(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
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
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.security,
            title: 'Segurança e Login',
            subtitle: 'Senha, 2FA e dispositivos',
            color: const Color(0xFFFF9800),
            isDark: isDark,
            onTap: () => context.push('/profile/security'),
          ),
          _buildDivider(isDark),
          _buildSettingsTile(
            context,
            icon: Icons.notifications,
            title: 'Notificações',
            subtitle: 'Alertas e lembretes',
            color: const Color(0xFF9C27B0),
            isDark: isDark,
            onTap: () => context.push('/profile/notifications'),
          ),
          _buildDivider(isDark),
          _buildSettingsTile(
            context,
            icon: Icons.palette,
            title: 'Tema',
            subtitle: 'Claro, escuro ou automático',
            color: const Color(0xFF0072FF),
            isDark: isDark,
            onTap: () => context.push('/profile/theme'),
          ),
          _buildDivider(isDark),
          _buildSettingsTile(
            context,
            icon: Icons.language,
            title: 'Idioma',
            subtitle: 'Português (PT-BR)',
            color: const Color(0xFF43A047),
            isDark: isDark,
            onTap: () => context.push('/profile/language'),
          ),
          _buildDivider(isDark),
          _buildSettingsTile(
            context,
            icon: Icons.integration_instructions,
            title: 'Integrações',
            subtitle: 'Google, Apple, GitHub',
            color: const Color(0xFF00ACC1),
            isDark: isDark,
            onTap: () => context.push('/profile/integrations'),
          ),
          _buildDivider(isDark),
          _buildSettingsTile(
            context,
            icon: Icons.backup,
            title: 'Backup e Sincronização',
            subtitle: 'Nuvem e exportação',
            color: const Color(0xFF7B1FA2),
            isDark: isDark,
            onTap: () => context.push('/profile/backup'),
          ),
        ],
      ),
    );
  }

  // ========== SUPORTE E SISTEMA ==========
  Widget _buildSupportSection(BuildContext context, WidgetRef ref, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
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
        children: [
          _buildSettingsTile(
            context,
            icon: Icons.help_outline,
            title: 'Central de Ajuda',
            subtitle: 'FAQ e documentação',
            color: const Color(0xFF0072FF),
            isDark: isDark,
            onTap: () => context.push('/profile/help'),
          ),
          _buildDivider(isDark),
          _buildSettingsTile(
            context,
            icon: Icons.feedback,
            title: 'Enviar Feedback',
            subtitle: 'Sugestões e melhorias',
            color: const Color(0xFF43A047),
            isDark: isDark,
            onTap: () => context.push('/profile/feedback'),
          ),
          _buildDivider(isDark),
          _buildSettingsTile(
            context,
            icon: Icons.info_outline,
            title: 'Versão do Aplicativo',
            subtitle: 'v1.0.0',
            color: const Color(0xFF9E9E9E),
            isDark: isDark,
            onTap: () => _showVersionDialog(context, isDark),
          ),
          _buildDivider(isDark),
          _buildSettingsTile(
            context,
            icon: Icons.policy,
            title: 'Privacidade e Termos',
            subtitle: 'Políticas e condições',
            color: const Color(0xFF616161),
            isDark: isDark,
            onTap: () => context.push('/profile/privacy'),
          ),
          _buildDivider(isDark),
          _buildSettingsTile(
            context,
            icon: Icons.logout,
            title: 'Sair da Conta',
            subtitle: 'Fazer logout',
            color: const Color(0xFFC62828),
            isDark: isDark,
            onTap: () => _showLogoutDialog(context, ref),
          ),
        ],
      ),
    );
  }

  // ========== AÇÕES RÁPIDAS ==========
  Widget _buildQuickActions(BuildContext context, WidgetRef ref, bool isDark) {
    return Wrap(
      alignment: WrapAlignment.spaceEvenly,
      runSpacing: 16,
      spacing: 16,
      children: [
        _buildQuickActionButton(
          'Editar\nPerfil',
          Icons.edit,
          const Color(0xFF0072FF),
          () => context.push('/profile/edit'),
          isDark,
        ),
        _buildQuickActionButton(
          'Alterar\nSenha',
          Icons.lock,
          const Color(0xFFFF9800),
          () => context.push('/profile/change-password'),
          isDark,
        ),
        _buildQuickActionButton(
          'Tema\nEscuro',
          Icons.dark_mode,
          const Color(0xFF9C27B0),
          () => context.push('/profile/theme'),
          isDark,
        ),
        _buildQuickActionButton(
          'Histórico\nLogin',
          Icons.history,
          const Color(0xFF00ACC1),
          () {
            // TODO: Mostrar histórico de login
          },
          isDark,
        ),
        _buildQuickActionButton(
          'Conectar\nGoogle',
          Icons.link,
          const Color(0xFF43A047),
          () => context.push('/profile/integrations'),
          isDark,
        ),
        _buildQuickActionButton(
          'Gerar\nBackup',
          Icons.backup,
          const Color(0xFF7B1FA2),
          () => context.push('/profile/backup'),
          isDark,
        ),
      ],
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isDark,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 90,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: color.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF1C1C1C),
                fontFamily: 'Inter',
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  // ========== WIDGETS AUXILIARES ==========
  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
        fontFamily: 'Poppins',
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required bool isDark,
    VoidCallback? onTap,
  }) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
          fontFamily: 'Inter',
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
          fontFamily: 'Inter',
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(
        height: 1,
        color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
      ),
    );
  }

  // ========== DIALOGS ==========
  void _showAvatarOptions(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Color(0xFF0072FF)),
              title: Text(
                'Tirar Foto',
                style: TextStyle(
                  color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                  fontFamily: 'Inter',
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final actions = ref.read(profileActionsProvider);
                final imageFile = await actions.pickImageFromCamera();
                if (imageFile != null) {
                  await ref.read(userProfileProvider.notifier).updateAvatar(imageFile);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Color(0xFF43A047)),
              title: Text(
                'Escolher da Galeria',
                style: TextStyle(
                  color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                  fontFamily: 'Inter',
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final actions = ref.read(profileActionsProvider);
                final imageFile = await actions.pickImageFromGallery();
                if (imageFile != null) {
                  await ref.read(userProfileProvider.notifier).updateAvatar(imageFile);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Color(0xFFC62828)),
              title: Text(
                'Remover Foto',
                style: TextStyle(
                  color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                  fontFamily: 'Inter',
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                await ref.read(userProfileProvider.notifier).removeAvatar();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Sair da Conta',
          style: TextStyle(
            color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Tem certeza que deseja sair da sua conta?',
          style: TextStyle(
            color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
            fontFamily: 'Inter',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await SupabaseService.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC62828),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Sair',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showVersionDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF0072FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.info_outline,
                color: Color(0xFF0072FF),
                size: 28,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Nero',
              style: TextStyle(
                color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVersionInfo('Versão', '1.0.0', Icons.tag, isDark),
            const SizedBox(height: 12),
            _buildVersionInfo('Build', '100', Icons.build, isDark),
            const SizedBox(height: 12),
            _buildVersionInfo('Plataforma', 'Flutter', Icons.flutter_dash, isDark),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF0072FF).withOpacity(0.1)
                    : const Color(0xFFE8F0FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '🎉 Novidades:\n• Módulo de perfil completo\n• Tema adaptativo\n• Estatísticas em tempo real',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                  fontFamily: 'Inter',
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Fechar',
              style: TextStyle(
                color: Color(0xFF0072FF),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionInfo(String label, String value, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: isDark ? const Color(0xFF757575) : const Color(0xFF8C8C8C),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
            fontFamily: 'Inter',
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
            fontFamily: 'Inter',
          ),
        ),
      ],
    );
  }
}
