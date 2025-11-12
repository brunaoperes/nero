import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FeedbackPage extends ConsumerStatefulWidget {
  const FeedbackPage({super.key});

  @override
  ConsumerState<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends ConsumerState<FeedbackPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedType = 'suggestion';

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

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
          'Enviar Feedback',
          style: TextStyle(
            color: isDark ? Colors.white : const Color(0xFF1C1C1C),
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('Tipo de Feedback', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1C1C1C), fontFamily: 'Poppins')),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
              ),
              child: Column(
                children: [
                  _buildTypeOption('💡', 'Sugestão', 'suggestion', isDark),
                  Divider(height: 1, color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
                  _buildTypeOption('🐛', 'Bug/Problema', 'bug', isDark),
                  Divider(height: 1, color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
                  _buildTypeOption('⭐', 'Elogio', 'praise', isDark),
                  Divider(height: 1, color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
                  _buildTypeOption('❓', 'Outro', 'other', isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Detalhes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1C1C1C), fontFamily: 'Poppins')),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1C)),
              decoration: InputDecoration(
                labelText: 'Título',
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.title, color: Color(0xFF0072FF)),
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _messageController,
              style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1C)),
              maxLines: 6,
              decoration: InputDecoration(
                labelText: 'Mensagem',
                filled: true,
                fillColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                alignLabelWithHint: true,
              ),
              validator: (v) => v?.isEmpty ?? true ? 'Obrigatório' : null,
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Feedback enviado com sucesso! Obrigado.'), backgroundColor: Color(0xFF43A047)),
                    );
                    Navigator.pop(context);
                  }
                },
                icon: const Icon(Icons.send),
                label: const Text('Enviar Feedback'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0072FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeOption(String emoji, String title, String value, bool isDark) {
    return RadioListTile<String>(
      value: value,
      groupValue: _selectedType,
      onChanged: (v) => setState(() => _selectedType = v!),
      title: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Text(title, style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1C1C1C), fontFamily: 'Inter', fontWeight: FontWeight.w600)),
        ],
      ),
      activeColor: const Color(0xFF0072FF),
    );
  }
}
