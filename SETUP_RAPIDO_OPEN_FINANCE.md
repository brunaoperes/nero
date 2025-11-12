# 🚀 Setup Rápido - Open Finance

## Ordem de Execução

### 1️⃣ Criar conta Pluggy
- Acesse: https://dashboard.pluggy.ai/
- Anote o `Client ID` e `Client Secret`

### 2️⃣ Backend - Instalar dependências
```bash
cd nero-backend
npm install
```

### 3️⃣ Backend - Configurar .env
Edite `nero-backend/.env`:
```env
PLUGGY_CLIENT_ID=seu_client_id_aqui
PLUGGY_CLIENT_SECRET=seu_client_secret_aqui
PLUGGY_BASE_URL=https://api.pluggy.ai
```

### 4️⃣ Supabase - Criar tabelas
No SQL Editor do Supabase, execute NA ORDEM:

**1. Primeiro** → `supabase_categories_setup.sql`
```sql
-- Cria a tabela categories e categorias padrão
```

**2. Depois** → `supabase_open_finance_setup.sql`
```sql
-- Cria as tabelas Open Finance
```

### 5️⃣ Flutter - Instalar dependências
```bash
cd nero
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### 6️⃣ Iniciar Backend
```bash
cd nero-backend
npm run dev
```

### 7️⃣ Rodar Flutter
```bash
cd nero
flutter run
```

---

## ✅ Verificar se funcionou

### Verificar Backend
```bash
curl http://localhost:3000/health
```

Deve retornar:
```json
{
  "success": true,
  "message": "Nero Backend is running"
}
```

### Verificar Tabelas no Supabase
```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN (
  'categories',
  'bank_connections',
  'bank_accounts',
  'synced_transactions',
  'sync_logs'
);
```

Deve listar 5 tabelas.

### Verificar Categorias
```sql
SELECT COUNT(*) FROM categories WHERE is_system = true;
```

Deve retornar 16 categorias padrão.

---

## 🎯 Testar no App

1. Navegue para a página de Open Finance
2. Clique em **"Conectar Banco"**
3. No widget Pluggy, selecione **"Itaú (Sandbox)"**
4. Use as credenciais de teste:
   - **Usuário**: `user-ok`
   - **Senha**: `password-ok`
5. Aguarde a sincronização
6. Veja as transações importadas e categorizadas!

---

## ❌ Erro: relation "categories" does not exist

**Solução**: Você executou os scripts na ordem errada.

Execute no SQL Editor do Supabase:
```sql
-- 1. Primeiro este:
-- Cole o conteúdo de supabase_categories_setup.sql

-- 2. Depois este (pode executar novamente sem problemas):
-- Cole o conteúdo de supabase_open_finance_setup.sql
```

---

## 📚 Documentação Completa
Veja `GUIA_INSTALACAO_OPEN_FINANCE.md` para detalhes completos.
