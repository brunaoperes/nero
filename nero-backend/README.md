# 🤖 Nero Backend - API de Inteligência Artificial

Backend Node.js com TypeScript que fornece serviços de IA para o app Nero usando GPT-4.

## 📋 Funcionalidades

- ✅ **Categorização Automática de Transações** - GPT-4 sugere categorias para despesas e receitas
- ✅ **Recomendações Personalizadas** - Análise de comportamento e sugestões proativas
- ✅ **Análise Financeira** - Insights sobre padrões de gastos
- ✅ **API REST** - Endpoints seguros com autenticação por API Key
- ✅ **Integração com Supabase** - Acesso direto ao banco de dados

## 🚀 Instalação

```bash
# Instalar dependências
npm install

# Copiar arquivo de ambiente
cp .env.example .env

# Editar .env e adicionar suas chaves
# - OPENAI_API_KEY (obtenha em https://platform.openai.com/api-keys)
# - SUPABASE_SERVICE_KEY (obtenha no dashboard do Supabase)
# - API_KEY (crie uma chave aleatória forte)
```

## ⚙️ Configuração do .env

```env
PORT=3000
NODE_ENV=development

# OpenAI
OPENAI_API_KEY=sk-proj-xxxxxxxxxxxxx
OPENAI_MODEL=gpt-4-turbo-preview

# Supabase
SUPABASE_URL=https://yyxrgfwezgffncxuhkvo.supabase.co
SUPABASE_SERVICE_KEY=your_service_key_here
SUPABASE_ANON_KEY=your_anon_key_here

# Segurança
JWT_SECRET=your_long_random_secret_min_32_chars
API_KEY=your_api_key_here

# Rate Limiting
RATE_LIMIT_WINDOW_MS=900000
RATE_LIMIT_MAX_REQUESTS=100
```

## 🏃 Execução

```bash
# Desenvolvimento (com hot reload)
npm run dev

# Build para produção
npm run build

# Produção
npm start
```

## 📡 Endpoints da API

### Health Check

```http
GET /health
```

**Resposta:**
```json
{
  "success": true,
  "message": "Nero Backend is running",
  "timestamp": "2025-01-08T12:00:00.000Z",
  "environment": "development"
}
```

---

### Categorizar Transação

Usa GPT-4 para sugerir uma categoria para uma transação financeira.

```http
POST /api/ai/categorize-transaction
Content-Type: application/json
x-api-key: your_api_key_here

{
  "description": "Mercado Extra",
  "amount": 150.50,
  "type": "expense",
  "user_id": "uuid-do-usuario"
}
```

**Resposta:**
```json
{
  "success": true,
  "data": {
    "category": "Alimentação",
    "confidence": 0.95,
    "reasoning": "Compra em supermercado típica de alimentação"
  }
}
```

---

### Categorizar Lote de Transações

Categoriza múltiplas transações em uma única chamada.

```http
POST /api/ai/categorize-batch
Content-Type: application/json
x-api-key: your_api_key_here

{
  "transactions": [
    {
      "description": "Uber",
      "amount": 25.00,
      "type": "expense",
      "user_id": "uuid-do-usuario"
    },
    {
      "description": "Netflix",
      "amount": 39.90,
      "type": "expense",
      "user_id": "uuid-do-usuario"
    }
  ]
}
```

**Resposta:**
```json
{
  "success": true,
  "data": [
    {
      "category": "Transporte",
      "confidence": 0.98,
      "reasoning": "Serviço de transporte por aplicativo"
    },
    {
      "category": "Lazer",
      "confidence": 0.92,
      "reasoning": "Assinatura de streaming de entretenimento"
    }
  ]
}
```

---

### Gerar Recomendações

Analisa o comportamento do usuário e gera recomendações personalizadas.

```http
POST /api/ai/recommendations
Content-Type: application/json
x-api-key: your_api_key_here

{
  "user_id": "uuid-do-usuario"
}
```

**Com contexto opcional:**
```http
POST /api/ai/recommendations
Content-Type: application/json
x-api-key: your_api_key_here

{
  "user_id": "uuid-do-usuario",
  "context": {
    "tasks": [...],
    "transactions": [...]
  }
}
```

**Resposta:**
```json
{
  "success": true,
  "data": {
    "recommendations": [
      {
        "id": "uuid",
        "user_id": "uuid-do-usuario",
        "type": "financial",
        "title": "Gastos com Lazer acima da média",
        "description": "Seus gastos com lazer aumentaram 40% este mês. Considere reduzir para manter o orçamento.",
        "priority": "medium",
        "confidence": 0.85,
        "is_read": false,
        "is_dismissed": false,
        "created_at": "2025-01-08T12:00:00.000Z"
      }
    ],
    "insights": [
      "Você completou 80% das tarefas este mês - excelente!",
      "Suas despesas com alimentação estão 15% abaixo da média"
    ]
  }
}
```

## 🔒 Autenticação

Todas as rotas `/api/*` requerem autenticação por API Key.

**Header obrigatório:**
```
x-api-key: your_api_key_here
```

## 🛠️ Tecnologias

- **Node.js** + **TypeScript**
- **Express** - Framework web
- **OpenAI SDK** - Integração com GPT-4
- **Supabase JS** - Cliente do banco de dados
- **Zod** - Validação de schemas
- **Helmet** - Segurança HTTP
- **CORS** - Cross-Origin Resource Sharing
- **Morgan** - Logger HTTP
- **Compression** - Compressão de respostas

## 📁 Estrutura do Projeto

```
nero-backend/
├── src/
│   ├── config/              # Configurações (OpenAI, Supabase, env)
│   ├── controllers/         # Controladores das rotas
│   ├── services/            # Lógica de negócio (IA)
│   ├── models/              # Tipos e interfaces TypeScript
│   ├── routes/              # Definição de rotas
│   ├── middlewares/         # Autenticação, validação, erros
│   └── index.ts             # Entry point do servidor
├── package.json
├── tsconfig.json
├── .env.example
└── README.md
```

## 🧪 Testes

Para testar a API localmente, use:

```bash
# Testar health check
curl http://localhost:3000/health

# Testar categorização (substitua YOUR_API_KEY)
curl -X POST http://localhost:3000/api/ai/categorize-transaction \
  -H "Content-Type: application/json" \
  -H "x-api-key: YOUR_API_KEY" \
  -d '{
    "description": "Starbucks",
    "amount": 15.50,
    "type": "expense",
    "user_id": "test-user-id"
  }'
```

## 📊 Logs

O servidor usa Morgan para logging HTTP. Todos os requests são logados no console.

## 🚨 Tratamento de Erros

A API retorna erros no formato padrão:

```json
{
  "success": false,
  "error": "Mensagem de erro descritiva"
}
```

**Códigos HTTP:**
- `200` - Sucesso
- `400` - Bad Request (validação falhou)
- `401` - Unauthorized (API Key ausente)
- `403` - Forbidden (API Key inválida)
- `404` - Not Found
- `500` - Internal Server Error

## 🔐 Segurança

- ✅ API Key obrigatória em todas as rotas protegidas
- ✅ Helmet para headers de segurança
- ✅ CORS configurável por ambiente
- ✅ Validação de input com Zod
- ✅ Rate limiting (configurável)
- ✅ Compressão de respostas
- ✅ Logging de requisições

## 📝 Notas

- O modelo GPT-4 é mais preciso mas mais lento e caro
- Para produção, considere usar cache (Redis) para reduzir custos
- Monitore o uso da API do OpenAI no dashboard
- Implemente rate limiting para evitar abuso

## 🚀 Deploy

Recomendações para deploy em produção:

- **Render** (fácil e gratuito para começar)
- **Railway** (simples com CI/CD)
- **Vercel** (serverless functions)
- **AWS Lambda** (escalável)
- **DigitalOcean** (VPS tradicional)

## 📄 Licença

MIT

---

**Desenvolvido com ❤️ para o Nero - Gestor Pessoal Inteligente**
