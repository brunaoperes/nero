# 🗺️ Guia de Navegação - Nero App

## 📱 Onde Encontrar Cada Funcionalidade

---

## 🏠 Dashboard (Tela Inicial)

### Como acessar:
- Ícone **🏠 Home** na barra inferior

### O que você encontra:
1. **Header com Blur**
   - Avatar + saudação
   - Toggle de tema ☀️/🌙
   - Notificações 🔔

2. **Seção: Foco do Dia**
   - ✨ Card de IA com sugestões inteligentes
   - 📊 Widget de Tarefas (gráfico circular)
     - Mostra progresso: Concluídas/Pendentes/Total
     - Botão "Ver todas" → Lista completa de tarefas

3. **Seção: Finanças**
   - 💰 Resumo Financeiro (gráfico de barras)
     - Card de saldo com gradiente verde
     - Receitas e despesas
     - Gráfico dos últimos 7 dias
   - **🏦 Card Open Finance** ← NOVO!
     - Conecte suas contas bancárias
     - Importação automática de transações

4. **Seção: Insights da IA**
   - 📈 Padrão de Gastos
   - 💎 Meta de Economia
   - ⚡ Produtividade

5. **Speed Dial FAB** (botão + no canto)
   - 🎯 Nova Tarefa
   - 💰 Nova Transação
   - 🏢 Nova Empresa

---

## 🏦 Open Finance (Conexões Bancárias)

### ⭐ Como acessar - 3 FORMAS:

#### Opção 1: Pelo Dashboard (MAIS FÁCIL)
```
1. Abra o app
2. Role até a seção "Finanças"
3. Clique no card azul "Open Finance"
   (Logo abaixo do gráfico financeiro)
```

#### Opção 2: URL Direta
```
Digite na barra do navegador:
http://localhost:PORTA/bank-connections
```

#### Opção 3: Programaticamente
```dart
context.push('/bank-connections');
```

### O que você encontra:
- **Lista de bancos conectados**
  - Logo do banco
  - Status da conexão (Atualizado/Erro/etc)
  - Última sincronização
  - Opções: Sincronizar, Remover

- **Botão "Adicionar Banco"**
  - Abre widget Pluggy Connect
  - Conecta de forma segura com Open Finance
  - Importa transações automaticamente

- **Estados da tela:**
  - Vazio: Mensagem + botão grande "Conectar Banco"
  - Com dados: Lista de conexões + FAB para adicionar

---

## ✅ Tarefas

### Como acessar:
- Ícone **✓ Tarefas** na barra inferior

### O que você encontra:
- **Lista de todas as tarefas**
  - Filtros (Pessoal/Empresa/Recorrente)
  - Ordenação (Data/Prioridade/etc)
  - Busca por texto

- **Botão + (FAB)**
  - Abre tela "Nova Tarefa V2"

- **Clique em uma tarefa**
  - Abre detalhes da tarefa
  - Opções: Editar, Deletar, Concluir

### Criar Nova Tarefa:
```
1. Clique no + (FAB)
2. OU: Dashboard → Speed Dial FAB → "Nova Tarefa"
3. Preencha os campos
4. ✨ Use "Sugerir com IA" para preencher automaticamente
5. Clique em "Criar Tarefa"
```

---

## 🏢 Empresas

### Como acessar:
- Ícone **🏢 Empresas** na barra inferior

### O que você encontra:
- **Lista de empresas cadastradas**
  - Nome, tipo, contato
  - Status (Ativa/Inativa)

- **Botão + (FAB)**
  - Cadastrar nova empresa

- **Clique em uma empresa**
  - Detalhes completos
  - Ações rápidas:
    - 📝 Nova Tarefa (para essa empresa)
    - 📅 Agendar Reunião
    - ✓ Checklist
    - 📊 Timeline

---

## 💰 Finanças

### Como acessar:
- Ícone **💰 Finanças** na barra inferior

### O que você encontra:
- **Lista de transações**
  - Receitas (verde)
  - Despesas (vermelho)
  - Categorização automática por IA

- **Filtros e busca**
  - Por data
  - Por categoria
  - Por tipo (Receita/Despesa)

- **Botão + (FAB)**
  - Adicionar nova transação manual

- **Menu superior**
  - Relatórios financeiros
  - Gráficos detalhados
  - Exportar dados

---

## 👤 Perfil

### Como acessar:
- Ícone **👤 Perfil** na barra inferior

### O que você encontra:
- **Em desenvolvimento**
- Configurações do usuário
- Preferências do app
- Logout

---

## 🎨 Recursos Globais

### Toggle de Tema (☀️/🌙)
- **Onde:** Header do Dashboard (canto superior direito)
- **Função:** Alterna entre tema claro e escuro
- **Persistência:** Escolha é salva automaticamente

### Notificações (🔔)
- **Onde:** Header do Dashboard (canto superior direito)
- **Função:** Ver notificações e alertas

### Speed Dial FAB (+)
- **Onde:** Canto inferior direito (somente no Dashboard)
- **Ações:**
  - 🎯 Nova Tarefa
  - 💰 Nova Transação
  - 🏢 Nova Empresa
- **Como usar:** Clique no + para expandir

---

## 🔍 Busca e Filtros

### Tarefas
- **Filtrar por:**
  - Origem (Pessoal/Empresa/Recorrente)
  - Prioridade (Baixa/Média/Alta)
  - Status (Pendente/Concluído)

### Finanças
- **Filtrar por:**
  - Tipo (Receita/Despesa)
  - Categoria
  - Período (Hoje/Semana/Mês)

---

## 🚀 Atalhos Úteis

### Dashboard:
- **Scroll:** Ativa blur no header
- **Pull to refresh:** Atualiza dados
- **Speed Dial:** Adiciona rapidamente

### Nova Tarefa:
- **Sugerir com IA:** Preenche campos automaticamente
- **Data & Horário:** Card unificado
- **Origem/Prioridade:** Um clique

### Open Finance:
- **Pull to refresh:** Sincroniza todas as conexões
- **Menu (⋮):** Sincronizar ou remover banco
- **FAB +:** Adicionar nova conexão

---

## 📊 Hierarquia Visual

```
Nero App
│
├── 🏠 Dashboard (Home)
│   ├── Header (Tema, Notificações)
│   ├── Foco do Dia
│   │   ├── Card IA
│   │   └── Tarefas (gráfico)
│   ├── Finanças
│   │   ├── Resumo (gráfico)
│   │   └── 🏦 Open Finance ← CLIQUE AQUI!
│   ├── Insights IA
│   └── Speed Dial FAB
│
├── ✅ Tarefas
│   ├── Lista
│   ├── Filtros
│   └── + Nova Tarefa
│
├── 🏢 Empresas
│   ├── Lista
│   └── + Nova Empresa
│
├── 💰 Finanças
│   ├── Transações
│   ├── Relatórios
│   └── + Nova Transação
│
└── 👤 Perfil
    └── Configurações
```

---

## ⚡ Ações Rápidas

| Quero... | Onde ir |
|----------|---------|
| Conectar banco | Dashboard → Finanças → Card "Open Finance" |
| Criar tarefa com IA | Speed Dial FAB → Nova Tarefa → ✨ Sugerir com IA |
| Ver progresso de tarefas | Dashboard → Widget de Tarefas |
| Mudar tema | Dashboard → Header → ☀️/🌙 |
| Ver gastos da semana | Dashboard → Finanças → Gráfico de barras |
| Sincronizar banco | Open Finance → Menu (⋮) → Sincronizar |
| Adicionar empresa | Empresas → FAB + |
| Ver relatório financeiro | Finanças → Menu → Relatórios |

---

## 🎯 Dicas de Navegação

1. **Dashboard é sua base:** Sempre volta aqui para visão geral
2. **Speed Dial FAB:** Ações rápidas sem sair do dashboard
3. **Pull to refresh:** Funciona em todas as listas
4. **Cards clicáveis:** Quase tudo é clicável no dashboard
5. **Tema persistente:** Escolha uma vez, mantém para sempre

---

## 🆘 Não Encontrou?

Se não encontrou alguma funcionalidade:

1. **Volte ao Dashboard** (🏠 na barra inferior)
2. **Role a tela** para ver todas as seções
3. **Procure por cards azuis/gradientes** - são clicáveis
4. **Teste o Speed Dial FAB** (+) no canto
5. **Verifique se está autenticado** (algumas features requerem login)

---

**Última atualização:** 09/11/2025
**Versão do app:** 2.0.0

**Dúvidas?** Todas as funcionalidades têm tooltips e mensagens de ajuda! 💡
