# 🏦 Guia de Instalação - Open Finance (Pluggy)

Este guia contém todos os passos necessários para configurar e testar a integração Open Finance no Nero.

---

## 📋 Índice
1. [Configuração da Conta Pluggy](#1-configuração-da-conta-pluggy)
2. [Configuração do Backend](#2-configuração-do-backend)
3. [Configuração do Banco de Dados](#3-configuração-do-banco-de-dados)
4. [Configuração do Flutter](#4-configuração-do-flutter)
5. [Testes](#5-testes)

---

## 1. Configuração da Conta Pluggy

### 1.1 Criar Conta
1. Acesse: https://dashboard.pluggy.ai/
2. Crie uma conta ou faça login
3. Complete o cadastro do time:
   - **Nome do time**: Gestor Pessoal (ou o que preferir)
   - **Plataformas**: Selecione **Web** e **Mobile**

### 1.2 Obter Credenciais
1. No dashboard, vá em **"API Keys"** no menu lateral
2. Copie:
   - `Client ID`
   - `Client Secret`

---

## 2. Configuração do Backend

### 2.1 Instalar Dependências
```bash
cd nero-backend
npm install
```

As dependências `axios` e `node-cron` já foram adicionadas ao `package.json`.

### 2.2 Configurar Variáveis de Ambiente
Edite o arquivo `nero-backend/.env` e adicione:

```env
# Pluggy (Open Finance)
PLUGGY_CLIENT_ID=seu_client_id_aqui
PLUGGY_CLIENT_SECRET=seu_client_secret_aqui
PLUGGY_BASE_URL=https://api.pluggy.ai
```

**IMPORTANTE**: Substitua `seu_client_id_aqui` e `seu_client_secret_aqui` pelas credenciais obtidas no passo 1.2.

### 2.3 Iniciar o Backend
```bash
cd nero-backend
npm run dev
```

Você deverá ver no console:
```
✅ Open Finance schedulers initialized
   • Full sync: Every 6 hours
   • Outdated check: Every hour
   • Daily complete sync: 3 AM
```

---

## 3. Configuração do Banco de Dados

### 3.1 Executar Scripts SQL no Supabase

**Passo 1: Criar tabela de categorias (se ainda não existir)**

1. Acesse o **Supabase Dashboard**: https://supabase.com/dashboard
2. Selecione seu projeto
3. Vá em **SQL Editor** (menu lateral)
4. Crie uma nova query
5. Cole o conteúdo do arquivo `supabase_categories_setup.sql`
6. Clique em **"Run"** para executar

**Passo 2: Criar tabelas Open Finance**

1. No mesmo **SQL Editor**
2. Crie uma nova query
3. Cole o conteúdo do arquivo `supabase_open_finance_setup.sql`
4. Clique em **"Run"** para executar

Este script irá criar:
- ✅ Tabela `bank_connections` (conexões bancárias)
- ✅ Tabela `bank_accounts` (contas bancárias)
- ✅ Tabela `synced_transactions` (transações sincronizadas)
- ✅ Tabela `sync_logs` (logs de sincronização)
- ✅ Políticas RLS (Row Level Security)
- ✅ Triggers e Views úteis

### 3.2 Verificar Tabelas Criadas
Execute esta query no SQL Editor para verificar:

```sql
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('bank_connections', 'bank_accounts', 'synced_transactions', 'sync_logs');
```

Você deve ver 4 tabelas listadas.

---

## 4. Configuração do Flutter

### 4.1 Instalar Dependências
```bash
cd nero
flutter pub get
```

### 4.2 Gerar Código Freezed
```bash
cd nero
flutter pub run build_runner build --delete-conflicting-outputs
```

Este comando irá gerar os arquivos `.freezed.dart` e `.g.dart` para os novos models:
- `bank_connector_model.freezed.dart`
- `bank_connection_model.freezed.dart`
- `bank_account_model.freezed.dart`
- `synced_transaction_model.freezed.dart`

### 4.3 Adicionar Rota no Router

Abra o arquivo `nero/lib/core/config/router/app_router.dart` e adicione a rota para Open Finance:

```dart
import 'package:nero/features/open_finance/presentation/pages/bank_connections_page.dart';

// Na lista de rotas, adicione:
GoRoute(
  path: '/bank-connections',
  name: 'bank-connections',
  builder: (context, state) => const BankConnectionsPage(),
),
```

### 4.4 Adicionar ao Menu (Opcional)

Para adicionar um botão no menu ou dashboard, você pode usar:

```dart
ElevatedButton.icon(
  onPressed: () {
    context.push('/bank-connections');
  },
  icon: const Icon(Icons.account_balance),
  label: const Text('Open Finance'),
)
```

---

## 5. Testes

### 5.1 Testar Backend

#### Teste 1: Health Check
```bash
curl http://localhost:3000/health
```

Resposta esperada:
```json
{
  "success": true,
  "message": "Nero Backend is running",
  "timestamp": "2025-11-09T..."
}
```

#### Teste 2: Listar Conectores
```bash
curl -H "X-API-Key: YOUR_API_KEY" \
     http://localhost:3000/api/open-finance/connectors
```

Resposta esperada: Lista de bancos disponíveis.

### 5.2 Testar Flutter

1. **Inicie o app Flutter**:
   ```bash
   cd nero
   flutter run
   ```

2. **Navegue até a página de Open Finance**:
   - Use o menu ou navegue para `/bank-connections`

3. **Teste o fluxo completo**:
   - ✅ Ver mensagem "Nenhum banco conectado"
   - ✅ Clicar em "Conectar Banco"
   - ✅ Ver modal com Pluggy Connect Widget
   - ✅ Conectar uma conta de teste (use o sandbox do Pluggy)
   - ✅ Ver a conexão criada na lista
   - ✅ Testar sincronização manual
   - ✅ Testar remoção de conexão

### 5.3 Usar Sandbox do Pluggy (Ambiente de Teste)

O Pluggy fornece bancos de teste no ambiente sandbox:

1. **Banco de Teste**: Selecione "Itaú (Sandbox)" ou outro banco sandbox
2. **Credenciais de Teste**:
   - **Usuário**: `user-ok`
   - **Senha**: `password-ok`

Esses dados são públicos e servem apenas para teste.

### 5.4 Verificar Dados no Supabase

Após conectar um banco, verifique no Supabase:

```sql
-- Ver conexões criadas
SELECT * FROM bank_connections;

-- Ver contas sincronizadas
SELECT * FROM bank_accounts;

-- Ver transações importadas
SELECT * FROM synced_transactions;

-- Ver logs de sincronização
SELECT * FROM sync_logs ORDER BY started_at DESC LIMIT 10;
```

---

## 📊 Arquitetura Implementada

### Backend (Node.js/TypeScript)
```
nero-backend/src/
├── config/
│   └── pluggy.ts                    ✅ Configuração Pluggy
├── models/
│   └── pluggy.types.ts              ✅ TypeScript types
├── services/
│   ├── pluggy.service.ts            ✅ Serviço Pluggy API
│   └── openFinance.service.ts       ✅ Serviço de integração
├── controllers/
│   └── openFinance.controller.ts    ✅ Controller HTTP
├── routes/
│   └── openFinance.routes.ts        ✅ Rotas da API
└── schedulers/
    └── openFinanceSync.scheduler.ts ✅ Sync automático
```

### Frontend (Flutter)
```
nero/lib/
├── shared/models/
│   ├── bank_connector_model.dart    ✅ Model do conector
│   ├── bank_connection_model.dart   ✅ Model da conexão
│   ├── bank_account_model.dart      ✅ Model da conta
│   └── synced_transaction_model.dart ✅ Model da transação
├── core/services/
│   └── open_finance_service.dart    ✅ Serviço HTTP
└── features/open_finance/
    └── presentation/
        ├── pages/
        │   └── bank_connections_page.dart      ✅ Página principal
        └── widgets/
            ├── bank_connection_card.dart       ✅ Card de conexão
            └── pluggy_connect_widget.dart      ✅ WebView widget
```

### Banco de Dados (Supabase)
```
Tabelas:
├── bank_connections       ✅ Conexões bancárias
├── bank_accounts          ✅ Contas bancárias
├── synced_transactions    ✅ Transações sincronizadas
└── sync_logs              ✅ Logs de sincronização

Recursos:
├── RLS Policies           ✅ Segurança row-level
├── Triggers               ✅ Auto-update timestamps
└── Views                  ✅ bank_connections_summary, sync_statistics
```

---

## 🚀 Endpoints da API

### Autenticação
Todos os endpoints requerem:
- Header `X-API-Key`: Sua API key configurada
- Header `Authorization`: Bearer token do Supabase (usuário logado)

### Endpoints Disponíveis

#### 1. Obter Connect Token
```
GET /api/open-finance/connect-token
```
Retorna um token para usar no Pluggy Connect Widget.

#### 2. Listar Conectores (Bancos)
```
GET /api/open-finance/connectors
Query params:
  - types: string[] (optional)
  - countries: string[] (optional)
  - name: string (optional)
```

#### 3. Criar Conexão
```
POST /api/open-finance/connections
Body: {
  "itemId": "string"
}
```

#### 4. Listar Conexões
```
GET /api/open-finance/connections
```

#### 5. Sincronizar Conexão
```
POST /api/open-finance/connections/:connectionId/sync
```

#### 6. Deletar Conexão
```
DELETE /api/open-finance/connections/:connectionId
```

#### 7. Listar Contas
```
GET /api/open-finance/accounts
```

---

## 🔄 Sincronização Automática

O sistema possui 3 schedulers automáticos:

1. **Sincronização Completa** (a cada 6 horas)
   - Sincroniza todas as conexões ativas

2. **Verificação de Desatualizados** (a cada hora)
   - Sincroniza conexões não atualizadas há mais de 12 horas

3. **Sincronização Diária** (3h da manhã)
   - Sincronização completa em horário de menor uso

---

## ⚠️ Problemas Comuns

### 1. Erro "relation 'categories' does not exist"
**Solução**: Execute o script `supabase_categories_setup.sql` ANTES do script de Open Finance.

```sql
-- No SQL Editor do Supabase, execute primeiro:
-- supabase_categories_setup.sql

-- Depois execute:
-- supabase_open_finance_setup.sql
```

Se já executou o script de Open Finance, não tem problema. A tabela `synced_transactions` foi criada sem a foreign key para categories. Execute apenas o script de categories agora.

### 2. Erro "Failed to authenticate with Pluggy API"
- ✅ Verifique se o `PLUGGY_CLIENT_ID` e `PLUGGY_CLIENT_SECRET` estão corretos
- ✅ Verifique se não há espaços extras no `.env`
- ✅ Certifique-se de que está usando as credenciais corretas (sandbox vs production)

### 3. WebView não carrega
- ✅ Verifique se a dependência `webview_flutter` foi instalada: `flutter pub get`
- ✅ No Android, verifique permissões de internet no `AndroidManifest.xml`
- ✅ No iOS, verifique `Info.plist` para permissões de network

### 4. Tabelas não criadas no Supabase
- ✅ Execute o SQL script novamente
- ✅ Verifique se há erros no SQL Editor
- ✅ Verifique se a extensão `uuid-ossp` está habilitada:
  ```sql
  CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
  ```

### 5. Categorização não funciona
- ✅ Verifique se o `OPENAI_API_KEY` está configurado no backend `.env`
- ✅ Verifique se a tabela `categories` existe no Supabase
- ✅ Verifique se há categorias cadastradas:
  ```sql
  SELECT COUNT(*) FROM categories WHERE is_system = true;
  ```

---

## 📝 Próximos Passos

Depois de testar e confirmar que tudo funciona:

1. **Produção**:
   - Obtenha credenciais de produção do Pluggy
   - Configure variáveis de ambiente de produção

2. **Melhorias**:
   - Adicionar página de detalhes da conta
   - Gráficos de gastos por banco
   - Notificações de sincronização
   - Suporte a múltiplas contas do mesmo banco

3. **Segurança**:
   - Implementar rate limiting
   - Adicionar logs de auditoria
   - Criptografar dados sensíveis

---

## 📚 Documentação

- **Pluggy Docs**: https://docs.pluggy.ai/
- **Pluggy Dashboard**: https://dashboard.pluggy.ai/
- **Supabase Docs**: https://supabase.com/docs
- **WebView Flutter**: https://pub.dev/packages/webview_flutter

---

## 🆘 Suporte

Se encontrar problemas:
1. Verifique os logs do backend (`npm run dev`)
2. Verifique os logs do Flutter (`flutter run -v`)
3. Consulte a documentação do Pluggy
4. Abra uma issue no GitHub

---

**Implementado com sucesso! 🎉**

Todos os 15 itens da implementação Open Finance foram concluídos:
- ✅ Backend completo com Pluggy API
- ✅ Frontend Flutter com UI moderna
- ✅ Banco de dados estruturado
- ✅ Sincronização automática
- ✅ Categorização por IA integrada
