# Sistema de Auto-Atualização

Este diretório contém os arquivos necessários para o sistema de auto-atualização do app.

## Arquivos

- **latest.json**: Manifesto com informações da versão mais recente
- **generate_hash.sh**: Script Linux/Mac para gerar hash SHA-256
- **generate_hash.ps1**: Script Windows para gerar hash SHA-256

## Guia Rápido de Release

### 1. Build do APK

```bash
flutter build apk --release
```

### 2. Gerar Hash

**Windows:**
```powershell
.\updates\generate_hash.ps1 build\app\outputs\flutter-apk\app-release.apk
```

**Linux/Mac:**
```bash
./updates/generate_hash.sh build/app/outputs/flutter-apk/app-release.apk
```

### 3. Fazer Upload do APK

Opções:
- GitHub Releases
- Firebase Hosting
- Servidor próprio

### 4. Atualizar latest.json

Edite o arquivo com:
- Nova versão
- Nova URL do APK
- Novo hash SHA-256
- Changelog atualizado

### 5. Publicar latest.json

Faça commit e push, ou upload para seu servidor.

## Estrutura do latest.json

```json
{
  "versionName": "1.1.0",
  "versionCode": 110,
  "minVersionCode": 100,
  "mandatory": false,
  "apkUrl": "https://...",
  "apkSha256": "...",
  "changelog": ["..."]
}
```

## Configuração da URL

Edite em `lib/services/app_update_service.dart`:

```dart
static const String _manifestUrl = 'SUA_URL_AQUI';
```

## Mais Informações

Consulte o guia completo em: `docs/AUTO_UPDATE_GUIDE.md`
