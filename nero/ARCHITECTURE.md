# Arquitetura do Nero

Este documento descreve a arquitetura do aplicativo Nero, suas decisões de design e padrões utilizados.

## 📐 Visão Geral

O Nero segue os princípios da **Clean Architecture** proposta por Robert C. Martin (Uncle Bob), adaptada para Flutter.

### Princípios Fundamentais

1. **Separação de Responsabilidades**: Cada camada tem responsabilidades bem definidas
2. **Independência de Frameworks**: A lógica de negócio não depende de frameworks externos
3. **Testabilidade**: Todas as camadas podem ser testadas independentemente
4. **Independência da UI**: A UI pode mudar sem afetar a lógica de negócio
5. **Independência do Banco de Dados**: Podemos trocar o Supabase por outro backend facilmente

## 🏗️ Estrutura de Camadas

```
lib/
├── core/                     # Núcleo da aplicação
│   ├── config/              # Configurações (tema, rotas, i18n)
│   ├── services/            # Serviços globais (Supabase, notificações)
│   └── constants/           # Constantes globais
├── features/                # Features/Módulos da aplicação
│   └── [feature]/
│       ├── data/           # Camada de Dados
│       │   ├── datasources/    # Fontes de dados (API, Local)
│       │   └── repositories/   # Implementação dos repositórios
│       ├── domain/         # Camada de Domínio
│       │   ├── entities/       # Entidades de negócio
│       │   ├── repositories/   # Interfaces dos repositórios
│       │   └── usecases/       # Casos de uso
│       └── presentation/   # Camada de Apresentação
│           ├── pages/          # Páginas/Telas
│           ├── providers/      # Providers (Riverpod)
│           └── widgets/        # Widgets específicos
└── shared/                  # Código compartilhado
    ├── widgets/            # Widgets reutilizáveis
    ├── models/             # Modelos compartilhados
    └── utils/              # Utilitários
```

## 🔄 Fluxo de Dados

```
UI (Presentation)
    ↓
Providers (Riverpod)
    ↓
Use Cases (Domain)
    ↓
Repositories (Domain Interface)
    ↓
Repository Implementation (Data)
    ↓
Data Sources (API/Local)
```

## 📦 Camadas Detalhadas

### 1. Camada de Apresentação (Presentation)

**Responsabilidade**: Exibir dados ao usuário e capturar interações.

**Componentes**:
- **Pages**: Telas completas do aplicativo
- **Widgets**: Componentes de UI reutilizáveis
- **Providers**: Gerenciamento de estado com Riverpod

**Características**:
- Não contém lógica de negócio
- Usa Providers para acessar dados
- Reage a mudanças de estado
- Exibe loading, erro e sucesso

**Exemplo**:
```dart
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Acessa o provider
    final authService = ref.watch(authServiceProvider);

    // UI reage ao estado
    return Scaffold(...);
  }
}
```

### 2. Camada de Domínio (Domain)

**Responsabilidade**: Conter a lógica de negócio da aplicação.

**Componentes**:
- **Entities**: Objetos de negócio puros
- **Repositories (Interface)**: Contratos que definem operações
- **Use Cases**: Casos de uso específicos da aplicação

**Características**:
- Independente de frameworks
- Não conhece Flutter, Supabase ou qualquer biblioteca externa
- Define "o que" o app faz, não "como"
- Altamente testável

**Exemplo**:
```dart
// Entity
class User {
  final String id;
  final String email;
  final String? name;
}

// Repository Interface
abstract class AuthRepository {
  Future<User> signIn(String email, String password);
  Future<void> signOut();
}

// Use Case
class SignInUseCase {
  final AuthRepository repository;

  Future<User> call(String email, String password) {
    return repository.signIn(email, password);
  }
}
```

### 3. Camada de Dados (Data)

**Responsabilidade**: Implementar acesso aos dados.

**Componentes**:
- **Data Sources**: Comunicação com APIs, bancos locais, cache
- **Repository Implementation**: Implementa as interfaces do Domain
- **Models**: Modelos de dados com serialização JSON

**Características**:
- Conhece APIs externas (Supabase, REST, etc)
- Implementa as interfaces do Domain
- Trata erros e exceções
- Converte dados externos para Entities

**Exemplo**:
```dart
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _client;

  @override
  Future<User> signIn(String email, String password) async {
    final response = await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );

    // Converte resposta da API para Entity
    return User(
      id: response.user!.id,
      email: response.user!.email!,
    );
  }
}
```

## 🎯 Gerenciamento de Estado (Riverpod)

O Nero usa **Riverpod** para gerenciamento de estado, seguindo boas práticas:

### Tipos de Providers

1. **Provider**: Para valores imutáveis
```dart
final configProvider = Provider((ref) => AppConfig());
```

2. **StateProvider**: Para estados simples
```dart
final counterProvider = StateProvider((ref) => 0);
```

3. **FutureProvider**: Para operações assíncronas
```dart
final userProvider = FutureProvider((ref) async {
  return ref.watch(authRepository).getCurrentUser();
});
```

4. **StreamProvider**: Para streams de dados
```dart
final authStateProvider = StreamProvider((ref) {
  return ref.watch(authRepository).authStateChanges;
});
```

5. **StateNotifierProvider**: Para estados complexos
```dart
final tasksProvider = StateNotifierProvider<TasksNotifier, TasksState>((ref) {
  return TasksNotifier(ref.watch(tasksRepository));
});
```

### Boas Práticas Riverpod

- ✅ Sempre use `ref.watch()` em `build()` para reatividade
- ✅ Use `ref.read()` em callbacks e métodos
- ✅ Divida providers grandes em providers menores
- ✅ Coloque providers próximos ao código que os usa
- ✅ Use `autoDispose` quando apropriado

## 🗄️ Banco de Dados (Supabase)

### Estrutura

O Nero usa **PostgreSQL** via **Supabase** com as seguintes características:

- **Row Level Security (RLS)**: Cada usuário só acessa seus próprios dados
- **Triggers**: Atualização automática de `updated_at`
- **Views**: Resumos calculados (tarefas, finanças)
- **Índices**: Otimização de queries

### Tabelas Principais

1. **users**: Dados do usuário
2. **companies**: Empresas cadastradas
3. **tasks**: Tarefas pessoais e empresariais
4. **meetings**: Reuniões
5. **transactions**: Transações financeiras
6. **ai_recommendations**: Sugestões da IA
7. **user_behavior**: Padrões de comportamento
8. **audit_logs**: Logs de auditoria

## 🤖 Integração com IA (ChatGPT)

### Arquitetura de IA

```
App Flutter
    ↓ (envia contexto)
Backend API
    ↓ (processa com ChatGPT)
OpenAI API
    ↓ (retorna recomendações)
Backend API
    ↓ (salva no Supabase)
Supabase
    ↓ (notifica app)
App Flutter (exibe sugestões)
```

### Segurança

- ⚠️ **NUNCA** exponha a chave da OpenAI no app
- ✅ Toda comunicação com IA passa pelo backend
- ✅ Backend valida tokens e permissões
- ✅ Logs de todas as interações com IA

### Dados Coletados para IA

1. **Comportamento de tarefas**: Horários de conclusão, frequência
2. **Padrões financeiros**: Gastos recorrentes, categorias
3. **Rotina**: Horários de trabalho, acordar, reuniões
4. **Contexto empresarial**: Tipo de empresa, atividades

## 🔒 Segurança

### Princípios de Segurança

1. **Autenticação**: JWT via Supabase Auth
2. **Autorização**: RLS no banco de dados
3. **Criptografia**: HTTPS para todas as comunicações
4. **Secrets**: Variáveis de ambiente, nunca hardcoded
5. **Auditoria**: Logs de todas as ações sensíveis

### Checklist de Segurança

- ✅ Todas as rotas protegidas validam token
- ✅ RLS habilitado em todas as tabelas
- ✅ Senhas nunca armazenadas em texto plano
- ✅ Secrets em variáveis de ambiente
- ✅ Validação de entrada em todos os endpoints
- ✅ Rate limiting no backend
- ✅ Logs de auditoria

## 🧪 Testes

### Estratégia de Testes

1. **Unit Tests**: Lógica de negócio (Domain)
2. **Widget Tests**: Widgets isolados
3. **Integration Tests**: Fluxos completos
4. **E2E Tests**: Testes end-to-end

### Estrutura de Testes

```
test/
├── unit/
│   ├── domain/
│   └── data/
├── widget/
│   └── presentation/
└── integration/
    └── features/
```

## 🚀 Performance

### Otimizações Implementadas

1. **Lazy Loading**: Dados carregados sob demanda
2. **Caching**: Uso de `SharedPreferences` para cache local
3. **Pagination**: Listas grandes paginadas
4. **Image Caching**: Cache de imagens com `CachedNetworkImage`
5. **Debouncing**: Em buscas e inputs
6. **Provider AutoDispose**: Libera memória automaticamente

### Métricas Monitoradas

- Tempo de carregamento de telas
- Tempo de resposta de APIs
- Uso de memória
- Tamanho do bundle

## 📖 Padrões de Código

### Nomenclatura

- **Classes**: PascalCase (`UserRepository`)
- **Variáveis**: camelCase (`userName`)
- **Constantes**: SCREAMING_SNAKE_CASE (`MAX_ITEMS`)
- **Arquivos**: snake_case (`user_repository.dart`)
- **Providers**: sufixo `Provider` (`authProvider`)

### Organização de Imports

```dart
// Dart
import 'dart:async';

// Flutter
import 'package:flutter/material.dart';

// Packages
import 'package:riverpod/riverpod.dart';

// Project
import '../../../core/config/app_colors.dart';
```

## 🔄 Fluxo de Desenvolvimento

1. **Feature Branch**: Crie uma branch para cada feature
2. **Implementar Domain**: Comece pelas entities e interfaces
3. **Implementar Data**: Implemente repositórios
4. **Implementar Presentation**: Crie UI e providers
5. **Testes**: Adicione testes em todas as camadas
6. **Code Review**: Revise código antes de merge
7. **Merge**: Faça merge para develop/main

## 📚 Recursos Adicionais

- [Clean Architecture - Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Clean Architecture](https://resocoder.com/flutter-clean-architecture-tdd/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Supabase Documentation](https://supabase.com/docs)

## 🤝 Contribuindo

Ao contribuir para o Nero:

1. Siga a arquitetura estabelecida
2. Escreva testes para seu código
3. Documente mudanças significativas
4. Use commits semânticos
5. Mantenha o código limpo e legível
