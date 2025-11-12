# ✅ Checklist de Setup - Nero

Siga este checklist passo a passo para configurar o projeto.

## 📋 Antes de Começar

- [ ] Flutter instalado (3.0+)
- [ ] Git instalado
- [ ] Editor de código (VS Code/Android Studio)
- [ ] Conta no Supabase (gratuita)
- [ ] Navegador Chrome (para testar web)

## 🚀 Fase 1: Setup Básico (10 minutos)

### 1.1 Verificar Instalações

```bash
# Execute cada comando e verifique se funciona
flutter --version
git --version
dart --version
```

- [ ] Todos os comandos funcionaram sem erro
- [ ] Flutter versão 3.0 ou superior

### 1.2 Preparar Projeto

```bash
# Navegar para a pasta do projeto
cd C:\Users\awgco\gestor_pessoal_ia\nero

# Verificar arquivos
dir
```

- [ ] Pasta `lib` existe
- [ ] Arquivo `pubspec.yaml` existe
- [ ] Arquivo `README.md` existe

### 1.3 Instalar Dependências

```bash
flutter pub get
```

**Aguarde**: Este comando pode demorar 2-5 minutos na primeira vez.

- [ ] Comando executou sem erros
- [ ] Mensagem "Got dependencies!" apareceu

### 1.4 Gerar Código

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

**Aguarde**: Pode demorar 1-3 minutos.

- [ ] Comando executou sem erros
- [ ] Arquivos `.freezed.dart` e `.g.dart` foram criados

**Se houver erro**, execute:
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

## 🔧 Fase 2: Configuração Supabase (15 minutos)

### 2.1 Criar Conta e Projeto

1. Acesse: https://supabase.com
2. Faça login ou crie conta (use GitHub)
3. Clique em "New Project"
4. Preencha:
   - Name: `nero-app`
   - Database Password: [ANOTE ESTA SENHA!]
   - Region: `South America (São Paulo)` ou mais próxima
5. Aguarde 1-2 minutos

- [ ] Projeto criado com sucesso
- [ ] Dashboard do projeto abriu

### 2.2 Obter Credenciais

1. No dashboard, clique em **Settings** (engrenagem)
2. Vá em **API**
3. Copie:
   - **Project URL**
   - **anon public key**

- [ ] URL copiada (ex: https://xxxxx.supabase.co)
- [ ] Anon key copiada (começa com eyJhbGc...)

### 2.3 Configurar Variáveis de Ambiente

```bash
# Criar arquivo .env
copy .env.example .env
```

Abra o arquivo `.env` em um editor de texto e cole suas credenciais:

```env
SUPABASE_URL=https://sua-url-aqui.supabase.co
SUPABASE_ANON_KEY=sua-chave-aqui
```

- [ ] Arquivo `.env` criado
- [ ] URL preenchida
- [ ] Anon key preenchida

### 2.4 Criar Banco de Dados

1. No Supabase, vá em **SQL Editor**
2. Clique em **New query**
3. Abra o arquivo `SUPABASE_SCHEMA.sql` do projeto
4. Copie **TODO** o conteúdo
5. Cole no SQL Editor do Supabase
6. Clique em **Run** (ou Ctrl+Enter)
7. Aguarde execução

- [ ] Query executou sem erros
- [ ] Mensagem "Success. No rows returned" apareceu

### 2.5 Verificar Tabelas

1. No Supabase, vá em **Table Editor**
2. Verifique se as seguintes tabelas existem:
   - [ ] users
   - [ ] companies
   - [ ] tasks
   - [ ] meetings
   - [ ] transactions
   - [ ] ai_recommendations
   - [ ] user_behavior
   - [ ] audit_logs

**Se alguma tabela não existir**, volte ao passo 2.4.

### 2.6 Configurar Autenticação

1. No Supabase, vá em **Authentication** → **Providers**
2. Verifique se **Email** está habilitado (verde)

- [ ] Email provider habilitado

**Opcional - Desabilitar Confirmação de Email (Apenas Dev):**
1. Vá em **Authentication** → **Settings**
2. Desative **Enable email confirmations**
3. Clique em **Save**

- [ ] Confirmação de email desabilitada (opcional)

## 🧪 Fase 3: Testar Aplicativo (10 minutos)

### 3.1 Executar App

```bash
flutter run -d chrome
```

**Aguarde**: Primeira execução pode demorar 2-5 minutos.

- [ ] Comando iniciou sem erros
- [ ] Chrome abriu automaticamente
- [ ] Tela de login apareceu

**Se houver erro de "device not found":**
```bash
# Listar dispositivos
flutter devices

# Executar em dispositivo específico
flutter run -d chrome
```

### 3.2 Testar Cadastro

No app:
1. Clique em "Não tem conta? Cadastre-se"
2. Preencha:
   - Nome: Seu Nome
   - Email: seu@email.com
   - Senha: teste123 (mínimo 6 caracteres)
   - Confirmar senha: teste123
3. Clique em "Criar Conta"

**Se confirmação de email estiver ativa:**
1. Verifique sua caixa de entrada
2. Clique no link de confirmação

- [ ] Conta criada sem erro
- [ ] Redirecionou para onboarding (ou pediu confirmação de email)

### 3.3 Testar Onboarding

Complete as 4 etapas:
1. Bem-vindo → Clique "Próximo"
2. Rotina → Selecione horários → "Próximo"
3. Empresa → Marque se tem empresa → "Próximo"
4. Modo Empreendedorismo → Ative/desative → "Finalizar"

- [ ] Todas as etapas funcionaram
- [ ] Redirecionou para o dashboard

### 3.4 Verificar Dashboard

No dashboard, você deve ver:
- [ ] Card "Sugestão da IA" no topo
- [ ] Widget "Foco do Dia"
- [ ] Lista de tarefas (vazia ou com exemplos)
- [ ] Resumo financeiro
- [ ] Bottom navigation bar com 5 itens

### 3.5 Testar Logout e Login

1. Clique no ícone de configurações (canto superior direito)
   - **Nota**: Botão pode não estar implementado ainda
2. Faça logout
3. Tente fazer login novamente com as mesmas credenciais

- [ ] Logout funcionou
- [ ] Login funcionou
- [ ] Voltou para o dashboard

## 🎨 Fase 4: Verificações de Qualidade (5 minutos)

### 4.1 Análise de Código

```bash
flutter analyze
```

- [ ] Nenhum erro crítico (erros em vermelho)
- [ ] Apenas warnings ou info (aceitável)

**Se houver erros:**
```bash
flutter clean
flutter pub get
flutter analyze
```

### 4.2 Hot Reload

Com o app rodando:
1. Abra `lib/features/dashboard/presentation/pages/dashboard_page.dart`
2. Mude o texto "Olá" para "Bem-vindo"
3. Salve o arquivo (Ctrl+S)
4. No terminal, pressione `r`

- [ ] App recarregou sem reiniciar completamente
- [ ] Mudança de texto apareceu

### 4.3 Tema Escuro

No Chrome DevTools:
1. Pressione F12
2. Clique nos 3 pontinhos → More tools → Rendering
3. Em "Emulate CSS media feature", selecione "prefers-color-scheme: dark"

- [ ] App mudou para tema escuro
- [ ] Cores escuras aplicadas (fundo #0A0A0A)

## 🎯 Fase 5: Configuração do Google Sign-In (Opcional - 20 minutos)

### 5.1 Google Cloud Console

1. Acesse: https://console.cloud.google.com
2. Crie novo projeto: "Nero App"
3. Selecione o projeto
4. Vá em **APIs & Services** → **Credentials**
5. Clique em **Create Credentials** → **OAuth 2.0 Client ID**

- [ ] Projeto criado
- [ ] OAuth screen configurado

### 5.2 Web Client ID

1. Application type: **Web application**
2. Name: `Nero Web`
3. Authorized redirect URIs:
   ```
   http://localhost:3000/auth/callback
   https://seu-projeto.supabase.co/auth/v1/callback
   ```
4. Clique **Create**
5. Copie **Client ID** e **Client Secret**

- [ ] Web Client ID criado
- [ ] Credenciais copiadas

### 5.3 Configurar no Supabase

1. No Supabase, vá em **Authentication** → **Providers**
2. Encontre **Google**
3. Ative o toggle
4. Cole:
   - Client ID
   - Client Secret
5. Salve

- [ ] Google provider configurado no Supabase

### 5.4 Testar Google Sign-In

1. No app, vá para a tela de login
2. Clique em "Continuar com Google"
3. Selecione sua conta Google
4. Autorize o acesso

- [ ] Popup do Google abriu
- [ ] Login funcionou
- [ ] Redirecionou para o app

## ✅ Checklist Final

### Código
- [ ] Projeto rodando sem erros
- [ ] Hot reload funcionando
- [ ] Temas (claro/escuro) funcionando
- [ ] Navegação entre telas funciona

### Backend
- [ ] Supabase configurado
- [ ] Banco de dados criado
- [ ] 8 tabelas existem
- [ ] RLS configurado
- [ ] Autenticação funciona

### Funcionalidades
- [ ] Cadastro funciona
- [ ] Login funciona
- [ ] Onboarding completo
- [ ] Dashboard exibe
- [ ] Google Sign-In (opcional)

### Documentação
- [ ] Leu o README.md
- [ ] Leu o QUICK_START.md
- [ ] Entendeu a estrutura (ARCHITECTURE.md)
- [ ] Sabe o que implementar (NEXT_STEPS.md)

## 🎉 Parabéns!

Se você completou todos os itens marcados, **seu setup está completo!**

### 📚 Próximos Passos

1. **Comece a desenvolver**: Consulte `NEXT_STEPS.md`
2. **Implemente features**: Comece pelo módulo de tarefas
3. **Siga a arquitetura**: Leia `ARCHITECTURE.md`
4. **Se tiver problemas**: Consulte `TROUBLESHOOTING.md`

### 💡 Dicas Finais

- Mantenha `flutter run` rodando e use hot reload (salve e pressione `r`)
- Use `flutter analyze` regularmente
- Commit frequente no Git
- Teste em múltiplas plataformas (Android, iOS, Web)

---

**Tempo total estimado**: 40-60 minutos

**Dificuldade**: Média

**Pré-requisitos**: Conhecimento básico de Flutter

Se você ficou travado em algum passo, consulte `TROUBLESHOOTING.md` ou abra uma issue no GitHub!

**Boa codificação!** 🚀
