# Guia de Auto-Atualização do App

Este documento descreve o sistema de auto-atualização implementado no app e como utilizá-lo.

## Índice

1. [Visão Geral](#visão-geral)
2. [Como Funciona](#como-funciona)
3. [Configuração Inicial](#configuração-inicial)
4. [Processo de Release](#processo-de-release)
5. [Hospedagem](#hospedagem)
6. [Segurança](#segurança)
7. [Limitações](#limitações)
8. [Troubleshooting](#troubleshooting)

## Visão Geral

O sistema de auto-atualização permite que o app Android seja atualizado automaticamente sem precisar da Play Store, baixando e instalando novos APKs diretamente.

### Características

- ✅ Verificação automática de atualizações a cada 24 horas
- ✅ Verificação manual pelo usuário
- ✅ Download com barra de progresso
- ✅ Possibilidade de pausar/retomar downloads
- ✅ Verificação de integridade via SHA-256
- ✅ Suporte a atualizações obrigatórias
- ✅ Changelog visível para o usuário
- ✅ Detecção automática de instalação via Play Store

### Plataformas

- **Android**: ✅ Auto-update completo via APK sideload
- **iOS**: ❌ Não permitido pela Apple (use TestFlight/App Store)

## Como Funciona

### Fluxo de Atualização

1. **Verificação**
   - App busca o arquivo `latest.json` do servidor
   - Compara `versionCode` com a versão instalada
   - Se houver atualização, exibe modal ao usuário

2. **Download**
   - Usuário confirma a atualização
   - APK é baixado com barra de progresso
   - Hash SHA-256 é verificado após download

3. **Instalação**
   - App solicita permissão de instalação (se necessário)
   - Abre instalador nativo do Android
   - Usuário confirma instalação
   - App é atualizado e reinicia

### Estrutura do Manifesto

O arquivo `latest.json` contém:

```json
{
  "versionName": "1.1.0",           // Versão legível (exibida ao usuário)
  "versionCode": 110,               // Código numérico da versão
  "minVersionCode": 100,            // Versão mínima requerida
  "mandatory": false,               // Se é obrigatória
  "apkUrl": "https://...",          // URL do APK
  "apkSha256": "abc123...",         // Hash SHA-256 do APK
  "changelog": [                    // Lista de mudanças
    "Nova funcionalidade X",
    "Correção de bug Y"
  ]
}
```

## Configuração Inicial

### 1. Atualizar a URL do Manifesto

Edite `lib/services/app_update_service.dart`:

```dart
static const String _manifestUrl =
    'https://SEU_DOMINIO/updates/latest.json';
```

Opções de hospedagem:
- GitHub Raw: `https://raw.githubusercontent.com/usuario/repo/main/updates/latest.json`
- Firebase Hosting: `https://seu-projeto.web.app/updates/latest.json`
- Servidor próprio: `https://seu-servidor.com/updates/latest.json`

### 2. Configurar Signing Key

Para que as atualizações funcionem, todas as versões devem ser assinadas com a mesma keystore.

#### Criar Keystore (primeira vez)

```bash
keytool -genkey -v -keystore ~/upload-keystore.jks \
  -storetype JKS -keyalg RSA -keysize 2048 \
  -validity 10000 -alias upload
```

#### Configurar no Android

Crie `android/key.properties`:

```properties
storePassword=SUA_SENHA
keyPassword=SUA_SENHA
keyAlias=upload
storeFile=/caminho/para/upload-keystore.jks
```

Edite `android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...

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
        }
    }
}
```

## Processo de Release

### 1. Atualizar Versão

Edite `pubspec.yaml`:

```yaml
version: 1.1.0+110  # formato: VERSÃO_LEGÍVEL+CÓDIGO
```

### 2. Build do APK Release

```bash
flutter build apk --release
```

O APK será gerado em: `build/app/outputs/flutter-apk/app-release.apk`

### 3. Gerar Hash SHA-256

#### Windows (PowerShell)
```powershell
.\updates\generate_hash.ps1 build\app\outputs\flutter-apk\app-release.apk
```

#### Linux/Mac
```bash
chmod +x updates/generate_hash.sh
./updates/generate_hash.sh build/app/outputs/flutter-apk/app-release.apk
```

### 4. Fazer Upload do APK

Opções:

#### GitHub Releases
1. Vá para Releases no GitHub
2. Clique em "Create a new release"
3. Tag: `v1.1.0`
4. Faça upload do APK
5. Copie a URL do arquivo

#### Firebase Hosting
```bash
firebase deploy --only hosting
```

### 5. Atualizar latest.json

Edite `updates/latest.json`:

```json
{
  "versionName": "1.1.0",
  "versionCode": 110,
  "minVersionCode": 100,
  "mandatory": false,
  "apkUrl": "URL_DO_APK_AQUI",
  "apkSha256": "HASH_GERADO_AQUI",
  "changelog": [
    "Descrição das mudanças"
  ]
}
```

### 6. Publicar latest.json

Faça commit e push do `latest.json` atualizado, ou faça upload para seu servidor.

## Hospedagem

### Opção 1: GitHub (Gratuito)

**Prós:**
- Totalmente gratuito
- Integrado com Git
- Releases organizados

**Contras:**
- Limite de 100 MB por arquivo
- Limite de banda: ~1 GB/mês (grátis)

**Como usar:**
1. Commit do `latest.json` no repositório
2. Use GitHub Releases para os APKs
3. Use URLs Raw para o manifesto

### Opção 2: Firebase Hosting (Gratuito)

**Prós:**
- 10 GB armazenamento
- 360 MB/dia de transferência
- CDN global
- SSL incluído

**Contras:**
- Requer conta Google
- Configuração inicial mais complexa

**Como usar:**
1. `firebase init hosting`
2. Coloque arquivos em `public/`
3. `firebase deploy --only hosting`

### Opção 3: Servidor Próprio

**Prós:**
- Controle total
- Sem limites (depende do servidor)

**Contras:**
- Requer servidor
- Você gerencia SSL e segurança

## Segurança

### Verificações Implementadas

1. **HTTPS Obrigatório**
   - Todas as conexões usam HTTPS
   - HTTP será rejeitado

2. **Verificação SHA-256**
   - Hash calculado após download
   - Instalação bloqueada se divergir
   - Arquivo corrompido é deletado

3. **Assinatura Consistente**
   - Todas as versões com mesma keystore
   - Android valida assinatura automaticamente
   - Instalação falha se assinatura divergir

4. **Não Permite Downgrade**
   - Só instala se versionCode > atual

### Boas Práticas

- ✅ Mantenha a keystore em local seguro
- ✅ Use senhas fortes para a keystore
- ✅ Não commite a keystore no Git
- ✅ Faça backup da keystore
- ✅ Use HTTPS sempre
- ✅ Considere Certificate Pinning para produção

## Limitações

### Android

- ✅ Funciona perfeitamente com sideload
- ⚠️ Se instalado via Play Store, auto-update é desabilitado
- ⚠️ Requer permissão `REQUEST_INSTALL_PACKAGES`
- ⚠️ Usuário precisa confirmar instalação (não é possível pular)

### iOS

- ❌ Auto-update de binário não é permitido
- ✅ Use TestFlight para testes
- ✅ Use App Store para produção
- ✅ Pode atualizar conteúdo remotamente (Remote Config)

## Troubleshooting

### Atualização não aparece

**Problema:** App não detecta nova versão

**Soluções:**
1. Verifique se `versionCode` no manifesto é maior que a versão instalada
2. Verifique se URL do manifesto está correta
3. Teste a URL no navegador
4. Veja logs com `flutter logs`

### Download falha

**Problema:** Erro ao baixar APK

**Soluções:**
1. Verifique conexão de internet
2. Teste URL do APK no navegador
3. Verifique se arquivo está acessível publicamente
4. Confirme que é HTTPS

### Hash inválido

**Problema:** "Hash SHA-256 inválido"

**Soluções:**
1. Regenere o hash do APK correto
2. Verifique se o APK no servidor é o mesmo que você gerou
3. Não edite o APK após gerar o hash

### Instalação falha

**Problema:** Não consegue instalar o APK

**Soluções:**
1. Verifique se tem permissão `REQUEST_INSTALL_PACKAGES`
2. Nas configurações do Android, permita instalar de fontes desconhecidas
3. Certifique-se que a assinatura é a mesma
4. Tente instalar o APK manualmente para ver o erro

### App instalado via Play Store

**Problema:** Auto-update não funciona

**Solução:**
- Isto é intencional! Apps da Play Store devem usar Play In-App Updates
- Para sideload, desinstale e reinstale o APK diretamente

## Exemplo de Uso no Código

### Verificar Manualmente

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

### Verificar ao Iniciar o App

```dart
@override
void initState() {
  super.initState();
  _checkForUpdates();
}

Future<void> _checkForUpdates() async {
  final updateService = AppUpdateService();

  // Verifica se deve checar (respeita intervalo de 24h)
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

## Suporte

Para problemas ou dúvidas:
1. Verifique os logs: `flutter logs`
2. Consulte este guia
3. Abra uma issue no GitHub

---

**Última atualização:** 2025-01-12
