# 🔥 GUIA COMPLETO: Configurar Firebase no Nero

Este guia contém **instruções passo a passo** para configurar o Firebase Cloud Messaging (FCM) no projeto Nero.

---

## 📋 PRÉ-REQUISITOS

- ✅ Conta Google
- ✅ Acesso ao [Firebase Console](https://console.firebase.google.com/)
- ✅ Flutter instalado
- ✅ Projeto Nero já configurado

---

## 🚀 PASSO 1: Criar Projeto no Firebase Console

### 1.1. Acessar o Firebase Console

1. Acesse: https://console.firebase.google.com/
2. Faça login com sua conta Google
3. Clique em **"Adicionar projeto"** (ou "Create a project")

### 1.2. Criar o Projeto

1. **Nome do projeto**: `Nero` (ou `nero-app`)
2. Clique em **Continuar**
3. **Google Analytics**: Pode desativar por enquanto (opcional)
4. Clique em **Criar projeto**
5. Aguarde a criação (1-2 minutos)
6. Clique em **Continuar**

---

## 📱 PASSO 2: Adicionar App Android

### 2.1. Registrar App Android

1. No Firebase Console, clique no ícone do **Android** (🤖)
2. Preencha os dados:
   - **Nome do pacote Android**: `com.nero.app`
     - ⚠️ **IMPORTANTE**: Deve ser exatamente este nome!
     - Para verificar, abra: `android/app/build.gradle`
     - Procure por: `applicationId "com.nero.app"`
   - **Apelido do app** (opcional): `Nero Android`
   - **SHA-1** (opcional): Pode pular por enquanto
3. Clique em **Registrar app**

### 2.2. Baixar google-services.json

1. Clique em **Baixar google-services.json**
2. **MOVA** o arquivo baixado para:
   ```
   C:\Users\Bruno\gestor_pessoal_ia\nero\android\app\google-services.json
   ```
3. ⚠️ **Caminho correto**: `android/app/google-services.json` (não na raiz!)
4. Clique em **Próxima**

### 2.3. Configurar build.gradle (Projeto)

1. Abra: `android/build.gradle`
2. Adicione a dependência do Google Services no topo do arquivo:

```gradle
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath 'com.google.gms:google-services:4.4.0'  // ← ADICIONE ESTA LINHA
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
```

### 2.4. Configurar build.gradle (App)

1. Abra: `android/app/build.gradle`
2. **No final do arquivo**, adicione esta linha:

```gradle
apply plugin: 'com.android.application'
apply plugin: 'kotlin-android'
apply plugin: 'com.google.gms.google-services'  // ← ADICIONE ESTA LINHA
```

3. No mesmo arquivo, verifique se `minSdkVersion` está correto:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // ← Deve ser no mínimo 21
        targetSdkVersion flutter.targetSdkVersion
    }
}
```

### 2.5. Configurar AndroidManifest.xml

1. Abra: `android/app/src/main/AndroidManifest.xml`
2. Adicione as permissões **antes** da tag `<application>`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    <!-- Permissões de notificação -->
    <uses-permission android:name="android.permission.INTERNET"/>
    <uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
    <uses-permission android:name="android.permission.VIBRATE"/>
    <uses-permission android:name="android.permission.WAKE_LOCK"/>
    <uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>

    <application>
        <!-- Configuração do FCM -->
        <meta-data
            android:name="com.google.firebase.messaging.default_notification_channel_id"
            android:value="high_importance_channel" />

        <!-- Resto do código... -->
    </application>
</manifest>
```

---

## 🍎 PASSO 3: Adicionar App iOS (Opcional)

### 3.1. Registrar App iOS

1. No Firebase Console, clique no ícone do **iOS** (🍎)
2. Preencha os dados:
   - **ID do pacote iOS**: `com.nero.app`
     - Para verificar, abra: `ios/Runner.xcodeproj` no Xcode
     - Vá em **Runner > General > Bundle Identifier**
   - **Apelido do app** (opcional): `Nero iOS`
3. Clique em **Registrar app**

### 3.2. Baixar GoogleService-Info.plist

1. Clique em **Baixar GoogleService-Info.plist**
2. **MOVA** o arquivo para:
   ```
   C:\Users\Bruno\gestor_pessoal_ia\nero\ios\Runner\GoogleService-Info.plist
   ```
3. Ou adicione via Xcode:
   - Abra o projeto no Xcode
   - Arraste o arquivo para a pasta `Runner`
   - ✅ Marque "Copy items if needed"
   - ✅ Marque o target "Runner"

### 3.3. Configurar Capabilities no Xcode

1. Abra: `ios/Runner.xcworkspace` no Xcode
2. Selecione **Runner** (projeto)
3. Vá em **Signing & Capabilities**
4. Clique em **+ Capability**
5. Adicione:
   - **Push Notifications**
   - **Background Modes** (marque "Remote notifications")

### 3.4. Configurar Info.plist

1. Abra: `ios/Runner/Info.plist`
2. Adicione esta chave **antes** de `</dict>`:

```xml
<key>UIBackgroundModes</key>
<array>
    <string>fetch</string>
    <string>remote-notification</string>
</array>
```

---

## 🔧 PASSO 4: Instalar Dependências Flutter

### 4.1. Instalar Pacotes

```powershell
cd C:\Users\Bruno\gestor_pessoal_ia\nero
flutter pub get
```

### 4.2. Verificar Instalação

```powershell
flutter doctor
```

Deve aparecer:
- ✅ Firebase Core instalado
- ✅ Firebase Messaging instalado

---

## ✅ PASSO 5: Testar Configuração

### 5.1. Compilar o App (Android)

```powershell
flutter run
```

Ou especificamente para Android:

```powershell
flutter run -d android
```

### 5.2. Verificar Logs

No console, procure por mensagens do Firebase:
```
[Firebase] Initialized successfully
[FCM] Token: ey...
```

Se aparecer o token do FCM, **está funcionando!** 🎉

---

## 🔔 PASSO 6: Enviar Notificação de Teste

### 6.1. No Firebase Console

1. Vá em **Cloud Messaging** (no menu lateral)
2. Clique em **Enviar primeira mensagem**
3. Preencha:
   - **Título**: "Teste Nero"
   - **Texto**: "Notificação funcionando!"
4. Clique em **Próximo**
5. Selecione o app (Android ou iOS)
6. Clique em **Próximo**
7. Clique em **Publicar**

### 6.2. Verificar no Dispositivo

- Se o app estiver em **background**: Notificação aparece na bandeja
- Se o app estiver em **foreground**: Você verá no console do Flutter

---

## 🐛 PROBLEMAS COMUNS

### ❌ Erro: "google-services.json not found"

**Solução**: Certifique-se de que o arquivo está em `android/app/google-services.json`

```powershell
ls android/app/google-services.json
```

### ❌ Erro: "FirebaseApp is not initialized"

**Solução**: Certifique-se de que `Firebase.initializeApp()` foi chamado no `main.dart`:

```dart
await Firebase.initializeApp();
```

### ❌ Erro: "Execution failed for task ':app:processDebugGoogleServices'"

**Solução**:
1. O `applicationId` no `build.gradle` deve ser igual ao package name no Firebase
2. Verifique se `google-services.json` está no lugar correto

### ❌ Notificações não aparecem (Android 13+)

**Solução**: Solicite permissão de notificação:

```dart
await FirebaseMessaging.instance.requestPermission();
```

### ❌ Erro ao compilar iOS

**Solução**:
```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

---

## 📊 VERIFICAÇÃO FINAL

### Checklist:
- [ ] Projeto criado no Firebase Console
- [ ] App Android registrado
- [ ] `google-services.json` no lugar correto
- [ ] `build.gradle` configurado (projeto e app)
- [ ] `AndroidManifest.xml` configurado
- [ ] App iOS registrado (se aplicável)
- [ ] `GoogleService-Info.plist` no lugar correto
- [ ] Capabilities configuradas no Xcode (se iOS)
- [ ] `flutter pub get` executado
- [ ] App compilado sem erros
- [ ] Token FCM gerado
- [ ] Notificação de teste enviada e recebida

---

## 📞 PRÓXIMOS PASSOS

Após concluir este guia:

1. ✅ Firebase configurado
2. ➡️ Voltar para o código e testar os serviços de notificação
3. ➡️ Ver `NOTIFICATIONS_GUIDE.md` para usar as notificações no app

---

## 🔗 LINKS ÚTEIS

- [Firebase Console](https://console.firebase.google.com/)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Messaging Docs](https://firebase.google.com/docs/cloud-messaging)
- [FlutterFire Setup Guide](https://firebase.flutter.dev/docs/overview)

---

**Criado em**: Janeiro 2025
**Versão**: 1.0
**Projeto**: Nero - Gestor Pessoal Inteligente
