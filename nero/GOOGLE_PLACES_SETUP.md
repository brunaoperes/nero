# 🚀 Sistema Híbrido Inteligente de Localização

O Nero agora usa um **sistema inteligente de 4 camadas** para busca de localizações com **fallback automático**:

1. **Google Places** - Melhor qualidade (premium) ⭐
2. **Geoapify** - Endereços e ruas 🗺️
3. **Foursquare** - Estabelecimentos comerciais 🏪
4. **Photon** - Backup de emergência 🔄

**Resultado:** A melhor experiência possível com gerenciamento inteligente de custos!

---

## 🎯 Como Funciona

### Fluxo de Busca Inteligente:

```
Usuário digita "Starbucks Paulista"
    ↓
1️⃣ Verifica uso do Google Places
    • Se < 56.000 req/mês (80%) → Usa Google Places ⭐
    • Se ≥ 56.000 req/mês → Pula para Geoapify + Foursquare
    ↓
2️⃣ Se Google Places não retornou ou excedeu limite:
    Busca PARALELA em:
    • Geoapify → Endereços, ruas, bairros
    • Foursquare → Cafés, restaurantes, lojas
    ↓
3️⃣ Se AMBOS falharem → Photon (backup)
    ↓
4️⃣ Se NADA encontrar → Opções manuais
```

---

## 🔑 Configuração da API do Google Places

### Por Que Usar Google Places?

✅ **Melhor qualidade de resultados**
✅ **Encontra qualquer local** (endereços + estabelecimentos)
✅ **Dados sempre atualizados**
✅ **$200/mês GRÁTIS** (~70.000 buscas)
✅ **Fallback automático** quando exceder limite

### Passo a Passo:

#### 1️⃣ Acessar Google Cloud Console

Acesse: [https://console.cloud.google.com/](https://console.cloud.google.com/)

#### 2️⃣ Criar ou Selecionar um Projeto

- Clique em **"Selecionar um projeto"** (topo da página)
- Clique em **"NOVO PROJETO"**
- Nome do projeto: `Nero App` (ou qualquer nome)
- Clique em **"CRIAR"**

#### 3️⃣ Ativar as APIs Necessárias

**3.1. Places API (New)**

- No menu lateral, vá em: **APIs e Serviços** → **Biblioteca**
- Busque por: **"Places API (New)"**
- Clique em **"ATIVAR"**

**3.2. Places API (opcional, para compatibilidade)**

- Busque por: **"Places API"**
- Clique em **"ATIVAR"**

#### 4️⃣ Criar Credenciais (API Key)

- No menu lateral: **APIs e Serviços** → **Credenciais**
- Clique em **"+ CRIAR CREDENCIAIS"**
- Selecione **"Chave de API"**
- Sua API Key será gerada! 🎉

**Copie a API Key** (algo como: `AIzaSyC4xxxxxxxxxxxxxxxxxxxxxxxxxxx`)

#### 5️⃣ (RECOMENDADO) Restringir a API Key

Para segurança, restrinja sua chave:

**5.1. Clique em "Editar chave de API"**

**5.2. Restrições de aplicativo:**
- Escolha: **"Sites"** (para web) OU **"Aplicativos Android/iOS"** (para mobile)
- Sites: Adicione `localhost:*` e seu domínio de produção
- Android: Adicione o SHA-1 fingerprint do app

**5.3. Restrições de API:**
- Selecione: **"Restringir chave"**
- Marque apenas:
  - ☑️ **Places API (New)**
  - ☑️ **Places API**

**5.4. Clique em "SALVAR"**

#### 6️⃣ Configurar no Código

Abra o arquivo: `lib/core/config/google_places_config.dart`

Substitua `YOUR_API_KEY_HERE` pela sua API Key:

```dart
static const String GOOGLE_PLACES_API_KEY = 'AIzaSyC4xxxxxxxxxxxxxxxxxxxxxxxxxxx';
```

✅ **Pronto!** Sistema híbrido configurado com sucesso! 🎉

---

## 💰 Gerenciamento de Custos

### Tier Gratuito do Google Places:

| Item | Valor |
|------|-------|
| **Crédito mensal grátis** | $200,00 |
| **Custo por busca (Autocomplete)** | $0,00283 ($2,83/1.000) |
| **Máximo de buscas grátis** | ~70.000 req/mês |
| **Limite de segurança (80%)** | 56.000 req/mês |
| **Fallback automático em** | 56.000 requisições |

### Como o Sistema Controla Custos:

1. **Tracking Automático:**
   - Conta cada requisição feita ao Google Places
   - Armazena contador localmente (SharedPreferences)
   - Reseta automaticamente no início de cada mês

2. **Limite de Segurança (80%):**
   - Quando atingir **56.000 requisições** (~$160)
   - Sistema **para de usar Google Places**
   - Ativa **fallback automático** para Geoapify + Foursquare
   - **Usuário não percebe** a mudança

3. **Alertas no Console:**
   ```
   ✅ Google Places: 5 resultados (1.245 req este mês)
   ⚠️ Google Places: 90% do limite usado (50.400 req)
   🔄 Google Places: Limite atingido, usando fallback
   ```

### Ver Uso Atual:

O sistema imprime estatísticas a cada 1.000 requisições:
```dart
📊 Google Places: 1000 requisições este mês
📊 Google Places: 2000 requisições este mês
...
```

Para ver estatísticas detalhadas, adicione no console do Flutter:
```dart
final stats = await GooglePlacesService.getUsageStats();
print('Uso: ${stats['percentage']}%');
print('Requisições: ${stats['count']}/${GooglePlacesConfig.safetyLimitRequests}');
print('Custo: \$${stats['cost'].toStringAsFixed(2)}');
print('Restantes: ${stats['remaining']}');
```

---

## 📊 Comparação Completa das APIs

| Recurso | Google Places | Geoapify | Foursquare | Photon |
|---------|---------------|----------|------------|--------|
| **Custo** | **Grátis $200/mês** | **Grátis 3k/dia** | **Grátis 95k/mês** | **Grátis ∞** |
| **API Key** | ⚠️ Configurar | ✅ Configurada | ✅ Configurada | ✅ Não precisa |
| **Qualidade Geral** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Endereços** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ |
| **Estabelecimentos** | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ |
| **Cafés/Restaurantes** | ✅ **Excelente** | ❌ Fraco | ✅ **Excelente** | ❌ Fraco |
| **Lojas/Comércio** | ✅ **Excelente** | ❌ Fraco | ✅ **Excelente** | ❌ Fraco |
| **Ruas/Bairros** | ✅ **Excelente** | ✅ **Excelente** | ⭐⭐⭐ | ✅ Muito bom |
| **Dados Atualizados** | **Tempo real** | Mensal | **Diário** | Semanal |
| **Velocidade** | Rápido | Rápido | Rápido | Médio |
| **Coordenadas** | Precisas | Precisas | Precisas | Precisas |

---

## 🎨 Experiência Visual

### Diferenciação por Fonte:

**Google Places (Premium):**
- ⭐ Ícone de estrela verde
- Nome em **verde negrito** (destaque premium)
- Badge: "Google Places"

**Estabelecimentos (Foursquare):**
- 🏪 Ícone de loja azul
- Nome em **azul** destacado
- Badge: "Foursquare"
- Categoria: "Café", "Restaurante", etc.

**Endereços (Geoapify):**
- 📍 Pin roxo
- Nome em texto normal
- Badge: "Geoapify"

**Backup (Photon):**
- 📍 Pin cinza
- Badge: "Photon"

---

## 💡 Exemplos de Busca

### Exemplo 1: Estabelecimento Popular

**Busca:** `"Starbucks Paulista"`

**Resultado (Google Places configurado):**
```
⭐ Starbucks Reserve Paulista (Google Places) [PREMIUM]
⭐ Starbucks Trianon MASP (Google Places) [PREMIUM]
⭐ Starbucks Coffee Paulista (Google Places) [PREMIUM]
```

**Resultado (Se Google Places exceder limite):**
```
🏪 Starbucks Coffee (Foursquare) [Fallback Automático]
🏪 Starbucks Reserve (Foursquare)
📍 Avenida Paulista (Geoapify)
```

### Exemplo 2: Endereço Exato

**Busca:** `"Avenida Paulista 1000"`

**Resultado (Google Places):**
```
⭐ Av. Paulista, 1000 - Bela Vista (Google Places) [Melhor precisão]
```

**Resultado (Fallback):**
```
📍 Av. Paulista, 1000 (Geoapify)
📍 Avenida Paulista, 1000 (Photon)
```

### Exemplo 3: Busca Mista

**Busca:** `"Padaria perto de mim"`

Google Places (se configurado):
```
⭐ Padaria Real (Google Places)
⭐ Padaria Bella Vista (Google Places)
⭐ Panificadora Paulista (Google Places)
```

Foursquare (fallback):
```
🏪 Padaria Real (Foursquare)
🏪 Padaria Estrela (Foursquare)
```

---

## 🔧 Troubleshooting

### ❌ Erro: "Google Places: API Key inválida"

**Causa:** API Key incorreta ou APIs não ativadas.

**Solução:**
1. Verifique se copiou a API Key corretamente
2. Confirme que ativou "Places API (New)"
3. Aguarde 1-2 minutos após ativar a API

### ❌ Erro: "Limite de requisições excedido"

**Causa:** Excedeu 56.000 requisições no mês.

**Solução:**
- **Nada!** Sistema ativa fallback automático
- Continue usando normalmente (Geoapify + Foursquare)
- Contador reseta automaticamente no próximo mês

### ❌ Erro: "API key not valid. Please pass a valid API key."

**Causa:** Restrições de API Key muito rígidas.

**Solução:**
1. Vá em **Credenciais** → Editar sua API Key
2. Em "Restrições de aplicativo", selecione: **"Nenhum"** (temporariamente)
3. Teste novamente
4. Se funcionar, configure restrições mais flexíveis

### ℹ️ "🔄 Google Places: vazio ou limite excedido, usando fallback"

**Causa:** Sistema atingiu 80% do limite de segurança.

**Status:** **Normal!** Sistema funcionando como esperado.
- Fallback para Geoapify + Foursquare ativado
- Qualidade ainda muito boa
- Nenhuma ação necessária

---

## 📈 Isso É Suficiente?

### Uso Típico (com Google Places):

| Cenário | Req/Mês | Google Places | Status |
|---------|---------|---------------|--------|
| **1 usuário, 20 buscas/dia** | 600 | ✅ Sempre usa | ✅✅✅ Perfeito |
| **10 usuários, 20 buscas/dia** | 6.000 | ✅ Sempre usa | ✅✅✅ Excelente |
| **100 usuários, 20 buscas/dia** | 60.000 | ⚠️ Perto do limite | ✅ OK com fallback |
| **500 usuários, 20 buscas/dia** | 300.000 | ❌ Usa fallback | ✅ Geoapify + Foursquare |

**Sistema distribui carga inteligentemente!**

---

## 🎯 Por Que Usar Google Places?

### Vantagens:

1. **Melhor cobertura:** Encontra TUDO (endereços + estabelecimentos)
2. **Dados atualizados:** Informações em tempo real
3. **Qualidade superior:** Resultados mais precisos e relevantes
4. **$200 grátis/mês:** Muito generoso para uso pessoal/médio
5. **Fallback inteligente:** Nunca fica sem serviço
6. **Zero manutenção:** Tracking automático de uso

### Quando Usar Apenas Fallbacks (Sem Google Places):

- ✅ Aplicativo com **muitos usuários** (>1000)
- ✅ Quer **zero custos potenciais**
- ✅ Não quer gerenciar API Key do Google
- ⚠️ Aceita **qualidade um pouco menor**

**Sistema funciona perfeitamente com ou sem Google Places!**

---

## 🔄 Arquitetura Técnica

### Tracking de Requisições:

```dart
// Verifica se pode usar Google Places
if (await GooglePlacesService.canUseGooglePlaces()) {
  // Conta atual < 56.000 → Usa Google Places
  final results = await GooglePlacesService.searchPlaces(query);
  // Incrementa contador automaticamente
} else {
  // Conta ≥ 56.000 → Fallback automático
  final results = await Future.wait([
    GeoapifyService.searchPlaces(query),
    FoursquareService.searchPlaces(query),
  ]);
}
```

### Reset Mensal Automático:

```dart
final currentMonth = DateTime.now().month;
final savedMonth = prefs.getInt('google_places_request_month');

if (currentMonth != savedMonth) {
  // Novo mês → Reset contador
  await prefs.setInt('google_places_request_count', 0);
  await prefs.setInt('google_places_request_month', currentMonth);
}
```

---

## ⚡ Próximos Passos

### Se Quiser Usar Google Places (Recomendado):

1. ✅ **Configure a API Key** (10 minutos)
2. ✅ **Cole no arquivo de configuração**
3. ✅ **Teste buscando**: "Starbucks", "Avenida Paulista 1000"
4. ✅ **Veja resultados premium** em verde com estrela ⭐

### Se Preferir Não Usar (100% Grátis):

1. ✅ **Não faça nada!**
2. ✅ Sistema usa **Geoapify + Foursquare** automaticamente
3. ✅ Ainda terá **excelente cobertura**
4. ✅ **Zero custos**, zero configuração extra

**Ambas as opções funcionam perfeitamente!** 🎉

---

## 🔗 Links Úteis

- [Google Cloud Console](https://console.cloud.google.com/)
- [Places API (New) Docs](https://developers.google.com/maps/documentation/places/web-service/op-overview)
- [Pricing Calculator](https://developers.google.com/maps/documentation/places/web-service/usage-and-billing)
- [Geoapify Dashboard](https://myprojects.geoapify.com/)
- [Foursquare Developers](https://foursquare.com/developers/)

---

## ❓ FAQ

### Q: É obrigatório configurar Google Places?
**R:** **Não!** Sistema funciona perfeitamente sem ele usando Geoapify + Foursquare. Google Places é **opcional** para melhor qualidade.

### Q: O que acontece se eu não configurar?
**R:** Sistema usa **Geoapify + Foursquare** desde o início. Você terá excelente cobertura, apenas sem a qualidade premium do Google.

### Q: Vou ser cobrado se exceder $200/mês?
**R:** **Não!** Sistema para de usar Google Places automaticamente aos **$160** (80% do limite). Fallback ativa antes de cobrar qualquer coisa.

### Q: Posso configurar alertas de uso?
**R:** O sistema já alerta no console quando chega a 90% do limite. Para alertas personalizados, use a função `GooglePlacesService.getUsageStats()`.

### Q: Como resetar o contador para testes?
**R:** Use: `await GooglePlacesService.resetCounter();` no console do Flutter.

### Q: Qual API é chamada primeiro?
**R:**
1. **Google Places** (se configurado e dentro do limite)
2. Se falhar ou exceder → **Geoapify + Foursquare** em paralelo
3. Se ambos falharem → **Photon**

### Q: Como sei qual API retornou cada resultado?
**R:** Cada card tem:
- ⭐ Verde = Google Places
- 🏪 Azul = Foursquare
- 📍 Roxo = Geoapify
- 📍 Cinza = Photon

### Q: O sistema avisa quando o fallback é ativado?
**R:** Sim! Aparece no console: `🔄 Google Places: Limite atingido, usando fallback`

### Q: Posso usar apenas Google Places sem fallback?
**R:** Tecnicamente sim, mas **não recomendado**. O fallback garante que o app sempre funcione.

---

**Sistema Híbrido Inteligente configurado e pronto para uso! 🚀**

- ✅ Google Places: **Configurar** (recomendado para melhor qualidade)
- ✅ Geoapify: Configurado
- ✅ Foursquare: Configurado
- ✅ Photon: Sempre disponível
- ✅ Fallback automático: **ATIVO**
- ✅ Tracking de custos: **ATIVO**
