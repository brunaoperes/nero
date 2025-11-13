# Guia Rápido - Sistema de Auto-Atualização

## Configuração Inicial (Faça uma vez)

### 1. Criar e Configurar Keystore

```bash
# Criar keystore
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
```

Crie `android/key.properties`:
```properties
storePassword=SUA_SENHA
keyPassword=SUA_SENHA
keyAlias=upload
storeFile=/caminho/para/upload-keystore.jks
```

### 2. Configurar URL do Manifesto

Edite `lib/services/app_update_service.dart` linha 16:
```dart
static const String _manifestUrl = 'SUA_URL_AQUI/latest.json';
```

Exemplos:
- GitHub: `https://raw.githubusercontent.com/usuario/repo/main/updates/latest.json`
- Firebase: `https://seu-projeto.web.app/updates/latest.json`

### 3. Configurar Hospedagem

#### Opção A: GitHub
1. Commite o `updates/latest.json` no repositório
2. Use GitHub Releases para hospedar os APKs
3. Use URLs Raw do GitHub

#### Opção B: Firebase
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
# Copie arquivos para public/
firebase deploy --only hosting
```

## Processo de Release (Toda nova versão)

### 1. Atualizar Versão

`pubspec.yaml`:
```yaml
version: 1.1.0+110  # VERSÃO+CÓDIGO
```

### 2. Build

```bash
flutter build apk --release
```

APK gerado em: `build/app/outputs/flutter-apk/app-release.apk`

### 3. Gerar Hash

**Windows:**
```powershell
.\updates\generate_hash.ps1 build\app\outputs\flutter-apk\app-release.apk
```

**Linux/Mac:**
```bash
./updates/generate_hash.sh build/app/outputs/flutter-apk/app-release.apk
```

### 4. Upload do APK

- GitHub Releases: Crie release `v1.1.0` e anexe o APK
- Firebase: Copie para `public/` e faça deploy
- Outro servidor: Upload via FTP/SCP

### 5. Atualizar Manifesto

Edite `updates/latest.json`:
```json
{
  "versionName": "1.1.0",
  "versionCode": 110,
  "minVersionCode": 100,
  "mandatory": false,
  "apkUrl": "URL_DO_APK",
  "apkSha256": "HASH_GERADO",
  "changelog": [
    "Nova funcionalidade X",
    "Correção de bug Y"
  ]
}
```

### 6. Publicar Manifesto

- GitHub: Commit e push
- Firebase: `firebase deploy --only hosting`
- Outro: Upload do arquivo

## Testando

### Teste Local

1. Instale a versão antiga no dispositivo
2. Abra o app
3. Toque em "Verificar Atualizações"
4. Deve aparecer o modal de atualização

### Verificar Logs

```bash
flutter logs
```

Procure por:
- `Buscando atualizações em:`
- `Informações de atualização recebidas:`
- `Download concluído:`

## Comandos Úteis

```bash
# Ver dependências instaladas
flutter pub get

# Build release
flutter build apk --release

# Build com código e nome customizados
flutter build apk --release --build-name=1.2.0 --build-number=120

# Ver informações do dispositivo
flutter devices

# Instalar no dispositivo conectado
flutter install

# Limpar build
flutter clean
```

## Troubleshooting Rápido

### Atualização não aparece
- Verifique URL do manifesto
- Teste URL no navegador
- Veja `flutter logs`

### Download falha
- Confirme que URL do APK funciona no navegador
- Verifique se é HTTPS

### Hash inválido
- Gere novamente o hash do APK correto
- Confirme que o APK não foi modificado após gerar o hash

### Não instala
- Permita "Fontes desconhecidas" nas configurações do Android
- Confirme que a keystore é a mesma

## Checklist de Release

- [ ] Atualizar versão no `pubspec.yaml`
- [ ] Build do APK release
- [ ] Gerar hash SHA-256
- [ ] Upload do APK
- [ ] Atualizar `latest.json` com nova versão, URL e hash
- [ ] Publicar `latest.json`
- [ ] Testar atualização em dispositivo com versão antiga

## Próximos Passos

Para informações detalhadas, consulte:
- `docs/AUTO_UPDATE_GUIDE.md` - Guia completo
- `updates/README.md` - Info sobre arquivos de atualização

---

**Dica:** Mantenha este arquivo aberto durante os releases!
