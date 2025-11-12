# 🔍 Sistema de Diagnóstico do Dashboard - Nero

## 📋 Logs Implementados

### Sistema de Cores dos Logs

| Emoji | Componente | Descrição |
|-------|-----------|-----------|
| 🔵 | Header & Dashboard | Logs principais de renderização e layout do header |
| 🟡 | Content Body | Logs do corpo principal de conteúdo |
| 🟣 | Insight Card | Logs do card de insights da IA |
| 🟠 | Task Card | Logs do card de tarefas |
| 🔴 | Finance Card | Logs do card financeiro |
| 🟢 | Scroll | Logs relacionados ao scroll controller |

## 📊 Ordem Esperada dos Logs

### 1. Inicialização do Dashboard

```
🔵 [DEBUG] Dashboard build iniciado
🔵 [SAFEAREA] Padding top: <valor>
🔵 [LAYOUT] Header height calculado: <valor>
🔵 [LAYOUT] Screen height: <valor>
🔵 [LAYOUT] Screen width: <valor>
```

**O que verificar:**
- `Padding top` deve ser > 0 (geralmente 44-50px em iPhone, 24-28px em Android)
- Se for 0, a SafeArea não está funcionando

### 2. Renderização do Header

```
🔵 [HEADER] Build iniciado
🔵 [HEADER] Status bar height: <valor>
🔵 [HEADER] isScrolled: false
🔵 [HEADER] Padding top calculado: <valor>
🔵 [RENDER] Header renderizado (Positioned)
```

**PostFrameCallback (após renderização):**
```
🔵 [HEADER] Container interno size: Size(width, height)
🔵 [HEADER-AVATAR] Size: Size(48.0, 48.0)
🔵 [HEADER-AVATAR] Position: Offset(x, y)
🔵 [HEADER-GREETING] Size: Size(width, height)
🔵 [HEADER-GREETING] Position: Offset(x, y)
🔵 [HEADER-ACTIONS] Size: Size(width, height)
🔵 [HEADER-ACTIONS] Position: Offset(x, y)
🔵 [LAYOUT] Header size: Size(width, height)
🔵 [LAYOUT] Header real height: <valor>
🔵 [POSITIONED] Header top: 0, left: 0, right: 0
```

**O que verificar:**
- Avatar deve ter exatamente 48x48
- Position Y do Avatar deve ser ~50-60 (depende da status bar)
- Greeting e Actions devem estar na mesma linha Y
- Se Position X do HEADER-ACTIONS for < 0 ou > screen width, há sobreposição

### 3. Renderização do Conteúdo

```
🟡 [CONTENT] Content body renderizado
🟡 [LAYOUT] Content body size: Size(width, height)
```

**O que verificar:**
- Width deve ser igual à largura da tela
- Height não deve ser Infinity

### 4. Renderização dos Cards

```
🟣 [RENDER] InsightCard sendo renderizado
🟣 [LAYOUT] InsightCard size: Size(width, height)
🟣 [LAYOUT] InsightCard position: Offset(x, y)

🟠 [RENDER] TaskCard sendo renderizado
🟠 [LAYOUT] TaskCard size: Size(width, height)
🟠 [LAYOUT] TaskCard position: Offset(x, y)

🔴 [RENDER] FinanceCard sendo renderizado
🔴 [LAYOUT] FinanceCard size: Size(width, height)
🔴 [LAYOUT] FinanceCard position: Offset(x, y)
```

**O que verificar:**
- Position Y do InsightCard deve ser > Header height (geralmente > 80)
- Cards devem ter Position X = 20 (margem lateral)
- Cards não devem ter Size com Infinity

### 5. Scroll Controller

```
🟢 [SCROLL] Controller hasClients: true
🟢 [SCROLL] Offset atual: 0.0
```

**O que verificar:**
- `hasClients: false` indica que o scroll não foi inicializado
- Offset inicial deve ser 0.0

## 🚨 Problemas Comuns e Como Identificar

### Problema 1: Texto "Bom dia, Bruno" Quebrado

**Sintomas nos logs:**
```
🔵 [HEADER-GREETING] Size: Size(0.0, 100.0)  // ❌ Width = 0
```

**Causa:** Column sem `mainAxisSize: MainAxisSize.min` dentro de `Expanded`

**Solução:** Adicionar `mainAxisSize: MainAxisSize.min` na Column da saudação

### Problema 2: Sobreposição Avatar e Ícones

**Sintomas nos logs:**
```
🔵 [HEADER-AVATAR] Position: Offset(20.0, 50.0)
🔵 [HEADER-ACTIONS] Position: Offset(-10.0, 50.0)  // ❌ X negativo
```

**Causa:** Row sem espaço suficiente ou sem `mainAxisSize`

**Solução:** Adicionar `mainAxisSize: MainAxisSize.min` no Row de actions

### Problema 3: Card de Insight Colidindo com Header

**Sintomas nos logs:**
```
🔵 [LAYOUT] Header real height: 120.0
🟣 [LAYOUT] InsightCard position: Offset(20.0, 50.0)  // ❌ Y < header height
```

**Causa:** Espaçamento calculado incorretamente

**Solução:** Verificar `SizedBox(height: headerHeight + 8)` no CustomScrollView

### Problema 4: SafeArea não Funcionando

**Sintomas nos logs:**
```
🔵 [SAFEAREA] Padding top: 0.0  // ❌ Deveria ser > 0
```

**Causa:** Scaffold não envolvido corretamente ou MediaQuery não disponível

**Solução:** Garantir que Scaffold está na raiz e MediaQuery está acessível

### Problema 5: Scroll Infinito ou Travado

**Sintomas nos logs:**
```
🟢 [SCROLL] Controller hasClients: false  // ❌ Nunca inicializou
```

**Causa:** `Expanded` dentro de `SingleChildScrollView`

**Solução:** Remover todos os `Expanded` do scroll

## 📐 Valores de Referência

### Dispositivos Comuns

| Dispositivo | Status Bar Height | Screen Width | Screen Height |
|------------|-------------------|--------------|---------------|
| iPhone 14  | 47 | 390 | 844 |
| iPhone SE  | 20 | 375 | 667 |
| Pixel 6    | 28 | 412 | 915 |
| Galaxy S21 | 24 | 384 | 854 |

### Tamanhos Esperados

| Componente | Width | Height |
|-----------|-------|--------|
| Avatar    | 48    | 48     |
| Header Total | Screen Width | ~76-120 (variável) |
| Insight Card | Screen Width - 40 | ~140-180 |
| Task Card | Screen Width - 40 | ~280-350 |
| Finance Card | Screen Width - 40 | ~450-550 |

## 🔧 Como Executar o Diagnóstico

### Passo 1: Executar o App

```bash
flutter run -d chrome
```

Ou para dispositivo físico:

```bash
flutter run -d <device-id>
```

### Passo 2: Observar o Console

Os logs aparecerão no console automaticamente ao abrir o Dashboard.

### Passo 3: Filtrar Logs

Para ver apenas logs de um componente:

```bash
# No terminal onde o flutter run está executando
# Pressione 's' para screenshot
# Pressione 'r' para hot reload
# Observe os logs no console
```

### Passo 4: Analisar a Sequência

A ordem correta deve ser:

1. 🔵 Dashboard build
2. 🔵 SafeArea logs
3. 🔵 Header build
4. 🔵 Header PostFrame logs
5. 🟡 Content body logs
6. 🟣 InsightCard logs
7. 🟠 TaskCard logs
8. 🔴 FinanceCard logs
9. 🟢 Scroll logs

**Se a ordem estiver diferente, há um problema de rebuild ou layout.**

### Passo 5: Comparar Valores

Use a tabela de "Valores de Referência" para comparar os tamanhos e posições.

## 🎯 Checklist de Diagnóstico

- [ ] SafeArea Padding top > 0
- [ ] Header height calculado corretamente
- [ ] Avatar 48x48
- [ ] Greeting Position Y = Avatar Position Y
- [ ] Actions Position X > 0
- [ ] InsightCard Position Y > Header Height
- [ ] Todos os cards com Width = Screen Width - 40
- [ ] Scroll Controller hasClients = true
- [ ] Nenhum Size com Infinity
- [ ] Nenhum Position com valores negativos

## 🔄 Próximos Passos Após Diagnóstico

1. **Identificar o componente problemático** pelos logs
2. **Verificar hierarquia de widgets** (Expanded, Flexible, Stack, Positioned)
3. **Corrigir constraints** (adicionar mainAxisSize, remover Expanded indevido)
4. **Validar SafeArea** e padding dinâmico
5. **Testar em diferentes tamanhos** de tela
6. **Remover logs** após correção (ou deixar em modo debug)

## 📝 Como Remover os Logs

Após identificar e corrigir o problema:

1. Buscar por `print('🔵` no código
2. Comentar ou remover as linhas de print
3. Manter os `WidgetsBinding.instance.addPostFrameCallback` se útil
4. Ou criar uma constante `const bool kDebugDashboard = false;` e envolver:

```dart
if (kDebugDashboard) {
  print('...');
}
```

---

**Data de Criação:** ${DateTime.now().toString().split('.')[0]}
**Versão:** 1.0
**Status:** 🟢 Sistema de diagnóstico ativo
