import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LanguagePage extends ConsumerStatefulWidget {
  const LanguagePage({super.key});

  @override
  ConsumerState<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends ConsumerState<LanguagePage> {
  String _selectedLang = 'pt-BR';

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
          'Idioma',
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
          Text('Idioma do Aplicativo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1C1C1C), fontFamily: 'Poppins')),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
            ),
            child: Column(
              children: [
                _buildLangOption('🇧🇷', 'Português (Brasil)', 'pt-BR', isDark),
                Divider(height: 1, color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
                _buildLangOption('🇺🇸', 'English (US)', 'en-US', isDark),
                Divider(height: 1, color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
                _buildLangOption('🇪🇸', 'Español', 'es-ES', isDark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLangOption(String flag, String title, String value, bool isDark) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedLang,
      onChanged: (v) => setState(() => _selectedLang = v!),
      title: Row(
        children: [
          Text(flag, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1C), fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        ],
      ),
      activeColor: const Color(0xFF0072FF),
    );
  }
}
