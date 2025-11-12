import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/supabase_service.dart';

/// Página de Segurança e Login
class SecurityPage extends ConsumerStatefulWidget {
  const SecurityPage({super.key});

  @override
  ConsumerState<SecurityPage> createState() => _SecurityPageState();
}

class _SecurityPageState extends ConsumerState<SecurityPage> {
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = SupabaseService.currentUser;

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
          'Segurança e Login',
          style: TextStyle(
            color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0072FF)))
          : SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informações da conta
                  _buildSectionTitle('Informações da Conta', isDark),
                  const SizedBox(height: 12),
                  _buildAccountInfo(user, isDark),

                  const SizedBox(height: 24),

                  // Senha e Autenticação
                  _buildSectionTitle('Senha e Autenticação', isDark),
                  const SizedBox(height: 12),
                  _buildPasswordSection(context, user, isDark),

                  const SizedBox(height: 24),

                  // Autenticação de dois fatores
                  _buildSectionTitle('Autenticação de Dois Fatores', isDark),
                  const SizedBox(height: 12),
                  _build2FASection(context, isDark),

                  const SizedBox(height: 24),

                  // Dispositivos e Sessões
                  _buildSectionTitle('Dispositivos Conectados', isDark),
                  const SizedBox(height: 12),
                  _buildDevicesSection(context, isDark),

                  const SizedBox(height: 24),

                  // Histórico de atividades
                  _buildSectionTitle('Atividade Recente', isDark),
                  const SizedBox(height: 12),
                  _buildActivitySection(isDark),

                  const SizedBox(height: 32),

                  // Ações de segurança
                  _buildDangerZone(context, isDark),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

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

  Widget _buildAccountInfo(dynamic user, bool isDark) {
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
          _buildInfoRow(
            'Email',
            user?.email ?? 'Não disponível',
            Icons.email,
            const Color(0xFF0072FF),
            isDark,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'ID do Usuário',
            user?.id ?? 'Não disponível',
            Icons.fingerprint,
            const Color(0xFF9C27B0),
            isDark,
            isId: true,
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            'Criado em',
            user?.createdAt != null
                ? DateFormat('dd/MM/yyyy • HH:mm').format(
                    user!.createdAt is String
                        ? DateTime.parse(user.createdAt)
                        : user.createdAt as DateTime
                  )
                : 'Não disponível',
            Icons.calendar_today,
            const Color(0xFF43A047),
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    String label,
    String value,
    IconData icon,
    Color color,
    bool isDark, {
    bool isId = false,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
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
              const SizedBox(height: 2),
              Text(
                isId && value.length > 20
                    ? '${value.substring(0, 8)}...${value.substring(value.length - 8)}'
                    : value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSection(BuildContext context, dynamic user, bool isDark) {
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
          _buildSecurityTile(
            context,
            icon: Icons.lock_outline,
            title: 'Alterar Senha',
            subtitle: 'Atualize sua senha de acesso',
            color: const Color(0xFFFF9800),
            isDark: isDark,
            onTap: () => context.push('/profile/change-password'),
          ),
          _buildDivider(isDark),
          _buildSecurityTile(
            context,
            icon: Icons.email_outlined,
            title: 'Alterar Email',
            subtitle: user?.email ?? 'Não disponível',
            color: const Color(0xFF0072FF),
            isDark: isDark,
            onTap: () => _showChangeEmailDialog(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _build2FASection(BuildContext context, bool isDark) {
    const is2FAEnabled = false; // TODO: Verificar se 2FA está ativo

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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF43A047).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.verified_user,
              color: Color(0xFF43A047),
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Autenticação de Dois Fatores',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Desativada - Recomendamos ativar',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: is2FAEnabled,
            onChanged: (value) {
              _show2FADialog(context, isDark, value);
            },
            activeColor: const Color(0xFF43A047),
          ),
        ],
      ),
    );
  }

  Widget _buildDevicesSection(BuildContext context, bool isDark) {
    // Dispositivo atual (exemplo)
    final currentDevice = {
      'name': 'Dispositivo Atual',
      'type': 'Mobile',
      'lastActive': DateTime.now(),
      'location': 'Brasil',
    };

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
          _buildDeviceTile(currentDevice, true, isDark),
          _buildDivider(isDark),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showDevicesDialog(context, isDark);
                },
                style: OutlinedButton.styleFrom(
                  side: BorderSide(
                    color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Ver Todos os Dispositivos',
                  style: TextStyle(
                    color: Color(0xFF0072FF),
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceTile(Map<String, dynamic> device, bool isCurrent, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0072FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              device['type'] == 'Mobile' ? Icons.smartphone : Icons.computer,
              color: const Color(0xFF0072FF),
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      device['name'],
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                        fontFamily: 'Inter',
                      ),
                    ),
                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF43A047).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'Atual',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF43A047),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${device['location']} • ${_formatTime(device['lastActive'])}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivitySection(bool isDark) {
    final activities = [
      {
        'action': 'Login realizado',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'device': 'Mobile',
        'location': 'São Paulo, BR',
      },
      {
        'action': 'Perfil atualizado',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'device': 'Web',
        'location': 'São Paulo, BR',
      },
      {
        'action': 'Senha alterada',
        'time': DateTime.now().subtract(const Duration(days: 7)),
        'device': 'Mobile',
        'location': 'Rio de Janeiro, BR',
      },
    ];

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
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: activities.length,
        separatorBuilder: (context, index) => _buildDivider(isDark),
        itemBuilder: (context, index) {
          final activity = activities[index];
          return _buildActivityTile(activity, isDark);
        },
      ),
    );
  }

  Widget _buildActivityTile(Map<String, dynamic> activity, bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF9C27B0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.history,
              color: Color(0xFF9C27B0),
              size: 20,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['action'],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${activity['device']} • ${activity['location']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
          Text(
            _formatTime(activity['time']),
            style: TextStyle(
              fontSize: 11,
              color: isDark ? const Color(0xFF757575) : const Color(0xFF8C8C8C),
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFFE53935).withOpacity(0.1)
            : const Color(0xFFFFEBEE),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE53935).withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber, color: Color(0xFFE53935), size: 24),
              const SizedBox(width: 12),
              Text(
                'Zona de Perigo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Ações irreversíveis que afetam permanentemente sua conta.',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _showDeleteAccountDialog(context, isDark),
              icon: const Icon(Icons.delete_forever, size: 20),
              label: const Text('Excluir Conta Permanentemente'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFFE53935),
                side: const BorderSide(color: Color(0xFFE53935)),
                padding: const EdgeInsets.symmetric(vertical: 14),
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

  Widget _buildSecurityTile(
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

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'agora';
    } else if (difference.inHours < 1) {
      return 'há ${difference.inMinutes}min';
    } else if (difference.inDays < 1) {
      return 'há ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'há ${difference.inDays}d';
    } else {
      return DateFormat('dd/MM/yy').format(time);
    }
  }

  // ===== DIALOGS =====

  void _showChangeEmailDialog(BuildContext context, bool isDark) {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Alterar Email',
          style: TextStyle(
            color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Digite seu novo endereço de email. Você receberá um link de confirmação.',
              style: TextStyle(
                color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
                fontFamily: 'Inter',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: TextStyle(
                color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
              ),
              decoration: InputDecoration(
                labelText: 'Novo Email',
                prefixIcon: const Icon(Icons.email, color: Color(0xFF0072FF)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancelar',
              style: TextStyle(
                color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar alteração de email
              Navigator.pop(context);
              _showSuccessSnackBar(context, 'Link de confirmação enviado!');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0072FF),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _show2FADialog(BuildContext context, bool isDark, bool enable) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          enable ? 'Ativar 2FA' : 'Desativar 2FA',
          style: TextStyle(
            color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          enable
              ? 'A autenticação de dois fatores adiciona uma camada extra de segurança à sua conta.'
              : 'Tem certeza que deseja desativar a autenticação de dois fatores?',
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
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar 2FA
              Navigator.pop(context);
              _showSuccessSnackBar(
                context,
                enable ? '2FA ativado com sucesso!' : '2FA desativado.',
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF43A047),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(enable ? 'Ativar' : 'Desativar'),
          ),
        ],
      ),
    );
  }

  void _showDevicesDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Dispositivos Conectados',
          style: TextStyle(
            color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Text(
            'Apenas o dispositivo atual está conectado.',
            style: TextStyle(
              color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
              fontFamily: 'Inter',
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fechar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.warning_amber, color: Color(0xFFE53935)),
            const SizedBox(width: 12),
            Text(
              'Excluir Conta',
              style: TextStyle(
                color: isDark ? const Color(0xFFFFFFFF) : const Color(0xFF1C1C1C),
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          'Esta ação é IRREVERSÍVEL. Todos os seus dados serão permanentemente deletados, incluindo:\n\n• Perfil e configurações\n• Empresas e tarefas\n• Transações financeiras\n• Histórico de atividades\n\nTem certeza absoluta?',
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
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implementar exclusão de conta
              Navigator.pop(context);
              _showErrorSnackBar(context, 'Funcionalidade em desenvolvimento');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE53935),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Sim, Excluir Tudo'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF43A047),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFE53935),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
