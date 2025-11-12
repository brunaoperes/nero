# ⚡ Comandos Úteis - Nero

Referência rápida de comandos para o desenvolvimento.

## 🚀 Executar o App

```bash
# Web (Chrome)
flutter run -d chrome

# Android
flutter run -d <device-id>

# iOS (somente macOS)
flutter run -d <device-id>

# Ver dispositivos disponíveis
flutter devices
```

## 🔄 Durante o Desenvolvimento

```bash
# Hot Reload (no terminal do app rodando)
r  # Reload rápido

# Hot Restart
R  # Reinicia o app mantendo estado

# Sair
q  # Fecha o app
```

## 📦 Dependências

```bash
# Instalar dependências
flutter pub get

# Atualizar dependências
flutter pub upgrade

# Adicionar nova dependência
flutter pub add nome_do_pacote

# Remover dependência
flutter pub remove nome_do_pacote
```

## 🏗️ Build Runner (Gerar Código)

```bash
# Gerar código (Freezed, Riverpod, JSON)
flutter pub run build_runner build --delete-conflicting-outputs

# Assistir mudanças e gerar automaticamente
flutter pub run build_runner watch --delete-conflicting-outputs

# Limpar código gerado
flutter pub run build_runner clean
```

## 🧹 Limpeza

```bash
# Limpar build
flutter clean

# Limpar + instalar + gerar
flutter clean && flutter pub get && flutter pub run build_runner build --delete-conflicting-outputs
```

## 🔍 Análise e Qualidade

```bash
# Analisar código
flutter analyze

# Formatar código
flutter format .

# Verificar instalação
flutter doctor

# Verificar com detalhes
flutter doctor -v
```

## 🧪 Testes

```bash
# Executar todos os testes
flutter test

# Teste específico
flutter test test/unit/auth_test.dart

# Com cobertura
flutter test --coverage

# Ver cobertura
genhtml coverage/lcov.info -o coverage/html
```

## 📱 Build de Produção

```bash
# Android APK
flutter build apk --release

# Android AAB (Google Play)
flutter build appbundle --release

# iOS (somente macOS)
flutter build ios --release

# Web
flutter build web --release
```

## 🐛 Debug

```bash
# Ver logs
flutter logs

# Modo profile (performance)
flutter run --profile

# Modo release
flutter run --release

# Abrir DevTools
flutter pub global activate devtools
flutter pub global run devtools
```

## 📊 Informações

```bash
# Versão do Flutter
flutter --version

# Informações do dispositivo
flutter devices -v

# Informações do app
flutter pub deps
```

## 🗄️ Supabase (via CLI - opcional)

```bash
# Instalar Supabase CLI
npm install -g supabase

# Login
supabase login

# Link com projeto
supabase link --project-ref yyxrgfwezgffncxuhkvo

# Migrations
supabase db push
```

## 🎨 Assets

```bash
# Gerar ícones do app
flutter pub run flutter_launcher_icons

# Gerar splash screen
flutter pub run flutter_native_splash:create
```

## 🔐 Environment

```bash
# Rodar com variáveis de ambiente
flutter run --dart-define=ENV=dev

# Build com variáveis
flutter build apk --dart-define=ENV=prod
```

## 🌐 Web

```bash
# Rodar web em porta específica
flutter run -d chrome --web-port=8080

# Build web com base href
flutter build web --base-href /nero/
```

## 📦 Packages Específicos

### Freezed (Modelos)

```bash
# Gerar modelos
flutter pub run build_runner build --delete-conflicting-outputs
```

### Riverpod (State)

```bash
# Gerar providers
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🔧 Troubleshooting

```bash
# Resolver problemas comuns
flutter clean
flutter pub get
flutter pub run build_runner clean
flutter pub run build_runner build --delete-conflicting-outputs

# Resetar cache
flutter pub cache clean
flutter pub get

# Problemas com CocoaPods (iOS)
cd ios
pod install
cd ..

# Problemas com Gradle (Android)
cd android
./gradlew clean
cd ..
```

## 🚀 Workflow Recomendado

### Iniciar o dia
```bash
git pull
flutter pub get
flutter run -d chrome
```

### Adicionar feature
```bash
# 1. Criar arquivos
# 2. Implementar código
# 3. Gerar código se necessário
flutter pub run build_runner build --delete-conflicting-outputs
# 4. Testar (hot reload automático)
```

### Finalizar o dia
```bash
flutter analyze
git add .
git commit -m "feat: descrição da feature"
git push
```

## 💡 Dicas

### Atalhos no terminal do app rodando

| Tecla | Ação |
|-------|------|
| `r` | Hot reload |
| `R` | Hot restart |
| `h` | Ajuda |
| `q` | Sair |
| `d` | Detach (manter rodando) |
| `v` | Abrir DevTools |

### VS Code

```json
// .vscode/launch.json
{
  "configurations": [
    {
      "name": "Flutter",
      "request": "launch",
      "type": "dart"
    }
  ]
}
```

Pressione `F5` para debug!

### Git Hooks (opcional)

```bash
# .git/hooks/pre-commit
flutter analyze
flutter test
```

---

**💡 Dica**: Salve este arquivo nos favoritos para consulta rápida!
