import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class BackupPage extends ConsumerStatefulWidget {
  const BackupPage({super.key});

  @override
  ConsumerState<BackupPage> createState() => _BackupPageState();
}

class _BackupPageState extends ConsumerState<BackupPage> {
  bool _autoBackup = true;

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
          'Backup e Sincronização',
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup, color: Color(0xFF0072FF)),
                  title: Text('Backup Automático', style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1C), fontFamily: 'Inter', fontWeight: FontWeight.w600)),
                  subtitle: Text('Sincronizar dados na nuvem', style: TextStyle(color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F), fontFamily: 'Inter', fontSize: 12)),
                  trailing: Switch(value: _autoBackup, onChanged: (v) => setState(() => _autoBackup = v), activeColor: const Color(0xFF0072FF)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.cloud_upload),
              label: const Text('Fazer Backup Agora'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0072FF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.file_download),
              label: const Text('Exportar Dados'),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF0072FF),
                side: const BorderSide(color: Color(0xFF0072FF)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
