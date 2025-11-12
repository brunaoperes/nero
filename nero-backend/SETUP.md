# 🚀 Setup Rápido do Nero Backend

## 📝 Pré-requisitos

- Node.js 18+ instalado
- Conta OpenAI com créditos (https://platform.openai.com)
- Projeto Supabase configurado

## ⚡ Instalação Rápida

```bash
# 1. Navegar até o diretório do backend
cd nero-backend

# 2. Instalar dependências
npm install

# 3. Criar arquivo .env
cp .env.example .env
```

## 🔑 Configurar Chaves API

### 1. OpenAI API Key

1. Acesse: https://platform.openai.com/api-keys
2. Clique em **"Create new secret key"**
3. Copie a chave (começa com `sk-proj-...`)
4. Cole no `.env`:
   ```env
   OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx
   ```

### 2. Supabase Service Key

1. Acesse seu projeto no Supabase: https://supabase.com/dashboard
2. Vá em **Settings → API**
3. Copie a **service_role key** (NÃO a anon key)
4. Cole no `.env`:
   ```env
   SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

### 3. API Key (Segurança)

Gere uma chave aleatória forte:

```bash
# No Linux/Mac/WSL
openssl rand -hex 32

# No PowerShell do Windows
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 32 | % {[char]$_})
```

Cole no `.env`:
```env
API_KEY=sua_chave_gerada_aqui
```

### 4. JWT Secret

Gere outro segredo:

```bash
# Linux/Mac/WSL
openssl rand -base64 48

# PowerShell
-join ((48..57) + (65..90) + (97..122) | Get-Random -Count 48 | % {[char]$_})
```

Cole no `.env`:
```env
JWT_SECRET=seu_secret_gerado_aqui
```

## ✅ Arquivo .env Completo

Seu `.env` deve ficar assim:

```env
PORT=3000
NODE_ENV=development

# OpenAI
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxxxxxxxxxxxxxxxxxx
OPENAI_MODEL=gpt-4-turbo-preview

# Supabase
SUPABASE_URL=https://yyxrgfwezgffncxuhkvo.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Segurança
JWT_SECRET=seu_jwt_secret_forte_com_min_32_caracteres_aqui
API_KEY=sua_api_key_forte_aqui

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

## 🏃 Executar o Servidor

```bash
# Desenvolvimento (com hot reload)
npm run dev
```

Você deve ver:

```
╔════════════════════════════════════════╗
║     🤖 Nero Backend - IA Server       ║
╠════════════════════════════════════════╣
║  Ambiente: development                 ║
║  Porta:    3000                        ║
║  URL:      http://localhost:3000       ║
╠════════════════════════════════════════╣
║  Endpoints disponíveis:                ║
║  • GET  /health                        ║
║  • POST /api/ai/categorize-transaction ║
║  • POST /api/ai/categorize-batch       ║
║  • POST /api/ai/recommendations        ║
╚════════════════════════════════════════╝
```

## 🧪 Testar a API

### 1. Health Check

```bash
curl http://localhost:3000/health
```

**Resposta esperada:**
```json
{
  "success": true,
  "message": "Nero Backend is running",
  "timestamp": "2025-01-08T..."
}
```

### 2. Testar Categorização

```bash
curl -X POST http://localhost:3000/api/ai/categorize-transaction \
  -H "Content-Type: application/json" \
  -H "x-api-key: SUA_API_KEY_AQUI" \
  -d '{
    "description": "Uber para o trabalho",
    "amount": 25.00,
    "type": "expense",
    "user_id": "test-user"
  }'
```

**Resposta esperada:**
```json
{
  "success": true,
  "data": {
    "category": "Transporte",
    "confidence": 0.98,
    "reasoning": "Serviço de transporte por aplicativo"
  }
}
```

### 3. Testar Recomendações

```bash
curl -X POST http://localhost:3000/api/ai/recommendations \
  -H "Content-Type: application/json" \
  -H "x-api-key": SUA_API_KEY_AQUI" \
  -d '{
    "user_id": "SEU_USER_ID_DO_SUPABASE"
  }'
```

## ❌ Problemas Comuns

### Erro: "OPENAI_API_KEY é obrigatória"

- Verifique se o arquivo `.env` existe
- Verifique se a chave está correta
- Certifique-se de que não há espaços extras

### Erro: "API Key inválida"

- O header `x-api-key` é obrigatório em rotas `/api/*`
- Use a mesma chave que você definiu em `API_KEY` no `.env`

### Erro: "Failed to fetch from Supabase"

- Verifique se a `SUPABASE_SERVICE_KEY` está correta
- Verifique se as tabelas existem no banco
- Certifique-se de que o RLS (Row Level Security) permite acesso com service key

### Erro de compilação TypeScript

```bash
# Limpar e reinstalar
rm -rf node_modules package-lock.json
npm install
```

## 📊 Monitorar Custos da OpenAI

1. Acesse: https://platform.openai.com/usage
2. Monitore o uso diário
3. Defina limites de gasto (Settings → Billing → Usage limits)

**Estimativa de custos:**
- GPT-4 Turbo: ~$0.01 por 1000 tokens de input
- Cada categorização: ~500 tokens = $0.005
- 1000 categorizações = ~$5.00

## 🚀 Próximos Passos

1. Integrar o backend com o app Flutter
2. Atualizar `BACKEND_API_URL` no `.env` do Nero
3. Implementar cache (Redis) para reduzir custos
4. Deploy em produção (Render, Railway, etc.)

## 📝 Notas

- **Nunca** compartilhe seu `.env` ou commit no Git
- Use variáveis de ambiente em produção
- Monitore logs para detectar problemas
- Implemente rate limiting adequado

---

**Dúvidas?** Consulte o [README.md](README.md) para mais detalhes!
