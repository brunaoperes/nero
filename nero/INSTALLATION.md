# Guia de Instalação e Deploy do Nero

Este guia explica como configurar e executar o aplicativo Nero do zero.

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- **Flutter** 3.0 ou superior ([Instalar Flutter](https://flutter.dev/docs/get-started/install))
- **Dart** 3.0 ou superior (incluído no Flutter)
- **Git** para clonar o repositório
- **Editor de código** (VS Code, Android Studio ou IntelliJ)
- **Conta Supabase** (gratuita) - [Criar conta](https://supabase.com)
- **Conta Google Cloud** (para Google Sign-In)
- **Conta Apple Developer** (para Apple Sign-In no iOS)

## 🚀 Passos de Instalação

### 1. Clonar o Repositório

```bash
git clone <url-do-repositorio>
cd nero
```

### 2. Instalar Dependências

```bash
flutter pub get
```

### 3. Configurar Supabase

#### 3.1. Criar Projeto no Supabase

1. Acesse [supabase.com](https://supabase.com)
2. Crie um novo projeto
3. Anote a **URL** e **anon key** do projeto

#### 3.2. Executar o Schema SQL

1. No dashboard do Supabase, vá em **SQL Editor**
2. Cole o conteúdo do arquivo `SUPABASE_SCHEMA.sql`
3. Execute o script (Run)
4. Verifique se todas as tabelas foram criadas em **Table Editor**

#### 3.3. Configurar Autenticação

1. No Supabase, vá em **Authentication** → **Providers**
2. Configure os providers necessários:
   - **Email**: Já vem habilitado
   - **Google**: Adicione Client ID e Client Secret
   - **Apple**: Adicione configurações do Apple Sign-In

### 4. Configurar Variáveis de Ambiente

#### 4.1. Criar arquivo .env

```bash
cp .env.example .env
```

#### 4.2. Preencher .env com suas credenciais

```env
SUPABASE_URL=https://seu-projeto.supabase.co
SUPABASE_ANON_KEY=sua-chave-anonima-aqui
```

### 5. Configurar Google Sign-In

#### 5.1. Criar projeto no Google Cloud Console

1. Acesse [console.cloud.google.com](https://console.cloud.google.com)
2. Crie um novo projeto
3. Ative a **Google Sign-In API**

#### 5.2. Criar credenciais OAuth 2.0

##### Para Android:

1. Vá em **Credenciais** → **Criar Credenciais** → **ID do cliente OAuth 2.0**
2. Tipo: **Aplicativo Android**
3. Nome do pacote: `com.seuapp.nero` (ou o que você definiu)
4. Certificado SHA-1:
   ```bash
   # Debug
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android

   # Release
   keytool -list -v -keystore /caminho/para/keystore.jks -alias sua-alias
   ```

##### Para iOS:

1. Crie outro ID do cliente OAuth 2.0
2. Tipo: **Aplicativo iOS**
3. ID do pacote: `com.seuapp.nero`

##### Para Web:

1. Crie outro ID do cliente OAuth 2.0
2. Tipo: **Aplicativo da Web**
3. Adicione as origens autorizadas

#### 5.3. Configurar no código

Adicione o Client ID no arquivo apropriado para cada plataforma.

**Android** (`android/app/src/main/AndroidManifest.xml`):
```xml
<meta-data
    android:name="com.google.android.gms.auth.api.signin.CLIENT_ID"
    android:value="SEU_CLIENT_ID_ANDROID" />
```

**iOS** (`ios/Runner/Info.plist`):
```xml
<key>GIDClientID</key>
<string>SEU_CLIENT_ID_IOS</string>
```

### 6. Configurar Apple Sign-In (somente iOS)

1. No Apple Developer, configure **Sign in with Apple**
2. Adicione o capability no Xcode:
   - Abra `ios/Runner.xcworkspace` no Xcode
   - Selecione o target Runner
   - Vá em **Signing & Capabilities**
   - Adicione **Sign in with Apple**

### 7. Gerar Código (Freezed e Riverpod)

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

Este comando gera:
- Arquivos `.freezed.dart` (modelos imutáveis)
- Arquivos `.g.dart` (JSON serialization)
- Arquivos de providers gerados pelo Riverpod

### 8. Executar o Aplicativo

#### Modo Debug:

```bash
flutter run
```

#### Escolher dispositivo:

```bash
# Listar dispositivos
flutter devices

# Executar em dispositivo específico
flutter run -d <device-id>
```

## 📱 Build para Produção

### Android (APK/AAB)

#### Build APK:

```bash
flutter build apk --release
```

O arquivo será gerado em: `build/app/outputs/flutter-apk/app-release.apk`

#### Build AAB (para Google Play):

```bash
flutter build appbundle --release
```

O arquivo será gerado em: `build/app/outputs/bundle/release/app-release.aab`

### iOS (IPA)

1. Abra o projeto no Xcode:
   ```bash
   open ios/Runner.xcworkspace
   ```

2. Configure o **Signing**:
   - Selecione seu time
   - Configure o bundle identifier
   - Configure os certificates e provisioning profiles

3. Build via Xcode:
   - Product → Archive
   - Distribute App

Ou via linha de comando:
```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

Os arquivos serão gerados em: `build/web/`

Para servir localmente:
```bash
cd build/web
python -m http.server 8000
```

## 🔧 Configurações Adicionais

### Configurar Firebase (Notificações Push)

Se quiser adicionar notificações push no futuro:

1. Crie um projeto no [Firebase Console](https://console.firebase.google.com)
2. Adicione os apps (Android/iOS)
3. Baixe e adicione os arquivos de configuração:
   - Android: `google-services.json` → `android/app/`
   - iOS: `GoogleService-Info.plist` → `ios/Runner/`

### Configurar Ícone e Splash Screen

#### Ícone:

1. Adicione sua imagem em `assets/images/app_icon.png` (1024x1024)
2. Instale o pacote:
   ```bash
   flutter pub add flutter_launcher_icons --dev
   ```
3. Configure em `pubspec.yaml` e execute:
   ```bash
   flutter pub run flutter_launcher_icons
   ```

#### Splash Screen:

1. Use o pacote `flutter_native_splash`
2. Configure em `pubspec.yaml`
3. Execute:
   ```bash
   flutter pub run flutter_native_splash:create
   ```

## 🧪 Testes

### Executar todos os testes:

```bash
flutter test
```

### Executar com cobertura:

```bash
flutter test --coverage
```

## 🐛 Troubleshooting

### Erro: "Supabase URL ou Key não configurados"

- Verifique se o arquivo `.env` existe e está preenchido
- Verifique se as constantes em `app_constants.dart` estão corretas

### Erro: "Google Sign-In failed"

- Verifique se o SHA-1 está correto
- Verifique se o pacote está configurado em `AndroidManifest.xml`
- Verifique se o Client ID está correto

### Erro ao gerar código:

```bash
# Limpar build
flutter clean

# Reinstalar dependências
flutter pub get

# Gerar novamente
flutter pub run build_runner build --delete-conflicting-outputs
```

## 📚 Próximos Passos

Após a instalação, você pode:

1. **Configurar o Backend** para IA e Open Finance
2. **Implementar as features pendentes** (módulos de tarefas completos, empresas, finanças)
3. **Adicionar testes unitários e de integração**
4. **Configurar CI/CD** (GitHub Actions, Codemagic, etc)
5. **Publicar nas lojas** (Google Play Store, Apple App Store)

## 🆘 Suporte

Se encontrar problemas:

1. Verifique a documentação do Flutter: https://docs.flutter.dev
2. Verifique a documentação do Supabase: https://supabase.com/docs
3. Abra uma issue no repositório do projeto

## 📄 Licença

Este projeto está sob licença MIT. Veja o arquivo `LICENSE` para mais detalhes.
