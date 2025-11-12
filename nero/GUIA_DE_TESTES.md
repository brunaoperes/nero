# 🧪 GUIA DE TESTES - Nero

Guia passo a passo para testar todas as funcionalidades do app.

---

## 📋 PRÉ-REQUISITOS

✅ App rodando no Chrome (você já fez isso!)
✅ Tela de login visível

---

## 🎯 TESTE 1: Criar Conta (2 minutos)

### Passo a Passo:

1. **Na tela de login**, procure o texto:
   ```
   "Não tem conta? Cadastre-se"
   ```

2. **Clique** nesse link

3. **Você verá a tela de cadastro** com os campos:
   - Nome
   - E-mail
   - Senha
   - Confirmar senha

4. **Preencha os dados**:
   ```
   Nome: Teste Nero
   Email: teste@nero.com
   Senha: teste123
   Confirmar senha: teste123
   ```

5. **Clique no botão "Criar Conta"**

### ✅ Resultado Esperado:

**OPÇÃO A** - Sem confirmação de email:
- Redireciona direto para o **Onboarding** (4 etapas)

**OPÇÃO B** - Com confirmação de email:
- Mostra mensagem: "Verifique seu email"
- Você precisa abrir o email e clicar no link
- Depois fazer login

### 🐛 Se der erro:

- **"Email já existe"**: Use outro email (teste2@nero.com)
- **"Senha muito curta"**: Use pelo menos 6 caracteres
- **"Erro de conexão"**: Verifique se o Supabase está configurado

---

## 🎯 TESTE 2: Onboarding (3 minutos)

Após criar a conta, você verá 4 etapas:

### 📍 ETAPA 1: Bem-vindo

**O que você vê**:
- Ícone de mão acenando 👋
- Texto: "Bem-vindo ao Nero!"
- Descrição sobre o app
- Botão "Próximo"

**O que fazer**:
- Leia o texto
- Clique em **"Próximo"**

---

### 📍 ETAPA 2: Sua Rotina

**O que você vê**:
- Título: "Sua Rotina"
- 3 cards para configurar horários:
  - Que horas você acorda?
  - Que horas começa a trabalhar?
  - Que horas termina o trabalho?

**O que fazer**:

1. **Clique no primeiro card** (acordar)
   - Um seletor de horário vai abrir
   - Escolha um horário (ex: 07:00)
   - Confirme

2. **Clique no segundo card** (começar trabalho)
   - Escolha horário (ex: 09:00)
   - Confirme

3. **Clique no terceiro card** (terminar trabalho)
   - Escolha horário (ex: 18:00)
   - Confirme

4. **Clique em "Próximo"**

**💡 Dica**: Você pode pular (não selecionar nenhum horário)

---

### 📍 ETAPA 3: Você é Empreendedor?

**O que você vê**:
- Título: "Você é empreendedor?"
- Switch: "Possuo uma empresa"
- Se ativar, aparece campo: "Nome da Empresa"

**O que fazer**:

**OPÇÃO A** - Tem empresa:
1. Ative o switch "Possuo uma empresa"
2. Digite o nome da empresa: "Minha Empresa Teste"
3. Clique "Próximo"

**OPÇÃO B** - Não tem empresa:
1. Deixe o switch desativado
2. Clique "Próximo"

---

### 📍 ETAPA 4: Modo Empreendedorismo

**O que você vê**:
- Título: "Modo Empreendedorismo"
- Switch: "Ativar Modo Empreendedorismo"
- Lista de recursos (se ativado):
  - Gestão de Empresas
  - Tarefas Empresariais
  - Reuniões
  - Relatórios
  - Timeline

**O que fazer**:

1. **Ative o switch** (para testar todos os recursos)
2. Veja a lista de recursos aparecer
3. **Clique em "Finalizar"**

### ✅ Resultado Esperado:

- Redireciona para o **Dashboard**
- Os dados foram salvos no Supabase

---

## 🎯 TESTE 3: Dashboard (5 minutos)

Após completar o onboarding, você verá o **Dashboard Principal**.

### 🔍 O Que Verificar:

#### 1️⃣ **Header (Topo)**

**O que você vê**:
- Texto: "Olá, [Seu Nome]" ou "Olá, Usuário"
- Ícone de notificações (sino)
- Ícone de configurações (engrenagem)

**O que fazer**:
- ✅ Confirme que seu nome aparece
- ✅ Clique no ícone de notificações (pode não fazer nada ainda)
- ✅ Clique no ícone de configurações (pode não fazer nada ainda)

---

#### 2️⃣ **Card de Sugestão da IA** (Primeiro card)

**O que você vê**:
- Card com gradiente azul/ciano
- Badge: "Sugestão da IA" com ícone ✨
- Mensagem exemplo: "Você costuma concluir tarefas às 9h. Deseja criar uma rotina de foco nesse horário?"
- Botões: "Não, obrigado" e "Sim, vamos lá!"

**O que fazer**:
- ✅ Confirme que o card aparece
- ✅ Clique em "Não, obrigado" (pode não fazer nada ainda)
- ✅ Verifique o estilo visual (gradiente azul)

---

#### 3️⃣ **Widget de Foco do Dia**

**O que você vê**:
- Card com ícone de foco
- Texto: "Falta X tarefa(s) para zerar o dia"
- Barra de progresso
- Texto: "X de Y concluídas" e "Z%"

**O que fazer**:
- ✅ Confirme que aparece
- ✅ Veja o progresso (provavelmente 0/0 = 0%)

---

#### 4️⃣ **Seção "Tarefas de Hoje"**

**O que você vê**:
- Título: "Tarefas de Hoje"
- Link: "Ver todas"
- Lista de tarefas (pode ter exemplos ou estar vazia)

**Tarefas exemplo** (se aparecerem):
- Fazer compras no mercado 🔵 (pessoal)
- Revisar relatório mensal 🟡 (empresa)
- Ligar para cliente ✅ (IA)
- Preparar apresentação 🔵 (pessoal)

**O que fazer**:
- ✅ Clique no checkbox de uma tarefa (marca como concluída)
- ✅ Clique em "Ver todas" (pode redirecionar ou não fazer nada)
- ✅ Clique em uma tarefa (pode abrir detalhes ou não)

---

#### 5️⃣ **Seção "Resumo Financeiro"**

**O que você vê**:
- Título: "Resumo Financeiro"
- Link: "Ver detalhes"
- Card com:
  - Período: "Esta Semana"
  - Receitas: R$ 5.000,00 (exemplo)
  - Despesas: R$ 3.200,00 (exemplo)
  - Saldo: R$ 1.800,00 (verde se positivo)

**O que fazer**:
- ✅ Confirme que aparece
- ✅ Clique em "Ver detalhes" (pode não fazer nada ainda)

---

#### 6️⃣ **Bottom Navigation Bar** (Barra inferior)

**O que você vê**:
- 5 ícones:
  1. 🏠 Home (ativo - azul)
  2. ✓ Tarefas
  3. 💼 Empresas
  4. 💰 Finanças
  5. 👤 Perfil

**O que fazer**:
- ✅ Clique em cada ícone
- ⚠️ A maioria pode não fazer nada ainda (não implementado)
- ✅ "Home" deve estar destacado (azul)

---

#### 7️⃣ **Botão Flutuante "+"** (FAB - canto inferior direito)

**O que você vê**:
- Botão redondo azul com ícone "+"

**O que fazer**:
- ✅ Clique no botão "+"
- ✅ Deve abrir um diálogo: "Nova Tarefa"
- ✅ Digite um título: "Minha primeira tarefa"
- ✅ Clique em "Criar"
- ✅ Deve aparecer mensagem: "Tarefa criada com sucesso!"

---

## 🎯 TESTE 4: Logout e Login Novamente (2 minutos)

### Fazer Logout:

**Como fazer**:
- No momento, o botão de logout pode não estar implementado
- Se estiver, procure em:
  - Ícone de configurações > Logout
  - Menu > Sair
  - Ícone de perfil > Logout

**Se não encontrar logout**:
- Abra o DevTools do Chrome (F12)
- Vá em Application > Storage > Clear site data
- Recarregue a página (F5)

---

### Fazer Login:

1. Você verá a tela de login novamente
2. **Preencha**:
   ```
   Email: teste@nero.com
   Senha: teste123
   ```
3. **Clique em "Entrar"**

### ✅ Resultado Esperado:

- Login bem-sucedido
- Redireciona para o Dashboard (pula o onboarding pois já foi feito)
- Seus dados estão salvos

---

## 🎯 TESTE 5: Verificar Dados no Supabase (2 minutos)

### Como Verificar:

1. **Abra o Supabase**:
   ```
   https://supabase.com/dashboard/project/yyxrgfwezgffncxuhkvo
   ```

2. **Vá em "Table Editor"**

3. **Clique na tabela "users"**

### ✅ O que você deve ver:

- Seu usuário cadastrado com:
  - ✅ ID
  - ✅ Email (teste@nero.com)
  - ✅ Nome (Teste Nero)
  - ✅ entrepreneur_mode (true/false)
  - ✅ wake_up_time, work_start_time, etc
  - ✅ onboarding_completed (true)
  - ✅ created_at (data/hora)

4. **Clique na tabela "companies"** (se você criou empresa)

### ✅ O que você deve ver:

- Sua empresa com:
  - ✅ Nome da empresa
  - ✅ user_id (seu ID)
  - ✅ is_active (true)

---

## 📊 CHECKLIST DE TESTES

Marque o que você testou:

### Autenticação
- [ ] Criar conta nova
- [ ] Fazer login
- [ ] Fazer logout
- [ ] Dados salvos no Supabase

### Onboarding
- [ ] Etapa 1: Bem-vindo
- [ ] Etapa 2: Horários funcionam
- [ ] Etapa 3: Campo de empresa aparece
- [ ] Etapa 4: Lista de recursos aparece
- [ ] Dados salvos após finalizar

### Dashboard
- [ ] Nome do usuário aparece no header
- [ ] Card de IA é exibido
- [ ] Widget de foco é exibido
- [ ] Lista de tarefas é exibida
- [ ] Resumo financeiro é exibido
- [ ] Bottom navigation funciona
- [ ] Botão "+" abre diálogo
- [ ] Diálogo de criar tarefa funciona

### Visual
- [ ] Tema escuro/claro funciona
- [ ] Cores Nero (azul + dourado)
- [ ] Cards têm bordas arredondadas
- [ ] Ícones aparecem corretamente
- [ ] Fonte Inter/Poppins carrega

---

## 🐛 PROBLEMAS COMUNS

### "Email já existe"
→ Use outro email ou faça login

### "Invalid login credentials"
→ Verifique email e senha

### Página em branco
→ Abra Console (F12) e veja erros

### "relation does not exist"
→ Você não executou o SQL no Supabase

### Botões não funcionam
→ Normal! Algumas features não estão implementadas ainda

---

## ✅ RESULTADO FINAL

Se você completou todos os testes:

```
✅ Autenticação funciona
✅ Onboarding funciona
✅ Dashboard carrega
✅ Dados são salvos no Supabase
✅ App está 100% funcional para começar desenvolvimento!
```

---

## 🎉 PRÓXIMO PASSO

Agora que testou e tudo funciona:

1. **Leia**: `AGORA_QUE_FUNCIONOU.md`
2. **Comece a desenvolver**: Implementar features restantes
3. **Consulte**: `COMANDOS_UTEIS.md` quando precisar

---

**💡 Dica**: Tire screenshots dos testes e guarde para documentação!

**🚀 Pronto para desenvolver!**
