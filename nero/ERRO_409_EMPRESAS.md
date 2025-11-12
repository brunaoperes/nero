# 🐛 Erro 409 ao Criar Empresa - Diagnóstico

## Erro Reportado
```
POST https://yyxrgfwezgffncxuhkvo.supabase.co/rest/v1/companies?select=%2A 409 (Conflict)
```

## 🔍 Análise do Problema

### O que é Erro 409 (Conflict)?
O código HTTP 409 indica que há um **conflito** com o estado atual do recurso. No contexto do Supabase, geralmente ocorre quando:

1. **Violação de constraint UNIQUE** - Tentando criar um registro com valor único que já existe
2. **Problema com RLS Policies** - A policy está rejeitando o INSERT
3. **Trigger ou função do banco** - Alguma validação customizada está falhando
4. **ID duplicado** - Tentando inserir com ID que já existe

### Estrutura da Tabela Companies

Existem **duas versões diferentes** do schema:

#### Versão 1 (SUPABASE_SCHEMA.sql):
```sql
CREATE TABLE public.companies (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES public.users(id),
    name TEXT NOT NULL,
    description TEXT,
    type TEXT DEFAULT 'small',
    cnpj TEXT,
    logo_url TEXT,
    is_active BOOLEAN DEFAULT TRUE,
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);
```

#### Versão 2 (company_tables.sql):
```sql
CREATE TABLE companies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id),
  name TEXT NOT NULL,
  cnpj TEXT,
  -- ... muitos outros campos
  founded_date TIMESTAMPTZ NOT NULL,  -- OBRIGATÓRIO!
  status TEXT NOT NULL DEFAULT 'active',
  -- ...
);
```

### RLS Policies Configuradas

```sql
CREATE POLICY "Users can insert their own companies"
  ON companies FOR INSERT
  WITH CHECK (auth.uid() = user_id);
```

## 🐛 Possíveis Causas

### 1. Schema Incompatível ⚠️ **MAIS PROVÁVEL**

Se o banco estiver usando `company_tables.sql`, ele exige o campo `founded_date` que **NÃO** está sendo enviado pelo código!

**Código atual (company_remote_datasource.dart:70-79):**
```dart
.insert({
  'user_id': company.userId,
  'name': company.name,
  'description': company.description,
  'type': company.type,
  'cnpj': company.cnpj,
  'logo_url': company.logoUrl,
  'is_active': company.isActive,
  'metadata': company.metadata ?? {},
})
```

**Falta:** `founded_date`, `status`, e outros campos obrigatórios!

### 2. Empresa Já Existe

Pode haver uma empresa com o mesmo nome ou CNPJ já criada no banco.

### 3. Problema com user_id

O `user_id` sendo enviado pode não corresponder ao `auth.uid()` usado pela policy RLS.

### 4. Constraint UNIQUE não documentada

Pode haver um constraint UNIQUE no campo `name` ou `cnpj` que não está no schema.

## ✅ Soluções

### Solução 1: Verificar qual schema está no banco

Execute no SQL Editor do Supabase:

```sql
-- Ver estrutura da tabela companies
SELECT
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name = 'companies'
ORDER BY ordinal_position;

-- Ver constraints
SELECT
    tc.constraint_name,
    tc.constraint_type,
    kcu.column_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_name = 'companies';

-- Ver empresas existentes
SELECT id, user_id, name, cnpj, created_at
FROM companies
LIMIT 10;
```

### Solução 2: Ajustar o código para enviar todos os campos obrigatórios

Se o banco usa `company_tables.sql`, adicione os campos faltantes:

```dart
.insert({
  'user_id': company.userId,
  'name': company.name,
  'description': company.description,
  'type': company.type,
  'cnpj': company.cnpj,
  'logo_url': company.logoUrl,
  'is_active': company.isActive,
  'metadata': company.metadata ?? {},
  'founded_date': DateTime.now().toIso8601String(),  // ← ADICIONAR
  'status': 'active',                                 // ← ADICIONAR
})
```

### Solução 3: Melhorar tratamento de erros

Adicione logging detalhado para capturar a mensagem exata do erro:

```dart
Future<CompanyModel> createCompany(CompanyModel company) async {
  try {
    print('🔵 Tentando criar empresa: ${company.name}');
    print('🔵 User ID: ${company.userId}');

    final response = await _supabaseClient
        .from('companies')
        .insert({
          // ... campos
        })
        .select()
        .single();

    print('🟢 Empresa criada com sucesso!');
    return CompanyModel.fromJson({...});
  } catch (e) {
    print('🔴 Erro ao criar empresa: $e');
    print('🔴 Tipo do erro: ${e.runtimeType}');

    if (e is PostgrestException) {
      print('🔴 Código do erro: ${e.code}');
      print('🔴 Mensagem: ${e.message}');
      print('🔴 Detalhes: ${e.details}');
      print('🔴 Hint: ${e.hint}');
    }

    throw Exception('Erro ao criar empresa: $e');
  }
}
```

### Solução 4: Verificar RLS Policies

Execute no Supabase SQL Editor:

```sql
-- Ver todas as policies da tabela companies
SELECT
    schemaname,
    tablename,
    policyname,
    permissive,
    roles,
    cmd,
    qual,
    with_check
FROM pg_policies
WHERE tablename = 'companies';

-- Testar se o usuário atual pode inserir
SELECT auth.uid() as current_user_id;
```

### Solução 5: Limpar registros duplicados

Se houver empresas "fantasmas":

```sql
-- Ver se há empresas duplicadas pelo nome
SELECT name, COUNT(*)
FROM companies
GROUP BY name
HAVING COUNT(*) > 1;

-- Ver se há CNPJs duplicados
SELECT cnpj, COUNT(*)
FROM companies
WHERE cnpj IS NOT NULL
GROUP BY cnpj
HAVING COUNT(*) > 1;

-- Deletar empresa específica (SE NECESSÁRIO)
DELETE FROM companies
WHERE id = 'uuid-da-empresa';
```

## 🧪 Teste Rápido

1. Abra o Console do navegador (F12)
2. Tente criar uma empresa
3. Vá na aba **Network**
4. Procure pela requisição `POST /rest/v1/companies`
5. Clique nela e veja:
   - **Payload** (dados sendo enviados)
   - **Response** (resposta do servidor com detalhes do erro)
   - **Headers** (incluindo Authorization)

## 📝 Próximos Passos

1. ✅ Verificar qual schema está no banco de dados
2. ✅ Adicionar campos faltantes se necessário
3. ✅ Melhorar logging de erros
4. ✅ Verificar se há empresas duplicadas
5. ✅ Testar policies RLS
6. ✅ Ver resposta completa do erro no Network tab

---

## ✅ SOLUÇÃO ENCONTRADA!

### Causa Raiz Identificada:

O erro ocorre porque:
1. O usuário está autenticado no **Supabase Auth** (`auth.users`)
2. MAS não existe um registro correspondente na tabela **`public.users`**
3. A tabela `companies` faz referência a `public.users(id)`, não a `auth.users(id)`
4. Quando tenta criar uma empresa, a foreign key constraint falha

**Erro exato do console:**
```
PostgrestException(message: insert or update on table "companies" violates foreign key constraint "companies_user_id_fkey", code: 23503, details: Key is not present in table "users"., hint: null)
```

### Solução Implementada:

Criei o script **`FIX_USER_CREATION_TRIGGER.sql`** que:

1. **Cria uma função** `handle_new_user()` que copia automaticamente usuários de `auth.users` para `public.users`
2. **Cria um trigger** `on_auth_user_created` que executa essa função quando um usuário se registra
3. **Migra usuários existentes** que ainda não estão em `public.users`

### Como Aplicar:

1. Abra o **Supabase Dashboard**
2. Vá em **SQL Editor**
3. Cole e execute o conteúdo de `FIX_USER_CREATION_TRIGGER.sql`
4. Verifique que seu usuário foi criado em `public.users`
5. Tente criar uma empresa novamente

### Verificação Rápida:

```sql
-- Ver se seu usuário existe em public.users
SELECT id, email, name, created_at
FROM public.users
WHERE email = 'seu-email@exemplo.com';

-- Ver todos os usuários
SELECT COUNT(*) as total_users FROM public.users;
```

---

**Status:** ✅ Solução Implementada
**Prioridade:** Alta
**Data:** 2025-11-10
**Atualizado:** 2025-11-10
