# 🤖 Como Configurar ChatGPT para Sugestões de IA

## 📋 Status Atual

✅ **Integração pré-pronta e testável**
🔒 **Modo DEMO ativo** (sem custos de API)
⚡ **Pronto para ativar quando necessário**

---

## 🎯 Funcionamento Atual

### Modo DEMO (Padrão - SEM CUSTO)

Atualmente, a função "✨ Sugerir com IA" está funcionando em **modo local/demo**:

- ✅ **Não usa API externa** (sem custos)
- ✅ **Sugestões inteligentes baseadas em palavras-chave**
- ✅ **Totalmente funcional para testes**
- ✅ **Resposta rápida (2 segundos simulados)**

#### Palavras-chave reconhecidas:
- "reunião" ou "meeting" → Sugere preparar reunião
- "email" → Sugere responder emails
- "relatório" ou "report" → Sugere finalizar relatório
- "treino" ou "academia" → Sugere sessão de treino
- Outras → Sugestão padrão inteligente

---

## 🚀 Como Ativar o ChatGPT REAL

Quando você quiser usar o **ChatGPT real da OpenAI**, siga estes passos:

### Passo 1: Obter API Key da OpenAI

1. Acesse: https://platform.openai.com/api-keys
2. Faça login ou crie uma conta
3. Clique em "Create new secret key"
4. **Copie a chave** (ela aparece apenas uma vez!)
5. **Formato:** `sk-proj-...` (começa com `sk-`)

### Passo 2: Configurar a API Key

Abra o arquivo:
```
lib/core/services/openai_service.dart
```

Na linha 7, substitua `'SUA_API_KEY_AQUI'` pela sua chave real:

```dart
// ANTES
static const String _apiKey = 'SUA_API_KEY_AQUI';

// DEPOIS
static const String _apiKey = 'sk-proj-abc123...sua_chave_aqui...';
```

### Passo 3: Testar

1. Execute o app: `flutter run`
2. Vá em "Nova Tarefa"
3. Clique em "✨ Sugerir com IA"
4. **Pronto!** Agora usa ChatGPT real

---

## 💰 Custos da OpenAI

### Modelo GPT-3.5-turbo (Padrão configurado)

- **Custo:** ~$0.0015 por 1.000 tokens
- **Por sugestão:** ~$0.0003 (menos de 1 centavo)
- **100 sugestões:** ~$0.03 (3 centavos de dólar)
- **1.000 sugestões:** ~$0.30 (30 centavos de dólar)

### Modelo GPT-4 (Opcional - Melhor qualidade)

Para usar GPT-4, altere na linha 8 de `openai_service.dart`:

```dart
static const String _model = 'gpt-4'; // ou 'gpt-4-turbo'
```

- **Custo:** ~$0.03 por 1.000 tokens (20x mais caro)
- **Por sugestão:** ~$0.006 (menos de 1 centavo ainda)

---

## ⚙️ Configuração Avançada

### Usar Variáveis de Ambiente (Recomendado para Produção)

Em vez de colocar a chave diretamente no código, use variáveis de ambiente:

#### 1. Criar arquivo `.env`

Na raiz do projeto, crie `.env`:

```env
OPENAI_API_KEY=sk-proj-sua_chave_aqui
```

#### 2. Adicionar `.env` ao `.gitignore`

```gitignore
# API Keys e Secrets
.env
.env.local
.env.production
```

#### 3. Instalar flutter_dotenv

```bash
flutter pub add flutter_dotenv
```

#### 4. Atualizar openai_service.dart

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

class OpenAIService {
  static String get _apiKey => dotenv.env['OPENAI_API_KEY'] ?? '';

  // resto do código...
}
```

#### 5. Carregar .env no main.dart

```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}
```

---

## 🧪 Como Testar Sem Gastar

### Opção 1: Modo Demo (Atual)
Simplesmente não configure a API Key. O app usará sugestões locais.

### Opção 2: Limites da OpenAI
- OpenAI oferece **$5 grátis** para novas contas
- Suficiente para **~15.000 sugestões** com GPT-3.5

### Opção 3: Quotas e Limites
Configure limites no painel da OpenAI:
https://platform.openai.com/account/billing/limits

---

## 🔧 Personalizar as Sugestões

### Modificar o Prompt do ChatGPT

No arquivo `openai_service.dart`, linha 33-50, você pode personalizar como a IA se comporta:

```dart
'content': '''Você é um assistente de produtividade do app Nero.
Sua função é sugerir título, prioridade e data para tarefas.

Regras personalizadas:
- Seja conciso e objetivo
- Priorize tarefas matinais
- Considere o contexto do usuário
- etc...
'''
```

### Adicionar Mais Contexto

Você pode passar mais informações para a IA:

```dart
final context = '''
Descrição: ${_descriptionController.text}
Horário atual: ${DateTime.now()}
Tarefas existentes: ...
''';

suggestion = await OpenAIService.suggestTask(context: context);
```

---

## ❓ FAQ - Perguntas Frequentes

### 1. É obrigatório configurar o ChatGPT?

**Não!** O app funciona perfeitamente em modo demo sem custos.

### 2. Como sei se está usando ChatGPT real?

Verifique o arquivo `openai_service.dart`:
- Se `_apiKey = 'SUA_API_KEY_AQUI'` → **Modo Demo**
- Se `_apiKey = 'sk-proj...'` → **Modo Real (ChatGPT)**

### 3. Posso usar outro modelo de IA?

**Sim!** Você pode adaptar o código para usar:
- **Claude (Anthropic)** - API similar
- **Gemini (Google)** - API própria
- **Modelos locais** - Llama, Mistral, etc.

### 4. As sugestões são salvas?

Não, as sugestões são geradas em tempo real e não são armazenadas.

### 5. Funciona offline?

- **Modo Demo:** ✅ Sim (sugestões locais)
- **Modo ChatGPT:** ❌ Não (requer internet)

---

## 📊 Exemplo de Uso Real

### Input do Usuário:
```
Descrição: "preciso preparar apresentação para reunião com cliente amanhã de manhã"
```

### Sugestão do ChatGPT:
```json
{
  "title": "Preparar apresentação para cliente",
  "priority": "high",
  "dueDate": "2025-11-10T08:00:00",
  "reasoning": "Reuniões com clientes são prioridade alta e requerem preparação antecipada"
}
```

### Aplicado no Formulário:
- ✅ Título: "Preparar apresentação para cliente"
- ✅ Prioridade: Alta (vermelho)
- ✅ Data: 10/11/2025 às 08:00

---

## 🎯 Conclusão

**Estado Atual:** ✅ Tudo pronto e funcional (modo demo)

**Para ativar ChatGPT:** Apenas adicione sua API Key

**Custo estimado:** Menos de $0.30 para 1.000 sugestões

**Recomendação:** Mantenha em modo demo durante desenvolvimento e ative apenas em produção ou quando necessário.

---

**Implementado por:** Claude Code
**Data:** 09/11/2025
**Status:** ✅ Pronto para uso
