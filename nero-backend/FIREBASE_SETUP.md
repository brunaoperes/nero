# 🔥 Firebase Setup para Push Notifications

## 1. Criar Projeto no Firebase

1. Acesse: https://console.firebase.google.com/
2. Clique em **"Add project"** ou **"Adicionar projeto"**
3. Nome do projeto: `nero-app` (ou outro nome)
4. Desabilite Google Analytics (opcional)
5. Clique em **"Create project"**

---

## 2. Configurar Firebase Cloud Messaging (FCM)

### Para Android:

1. No console do Firebase, clique no ícone do Android
2. Package name: `com.nero.app` (ou seu package)
3. Download `google-services.json`
4. Copie para: `nero/android/app/google-services.json`

### Para iOS (opcional):

1. Clique no ícone do iOS
2. Bundle ID: `com.nero.app`
3. Download `GoogleService-Info.plist`
4. Copie para: `nero/ios/Runner/GoogleService-Info.plist`

### Para Web:

1. No console Firebase, vá em **Project Settings** → **General**
2. Role até **Your apps** → **Web apps**
3. Clique em **Add app** → Escolha **Web**
4. Nickname: `Nero Web`
5. Copie as configurações (você vai precisar no Flutter)

---

## 3. Gerar Service Account Key (Backend)

1. No console do Firebase, clique no ícone de engrenagem ⚙️
2. **Project Settings** → **Service Accounts**
3. Clique em **"Generate new private key"**
4. Confirme clicando em **"Generate key"**
5. Um arquivo `.json` será baixado

**Exemplo do arquivo baixado:**
```json
{
  "type": "service_account",
  "project_id": "nero-app-xxxxx",
  "private_key_id": "abc123...",
  "private_key": "-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n",
  "client_email": "firebase-adminsdk-xxxxx@nero-app.iam.gserviceaccount.com",
  "client_id": "123456789",
  "auth_uri": "https://accounts.google.com/o/oauth2/auth",
  "token_uri": "https://oauth2.googleapis.com/token",
  ...
}
```

---

## 4. Configurar Backend Node.js

### Opção A: Arquivo JSON (Recomendado para desenvolvimento)

1. Renomeie o arquivo baixado para `firebase-service-account.json`
2. Mova para a raiz do projeto backend:
   ```
   nero-backend/firebase-service-account.json
   ```
3. Adicione ao `.gitignore`:
   ```
   firebase-service-account.json
   ```

### Opção B: Variáveis de Ambiente (Recomendado para produção)

Edite o arquivo `.env` e adicione:

```env
FIREBASE_PROJECT_ID=nero-app-xxxxx
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nSUA_CHAVE_AQUI\n-----END PRIVATE KEY-----\n"
FIREBASE_CLIENT_EMAIL=firebase-adminsdk-xxxxx@nero-app.iam.gserviceaccount.com
```

**IMPORTANTE:** A `PRIVATE_KEY` deve estar entre aspas duplas e com os `\n` preservados!

---

## 5. Instalar Dependências

```bash
cd nero-backend
npm install firebase-admin node-cron
```

**Se tiver erro no WSL, rode no PowerShell:**

```powershell
cd C:\Users\Bruno\gestor_pessoal_ia\nero-backend
npm install firebase-admin node-cron
```

---

## 6. Habilitar Cloud Messaging API

1. Vá em: https://console.cloud.google.com/
2. Selecione seu projeto Firebase
3. Menu → **APIs & Services** → **Library**
4. Pesquise por: **"Cloud Messaging API"**
5. Clique e depois em **"Enable"**

---

## 7. Testar Configuração

Após configurar tudo, rode:

```bash
cd nero-backend
npm run dev
```

Você deve ver:
```
✓ Firebase Admin SDK initialized successfully
✓ Project ID: nero-app-xxxxx
```

---

## 8. Obter Server Key (Para o Flutter)

1. Firebase Console → **Project Settings**
2. Aba **Cloud Messaging**
3. Copie o **Server key** (você vai usar no Flutter)

---

## 📋 Checklist

- [ ] Projeto Firebase criado
- [ ] Cloud Messaging configurado
- [ ] Service Account Key baixado
- [ ] Arquivo `firebase-service-account.json` no backend OU variáveis no `.env`
- [ ] Dependências instaladas (`firebase-admin`, `node-cron`)
- [ ] Cloud Messaging API habilitada
- [ ] Backend testado e funcionando

---

## 🔒 Segurança

**NUNCA comite:**
- `firebase-service-account.json`
- Chaves privadas no código
- `.env` com credenciais reais

**Sempre use:**
- `.gitignore` para excluir arquivos sensíveis
- Variáveis de ambiente em produção
- Secrets do GitHub/Vercel para deploy

---

## 🚀 Próximos Passos

Após configurar o Firebase:
1. O backend poderá enviar push notifications
2. O Flutter receberá as notificações
3. Sistema de lembretes estará funcional

---

**Data:** 08/11/2025
