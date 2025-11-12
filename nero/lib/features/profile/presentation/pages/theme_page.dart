import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemePage extends ConsumerStatefulWidget {
  const ThemePage({super.key});

  @override
  ConsumerState<ThemePage> createState() => _ThemePageState();
}

class _ThemePageState extends ConsumerState<ThemePage> {
  String _selectedTheme = 'auto';

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
          'Tema',
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
          Text('Aparência do Aplicativo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1C1C1C), fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
            ),
            child: Column(
              children: [
                _buildThemeOption('Automático', 'auto', 'Segue o sistema', Icons.brightness_auto, isDark),
                Divider(height: 1, color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
                _buildThemeOption('Claro', 'light', 'Modo claro sempre ativo', Icons.light_mode, isDark),
                Divider(height: 1, color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
                _buildThemeOption('Escuro', 'dark', 'Modo escuro sempre ativo', Icons.dark_mode, isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption(String title, String value, String subtitle, IconData icon, bool isDark) {
    final isSelected = _selectedTheme == value;
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedTheme,
      onChanged: (v) => setState(() => _selectedTheme = v!),
      title: Text(title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1C), fontFamily: 'Inter', fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: TextStyle(color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F), fontFamily: 'Inter', fontSize: 12)),
      secondary: Icon(icon, color: isSelected ? const Color(0xFF0072FF) : (isDark ? const Color(0xFF757575) : const Color(0xFF8C8C8C))),
      activeColor: const Color(0xFF0072FF),
    );
  }
}
