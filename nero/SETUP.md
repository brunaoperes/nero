# 🚀 Setup Rápido do Nero

Este guia te ajudará a colocar o projeto Nero em produção rapidamente.

## ⚠️ IMPORTANTE: Execute estes comandos no seu terminal (PowerShell ou CMD)

O projeto está localizado em: `C:\Users\awgco\gestor_pessoal_ia\nero`

## 📝 Passo a Passo

### 1. Verificar Instalação do Flutter

```bash
flutter --version
```

Se não estiver instalado, baixe em: https://flutter.dev/docs/get-started/install/windows

### 2. Navegar para o Projeto

```bash
cd C:\Users\awgco\gestor_pessoal_ia\nero
```

### 3. Instalar Dependências

```bash
flutter pub get
```

Este comando pode demorar alguns minutos na primeira vez.

### 4. Gerar Arquivos de Código (Freezed + Riverpod)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Este comando gerará os arquivos:
- `*.freezed.dart` (modelos imutáveis)
- `*.g.dart` (JSON serialization)

**Nota**: Se houver erros, execute:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 5. Configurar Variáveis de Ambiente

Crie o arquivo `.env` (copie do `.env.example`):

```bash
copy .env.example .env
```

Edite o arquivo `.env` e adicione suas credenciais do Supabase.

### 6. Verificar se Não Há Erros

```bash
flutter analyze
```

Deve retornar "No issues found!" (ou apenas warnings, que são aceitáveis).

### 7. Executar o Aplicativo

#### Listar dispositivos disponíveis:

```bash
flutter devices
```

#### Executar em um dispositivo específico:

```bash
# Chrome (Web)
flutter run -d chrome

# Emulador Android
flutter run -d <android-device-id>

# Emulador iOS (somente macOS)
flutter run -d <ios-device-id>
```

## 🐛 Solução de Problemas Comuns

### Erro: "Dart SDK not found"

Execute:
```bash
flutter doctor
```

E siga as instruções para corrigir problemas.

### Erro: "Unable to generate build script"

Execute:
```bash
flutter clean
flutter pub get
dart pub global activate build_runner
flutter pub run build_runner build --delete-conflicting-outputs
```

### Erro de importação de modelos

Os arquivos `.freezed.dart` e `.g.dart` precisam ser gerados. Execute o passo 4 novamente.

### Erro: "SUPABASE_URL not found"

Verifique se:
1. O arquivo `.env` existe
2. Está preenchido com suas credenciais
3. Execute novamente após criar o arquivo

## 📋 Checklist de Verificação

Antes de começar o desenvolvimento, verifique:

- [ ] Flutter instalado e funcionando (`flutter doctor`)
- [ ] Dependências instaladas (`flutter pub get`)
- [ ] Código gerado sem erros (`build_runner`)
- [ ] Arquivo `.env` configurado
- [ ] `flutter analyze` sem erros críticos
- [ ] App executa em pelo menos um dispositivo

## 🎯 Próximos Passos Após Setup

Depois que o app estiver rodando:

1. **Configurar Supabase**:
   - Criar projeto em supabase.com
   - Executar o script `SUPABASE_SCHEMA.sql` no SQL Editor
   - Copiar URL e anon key para o `.env`

2. **Configurar Google Sign-In**:
   - Seguir o guia em `INSTALLATION.md`
   - Configurar OAuth no Google Cloud Console

3. **Testar funcionalidades básicas**:
   - [ ] Criar conta
   - [ ] Fazer login
   - [ ] Completar onboarding
   - [ ] Visualizar dashboard

4. **Começar desenvolvimento**:
   - Consulte `NEXT_STEPS.md` para ver o que implementar
   - Siga a arquitetura em `ARCHITECTURE.md`

## 💡 Dicas de Desenvolvimento

### Hot Reload

Quando o app estiver rodando, você pode:
- Pressionar `r` para hot reload (rápido)
- Pressionar `R` para hot restart (reinicia o app)
- Pressionar `q` para sair

### Debug no VS Code

1. Abra a pasta `nero` no VS Code
2. Instale a extensão "Flutter"
3. Pressione `F5` para debug
4. Coloque breakpoints clicando à esquerda dos números de linha

### Visualizar Logs

```bash
flutter logs
```

### Verificar Performance

```bash
flutter run --profile
```

## 🆘 Precisa de Ajuda?

Se encontrar problemas:

1. Verifique a documentação: `INSTALLATION.md`
2. Consulte: https://docs.flutter.dev
3. Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

## 🎉 Tudo Funcionando?

Se o app está rodando sem erros, parabéns! 🎊

Agora você pode começar a implementar as features pendentes. Consulte:
- `NEXT_STEPS.md` - Roadmap de desenvolvimento
- `ARCHITECTURE.md` - Arquitetura e padrões
- `README.md` - Visão geral do projeto

---

**Dica**: Mantenha sempre um terminal aberto com `flutter run` e outro para executar comandos Git, testes, etc.
