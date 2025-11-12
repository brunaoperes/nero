# Próximos Passos - Nero

Este documento lista as features e melhorias pendentes para completar o MVP do Nero.

## ✅ Implementado (MVP v0.1)

- [x] Estrutura do projeto com Clean Architecture
- [x] Configuração do Riverpod para state management
- [x] Sistema de temas (claro/escuro) com paleta Nero
- [x] Configuração do GoRouter para navegação
- [x] Integração com Supabase
- [x] Módulo de autenticação (login, registro, Google)
- [x] Tela de onboarding inteligente
- [x] Dashboard com widgets principais
- [x] Widgets compartilhados (AI Card, Focus, Tasks, Finance)
- [x] Modelos de dados (User, Task, Company, Transaction, etc)
- [x] Schema SQL completo do Supabase
- [x] Documentação de arquitetura e instalação

## 🚧 Pendente (MVP v1.0)

### 1. Módulo de Tarefas Completo

**Prioridade: Alta** 🔴

- [ ] Página de listagem de todas as tarefas
- [ ] Página de detalhes da tarefa
- [ ] Criar, editar e excluir tarefas
- [ ] Filtros (por status, origem, prioridade, data)
- [ ] Ordenação (por data, prioridade, alfabética)
- [ ] Busca de tarefas
- [ ] Tarefas recorrentes (diária, semanal, mensal)
- [ ] Notificações de tarefas vencidas
- [ ] Arrastar para completar (swipe gesture)
- [ ] Subtarefas/checklists

**Arquivos a criar**:
```
features/tasks/
├── data/
│   ├── datasources/task_remote_datasource.dart
│   └── repositories/task_repository_impl.dart
├── domain/
│   ├── repositories/task_repository.dart
│   └── usecases/
│       ├── create_task.dart
│       ├── update_task.dart
│       ├── delete_task.dart
│       └── get_tasks.dart
└── presentation/
    ├── pages/
    │   ├── tasks_list_page.dart
    │   └── task_detail_page.dart
    ├── providers/tasks_providers.dart
    └── widgets/
        ├── task_filter_widget.dart
        └── task_form_widget.dart
```

### 2. Módulo de Empresas

**Prioridade: Alta** 🔴

- [ ] Página de listagem de empresas
- [ ] Página de detalhes da empresa
- [ ] Criar, editar e excluir empresas
- [ ] Dashboard da empresa individual
- [ ] Timeline de ações da empresa
- [ ] Tarefas específicas da empresa
- [ ] Checklists automáticos (financeiro semanal, etc)
- [ ] Relatórios por empresa

**Arquivos a criar**:
```
features/companies/
├── data/...
├── domain/...
└── presentation/
    ├── pages/
    │   ├── companies_list_page.dart
    │   ├── company_detail_page.dart
    │   └── company_dashboard_page.dart
    └── widgets/
        ├── company_card_widget.dart
        └── company_timeline_widget.dart
```

### 3. Módulo de Finanças

**Prioridade: Média** 🟡

- [ ] Página de transações
- [ ] Adicionar transação manual
- [ ] Editar e excluir transações
- [ ] Confirmar categorias sugeridas pela IA
- [ ] Gráficos de receitas/despesas
- [ ] Filtros por categoria, data, tipo
- [ ] Exportar relatório (PDF/Excel)
- [ ] Integração com Open Finance (Pluggy) via backend
- [ ] Sincronização automática de contas

**Arquivos a criar**:
```
features/finance/
├── presentation/
│   ├── pages/
│   │   ├── transactions_page.dart
│   │   ├── transaction_detail_page.dart
│   │   └── finance_reports_page.dart
│   └── widgets/
│       ├── transaction_card.dart
│       ├── category_chip.dart
│       └── finance_chart.dart
└── ...
```

### 4. Módulo de Reuniões

**Prioridade: Média** 🟡

- [ ] Página de listagem de reuniões
- [ ] Criar, editar e excluir reuniões
- [ ] Campos: título, descrição, local, data/hora
- [ ] Lista de participantes
- [ ] Agenda da reunião
- [ ] Notas da reunião
- [ ] Notificações de reuniões próximas
- [ ] Integração com calendário do dispositivo

**Arquivos a criar**:
```
features/meetings/
└── presentation/
    ├── pages/
    │   ├── meetings_list_page.dart
    │   └── meeting_detail_page.dart
    └── widgets/
        └── meeting_card.dart
```

### 5. Integração com IA (ChatGPT)

**Prioridade: Alta** 🔴

- [ ] Criar backend API em Node.js/Python
- [ ] Endpoint para processar contexto do usuário
- [ ] Endpoint para gerar recomendações
- [ ] Salvar recomendações no Supabase
- [ ] Implementar serviço de análise de comportamento
- [ ] Criar sistema de pontuação de confiança
- [ ] Notificações push de sugestões da IA
- [ ] Tela "O que o Nero aprende sobre você"
- [ ] Aceitar/rejeitar sugestões
- [ ] Histórico de recomendações

**Backend a criar**:
```
nero-backend/
├── src/
│   ├── services/
│   │   ├── openai.service.js
│   │   └── behavior.service.js
│   ├── controllers/
│   │   └── ai.controller.js
│   └── routes/
│       └── ai.routes.js
└── package.json
```

### 6. Sistema de Notificações

**Prioridade: Média** 🟡

- [ ] Configurar Firebase Cloud Messaging
- [ ] Notificações de tarefas vencidas
- [ ] Notificações de reuniões próximas
- [ ] Notificações de sugestões da IA
- [ ] Central de notificações no app
- [ ] Abas "IA" e "Sistema"
- [ ] Marcar como lida
- [ ] Configurações de notificações

### 7. Modo Offline

**Prioridade: Baixa** 🟢

- [ ] Configurar Hive/Drift para banco local
- [ ] Sincronização automática ao voltar online
- [ ] Indicador de status offline
- [ ] Queue de ações pendentes
- [ ] Resolver conflitos de sincronização

### 8. Internacionalização (i18n)

**Prioridade: Baixa** 🟢

- [ ] Configurar pacote `flutter_localizations`
- [ ] Criar arquivos de tradução (pt-BR, en-US)
- [ ] Extrair todos os textos hardcoded
- [ ] Implementar seletor de idioma
- [ ] Traduzir todas as telas

### 9. Relatórios

**Prioridade: Média** 🟡

- [ ] Template "Relatório da Semana"
- [ ] Template "Relatório Financeiro"
- [ ] Template "Relatório Empresarial"
- [ ] Exportar PDF com logo Nero
- [ ] Exportar Excel
- [ ] Gráficos e visualizações
- [ ] Compartilhar relatórios

### 10. Perfil e Configurações

**Prioridade: Média** 🟡

- [ ] Página de perfil do usuário
- [ ] Editar dados pessoais
- [ ] Alterar foto de perfil
- [ ] Página de configurações
- [ ] Alternar tema (claro/escuro)
- [ ] Alternar modo empreendedorismo
- [ ] Configurar notificações
- [ ] Alterar senha
- [ ] Excluir conta
- [ ] Sobre o app

## 🔧 Melhorias Técnicas

### Testes

- [ ] Testes unitários para repositories
- [ ] Testes unitários para use cases
- [ ] Testes de widget para páginas principais
- [ ] Testes de integração para fluxos críticos
- [ ] Configurar coverage mínimo (80%)

### Performance

- [ ] Implementar lazy loading em listas
- [ ] Adicionar cache de imagens
- [ ] Otimizar queries do Supabase
- [ ] Implementar pagination em todas as listas
- [ ] Analisar bundle size

### CI/CD

- [ ] Configurar GitHub Actions
- [ ] Build automático (Android/iOS)
- [ ] Testes automáticos
- [ ] Deploy automático para Firebase App Distribution
- [ ] Versionamento semântico automático

### Documentação

- [ ] Documentar todos os providers
- [ ] Adicionar exemplos de uso
- [ ] Criar guia de contribuição
- [ ] Documentar APIs do backend

## 🎨 Melhorias de UI/UX

- [ ] Animações de transição entre telas
- [ ] Feedback haptic em ações importantes
- [ ] Skeleton loaders
- [ ] Empty states com ilustrações
- [ ] Error states com ações de recuperação
- [ ] Onboarding mais interativo (tutorial)
- [ ] Dark mode refinado
- [ ] Accessibility (a11y)

## 📱 Features Futuras (v2.0+)

### Backend Completo

- [ ] API REST completa em Node.js/Python
- [ ] Autenticação JWT
- [ ] Rate limiting
- [ ] Logs estruturados
- [ ] Monitoring (Sentry, DataDog)

### Open Finance (Pluggy)

- [ ] Integração completa com Pluggy
- [ ] Conectar contas bancárias
- [ ] Sincronização automática de transações
- [ ] Categorização inteligente com IA
- [ ] Previsões financeiras

### IA Avançada

- [ ] Análise preditiva de gastos
- [ ] Sugestões de economia
- [ ] Otimização de rotina
- [ ] Assistente por voz
- [ ] Chat com o Nero

### Recursos Sociais

- [ ] Compartilhar tarefas com equipe
- [ ] Colaboração em empresas
- [ ] Timeline pública
- [ ] Gamificação (badges, níveis)

### Integrações

- [ ] Google Calendar
- [ ] Trello/Asana
- [ ] Slack
- [ ] WhatsApp Business
- [ ] E-mail

## 📅 Roadmap Sugerido

### Sprint 1 (2 semanas)
- Módulo de Tarefas Completo
- Sistema de Notificações básico

### Sprint 2 (2 semanas)
- Módulo de Empresas
- Módulo de Reuniões

### Sprint 3 (2 semanas)
- Módulo de Finanças
- Backend API inicial

### Sprint 4 (2 semanas)
- Integração com IA
- Relatórios

### Sprint 5 (1 semana)
- Perfil e Configurações
- Testes e correções

### Sprint 6 (1 semana)
- Polish final
- Deploy nas lojas

## 🎯 Definição de Pronto (DoD)

Para considerar uma feature completa:

- [ ] Código implementado seguindo Clean Architecture
- [ ] Testes unitários com cobertura > 80%
- [ ] Testes de widget para UI
- [ ] Documentação atualizada
- [ ] Code review aprovado
- [ ] Sem erros no analyzer
- [ ] Testado em Android e iOS
- [ ] Acessibilidade verificada

## 📞 Contato

Dúvidas sobre o desenvolvimento? Entre em contato:
- GitHub Issues: [link]
- Discord: [link]
- E-mail: dev@nero.app

---

**Última atualização**: 2025-11-07
