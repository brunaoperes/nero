# ⚡ Quick Start - Nero

Guia super rápido para começar a desenvolver agora!

## 🎯 3 Comandos para Começar

**No PowerShell/CMD, na pasta do projeto:**

```bash
# 1. Instalar dependências
flutter pub get

# 2. Gerar código
flutter pub run build_runner build --delete-conflicting-outputs

# 3. Executar app
flutter run -d chrome
```

Pronto! O app deve abrir no navegador. 🚀

## 🔑 Configuração Mínima

### 1. Criar arquivo .env

```bash
copy .env.example .env
```

Edite o `.env` e adicione (valores de exemplo):

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-aqui
```

### 2. Configurar Supabase (5 minutos)

1. Crie conta em: https://supabase.com
2. Crie novo projeto
3. No SQL Editor, cole e execute o conteúdo de `SUPABASE_SCHEMA.sql`
4. Copie as credenciais para o `.env`

**Guia completo**: `SUPABASE_SETUP.md`

## 📱 Comandos Úteis

### Desenvolvimento

```bash
# Executar no Chrome
flutter run -d chrome

# Executar em Android
flutter run -d <device-id>

# Hot reload (no terminal do app rodando)
r  # Reload rápido
R  # Restart completo
q  # Sair
```

### Debug

```bash
# Analisar código
flutter analyze

# Ver logs
flutter logs

# Limpar build
flutter clean
```

### Build

```bash
# Android APK
flutter build apk --release

# Android AAB (Google Play)
flutter build appbundle --release

# Web
flutter build web --release

# iOS (somente macOS)
flutter build ios --release
```

## 🗂️ Estrutura Rápida

```
nero/
├── lib/
│   ├── core/          # Config, tema, serviços
│   ├── features/      # Módulos (auth, dashboard, etc)
│   └── shared/        # Código compartilhado
├── assets/            # Imagens, ícones, fontes
└── test/              # Testes
```

## 🎨 Temas e Cores

```dart
// Cores principais
AppColors.primary      // #0072FF (Azul Elétrico)
AppColors.secondary    // #FFD700 (Dourado)
AppColors.aiAccent     // #00E5FF (IA)

// Usar no código
Container(
  color: AppColors.primary,
)
```

## 🧩 Widgets Prontos

```dart
// Card de sugestão da IA
AISuggestionCard(
  message: 'Sugestão aqui',
  type: 'task',
)

// Widget de foco
FocusWidget(
  pendingTasks: 1,
  totalTasks: 5,
)

// Lista de tarefas
QuickTasksWidget()

// Resumo financeiro
FinanceSummaryWidget(
  income: 5000,
  expenses: 3200,
  period: 'Esta Semana',
)
```

## 🔐 Autenticação

```dart
// Provider de autenticação
final authService = ref.read(authServiceProvider);

// Login
await authService.signInWithEmail(
  email: 'user@example.com',
  password: 'password',
);

// Registro
await authService.signUpWithEmail(
  email: 'user@example.com',
  password: 'password',
  name: 'Nome',
);

// Google Sign-In
await authService.signInWithGoogle();

// Logout
await authService.signOut();
```

## 🗄️ Banco de Dados

```dart
// Acessar Supabase client
final supabase = SupabaseService.client;

// Buscar dados
final data = await supabase
  .from('tasks')
  .select()
  .eq('user_id', userId);

// Inserir
await supabase.from('tasks').insert({
  'title': 'Nova tarefa',
  'user_id': userId,
});

// Atualizar
await supabase
  .from('tasks')
  .update({'is_completed': true})
  .eq('id', taskId);

// Deletar
await supabase
  .from('tasks')
  .delete()
  .eq('id', taskId);
```

## 🎯 Navegação

```dart
// Navegar para outra tela
context.go('/dashboard');

// Com parâmetros
context.go('/tasks/123');

// Voltar
context.pop();
```

## 📦 State Management (Riverpod)

```dart
// Criar provider
final counterProvider = StateProvider((ref) => 0);

// Usar no widget
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = ref.watch(counterProvider);

    return Text('$count');
  }
}

// Modificar estado
ref.read(counterProvider.notifier).state++;
```

## 🧪 Testes

```bash
# Executar todos os testes
flutter test

# Com cobertura
flutter test --coverage

# Teste específico
flutter test test/unit/auth_test.dart
```

## 📚 Documentação

- **Arquitetura**: `ARCHITECTURE.md`
- **Setup Completo**: `SETUP.md`
- **Instalação**: `INSTALLATION.md`
- **Supabase**: `SUPABASE_SETUP.md`
- **Próximos Passos**: `NEXT_STEPS.md`

## 🐛 Problemas Comuns

### Build Runner falha

```bash
flutter clean
flutter pub get
dart pub global activate build_runner
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erro de importação

Execute o build_runner para gerar arquivos `.freezed.dart` e `.g.dart`

### App não conecta ao Supabase

Verifique:
1. `.env` existe e está preenchido
2. Credenciais estão corretas
3. Reinicie o app após criar `.env`

## 💡 Dicas

1. **Use Hot Reload** - Salve alterações e veja mudanças instantâneas
2. **Flutter DevTools** - Execute `flutter pub global activate devtools`
3. **VS Code Extensions** - Instale "Flutter" e "Dart"
4. **Snippets** - Digite `stless` + Tab para criar StatelessWidget
5. **Format ao Salvar** - Configure no VS Code para formatar automaticamente

## 🚀 Pronto para Desenvolver!

Agora você tem tudo que precisa para começar. Consulte `NEXT_STEPS.md` para ver o que implementar primeiro.

**Sugestão**: Comece implementando o módulo de tarefas completo (prioridade alta).

---

**Boa codificação!** 💙
