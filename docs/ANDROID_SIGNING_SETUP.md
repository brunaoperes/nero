# Configuração de Assinatura Android

Este guia mostra como configurar a assinatura do APK para permitir atualizações.

## Por que isso é importante?

Para que as atualizações funcionem, **TODAS as versões do app devem ser assinadas com a mesma keystore**.
O Android valida a assinatura e só permite instalar atualizações se forem da mesma origem.

## Passo 1: Criar a Keystore (Primeira Vez)

### Linux/Mac

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
```

### Windows

```powershell
keytool -genkey -v -keystore %USERPROFILE%\upload-keystore.jks ^
  -storetype JKS -keyalg RSA -keysize 2048 ^
  -validity 10000 -alias upload
```

**Importante:**
- Escolha uma senha forte e **GUARDE-A BEM**
- Se perder a keystore ou senha, não poderá mais atualizar o app
- Faça backup da keystore em local seguro

## Passo 2: Criar arquivo key.properties

Crie o arquivo `android/key.properties`:

```properties
storePassword=SUA_SENHA_AQUI
keyPassword=SUA_SENHA_AQUI
keyAlias=upload
storeFile=/caminho/completo/para/upload-keystore.jks
```

**Exemplo Windows:**
```properties
storePassword=minhasenha123
keyPassword=minhasenha123
keyAlias=upload
storeFile=C:\\Users\\SeuUsuario\\upload-keystore.jks
```

**Exemplo Linux/Mac:**
```properties
storePassword=minhasenha123
keyPassword=minhasenha123
keyAlias=upload
storeFile=/home/usuario/upload-keystore.jks
```

## Passo 3: Configurar build.gradle

Edite `android/app/build.gradle`.

### Adicione no topo (antes de `android {`):

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}
```

### Dentro de `android {`, adicione `signingConfigs`:

```gradle
android {
    // ... outras configurações ...

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            // ... outras configurações de release ...
        }
    }
}
```

## Passo 4: Adicionar ao .gitignore

**MUITO IMPORTANTE:** Nunca commite a keystore ou senhas no Git!

Adicione ao `.gitignore`:

```
# Keystore e configurações sensíveis
*.jks
*.keystore
android/key.properties
android/app/key.properties
upload-keystore.jks
```

## Passo 5: Testar a Configuração

```bash
flutter build apk --release
```

Se funcionar sem erros, sua configuração está correta!

## Arquivo build.gradle Completo (Exemplo)

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

plugins {
    id "com.android.application"
    id "kotlin-android"
    id "dev.flutter.flutter-gradle-plugin"
}

android {
    namespace = "com.example.gestor_pessoal_ia"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8
    }

    defaultConfig {
        applicationId = "com.example.gestor_pessoal_ia"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            shrinkResources true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }

        debug {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source = "../.."
}
```

## Verificar Assinatura do APK

### Ver informações da keystore:

```bash
keytool -list -v -keystore ~/upload-keystore.jks
```

### Ver assinatura do APK gerado:

```bash
# Linux/Mac
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk

# Windows
jarsigner -verify -verbose -certs build\app\outputs\flutter-apk\app-release.apk
```

## Backup da Keystore

**CRÍTICO:** Faça backup da keystore!

1. Copie o arquivo `.jks` para um local seguro
2. Salve as senhas em um gerenciador de senhas
3. Considere armazenar em:
   - Nuvem criptografada (Google Drive com senha, Dropbox, etc)
   - Disco externo
   - Repositório privado Git (com criptografia)

**Se perder a keystore:**
- Não poderá mais atualizar o app
- Terá que publicar um novo app com novo package name
- Usuários terão que desinstalar e instalar novamente

## Troubleshooting

### Erro: "keystore not found"

O caminho no `storeFile` está errado. Use caminho absoluto.

### Erro: "incorrect password"

Verifique as senhas no `key.properties`.

### Erro: "Failed to read key from store"

A keystore pode estar corrompida ou o alias está errado.

### APK não instala sobre versão anterior

As versões foram assinadas com keystores diferentes. Use sempre a mesma keystore.

## Segurança

- ✅ Use senhas fortes
- ✅ Faça backup da keystore
- ✅ Não commite no Git
- ✅ Limite acesso à keystore
- ✅ Use ambiente seguro para builds de release

---

**Última atualização:** 2025-01-12
