# 🏢 MÓDULO DE EMPRESAS - UI COMPLETA

Copie cada seção para o arquivo indicado.

---

## 📄 COMPANY HOME PAGE (Atualizada)

**Arquivo**: `lib/features/company/presentation/pages/company_home_page.dart`

```dart
// lib/features/company/presentation/pages/company_home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/company_entity.dart';
import '../providers/company_providers.dart';
import '../widgets/company_card.dart';
import 'company_detail_page.dart';
import 'company_form_page.dart';

class CompanyHomePage extends ConsumerWidget {
  const CompanyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companiesAsync = ref.watch(companiesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Empresas',
              style: AppTextStyles.headingH2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              'Gerencie seus negócios',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: companiesAsync.when(
        data: (companies) {
          if (companies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.business,
                    size: 80,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Nenhuma empresa cadastrada',
                    style: AppTextStyles.headingH3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cadastre sua primeira empresa',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _navigateToForm(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('Criar Empresa'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final activeCompanies = companies.where((c) => c.status == CompanyStatus.active).toList();
          final otherCompanies = companies.where((c) => c.status != CompanyStatus.active).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (activeCompanies.isNotEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Empresas Ativas',
                      style: AppTextStyles.headingH3.copyWith(
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      '${activeCompanies.length}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...activeCompanies.map((company) {
                  return CompanyCard(
                    company: company,
                    onTap: () => _navigateToDetail(context, ref, company),
                  );
                }),
              ],
              
              if (otherCompanies.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Outras Empresas',
                  style: AppTextStyles.headingH3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ...otherCompanies.map((company) {
                  return CompanyCard(
                    company: company,
                    onTap: () => _navigateToDetail(context, ref, company),
                  );
                }),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppColors.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Erro ao carregar empresas',
                style: AppTextStyles.bodyLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToForm(context, ref),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Nova Empresa',
          style: AppTextStyles.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _navigateToForm(BuildContext context, WidgetRef ref) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CompanyFormPage()),
    );

    if (result == true) {
      ref.invalidate(companiesProvider);
    }
  }

  void _navigateToDetail(BuildContext context, WidgetRef ref, CompanyEntity company) async {
    ref.read(selectedCompanyIdProvider.notifier).state = company.id;
    
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CompanyDetailPage(company: company),
      ),
    );

    ref.invalidate(companiesProvider);
  }
}
```

---

## 📄 COMPANY FORM PAGE

**Arquivo**: `lib/features/company/presentation/pages/company_form_page.dart`

```dart
// lib/features/company/presentation/pages/company_form_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../domain/entities/company_entity.dart';
import '../providers/company_providers.dart';

class CompanyFormPage extends ConsumerStatefulWidget {
  final CompanyEntity? company;

  const CompanyFormPage({super.key, this.company});

  @override
  ConsumerState<CompanyFormPage> createState() => _CompanyFormPageState();
}

class _CompanyFormPageState extends ConsumerState<CompanyFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _monthlyRevenueController = TextEditingController();
  final _employeeCountController = TextEditingController();

  CompanyType _type = CompanyType.individual;
  CompanyStatus _status = CompanyStatus.active;
  DateTime _foundedDate = DateTime.now();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.company != null) {
      _nameController.text = widget.company!.name;
      _cnpjController.text = widget.company!.cnpj ?? '';
      _emailController.text = widget.company!.email ?? '';
      _phoneController.text = widget.company!.phone ?? '';
      _websiteController.text = widget.company!.website ?? '';
      _descriptionController.text = widget.company!.description ?? '';
      _addressController.text = widget.company!.address ?? '';
      _cityController.text = widget.company!.city ?? '';
      _stateController.text = widget.company!.state ?? '';
      _zipCodeController.text = widget.company!.zipCode ?? '';
      _monthlyRevenueController.text = widget.company!.monthlyRevenue?.toString() ?? '';
      _employeeCountController.text = widget.company!.employeeCount?.toString() ?? '';
      _type = widget.company!.type;
      _status = widget.company!.status;
      _foundedDate = widget.company!.foundedDate;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cnpjController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _monthlyRevenueController.dispose();
    _employeeCountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _foundedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _foundedDate = picked);
    }
  }

  Future<void> _saveCompany() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      final company = CompanyEntity(
        id: widget.company?.id ?? '',
        userId: userId,
        name: _nameController.text.trim(),
        cnpj: _cnpjController.text.trim().isEmpty ? null : _cnpjController.text.trim(),
        email: _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
        website: _websiteController.text.trim().isEmpty ? null : _websiteController.text.trim(),
        description: _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        type: _type,
        address: _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
        state: _stateController.text.trim().isEmpty ? null : _stateController.text.trim(),
        zipCode: _zipCodeController.text.trim().isEmpty ? null : _zipCodeController.text.trim(),
        logo: widget.company?.logo,
        status: _status,
        foundedDate: _foundedDate,
        monthlyRevenue: _monthlyRevenueController.text.isEmpty ? null : double.tryParse(_monthlyRevenueController.text),
        employeeCount: _employeeCountController.text.isEmpty ? null : int.tryParse(_employeeCountController.text),
        createdAt: widget.company?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      if (widget.company == null) {
        await ref.read(companyControllerProvider.notifier).createCompany(company);
      } else {
        await ref.read(companyControllerProvider.notifier).updateCompany(company);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.company == null ? 'Empresa criada com sucesso!' : 'Empresa atualizada!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro: $e'),
            backgroundColor: AppColors.error,
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          widget.company == null ? 'Nova Empresa' : 'Editar Empresa',
          style: AppTextStyles.headingH2.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Nome
            TextFormField(
              controller: _nameController,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Nome da Empresa *',
                hintText: 'Ex: Tech Solutions LTDA',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Nome é obrigatório';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Tipo
            DropdownButtonFormField<CompanyType>(
              value: _type,
              decoration: InputDecoration(
                labelText: 'Tipo de Empresa *',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
              items: CompanyType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _type = value);
                }
              },
            ),
            const SizedBox(height: 16),

            // CNPJ
            TextFormField(
              controller: _cnpjController,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'CNPJ',
                hintText: '00.000.000/0000-00',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: 'E-mail',
                hintText: 'contato@empresa.com',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Phone
            TextFormField(
              controller: _phoneController,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'Telefone',
                hintText: '(00) 00000-0000',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Website
            TextFormField(
              controller: _websiteController,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              keyboardType: TextInputType.url,
              decoration: InputDecoration(
                labelText: 'Website',
                hintText: 'www.empresa.com',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descrição',
                hintText: 'Breve descrição da empresa...',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Endereço',
              style: AppTextStyles.headingH3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),

            // Address
            TextFormField(
              controller: _addressController,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              decoration: InputDecoration(
                labelText: 'Endereço',
                hintText: 'Rua, número, bairro',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cityController,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Cidade',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'UF',
                      filled: true,
                      fillColor: AppColors.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ZIP Code
            TextFormField(
              controller: _zipCodeController,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'CEP',
                hintText: '00000-000',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 24),

            Text(
              'Informações Adicionais',
              style: AppTextStyles.headingH3.copyWith(color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),

            // Data de fundação
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Data de Fundação',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${_foundedDate.day}/${_foundedDate.month}/${_foundedDate.year}',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Monthly Revenue
            TextFormField(
              controller: _monthlyRevenueController,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Receita Mensal (R\$)',
                hintText: '0.00',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Employee Count
            TextFormField(
              controller: _employeeCountController,
              style: AppTextStyles.bodyMedium.copyWith(color: AppColors.textPrimary),
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Número de Funcionários',
                hintText: '0',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Status
            DropdownButtonFormField<CompanyStatus>(
              value: _status,
              decoration: InputDecoration(
                labelText: 'Status *',
                filled: true,
                fillColor: AppColors.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.border),
                ),
              ),
              items: CompanyStatus.values.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.displayName),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
            ),
            const SizedBox(height: 32),

            // Save Button
            SizedBox(
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveCompany,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.company == null ? 'Criar Empresa' : 'Salvar Alterações',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            // Delete Button (if editing)
            if (widget.company != null) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Confirmar exclusão'),
                      content: const Text(
                        'Tem certeza que deseja excluir esta empresa? Esta ação não pode ser desfeita.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text(
                            'Excluir',
                            style: TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirm == true && mounted) {
                    await ref.read(companyControllerProvider.notifier).deleteCompany(widget.company!.id);

                    if (mounted) {
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Empresa excluída'),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.delete, color: AppColors.error),
                label: Text(
                  'Excluir Empresa',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
```

---

Continue nos próximos arquivos para:
- CompanyDetailPage
- ClientsPage + ClientFormPage
- ContractsPage + ContractFormPage
- ProjectsPage + ProjectFormPage
- Widgets (CompanyCard, ClientCard, ContractCard, ProjectCard)
- DashboardPage

Total: ~15 arquivos restantes
