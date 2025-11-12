# 🏢 MÓDULO DE EMPRESAS - GUIA RÁPIDO

**Status**: Backend 100% | Frontend: Código fornecido
**Tempo para completar**: 30-60 minutos

---

## 📊 RESUMO DO QUE FOI CRIADO

### ✅ Domain Layer (5 arquivos)
- `company_entity.dart` - 9 tipos de empresa (MEI, LTDA, SA, etc)
- `client_entity.dart` - Pessoa Física/Jurídica
- `contract_entity.dart` - Contratos com status e pagamentos
- `project_entity.dart` - Projetos com progresso e deadlines
- `company_repository.dart` - Interface com 30+ métodos

### ✅ Data Layer (9 arquivos)
- 4 Models com Freezed (company, client, contract, project)
- `company_remote_datasource.dart` (700+ linhas) - Ver `COMPANY_MODULE_COMPLETE_CODE.md`
- `company_repository_impl.dart` - Ver `COMPANY_MODULE_COMPLETE_CODE.md`

### ✅ Database
- `company_tables.sql` - 4 tabelas + índices + RLS + triggers
- Funções automáticas para atualizar receita e contagem de projetos

---

## 🚀 PRÓXIMOS PASSOS (3 etapas)

### ETAPA 1: Copiar Código do Datasource e Repository (5 min)

**Arquivo criado**: `COMPANY_MODULE_COMPLETE_CODE.md`

Copie o código de lá para:
1. `lib/features/company/data/datasources/company_remote_datasource.dart`
2. `lib/features/company/data/repositories/company_repository_impl.dart`

### ETAPA 2: Executar SQL no Supabase (5 min)

1. Abra Supabase Dashboard → SQL Editor
2. Copie TODO o conteúdo de `supabase/migrations/company_tables.sql`
3. Execute

**Resultado esperado**:
```
✅ 4 tabelas criadas (companies, clients, contracts, projects)
✅ Índices criados
✅ RLS policies aplicadas
✅ Triggers configurados
✅ Funções auxiliares criadas
```

### ETAPA 3: Gerar Código Freezed (2 min)

```powershell
cd C:\Users\Bruno\gestor_pessoal_ia\nero
flutter pub run build_runner build --delete-conflicting-outputs
```

**Arquivos gerados**:
- `company_model.freezed.dart` + `.g.dart`
- `client_model.freezed.dart` + `.g.dart`
- `contract_model.freezed.dart` + `.g.dart`
- `project_model.freezed.dart` + `.g.dart`

---

## 📱 OPÇÃO A: MVP Rápido (Recomendado - 15 min)

Vou criar apenas 3 páginas essenciais para você ter o sistema funcionando:

1. **CompanyHomePage** - Lista de empresas
2. **CompanyFormPage** - Criar/editar empresa
3. **ClientsListPage** - Lista de clientes

### Código Simplificado

**Providers** (~100 linhas):
```dart
// lib/features/company/presentation/providers/company_providers.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/company_remote_datasource.dart';
import '../../data/repositories/company_repository_impl.dart';
import '../../domain/entities/company_entity.dart';
import '../../domain/entities/client_entity.dart';
import '../../domain/repositories/company_repository.dart';

// Datasource Provider
final companyDatasourceProvider = Provider<CompanyRemoteDatasource>((ref) {
  return CompanyRemoteDatasource(Supabase.instance.client);
});

// Repository Provider
final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  return CompanyRepositoryImpl(ref.read(companyDatasourceProvider));
});

// Companies Provider
final companiesProvider = FutureProvider.autoDispose<List<CompanyEntity>>((ref) async {
  final repository = ref.read(companyRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) throw Exception('Usuário não autenticado');
  return await repository.getCompanies(userId);
});

// Active Companies Provider
final activeCompaniesProvider = FutureProvider.autoDispose<List<CompanyEntity>>((ref) async {
  final repository = ref.read(companyRepositoryProvider);
  final userId = Supabase.instance.client.auth.currentUser?.id;
  if (userId == null) throw Exception('Usuário não autenticado');
  return await repository.getActiveCompanies(userId);
});

// Clients Provider (by company)
final clientsProvider = FutureProvider.autoDispose.family<List<ClientEntity>, String>((ref, companyId) async {
  final repository = ref.read(companyRepositoryProvider);
  return await repository.getClients(companyId);
});

// Company Controller
class CompanyController extends StateNotifier<AsyncValue<void>> {
  final CompanyRepository _repository;

  CompanyController(this._repository) : super(const AsyncValue.data(null));

  Future<void> createCompany(CompanyEntity company) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.createCompany(company));
  }

  Future<void> updateCompany(CompanyEntity company) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.updateCompany(company));
  }

  Future<void> deleteCompany(String id) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _repository.deleteCompany(id));
  }
}

final companyControllerProvider = StateNotifierProvider<CompanyController, AsyncValue<void>>((ref) {
  return CompanyController(ref.read(companyRepositoryProvider));
});
```

**Home Page** (~150 linhas):
```dart
// lib/features/company/presentation/pages/company_home_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../providers/company_providers.dart';

class CompanyHomePage extends ConsumerWidget {
  const CompanyHomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final companiesAsync = ref.watch(companiesProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Minhas Empresas',
          style: AppTextStyles.headingH2.copyWith(color: AppColors.textPrimary),
        ),
      ),
      body: companiesAsync.when(
        data: (companies) {
          if (companies.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.business, size: 80, color: AppColors.textSecondary),
                  SizedBox(height: 16),
                  Text('Nenhuma empresa cadastrada', style: AppTextStyles.bodyLarge),
                  SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navegar para formulário
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Formulário em desenvolvimento')),
                      );
                    },
                    icon: Icon(Icons.add),
                    label: Text('Criar Empresa'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies[index];
              return Card(
                margin: EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(Icons.business, color: AppColors.primary),
                  ),
                  title: Text(company.name, style: AppTextStyles.bodyMedium),
                  subtitle: Text(
                    '${company.type.displayName} - ${company.status.displayName}',
                    style: AppTextStyles.bodySmall,
                  ),
                  trailing: Icon(Icons.chevron_right),
                  onTap: () {
                    // TODO: Navegar para detalhes
                  },
                ),
              );
            },
          );
        },
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Erro: $error', style: TextStyle(color: AppColors.error)),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navegar para formulário
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Formulário em desenvolvimento')),
          );
        },
        backgroundColor: AppColors.primary,
        child: Icon(Icons.add),
      ),
    );
  }
}
```

---

## 📱 OPÇÃO B: Sistema Completo (2-3 horas)

Para implementação completa com:
- Formulários de empresa, cliente, contrato e projeto
- Dashboard com analytics
- Gráficos de receita
- Gestão de contratos com alertas
- Timeline de projetos

**Solicite**: "Complete o módulo de empresas com UI completa"

E eu crio:
- 8+ páginas
- 6+ widgets
- Providers completos
- Forms com validação
- Analytics e dashboards

---

## 📊 ESTRUTURA DO MÓDULO

```
lib/features/company/
├── domain/
│   ├── entities/
│   │   ├── company_entity.dart ✅
│   │   ├── client_entity.dart ✅
│   │   ├── contract_entity.dart ✅
│   │   └── project_entity.dart ✅
│   └── repositories/
│       └── company_repository.dart ✅
├── data/
│   ├── models/
│   │   ├── company_model.dart ✅
│   │   ├── client_model.dart ✅
│   │   ├── contract_model.dart ✅
│   │   └── project_model.dart ✅
│   ├── datasources/
│   │   └── company_remote_datasource.dart ⏳ (código em COMPANY_MODULE_COMPLETE_CODE.md)
│   └── repositories/
│       └── company_repository_impl.dart ⏳ (código em COMPANY_MODULE_COMPLETE_CODE.md)
└── presentation/
    ├── providers/
    │   └── company_providers.dart ⏳ (código acima - MVP)
    └── pages/
        └── company_home_page.dart ⏳ (código acima - MVP)
```

---

## ✅ CHECKLIST

- [ ] Copiar datasource do arquivo COMPANY_MODULE_COMPLETE_CODE.md
- [ ] Copiar repository impl do arquivo COMPANY_MODULE_COMPLETE_CODE.md
- [ ] Executar SQL no Supabase
- [ ] Rodar build_runner
- [ ] Copiar providers (código MVP acima)
- [ ] Copiar company_home_page (código MVP acima)
- [ ] Adicionar rota `/company` no app_router.dart
- [ ] Testar o app

---

## 🎯 QUAL OPÇÃO VOCÊ PREFERE?

**A) MVP Rápido** (15 min) - Sistema básico funcionando
**B) Sistema Completo** (2-3h) - Todas as features

**Me avise e eu continuo a implementação!** 🚀

---

**Módulo Empresas**: Backend 100% | Frontend: MVP ou Completo (você escolhe)
