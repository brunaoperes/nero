import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PrivacyPolicyPage extends ConsumerWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'Privacidade e Termos',
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
          _buildPolicySection(
            'Política de Privacidade',
            'Última atualização: ${DateTime.now().year}',
            [
              'O Nero está comprometido em proteger sua privacidade. Coletamos apenas as informações necessárias para fornecer nossos serviços.',
              'Seus dados financeiros são criptografados e armazenados de forma segura. Nunca compartilhamos suas informações com terceiros sem seu consentimento.',
              'Você tem controle total sobre seus dados e pode exportá-los ou deletá-los a qualquer momento.',
            ],
            isDark,
          ),
          const SizedBox(height: 24),
          _buildPolicySection(
            'Termos de Uso',
            'Última atualização: ${DateTime.now().year}',
            [
              'Ao usar o Nero, você concorda em usar o aplicativo de forma responsável e em conformidade com as leis aplicáveis.',
              'O Nero é fornecido "como está" e não nos responsabilizamos por perdas ou danos decorrentes do uso do aplicativo.',
              'Reservamo-nos o direito de modificar estes termos a qualquer momento. Alterações significativas serão notificadas.',
            ],
            isDark,
          ),
          const SizedBox(height: 24),
          _buildPolicySection(
            'Coleta de Dados',
            'O que coletamos',
            [
              '• Informações de conta (email, nome)',
              '• Dados financeiros que você registra',
              '• Informações de uso do aplicativo',
              '• Dados técnicos (tipo de dispositivo, versão do sistema)',
            ],
            isDark,
          ),
          const SizedBox(height: 24),
          _buildPolicySection(
            'Seus Direitos',
            'Você tem direito a',
            [
              '• Acessar todos os seus dados',
              '• Corrigir informações incorretas',
              '• Exportar seus dados',
              '• Deletar sua conta e dados',
              '• Revogar permissões',
            ],
            isDark,
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF0072FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF0072FF).withOpacity(0.3)),
            ),
            child: Column(
              children: [
                const Icon(Icons.email, color: Color(0xFF0072FF), size: 32),
                const SizedBox(height: 12),
                Text('Dúvidas sobre privacidade?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1C1C1C), fontFamily: 'Poppins')),
                const SizedBox(height: 8),
                Text('Entre em contato: privacidade@nero.app', style: TextStyle(color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F), fontFamily: 'Inter', fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPolicySection(String title, String subtitle, List<String> items, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1C1C1C), fontFamily: 'Poppins')),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F), fontFamily: 'Inter')),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(item, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F), fontFamily: 'Inter', height: 1.5)),
          )),
        ],
      ),
    );
  }
}
