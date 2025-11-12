# 🔑 Como Obter as Credenciais do Pluggy

## Passo a Passo Detalhado

### 1️⃣ Acesse o Pluggy Dashboard
Abra no navegador: **https://dashboard.pluggy.ai/**

---

### 2️⃣ Criar conta ou fazer Login

**Se ainda não tem conta:**
- Clique em "Sign up" / "Criar conta"
- Preencha seus dados
- Verifique seu e-mail

**Se já tem conta:**
- Clique em "Sign in" / "Login"
- Entre com suas credenciais

---

### 3️⃣ Criar ou Selecionar um Time

Após fazer login, você verá uma tela para criar um "Team" (Time):

**Campos:**
- **Nome do time**: `Gestor Pessoal` (ou o nome que preferir)
- **Avatar**: Opcional
- **Quais plataformas você utilizará?**
  - ✅ Marque: **Web**
  - ✅ Marque: **Mobile** (ou iOS/Android)

Clique em **"Create"** ou **"Criar"**

---

### 4️⃣ Acessar as API Keys

Você será redirecionado para o dashboard. No **menu lateral esquerdo**, procure por:

```
📊 Dashboard
🔌 Connectors
🔑 API Keys          ← CLIQUE AQUI
👥 Users
⚙️  Settings
```

**OU**

Acesse diretamente: **https://dashboard.pluggy.ai/api-keys**

---

### 5️⃣ Visualizar suas Credenciais

Na página "API Keys", você verá:

```
┌─────────────────────────────────────────────┐
│ API Keys                                     │
├─────────────────────────────────────────────┤
│                                              │
│ Client ID                                    │
│ ┌─────────────────────────────────────────┐ │
│ │ abc123def456...                      📋 │ │ ← COPIE ESTE
│ └─────────────────────────────────────────┘ │
│                                              │
│ Client Secret                                │
│ ┌─────────────────────────────────────────┐ │
│ │ ••••••••••••••••••                  👁️  │ │ ← CLIQUE NO OLHO
│ └─────────────────────────────────────────┘ │
│                                              │
│ Environment: Sandbox / Production           │
│                                              │
└─────────────────────────────────────────────┘
```

**Importante:**
- O **Client Secret** fica oculto por padrão
- Clique no ícone do **olho 👁️** para revelar
- Ou clique no ícone de **copiar 📋** para copiar direto

---

### 6️⃣ Copiar as Credenciais

**1. Copie o Client ID:**
```
Client ID: clique no ícone 📋 ao lado
```

**2. Copie o Client Secret:**
```
Client Secret: clique no ícone 👁️ para revelar, depois 📋 para copiar
```

---

### 7️⃣ Colar no arquivo .env

Abra o arquivo `nero-backend/.env` e cole:

```env
# Pluggy (Open Finance)
PLUGGY_CLIENT_ID=cole_seu_client_id_aqui
PLUGGY_CLIENT_SECRET=cole_seu_client_secret_aqui
PLUGGY_BASE_URL=https://api.pluggy.ai
```

**Exemplo preenchido:**
```env
# Pluggy (Open Finance)
PLUGGY_CLIENT_ID=a1b2c3d4-e5f6-7890-abcd-ef1234567890
PLUGGY_CLIENT_SECRET=sk_test_9876543210abcdefghijklmnopqrstuvwxyz
PLUGGY_BASE_URL=https://api.pluggy.ai
```

---

## 🔄 Ambiente Sandbox vs Production

### Sandbox (Teste)
- Usado para desenvolvimento e testes
- Bancos de teste disponíveis
- Credenciais de teste para conectar
- **GRATUITO**

**Como usar:**
- Use as credenciais normalmente
- No app, selecione bancos que terminam com "(Sandbox)"
- Use credenciais de teste: `user-ok` / `password-ok`

### Production (Produção)
- Usado para ambiente real
- Conecta bancos reais dos usuários
- **PAGO** (verificar planos em https://pluggy.ai/pricing)

**Como ativar:**
- No dashboard, vá em **Settings** → **Environment**
- Mude de "Sandbox" para "Production"
- Novas credenciais serão geradas

---

## 🎯 Ambientes Disponíveis no Pluggy

Quando você cria uma conta no Pluggy, você recebe:

### 1. Sandbox (Padrão)
```
Client ID (Sandbox):     client_id_sandbox_...
Client Secret (Sandbox): sk_test_...
```

Este é o que você deve usar AGORA para testes!

### 2. Production (Quando ativar)
```
Client ID (Production):     client_id_prod_...
Client Secret (Production): sk_live_...
```

Use isso somente quando o app estiver pronto para produção.

---

## 📸 Onde encontrar no Dashboard

### Menu Principal (barra lateral esquerda):

```
┌──────────────────────┐
│ 🏠 Home              │
│ 📊 Overview          │
│ ────────────────────│
│ 🔌 Connectors        │  ← Lista de bancos disponíveis
│ 📁 Items             │  ← Conexões criadas (após testes)
│ 💳 Accounts          │  ← Contas sincronizadas
│ 💸 Transactions      │  ← Transações importadas
│ ────────────────────│
│ 🔑 API Keys          │  ← SUAS CREDENCIAIS AQUI!
│ 🔗 Webhooks          │
│ 📊 Logs              │
│ ────────────────────│
│ ⚙️  Settings         │
│ 👤 Profile           │
└──────────────────────┘
```

---

## ✅ Checklist de Validação

Depois de copiar as credenciais, valide:

- [ ] Client ID copiado (formato: `uuid-uuid-uuid...`)
- [ ] Client Secret copiado (formato: `sk_test_...` para sandbox)
- [ ] Colado no arquivo `nero-backend/.env`
- [ ] SEM espaços extras antes ou depois
- [ ] SEM aspas ao redor dos valores
- [ ] Backend reiniciado (`npm run dev`)

---

## 🧪 Testar as Credenciais

### Teste 1: Backend inicializa
```bash
cd nero-backend
npm run dev
```

**Saída esperada:**
```
✅ Open Finance schedulers initialized
   • Full sync: Every 6 hours
   • Outdated check: Every hour
   • Daily complete sync: 3 AM
```

**Se der erro:**
```
⚠️  Pluggy credentials not configured. Open Finance features will be disabled.
```
→ Verifique se o `.env` está correto.

### Teste 2: API funciona
```bash
curl -H "X-API-Key: YOUR_API_KEY" \
     http://localhost:3000/api/open-finance/connectors
```

**Resposta esperada:**
```json
{
  "success": true,
  "data": [
    {
      "id": 201,
      "name": "Itaú (Sandbox)",
      "imageUrl": "https://...",
      ...
    }
  ],
  "total": 50
}
```

---

## 🆘 Ainda com Dúvidas?

### Opção 1: Ver exemplo visual
Pluggy tem um vídeo no YouTube mostrando o dashboard:
- Busque: "Pluggy API tutorial"
- Ou acesse: https://docs.pluggy.ai/docs/quickstart

### Opção 2: Verificar documentação
- Docs oficiais: https://docs.pluggy.ai/
- Getting started: https://docs.pluggy.ai/docs/getting-started

### Opção 3: Suporte Pluggy
- E-mail: support@pluggy.ai
- Chat: Disponível no dashboard (canto inferior direito)

---

## 🎉 Pronto!

Depois de obter as credenciais e colocar no `.env`:

1. ✅ Reinicie o backend: `npm run dev`
2. ✅ Verifique os logs (não deve ter warning de Pluggy)
3. ✅ Teste o endpoint de connectors
4. ✅ Rode o app Flutter e teste conectar um banco!

---

**Última atualização:** 09/11/2025
