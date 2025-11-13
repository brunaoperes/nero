# ✅ Checklist - Sistema de Auto-Atualização

Use este checklist para garantir que tudo está configurado corretamente.

## 📋 Configuração Inicial (Faça Uma Vez)

### 1. Keystore de Assinatura
- [ ] Keystore criada com `keytool`
- [ ] Arquivo `android/key.properties` criado
- [ ] Senha da keystore salva em local seguro
- [ ] Backup da keystore em local seguro
- [ ] Keystore adicionada ao `.gitignore`

**Guia:** `docs/ANDROID_SIGNING_SETUP.md`

### 2. Configuração do Projeto
- [ ] `android/app/build.gradle` configurado com signingConfigs
- [ ] URL do manifesto configurada em `lib/services/app_update_service.dart`
- [ ] Dependências instaladas com `flutter pub get`

### 3. Hospedagem
- [ ] Método de hospedagem escolhido (GitHub/Firebase/Próprio)
- [ ] Conta/servidor configurado
- [ ] Manifesto `latest.json` acessível via HTTPS
- [ ] Local definido para hospedar APKs

**Guia:** `docs/AUTO_UPDATE_GUIDE.md` (seção Hospedagem)

## 🚀 Checklist de Release

Use este checklist a cada nova versão do app.

### 1. Preparação
- [ ] Código testado e funcional
- [ ] Changelog das mudanças documentado
- [ ] Versão atualizada em `pubspec.yaml` (formato: `1.2.0+120`)

### 2. Build
- [ ] Build executado: `flutter build apk --release`
- [ ] APK gerado em `build/app/outputs/flutter-apk/app-release.apk`
- [ ] APK testado em dispositivo (instalação e funcionamento)

### 3. Hash SHA-256
- [ ] Script de hash executado

**Windows:**
```powershell
.\updates\generate_hash.ps1 build\app\outputs\flutter-apk\app-release.apk
```

**Linux/Mac:**
```bash
./updates/generate_hash.sh build/app/outputs/flutter-apk/app-release.apk
```

- [ ] Hash copiado (ex: `a1b2c3d4...`)

### 4. Upload do APK
- [ ] APK renomeado (ex: `gestor-pessoal-v1.2.0.apk`)
- [ ] Upload realizado para servidor/GitHub Release
- [ ] URL do APK copiada (ex: `https://github.com/.../gestor-pessoal-v1.2.0.apk`)
- [ ] URL testada no navegador (download funciona?)

### 5. Atualização do Manifesto
- [ ] Arquivo `updates/latest.json` aberto
- [ ] `versionName` atualizada (ex: `"1.2.0"`)
- [ ] `versionCode` atualizado (ex: `120`)
- [ ] `minVersionCode` configurado (versão mínima requerida)
- [ ] `mandatory` definido (`true` ou `false`)
- [ ] `apkUrl` atualizada com URL do APK
- [ ] `apkSha256` atualizado com hash gerado
- [ ] `changelog` atualizado com lista de mudanças

**Exemplo:**
```json
{
  "versionName": "1.2.0",
  "versionCode": 120,
  "minVersionCode": 100,
  "mandatory": false,
  "apkUrl": "https://github.com/.../gestor-pessoal-v1.2.0.apk",
  "apkSha256": "a1b2c3d4e5f6...",
  "changelog": [
    "Nova funcionalidade X",
    "Melhorias de performance",
    "Correção de bugs"
  ]
}
```

### 6. Publicação do Manifesto
- [ ] `latest.json` commitado e pushed (se GitHub)
- [ ] OU `latest.json` feito upload (se servidor próprio)
- [ ] OU `firebase deploy --only hosting` (se Firebase)
- [ ] URL do manifesto testada no navegador

### 7. Testes
- [ ] Dispositivo com versão antiga do app
- [ ] App aberto e verificação automática funcionou
- [ ] OU botão "Verificar Atualizações" testado
- [ ] Modal de atualização apareceu
- [ ] Changelog exibido corretamente
- [ ] Download iniciou e concluiu
- [ ] Hash verificado com sucesso
- [ ] Instalação funcionou
- [ ] App atualizado e funcional

### 8. Documentação
- [ ] Notas de versão documentadas
- [ ] Tag criada no Git (ex: `v1.2.0`)
- [ ] Release notes publicadas (se aplicável)

## 🐛 Checklist de Troubleshooting

### Se atualização não aparecer:
- [ ] Verificar que `versionCode` remoto > local
- [ ] Testar URL do manifesto no navegador
- [ ] Verificar `flutter logs` para erros
- [ ] Confirmar que passou 24h desde última checagem (ou limpar cache)

### Se download falhar:
- [ ] URL do APK acessível no navegador
- [ ] Conexão de internet funcionando
- [ ] URL usa HTTPS (não HTTP)
- [ ] Arquivo não está corrompido

### Se hash for inválido:
- [ ] Hash gerado do APK correto (mesmo que está no servidor)
- [ ] APK não foi modificado após gerar hash
- [ ] Hash colado corretamente no manifesto (sem espaços extras)

### Se instalação falhar:
- [ ] Permissão "Fontes desconhecidas" habilitada no Android
- [ ] Keystore é a mesma usada na versão anterior
- [ ] Versão não é downgrade
- [ ] Espaço suficiente no dispositivo

## 📊 Checklist de Validação

### Antes de cada release, valide:
- [ ] Sistema de auto-update testado
- [ ] Versões incrementadas corretamente
- [ ] Changelog útil e claro
- [ ] APK assinado com keystore correta
- [ ] Hash SHA-256 validado
- [ ] URLs acessíveis publicamente
- [ ] Documentação atualizada

## 💡 Dicas

**Versionamento:**
- `versionName`: Legível para humanos (1.2.0, 2.0.1, etc)
- `versionCode`: Inteiro sempre crescente (100, 110, 120, etc)
- Nunca diminua o `versionCode`!

**Mandatory:**
- Use `mandatory: false` para atualizações normais
- Use `mandatory: true` para atualizações críticas de segurança
- Atualizações obrigatórias forçam o usuário a atualizar

**Segurança:**
- Sempre use HTTPS
- Sempre valide o hash SHA-256
- Mantenha a keystore segura
- Nunca commite senhas no Git

**Hospedagem GitHub:**
- Releases públicos: qualquer um pode baixar
- Releases privados: requer autenticação
- Raw files: use para o manifesto JSON

---

## 📚 Documentação de Referência

- **Início Rápido:** `docs/QUICK_START.md`
- **Guia Completo:** `docs/AUTO_UPDATE_GUIDE.md`
- **Assinatura Android:** `docs/ANDROID_SIGNING_SETUP.md`
- **README:** `README_AUTO_UPDATE.md`

---

**Última atualização:** 2025-01-12

**Mantenha este arquivo à mão durante os releases!**
