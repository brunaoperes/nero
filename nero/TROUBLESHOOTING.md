# 🔧 Troubleshooting - Nero

Soluções para problemas comuns durante desenvolvimento.

## 🚨 Problemas de Setup

### ❌ "Flutter command not found"

**Problema**: Flutter não está instalado ou não está no PATH.

**Solução**:
1. Baixe Flutter: https://flutter.dev/docs/get-started/install/windows
2. Extraia em `C:\src\flutter`
3. Adicione ao PATH: `C:\src\flutter\bin`
4. Reinicie o terminal
5. Verifique: `flutter --version`

### ❌ "Dart SDK not found"

**Problema**: Dart vem com Flutter, mas pode estar corrompido.

**Solução**:
```bash
flutter doctor
```

Se mostrar erro, reinstale o Flutter.

### ❌ "pub get failed"

**Problema**: Erro ao instalar dependências.

**Soluções**:

**1. Verificar conexão internet**
```bash
ping pub.dev
```

**2. Limpar cache**
```bash
flutter pub cache clean
flutter clean
flutter pub get
```

**3. Verificar proxy** (se usar VPN/Proxy)
```bash
set HTTP_PROXY=http://proxy:port
set HTTPS_PROXY=http://proxy:port
flutter pub get
```

## 🏗️ Problemas com Build Runner

### ❌ "Unable to generate build script"

**Problema**: Conflito de dependências.

**Solução**:
```bash
flutter clean
flutter pub get
dart pub global activate build_runner
flutter pub run build_runner build --delete-conflicting-outputs
```

### ❌ "Conflicting outputs were detected"

**Problema**: Arquivos gerados existem e têm conflitos.

**Solução**:
```bash
# Deletar arquivos gerados
flutter pub run build_runner clean

# Gerar novamente com --delete-conflicting-outputs
flutter pub run build_runner build --delete-conflicting-outputs
```

### ❌ "Import errors for .freezed.dart files"

**Problema**: Arquivos Freezed não foram gerados.

**Solução**:
1. Verifique se `build_runner` está em `dev_dependencies` no `pubspec.yaml`
2. Execute:
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```
3. Os arquivos `.freezed.dart` e `.g.dart` devem ser criados

## 🔐 Problemas de Autenticação

### ❌ "SUPABASE_URL not found"

**Problema**: Variáveis de ambiente não configuradas.

**Soluções**:

**1. Verificar arquivo .env**
```bash
# Verificar se existe
dir .env

# Se não existe, criar
copy .env.example .env
```

**2. Verificar conteúdo do .env**
Abra `.env` e verifique:
```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-aqui
```

**3. Reiniciar app**
Após criar/editar `.env`, reinicie o app completamente.

### ❌ "Google Sign-In failed"

**Problema**: Configuração do Google Sign-In incorreta.

**Soluções**:

**Android:**
1. Verifique SHA-1:
```bash
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

2. Adicione SHA-1 no Google Cloud Console
3. Verifique `AndroidManifest.xml` tem o Client ID

**Web:**
1. Adicione origem autorizada no Google Cloud Console:
   - `http://localhost:port`
2. Adicione URI de redirecionamento:
   - `http://localhost:port/auth/callback`

**iOS:**
1. Verifique `Info.plist` tem o Client ID
2. Configure URL Scheme no Xcode

### ❌ "JWT expired" ou "Invalid token"

**Problema**: Token de autenticação expirado ou inválido.

**Solução**:
1. Faça logout e login novamente
2. Verifique se está usando `SUPABASE_ANON_KEY` (não `service_role`)
3. Limpe dados do app:
```bash
flutter clean
```

## 🗄️ Problemas com Supabase

### ❌ "relation does not exist"

**Problema**: Tabela não foi criada no banco.

**Solução**:
1. Acesse o Supabase: https://app.supabase.com
2. Vá em SQL Editor
3. Execute o script `SUPABASE_SCHEMA.sql` novamente
4. Verifique em Table Editor se as tabelas foram criadas

### ❌ "Row Level Security policy violation"

**Problema**: RLS bloqueando operação.

**Soluções**:

**1. Verificar políticas RLS**
No Supabase, vá em Authentication → Policies e verifique se existem políticas.

**2. Recriar políticas**
Execute novamente o script `SUPABASE_SCHEMA.sql`

**3. Verificar autenticação**
Certifique-se de que o usuário está autenticado:
```dart
final user = SupabaseService.currentUser;
print(user?.id); // Deve mostrar o ID
```

### ❌ "Connection refused" ou "Network error"

**Problema**: Não consegue conectar ao Supabase.

**Solução**:
1. Verifique conexão internet
2. Verifique URL no `.env` está correta
3. Teste URL no navegador:
   ```
   https://seu-projeto.supabase.co/rest/v1/
   ```
   Deve retornar JSON com erro 401 (autenticação necessária)

## 📱 Problemas de Execução

### ❌ "No devices found"

**Problema**: Nenhum dispositivo/emulador disponível.

**Soluções**:

**Chrome (Web):**
```bash
flutter run -d chrome
```

**Android Emulator:**
1. Abra Android Studio
2. AVD Manager → Create Virtual Device
3. Execute:
```bash
flutter emulators
flutter emulators --launch <emulator-id>
flutter run
```

**iOS Simulator (somente macOS):**
```bash
open -a Simulator
flutter run
```

### ❌ "Gradle build failed" (Android)

**Problema**: Erro ao compilar Android.

**Soluções**:

**1. Limpar build**
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter run
```

**2. Atualizar Gradle**
Edite `android/build.gradle`:
```gradle
dependencies {
    classpath 'com.android.tools.build:gradle:7.4.0'
}
```

**3. Verificar JDK**
```bash
java -version
```
Deve ser JDK 11 ou superior.

### ❌ "CocoaPods not installed" (iOS)

**Problema**: CocoaPods necessário para iOS.

**Solução** (somente macOS):
```bash
sudo gem install cocoapods
cd ios
pod install
cd ..
flutter run
```

## 🎨 Problemas de UI

### ❌ "Overflow error" em telas

**Problema**: Widget muito grande para o espaço disponível.

**Soluções**:

**1. Adicionar SingleChildScrollView**
```dart
SingleChildScrollView(
  child: Column(
    children: [...],
  ),
)
```

**2. Usar Expanded/Flexible**
```dart
Column(
  children: [
    Expanded(
      child: YourWidget(),
    ),
  ],
)
```

### ❌ "setState called after dispose"

**Problema**: Tentando atualizar estado após widget ser destruído.

**Solução**:
```dart
if (mounted) {
  setState(() {
    // sua lógica
  });
}
```

### ❌ Fontes não aparecem

**Problema**: Google Fonts não carrega.

**Soluções**:

**1. Verificar internet** (fontes são baixadas)

**2. Usar fontes locais**
Baixe as fontes e adicione em `assets/fonts/`, depois configure `pubspec.yaml`

## 🧪 Problemas com Testes

### ❌ "Test failed to run"

**Problema**: Erro ao executar testes.

**Solução**:
```bash
flutter clean
flutter pub get
flutter test
```

### ❌ "Widget tests failing"

**Problema**: Testes de widget quebrados.

**Solução**:
Envolva o teste com `TestWidgetsFlutterBinding`:
```dart
testWidgets('Meu teste', (WidgetTester tester) async {
  TestWidgetsFlutterBinding.ensureInitialized();
  await tester.pumpWidget(MyApp());
  // asserts...
});
```

## 🔍 Debugging

### Ver mais logs

```bash
# Logs detalhados
flutter run -v

# Apenas erros
flutter run --verbose
```

### Usar DevTools

```bash
flutter pub global activate devtools
flutter pub global run devtools
```

### Inspecionar estado

Adicione breakpoints no VS Code e execute em modo debug (F5).

## 📊 Problemas de Performance

### App lento

**Soluções**:

**1. Usar const widgets**
```dart
const Text('Texto'),
const SizedBox(height: 16),
```

**2. Evitar rebuilds desnecessários**
Use `ConsumerWidget` e `ref.watch()` apenas onde necessário.

**3. Profile mode**
```bash
flutter run --profile
```

**4. Analisar performance**
Use Flutter DevTools → Performance

## 🆘 Últimos Recursos

Se nada funcionar:

1. **Flutter Doctor**
```bash
flutter doctor -v
```
Siga todas as recomendações.

2. **Limpar tudo**
```bash
flutter clean
flutter pub cache clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

3. **Reinstalar Flutter**
Baixe versão mais recente e reinstale.

4. **Verificar Issues**
- GitHub do Flutter: https://github.com/flutter/flutter/issues
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

5. **Pedir ajuda**
- Discord do Flutter Brasil
- Reddit: r/FlutterDev
- GitHub Issues do projeto Nero

## 📞 Suporte

Se encontrou um bug no Nero:

1. Verifique se já não foi reportado
2. Abra uma issue no GitHub
3. Inclua:
   - Passos para reproduzir
   - Mensagem de erro completa
   - Output de `flutter doctor -v`
   - Screenshot (se aplicável)

---

**Lembre-se**: A maioria dos problemas se resolve com `flutter clean` + `flutter pub get` 😉
