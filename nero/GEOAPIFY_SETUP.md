# 📍 Busca de Localização - Sistema Híbrido GRATUITO

O Nero usa um **sistema híbrido inteligente** para busca de localizações:

1. **Geoapify** (principal) - Dados completos e atualizados
2. **Photon** (fallback) - Backup baseado em OpenStreetMap

**Resultado:** 100% gratuito com a melhor cobertura possível!

---

## 🎯 Como Funciona

### Fluxo de Busca Inteligente:

```
Usuário digita "Starbucks Paulista"
    ↓
1️⃣ Tenta primeiro no Geoapify (mais completo)
    ├─ ✅ Encontrou → Mostra resultados
    └─ ❌ Não encontrou ou erro → vai para passo 2
    ↓
2️⃣ Tenta no Photon (fallback gratuito)
    ├─ ✅ Encontrou → Mostra resultados
    └─ ❌ Não encontrou → mostra opções manuais
    ↓
3️⃣ Opções manuais:
    • Buscar no Google Maps
    • Buscar no Waze
    • Adicionar manualmente
```

---

## 🚀 Configuração do Geoapify (Recomendado)

### Passo 1: Criar Conta Gratuita

1. Acesse: https://www.geoapify.com/
2. Clique em **"Get Started Free"**
3. Crie sua conta (sem cartão de crédito!)
4. Confirme seu email

### Passo 2: Obter API Key

1. Faça login no dashboard
2. Vá em **"API Keys"** no menu lateral
3. Copie sua API Key (começa com algo como `a1b2c3d4e5f6...`)

### Passo 3: Configurar no App

1. Abra o arquivo: `lib/core/config/geoapify_config.dart`
2. Encontre a linha:
   ```dart
   static const String GEOAPIFY_API_KEY = 'YOUR_API_KEY_HERE';
   ```
3. Substitua `YOUR_API_KEY_HERE` pela sua API Key:
   ```dart
   static const String GEOAPIFY_API_KEY = 'a1b2c3d4e5f6...';
   ```
4. Salve o arquivo

**Pronto! 🎉** O sistema está configurado.

---

## 📊 Comparação: Geoapify vs Photon vs Nominatim

| Recurso | Geoapify | Photon | Nominatim |
|---------|----------|--------|-----------|
| **Custo** | **Gratuito** (3k/dia) | **Gratuito** (ilimitado) | **Gratuito** (limite informal) |
| **API Key** | Precisa | **Não precisa** | **Não precisa** |
| **Qualidade** | **Excelente** | Muito boa | Boa |
| **Estabelecimentos** | ✅ **Muito bom** | ✅ Bom | ⚠️ Limitado |
| **Endereços** | ✅ Excelente | ✅ Muito bom | ✅ Bom |
| **Coordenadas Precisas** | ✅ Sim | ✅ Sim | ✅ Sim |
| **Velocidade** | **Muito rápido** | Rápido | Rápido |
| **Dados Atualizados** | **Mensalmente** | Semanalmente | Semanalmente |

---

## 💡 Estratégia de Fallback

### Cenário 1: Geoapify Configurado
```
Busca → Geoapify → Photon (se falhar) → Opções manuais
```
- **Melhor cenário**: Dados completos do Geoapify
- **Se Geoapify falhar**: Photon garante backup
- **Se ambos falharem**: Usuário pode buscar em Maps/Waze

### Cenário 2: Geoapify NÃO Configurado
```
Busca → Photon → Opções manuais
```
- Ainda funciona 100% grátis com Photon
- Photon tem boa cobertura de endereços
- Opções manuais garantem que usuário sempre consegue adicionar

---

## 🆓 Tier Gratuito do Geoapify

### Limites:
- ✅ **3.000 requisições/dia**
- ✅ **90.000 requisições/mês**
- ✅ Sem cartão de crédito
- ✅ Sem expiração

### Isso é suficiente?
Para uso típico de um app pessoal:
- **1 usuário fazendo 10 buscas/dia** = 300 req/mês ✅
- **100 usuários fazendo 10 buscas/dia** = 30.000 req/mês ✅
- **300 usuários fazendo 10 buscas/dia** = 90.000 req/mês ✅

**Sim!** O tier gratuito é mais que suficiente para começar.

---

## 🔧 Testando o Sistema

### Teste 1: Verificar Configuração
```dart
// No console do Flutter, você verá:
// "Geoapify falhou: ..." → API Key não configurada (usa Photon)
// Nenhuma mensagem de erro → Geoapify funcionando! ✅
```

### Teste 2: Buscar Estabelecimentos
Experimente buscar:
- ✅ "Starbucks São Paulo"
- ✅ "Banco do Brasil"
- ✅ "Shopping Iguatemi"
- ✅ "McDonald's Paulista"

### Teste 3: Buscar Endereços
Experimente buscar:
- ✅ "Avenida Paulista 1000"
- ✅ "Rua Augusta 500"
- ✅ "Praça da Sé"

---

## 🎨 Experiência do Usuário

### Fluxo Completo:

1. **Digite 3+ caracteres**
   - Sistema busca automaticamente

2. **Veja sugestões em tempo real**
   - Resultados do Geoapify (ou Photon como fallback)
   - Nome do lugar + endereço completo

3. **Selecione uma sugestão**
   - Mini mapa mostra localização exata (se suportado)
   - Informações completas do lugar

4. **Se não encontrar:**
   - Botão "Buscar no Google Maps"
   - Botão "Buscar no Waze"
   - Botão "Adicionar Manualmente"
   - Modal permanece aberto ao retornar

5. **Confirme a localização**
   - Coordenadas GPS são salvas
   - Nome e endereço vinculados à tarefa

---

## 🔄 Upgrade Futuro (Opcional)

### Se o app crescer muito:

| Solução | Tier Gratuito | Custo Pago |
|---------|---------------|------------|
| **Geoapify Pro** | 3k/dia | $200/mês (100k req) |
| **Google Places API** | $200 grátis/mês | $2.50/1000 req |
| **Mapbox Places** | 100k req/mês | $0.50/1000 req |

**Por enquanto:** Sistema híbrido Geoapify + Photon é perfeito! 🎯

---

## ❓ FAQ

### Q: O que acontece se eu não configurar a API Key?
**R:** O sistema usa Photon automaticamente. Funciona 100%, mas com menos detalhes de estabelecimentos.

### Q: Geoapify é realmente gratuito?
**R:** Sim! 3.000 requisições/dia sem custo. Sem cartão de crédito.

### Q: E se eu exceder o limite gratuito?
**R:** O sistema automaticamente usa Photon como fallback. Usuário não percebe diferença.

### Q: Por que não usar só Photon?
**R:** Photon é ótimo, mas Geoapify tem dados mais completos de estabelecimentos comerciais.

### Q: Posso usar comercialmente?
**R:** Sim! Tanto Geoapify (tier free) quanto Photon permitem uso comercial.

### Q: Dados são atualizados?
**R:** Geoapify atualiza mensalmente. Photon/OSM atualizam semanalmente.

---

## 📚 Links Úteis

- [Geoapify Docs](https://www.geoapify.com/docs/)
- [Geoapify Dashboard](https://myprojects.geoapify.com/)
- [Photon Docs](https://photon.komoot.io/)
- [OpenStreetMap](https://www.openstreetmap.org/)

---

**Sistema pronto para uso!** 🎉

- ✅ Sem configuração obrigatória (Photon funciona sem API Key)
- ✅ Melhor experiência com Geoapify (grátis)
- ✅ Fallback automático garante 100% de disponibilidade
