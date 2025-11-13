# 🚀 Como Publicar o APK no GitHub

## ✅ APK Pronto para Publicar!

**Arquivo:** `C:\Users\Bruno\gestor_pessoal_ia\gestor-pessoal-v1.0.0.apk`
**Hash:** `3216B526263EF9A1CCC74C9F51694B0CFC540DE42831349A867BF841CB2F845D`

---

## 📤 Passo a Passo para Publicar

### 1. Fazer Push do Código

Abra o PowerShell ou Terminal e execute:

```bash
cd C:\Users\Bruno\gestor_pessoal_ia
git push origin main
```

**O que isso faz:**
- Envia o arquivo `updates/latest.json` para o GitHub
- Envia toda a documentação e código do sistema de auto-update

---

### 2. Criar GitHub Release

#### A. Acesse o GitHub:
```
https://github.com/brunaoperes/nero
```

#### B. Vá em Releases:
- Clique na aba **"Releases"** (lado direito da página)
- Clique em **"Create a new release"** (botão verde)

#### C. Preencha os campos:

**Tag version:**
```
v1.0.0
```

**Release title:**
```
Gestor Pessoal v1.0.0
```

**Description:** (copie e cole)
```markdown
# 🎉 Primeira Versão do Gestor Pessoal

Sistema de gestão pessoal com IA integrada e auto-atualização!

## ✨ Funcionalidades

- ✅ Sistema de auto-atualização implementado
- ✅ Interface moderna com Material Design 3
- ✅ Verificação automática de atualizações a cada 24h
- ✅ Tela de gerenciamento de atualizações
- ✅ Download com barra de progresso
- ✅ Verificação de integridade SHA-256

## 📲 Instalação

1. Baixe o arquivo `gestor-pessoal-v1.0.0.apk` abaixo
2. Transfira para seu celular Android
3. Instale normalmente
4. Permita "Fontes desconhecidas" se solicitado

## 🔐 Segurança

- **Hash SHA-256:** `3216B526263EF9A1CCC74C9F51694B0CFC540DE42831349A867BF841CB2F845D`
- APK assinado digitalmente
- Verificação automática de integridade

## 📖 Documentação

Veja o arquivo `INSTALACAO.md` no repositório para instruções completas.

---

**Tamanho:** 20.2 MB
**Versão:** 1.0.0
**Build:** 1
```

#### D. Anexar o APK:

1. Encontre a seção **"Attach binaries"** na parte inferior
2. Clique em **"Attach binaries by dropping them here or selecting them"**
3. Selecione o arquivo:
   ```
   C:\Users\Bruno\gestor_pessoal_ia\gestor-pessoal-v1.0.0.apk
   ```
4. Aguarde o upload completar (barra de progresso aparecerá)

#### E. Publicar:

- **NÃO** marque "This is a pre-release" (deixe desmarcado)
- **NÃO** marque "Set as the latest release" (deixe marcado - padrão)
- Clique em **"Publish release"** (botão verde)

---

### 3. Copiar URL do APK

Após publicar o release:

1. Você será redirecionado para a página do release
2. Procure o arquivo `gestor-pessoal-v1.0.0.apk` na seção "Assets"
3. Clique com botão direito no nome do arquivo
4. Selecione **"Copiar endereço do link"**

A URL deve ser:
```
https://github.com/brunaoperes/nero/releases/download/v1.0.0/gestor-pessoal-v1.0.0.apk
```

**✅ PRONTO!** O sistema de auto-update já está configurado para usar essa URL!

---

### 4. Verificar que Funcionou

#### A. Teste o manifesto:

Abra no navegador:
```
https://raw.githubusercontent.com/brunaoperes/nero/main/updates/latest.json
```

Você deve ver algo assim:
```json
{
  "versionName": "1.0.0",
  "versionCode": 1,
  "minVersionCode": 1,
  "mandatory": false,
  "apkUrl": "https://github.com/brunaoperes/nero/releases/download/v1.0.0/gestor-pessoal-v1.0.0.apk",
  "apkSha256": "3216B526263EF9A1CCC74C9F51694B0CFC540DE42831349A867BF841CB2F845D",
  "changelog": [...]
}
```

#### B. Teste o APK:

Clique na URL do APK (que você copiou no passo 3). O download deve iniciar.

---

### 5. Compartilhar com Usuários

Agora você pode compartilhar de duas formas:

#### Opção 1: Link Direto do APK
```
https://github.com/brunaoperes/nero/releases/download/v1.0.0/gestor-pessoal-v1.0.0.apk
```

#### Opção 2: Página do Release
```
https://github.com/brunaoperes/nero/releases/tag/v1.0.0
```
(Mais bonito, mostra descrição e changelog)

---

## 🔄 Próximas Atualizações

Quando você quiser lançar a versão 1.1.0:

### 1. Atualizar versão
Edite `pubspec.yaml`:
```yaml
version: 1.1.0+110
```

### 2. Fazer build
```bash
flutter build apk --release
```

### 3. Gerar hash
```powershell
.\updates\generate_hash.ps1 build\app\outputs\flutter-apk\app-release.apk
```

### 4. Atualizar `updates/latest.json`
```json
{
  "versionName": "1.1.0",
  "versionCode": 110,
  "minVersionCode": 1,
  "mandatory": false,
  "apkUrl": "https://github.com/brunaoperes/nero/releases/download/v1.1.0/gestor-pessoal-v1.1.0.apk",
  "apkSha256": "NOVO_HASH_AQUI",
  "changelog": [
    "Nova funcionalidade X",
    "Correção de bug Y"
  ]
}
```

### 5. Commit e push
```bash
git add updates/latest.json
git commit -m "Release v1.1.0"
git push origin main
```

### 6. Criar novo GitHub Release
- Tag: `v1.1.0`
- Anexar novo APK

**🎉 Todos os usuários com a versão 1.0.0 receberão notificação automática da atualização!**

---

## 🐛 Troubleshooting

### Erro ao fazer push
```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
git push origin main
```

### APK não aparece no release
- Certifique-se que o upload completou (barra verde 100%)
- Verifique o tamanho do arquivo (deve ser ~20 MB)

### URL do manifesto não funciona
- Aguarde 1-2 minutos após o push (GitHub precisa processar)
- Limpe o cache do navegador (Ctrl+F5)

### latest.json mostra versão antiga
- Certifique-se que fez o push: `git push origin main`
- Verifique no GitHub que o arquivo foi atualizado

---

## 📝 Checklist Final

Antes de publicar, verifique:

- [ ] `git push origin main` executado com sucesso
- [ ] GitHub Release criado (tag `v1.0.0`)
- [ ] APK anexado ao release
- [ ] URL do manifesto acessível:
      `https://raw.githubusercontent.com/brunaoperes/nero/main/updates/latest.json`
- [ ] URL do APK acessível e faz download
- [ ] Hash no `latest.json` confere com o APK

---

**Tudo pronto! Agora é só publicar! 🚀**

**Dúvidas?** Consulte:
- `INSTALACAO.md` - Como instalar o APK
- `docs/QUICK_START.md` - Guia rápido
- `docs/AUTO_UPDATE_GUIDE.md` - Guia completo
