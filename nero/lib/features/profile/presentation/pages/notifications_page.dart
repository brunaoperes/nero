import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  bool _pushEnabled = true;
  bool _emailEnabled = true;
  bool _taskReminders = true;
  bool _financeAlerts = true;
  bool _companyUpdates = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101010) : const Color(0xFFFAFAFA),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF101010) : const Color(0xFFFAFAFA),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: isDark ? Colors.white : const Color(0xFF1C1C1C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notificações',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1C1C1C),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSection(
            'Canais de Notificação',
            [
              _buildSwitch('Push Notifications', _pushEnabled, Icons.notifications, (v) => setState(() => _pushEnabled = v), isDark),
              _buildSwitch('Email Notifications', _emailEnabled, Icons.email, (v) => setState(() => _emailEnabled = v), isDark),
            ],
            isDark,
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Tipos de Alertas',
            [
              _buildSwitch('Lembretes de Tarefas', _taskReminders, Icons.task_alt, (v) => setState(() => _taskReminders = v), isDark),
              _buildSwitch('Alertas Financeiros', _financeAlerts, Icons.attach_money, (v) => setState(() => _financeAlerts = v), isDark),
              _buildSwitch('Atualizações de Empresas', _companyUpdates, Icons.business, (v) => setState(() => _companyUpdates = v), isDark),
            ],
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1C1C1C), fontFamily: 'Poppins')),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitch(String title, bool value, IconData icon, Function(bool) onChanged, bool isDark) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF0072FF)),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1C), fontFamily: 'Inter')),
      trailing: Switch(value: value, onChanged: onChanged, activeColor: const Color(0xFF0072FF)),
    );
  }
}
