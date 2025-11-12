import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/presentation/main_shell.dart';
import '../../../../core/services/supabase_service.dart';
import '../../../../shared/models/company_model.dart';
import '../providers/company_providers.dart';

class CompanyFormPage extends ConsumerStatefulWidget {
  final CompanyModel? company;

  const CompanyFormPage({super.key, this.company});

  @override
  ConsumerState<CompanyFormPage> createState() => _CompanyFormPageState();
}

class _CompanyFormPageState extends ConsumerState<CompanyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _cnpjController = TextEditingController();

  String _selectedType = 'small';
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      _nameController.text = widget.company!.name;
      _descriptionController.text = widget.company!.description ?? '';
      _cnpjController.text = widget.company!.cnpj ?? '';
      _selectedType = widget.company!.type;
      _isActive = widget.company!.isActive;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _cnpjController.dispose();
    super.dispose();
  }

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = SupabaseService.currentUser!.id;

      final company = CompanyModel(
        id: widget.company?.id ?? '', // Será ignorado pelo banco ao criar
        userId: userId,
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        type: _selectedType,
        cnpj: _cnpjController.text.trim().isEmpty ? null : _cnpjController.text.trim(),
        logoUrl: widget.company?.logoUrl,
        isActive: _isActive,
        metadata: widget.company?.metadata,
        createdAt: widget.company?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      bool success;
      if (widget.company == null) {
        success = await ref.read(companiesListProvider.notifier).createCompany(company);
      } else {
        success = await ref.read(companiesListProvider.notifier).updateCompany(company);
      }

      if (mounted) {
        if (success) {
          Navigator.of(context).pop(true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                widget.company == null
                    ? 'Empresa criada com sucesso!'
                    : 'Empresa atualizada com sucesso!',
              ),
              backgroundColor: const Color(0xFF009E0F),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Erro ao salvar empresa'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close,
            color: isDark ? const Color(0xFFEAEAEA) : AppColors.lightIcon,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.company == null ? 'Nova Empresa' : 'Editar Empresa',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFEAEAEA) : AppColors.lightText,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome *
                  TextFormField(
                    controller: _nameController,
                    style: TextStyle(
                      color: isDark ? const Color(0xFFEAEAEA) : AppColors.lightText,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                    decoration: InputDecoration(
                      labelText: 'Nome da Empresa *',
                      hintText: 'Ex.: Minha Empresa LTDA',
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF3A3A3A)
                              : AppColors.lightBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF3A3A3A)
                              : AppColors.lightBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'O nome é obrigatório';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Descrição
                  TextFormField(
                    controller: _descriptionController,
                    style: TextStyle(
                      color: isDark ? const Color(0xFFEAEAEA) : AppColors.lightText,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Descrição',
                      hintText: 'Detalhes sobre a empresa…',
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF3A3A3A)
                              : AppColors.lightBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF3A3A3A)
                              : AppColors.lightBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // CNPJ
                  TextFormField(
                    controller: _cnpjController,
                    style: TextStyle(
                      color: isDark ? const Color(0xFFEAEAEA) : AppColors.lightText,
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'CNPJ',
                      hintText: '00.000.000/0000-00',
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF3A3A3A)
                              : AppColors.lightBorder,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? const Color(0xFF3A3A3A)
                              : AppColors.lightBorder,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tipo
                  Text(
                    'Tipo de Empresa',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFEAEAEA) : AppColors.lightText,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _TypeButton(
                          label: 'MEI',
                          selected: _selectedType == 'mei',
                          color: const Color(0xFFFFD700),
                          onTap: () => setState(() => _selectedType = 'mei'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TypeButton(
                          label: 'Pequena',
                          selected: _selectedType == 'small',
                          color: AppColors.primary,
                          onTap: () => setState(() => _selectedType = 'small'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _TypeButton(
                          label: 'Serviços',
                          selected: _selectedType == 'services',
                          color: const Color(0xFF9C27B0),
                          onTap: () => setState(() => _selectedType = 'services'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Status
                  SwitchListTile(
                    title: Text(
                      'Empresa Ativa',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? const Color(0xFFEAEAEA) : AppColors.lightText,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    subtitle: Text(
                      _isActive ? 'Empresa em operação' : 'Empresa inativa',
                      style: TextStyle(
                        fontSize: 12,
                        color: (isDark
                                ? AppColors.textSecondary
                                : AppColors.lightTextSecondary)
                            .withOpacity(0.7),
                        fontFamily: 'Inter',
                      ),
                    ),
                    value: _isActive,
                    onChanged: (value) => setState(() => _isActive = value),
                    activeColor: const Color(0xFF009E0F),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 24),

                  // Botão Salvar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveCompany,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0072FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              widget.company == null ? 'Criar Empresa' : 'Salvar Alterações',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'Poppins',
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _TypeButton({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? color.withOpacity(0.2)
              : (isDark ? AppColors.darkSurface : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected
                ? color
                : (isDark ? const Color(0xFF3A3A3A) : AppColors.lightBorder),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
              color: selected
                  ? color
                  : (isDark ? AppColors.textSecondary : AppColors.lightTextSecondary),
              fontFamily: 'Inter',
            ),
          ),
        ),
      ),
    );
  }
}
