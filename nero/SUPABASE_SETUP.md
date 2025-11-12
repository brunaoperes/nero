# Configuração do Supabase para o Nero

Este guia rápido mostra como configurar o Supabase para o aplicativo Nero.

## 📝 Passo a Passo

### 1. Criar Conta no Supabase

1. Acesse: https://supabase.com
2. Clique em "Start your project"
3. Faça login com GitHub ou e-mail

### 2. Criar Novo Projeto

1. No dashboard, clique em "New Project"
2. Preencha:
   - **Name**: nero-app (ou o nome que preferir)
   - **Database Password**: Anote esta senha! (será necessária para backups)
   - **Region**: Escolha a mais próxima (ex: South America (São Paulo))
   - **Pricing Plan**: Free (suficiente para desenvolvimento)
3. Clique em "Create new project"
4. Aguarde 1-2 minutos enquanto o projeto é criado

### 3. Obter Credenciais

Após a criação, você verá o dashboard do projeto:

1. Clique em **Settings** (ícone de engrenagem no menu lateral)
2. Vá em **API**
3. Copie as seguintes informações:

```
Project URL: https://xxxxxxxxxxxxx.supabase.co
anon public key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 4. Configurar Variáveis de Ambiente

No arquivo `.env` do projeto Nero, adicione:

```env
SUPABASE_URL=https://xxxxxxxxxxxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

### 5. Criar Banco de Dados

1. No dashboard do Supabase, vá em **SQL Editor**
2. Clique em **New query**
3. Abra o arquivo `SUPABASE_SCHEMA.sql` do projeto Nero
4. Copie TODO o conteúdo do arquivo
5. Cole no editor SQL do Supabase
6. Clique em **Run** (ou pressione Ctrl+Enter)
7. Aguarde a execução (pode demorar alguns segundos)

**Resultado esperado**: Mensagem "Success. No rows returned"

### 6. Verificar Tabelas Criadas

1. Vá em **Table Editor** no menu lateral
2. Você deve ver as seguintes tabelas:
   - users
   - companies
   - tasks
   - meetings
   - transactions
   - ai_recommendations
   - user_behavior
   - audit_logs

Se todas as tabelas estiverem lá, parabéns! ✅

### 7. Configurar Autenticação

#### 7.1. Habilitar Providers

1. Vá em **Authentication** → **Providers**
2. Verifique se **Email** está habilitado (padrão)

#### 7.2. Configurar Google Sign-In

1. Ainda em **Providers**, encontre **Google**
2. Clique em **Google** para expandir
3. Ative o toggle **Enable Sign in with Google**
4. Você precisará de:
   - **Client ID** (do Google Cloud Console)
   - **Client Secret** (do Google Cloud Console)

**Como obter Client ID e Secret:**

1. Acesse: https://console.cloud.google.com
2. Crie um novo projeto (ou use existente)
3. Vá em **APIs & Services** → **Credentials**
4. Clique em **Create Credentials** → **OAuth 2.0 Client IDs**
5. Configure:
   - Application type: **Web application**
   - Name: Nero Auth
   - Authorized redirect URIs:
     ```
     https://xxxxxxxxxxxxx.supabase.co/auth/v1/callback
     ```
     (substitua pelo seu Project URL do Supabase)
6. Copie o **Client ID** e **Client Secret**
7. Cole no Supabase em **Authentication** → **Providers** → **Google**

#### 7.3. Configurar Apple Sign-In (Opcional)

Se você tem conta Apple Developer:

1. Vá em **Authentication** → **Providers**
2. Encontre **Apple**
3. Siga o guia do Supabase para configurar

### 8. Configurar RLS (Row Level Security)

O script SQL já configurou as políticas RLS, mas vamos verificar:

1. Vá em **Authentication** → **Policies**
2. Verifique se existem políticas para cada tabela
3. Deve haver políticas como:
   - "Users can view own data"
   - "Users can update own data"
   - etc.

Se não houver políticas, execute novamente o script `SUPABASE_SCHEMA.sql`.

### 9. Testar Conexão

Execute o app Nero e tente:

1. **Criar conta**: Deve enviar e-mail de confirmação
2. **Fazer login**: Deve funcionar após confirmar e-mail
3. **Google Sign-In**: Deve abrir popup do Google

Se tudo funcionar, a configuração está correta! 🎉

## 🔧 Configurações Avançadas

### Desabilitar Confirmação de E-mail (Apenas Desenvolvimento)

**⚠️ Apenas para desenvolvimento! Não use em produção!**

1. Vá em **Authentication** → **Settings**
2. Desative **Enable email confirmations**

### Configurar E-mail Customizado

1. Vá em **Authentication** → **Email Templates**
2. Customize os templates de:
   - Confirmação de e-mail
   - Recuperação de senha
   - Convite

### Configurar Domínio Customizado

Para produção, configure um domínio:

1. Vá em **Settings** → **Custom Domains**
2. Siga as instruções para configurar DNS

## 📊 Monitoramento

### Visualizar Usuários

1. Vá em **Authentication** → **Users**
2. Veja todos os usuários cadastrados
3. Você pode deletar usuários aqui (desenvolvimento)

### Visualizar Dados

1. Vá em **Table Editor**
2. Selecione uma tabela (ex: `users`, `tasks`)
3. Visualize, edite ou delete dados

### Logs

1. Vá em **Logs**
2. Veja logs de:
   - API
   - Database
   - Auth

## 🐛 Solução de Problemas

### Erro: "JWT expired" ou "Invalid token"

- Verifique se o `SUPABASE_ANON_KEY` está correto no `.env`
- Certifique-se de usar a **anon key**, não a **service_role key**

### Erro: "Row Level Security policy violation"

- Verifique se as políticas RLS estão criadas
- Execute o script SQL novamente

### Erro: "relation does not exist"

- A tabela não foi criada
- Execute o script `SUPABASE_SCHEMA.sql` novamente

### Não recebe e-mail de confirmação

1. Verifique **Authentication** → **Settings**
2. Veja se **Enable email confirmations** está ativo
3. Verifique a pasta de spam
4. Para desenvolvimento, desative a confirmação

## 📚 Recursos

- **Documentação Oficial**: https://supabase.com/docs
- **Guia de Auth**: https://supabase.com/docs/guides/auth
- **API Reference**: https://supabase.com/docs/reference/javascript/introduction
- **Exemplos**: https://github.com/supabase/supabase/tree/master/examples

## ✅ Checklist Final

Antes de começar o desenvolvimento, verifique:

- [ ] Projeto Supabase criado
- [ ] Credenciais copiadas para `.env`
- [ ] Script SQL executado sem erros
- [ ] Todas as 8 tabelas criadas
- [ ] RLS habilitado e políticas criadas
- [ ] Provider de Email habilitado
- [ ] Google Sign-In configurado (opcional)
- [ ] Testado criação de conta no app
- [ ] Testado login no app

## 🎉 Próximo Passo

Com o Supabase configurado, você está pronto para desenvolver!

Consulte `NEXT_STEPS.md` para ver o roadmap de desenvolvimento.

---

**Dica**: Salve as credenciais do Supabase em um gerenciador de senhas seguro!
