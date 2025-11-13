# Sistema de Auto-Atualização - Gestor Pessoal

Sistema completo de auto-atualização para distribuição do app Android fora da Play Store.

## Características

- ✅ Auto-atualização via APK sideload (Android)
- ✅ Verificação automática a cada 24 horas
- ✅ Download com progresso e possibilidade de pausar
- ✅ Verificação de integridade SHA-256
- ✅ Suporte a atualizações obrigatórias
- ✅ Detecção de origem da instalação (Play Store vs Sideload)
- ✅ Interface amigável com changelog
- ✅ Hospedagem gratuita (GitHub ou Firebase)

## Documentação

### Guias Rápidos
- **[QUICK_START.md](docs/QUICK_START.md)** - Comece aqui! Configuração e release rápido
- **[updates/README.md](updates/README.md)** - Info sobre arquivos de atualização

### Guias Detalhados
- **[AUTO_UPDATE_GUIDE.md](docs/AUTO_UPDATE_GUIDE.md)** - Guia completo do sistema
- **[ANDROID_SIGNING_SETUP.md](docs/ANDROID_SIGNING_SETUP.md)** - Configurar assinatura do Android

## Estrutura do Projeto

```
lib/
├── models/
│   └── update_info.dart           # Modelos de dados de atualização
├── services/
│   ├── app_update_service.dart    # Serviço principal de atualização
│   └── installer_detector.dart    # Detecta origem da instalação
├── widgets/
│   └── update_dialog.dart         # Dialog de atualização
├── screens/
│   └── updates_screen.dart        # Tela de gerenciamento de atualizações
└── main.dart                      # App principal com verificação automática

android/
├── app/src/main/
│   ├── kotlin/.../MainActivity.kt # Código nativo para detecção
│   ├── res/xml/file_paths.xml    # Configuração FileProvider
│   └── AndroidManifest.xml       # Permissões e configurações

updates/
├── latest.json                    # Manifesto de atualização
├── generate_hash.sh               # Script Linux/Mac para hash
└── generate_hash.ps1              # Script Windows para hash

docs/
├── QUICK_START.md                 # Início rápido
├── AUTO_UPDATE_GUIDE.md           # Guia completo
└── ANDROID_SIGNING_SETUP.md       # Configuração de assinatura
```

## Início Rápido

### 1. Configuração Inicial (Uma Vez)

1. **Criar keystore de assinatura**
   ```bash
   keytool -genkey -v -keystore ~/upload-keystore.jks \
     -storetype JKS -keyalg RSA -keysize 2048 \
     -validity 10000 -alias upload
   ```

2. **Criar `android/key.properties`**
   ```properties
   storePassword=SUA_SENHA
   keyPassword=SUA_SENHA
   keyAlias=upload
   storeFile=/caminho/para/upload-keystore.jks
   ```

3. **Configurar URL do manifesto em `lib/services/app_update_service.dart`**
   ```dart
   static const String _manifestUrl = 'SUA_URL/latest.json';
   ```

### 2. Primeiro Release

1. **Build do APK**
   ```bash
   flutter build apk --release
   ```

2. **Gerar hash SHA-256**
   ```bash
   # Windows
   .\updates\generate_hash.ps1 build\app\outputs\flutter-apk\app-release.apk

   # Linux/Mac
   ./updates/generate_hash.sh build/app/outputs/flutter-apk/app-release.apk
   ```

3. **Hospedar o APK** (GitHub Releases, Firebase, ou servidor próprio)

4. **Atualizar `updates/latest.json`**
   ```json
   {
     "versionName": "1.0.0",
     "versionCode": 100,
     "minVersionCode": 100,
     "mandatory": false,
     "apkUrl": "URL_DO_APK",
     "apkSha256": "HASH_GERADO",
     "changelog": ["Primeira versão"]
   }
   ```

5. **Publicar `latest.json`** (commit no GitHub ou upload no servidor)

## Como Funciona

### Fluxo do Usuário

1. App verifica atualizações ao abrir (respeita intervalo de 24h)
2. Se houver atualização, mostra modal com changelog
3. Usuário confirma e o download começa
4. Após download, hash SHA-256 é verificado
5. Instalador do Android é aberto
6. App é atualizado e reinicia

### Segurança

- ✅ HTTPS obrigatório
- ✅ Verificação SHA-256 de integridade
- ✅ Assinatura consistente via keystore
- ✅ Não permite downgrade de versão
- ✅ Detecção de instalação via Play Store

### Limitações

**Android:**
- ✅ Funciona perfeitamente com sideload
- ⚠️ Se instalado via Play Store, auto-update é desabilitado
- ⚠️ Requer permissão REQUEST_INSTALL_PACKAGES
- ⚠️ Usuário precisa confirmar instalação (Android não permite pular)

**iOS:**
- ❌ Auto-update de binário não permitido pela Apple
- ✅ Use TestFlight para testes
- ✅ Use App Store para produção

## Dependências

```yaml
dependencies:
  package_info_plus: ^8.0.0      # Info da versão do app
  dio: ^5.4.0                     # Download com progresso
  path_provider: ^2.1.1           # Acesso a diretórios
  install_plugin: ^2.1.0          # Instalação de APK
  crypto: ^3.0.3                  # Hash SHA-256
  flutter_secure_storage: ^9.0.0  # Armazenamento seguro
  device_info_plus: ^10.0.1       # Info do dispositivo
```

## Hospedagem (Gratuita)

### GitHub (Recomendado para começar)

- ✅ Totalmente gratuito
- ✅ 100 MB por arquivo
- ✅ Integrado com Git
- 📝 Limite de ~1 GB/mês de banda

**Setup:**
1. Commit do `latest.json`
2. Use Releases para APKs
3. URL: `https://raw.githubusercontent.com/user/repo/main/updates/latest.json`

### Firebase Hosting

- ✅ 10 GB armazenamento
- ✅ 360 MB/dia transferência
- ✅ CDN global + SSL

**Setup:**
```bash
npm install -g firebase-tools
firebase login
firebase init hosting
firebase deploy --only hosting
```

## Testando

### Teste Local

1. Instale versão antiga no dispositivo
2. Abra o app
3. Toque no ícone de atualização na AppBar
4. Ou aguarde 2 segundos para verificação automática
5. Confirme a atualização

### Debug

```bash
flutter logs
```

Procure por mensagens como:
- `Buscando atualizações em:`
- `Informações de atualização recebidas:`
- `Download concluído:`

## Uso no Código

### Verificar Atualização Manualmente

```dart
final updateService = AppUpdateService();
final updateInfo = await updateService.getAvailableUpdate();

if (updateInfo != null) {
  showDialog(
    context: context,
    builder: (context) => UpdateDialog(
      updateInfo: updateInfo,
      updateService: updateService,
    ),
  );
}
```

### Verificar ao Iniciar

```dart
@override
void initState() {
  super.initState();
  _checkForUpdates();
}

Future<void> _checkForUpdates() async {
  final updateService = AppUpdateService();

  if (await updateService.shouldCheckForUpdates()) {
    final updateInfo = await updateService.getAvailableUpdate();

    if (updateInfo != null && mounted) {
      showDialog(
        context: context,
        barrierDismissible: !updateInfo.mandatory,
        builder: (context) => UpdateDialog(
          updateInfo: updateInfo,
          updateService: updateService,
        ),
      );
    }
  }
}
```

## Troubleshooting

### Atualização não aparece
- Verifique URL do manifesto
- Teste URL no navegador
- Veja `flutter logs`
- Confirme que versionCode remoto > local

### Download falha
- Confirme que URL funciona no navegador
- Verifique conexão de internet
- Certifique-se que é HTTPS

### Hash inválido
- Gere hash do APK correto
- Não modifique o APK após gerar hash
- Use o mesmo APK no servidor

### Não instala
- Permita "Fontes desconhecidas" no Android
- Confirme que keystore é a mesma
- Tente instalar APK manualmente para ver erro

## Suporte

Para mais informações, consulte a documentação completa:
- [docs/QUICK_START.md](docs/QUICK_START.md)
- [docs/AUTO_UPDATE_GUIDE.md](docs/AUTO_UPDATE_GUIDE.md)
- [docs/ANDROID_SIGNING_SETUP.md](docs/ANDROID_SIGNING_SETUP.md)

## Licença

Este projeto está sob a licença definida no projeto principal.

---

**Desenvolvido para:** Gestor Pessoal com IA
**Última atualização:** 2025-01-12
