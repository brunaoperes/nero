# Nero - Gestor Pessoal Inteligente

<div align="center">
  <h3>🤖 Assistente pessoal com IA integrada</h3>
  <p>Organize sua rotina, finanças e negócios com inteligência artificial</p>
</div>

## 📱 Sobre o Projeto

Nero é um gestor pessoal multiplataforma (Android, iOS e Web) que utiliza inteligência artificial para ajudar usuários a organizar suas rotinas, tarefas e finanças.

### ✨ Funcionalidades

- **👤 Modo Pessoal**: Gestão de tarefas, rotina e finanças pessoais
- **💼 Modo Empreendedorismo**: Gestão de empresas, reuniões e relatórios
- **🤖 IA Proativa**: ChatGPT integrado via backend para sugestões inteligentes
- **💰 Open Finance**: Integração com Pluggy para sincronização bancária
- **📊 Relatórios**: Exportação em PDF e Excel
- **🌐 Offline First**: Funciona sem internet e sincroniza depois

## 🛠️ Stack Técnica

- **Framework**: Flutter 3.0+
- **Arquitetura**: Clean Architecture
- **State Management**: Riverpod
- **Navegação**: GoRouter
- **Backend**: Supabase (PostgreSQL)
- **IA**: ChatGPT (via backend)
- **Open Finance**: Pluggy

## 🏗️ Arquitetura

```
lib/
├── core/
│   ├── config/          # Rotas, tema, i18n
│   ├── services/        # Supabase, notificações
│   └── constants/       # Constantes globais
├── features/
│   ├── auth/           # Autenticação
│   ├── onboarding/     # Onboarding inteligente
│   ├── dashboard/      # Dashboard principal
│   ├── tasks/          # Gestão de tarefas
│   ├── companies/      # Gestão de empresas
│   ├── finance/        # Finanças e Open Finance
│   └── ai/             # Integração com IA
├── shared/
│   ├── widgets/        # Widgets compartilhados
│   ├── models/         # Modelos compartilhados
│   └── utils/          # Utilitários
└── main.dart
```

Cada feature segue Clean Architecture:
- **data**: datasources, repositories implementation
- **domain**: entities, repositories interface, use cases
- **presentation**: pages, providers (Riverpod), widgets

## 🎨 Design System

### Paleta de Cores Nero

| Elemento | Cor | Hex | Função |
|----------|-----|-----|--------|
| Primária | Azul Elétrico | `#0072FF` | Botões e ícones ativos |
| Secundária | Dourado Suave | `#FFD700` | IA e detalhes premium |
| Fundo Claro | Cinza Neutro | `#F5F5F5` | Fundo tema claro |
| Fundo Escuro | Preto Profundo | `#0A0A0A` | Fundo tema escuro |
| IA Accent | Azul Ciano | `#00E5FF` | Elementos da IA |

### Tipografia

- **Corpo**: Inter (Regular, Medium, SemiBold, Bold)
- **Títulos**: Poppins SemiBold

## 🚀 Como Executar

### Pré-requisitos

- Flutter 3.0+
- Dart 3.0+
- Conta Supabase
- Credenciais Google/Apple Sign-In (para autenticação social)

### Instalação

1. Clone o repositório
```bash
git clone <repo-url>
cd nero
```

2. Instale as dependências
```bash
flutter pub get
```

3. Configure as variáveis de ambiente
Crie um arquivo `.env` na raiz:
```env
SUPABASE_URL=sua_url_aqui
SUPABASE_ANON_KEY=sua_chave_aqui
```

4. Execute o projeto
```bash
flutter run
```

## 🗄️ Banco de Dados (Supabase)

### Principais Tabelas

- **users**: Dados do usuário e preferências
- **tasks**: Tarefas pessoais e empresariais
- **companies**: Empresas cadastradas
- **meetings**: Reuniões agendadas
- **transactions**: Transações financeiras
- **ai_recommendations**: Sugestões da IA
- **user_behavior**: Padrões de comportamento
- **audit_logs**: Logs de auditoria

Veja `SUPABASE_SCHEMA.md` para detalhes completos.

## 🤖 Inteligência Artificial

A IA do Nero é **executada exclusivamente no backend** por questões de segurança:

1. App envia contexto do usuário para API backend
2. Backend processa com ChatGPT
3. Recomendações são salvas no banco
4. App exibe sugestões personalizadas

### Exemplos de Sugestões

- "Você costuma concluir tarefas às 9h. Deseja criar uma rotina de foco?"
- "Sua categoria de alimentação aumentou 25% esta semana."
- "Reunião às 15h — quer revisar o checklist agora?"

## 📄 Licença

Este projeto está sob licença MIT.

## 👨‍💻 Desenvolvido com

- ❤️ e muito ☕
- Claude Code (Anthropic)
