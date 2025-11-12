import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HelpCenterPage extends ConsumerWidget {
  const HelpCenterPage({super.key});

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
          'Central de Ajuda',
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
          _buildSection('Começando', [
            _buildFAQItem('Como criar minha primeira empresa?', 'Acesse o menu Empresas e clique no botão "+" para adicionar uma nova empresa. Preencha os dados básicos e salve.', isDark),
            _buildFAQItem('Como adicionar tarefas?', 'Vá para a aba Tarefas e toque no botão flutuante "+". Defina título, descrição, prazo e prioridade.', isDark),
            _buildFAQItem('Como registrar transações?', 'Na seção Finanças, clique em "Nova Transação" e escolha entre receita ou despesa. Preencha os valores e categorias.', isDark),
          ], isDark),
          const SizedBox(height: 24),
          _buildSection('Recursos', [
            _buildFAQItem('O que é a IA do Nero?', 'Nero usa inteligência artificial para analisar suas finanças e fornecer insights personalizados sobre seus gastos e receitas.', isDark),
            _buildFAQItem('Como funciona o Open Finance?', 'Conecte suas contas bancárias de forma segura para importar transações automaticamente via Open Finance.', isDark),
            _buildFAQItem('Posso exportar meus dados?', 'Sim! Em Perfil > Backup, você pode exportar todos os seus dados em formato CSV ou JSON.', isDark),
          ], isDark),
          const SizedBox(height: 24),
          _buildSection('Segurança', [
            _buildFAQItem('Meus dados estão seguros?', 'Sim! Usamos criptografia de ponta a ponta e seus dados são armazenados em servidores seguros no Supabase.', isDark),
            _buildFAQItem('Como ativar autenticação de dois fatores?', 'Vá em Perfil > Segurança e Login > Autenticação de Dois Fatores e ative o switch.', isDark),
          ], isDark),
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
                const Icon(Icons.support_agent, color: Color(0xFF0072FF), size: 48),
                const SizedBox(height: 12),
                Text('Precisa de mais ajuda?', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1C1C1C), fontFamily: 'Poppins')),
                const SizedBox(height: 8),
                Text('Entre em contato com nosso suporte', style: TextStyle(color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F), fontFamily: 'Inter')),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.email, size: 18),
                  label: const Text('suporte@nero.app'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0072FF),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items, bool isDark) {
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
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildFAQItem(String question, String answer, bool isDark) {
    return ExpansionTile(
      title: Text(question, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white : const Color(0xFF1C1C1C), fontFamily: 'Inter')),
      iconColor: const Color(0xFF0072FF),
      collapsedIconColor: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(answer, style: TextStyle(fontSize: 13, color: isDark ? const Color(0xFFBDBDBD) : const Color(0xFF5F5F5F), fontFamily: 'Inter', height: 1.5)),
        ),
      ],
    );
  }
}
