# 🎨 Modernização UI/UX - Tela de Empresa (Tema Escuro)

## 📋 Status: Em Progresso

## ✅ Concluído

### 1. Atualização de Paleta de Cores ✅

**Arquivo:** `lib/core/config/app_colors.dart`

**Mudanças implementadas:**
```dart
// Tema Escuro Minimalista Moderno
darkBackground: #0E0E10  (antes #121212)
darkCard: #18181B        (antes #1E1E1E)
darkSurface: #18181B     (novo)
darkTextSecondary: #9E9E9E (antes #AAAAAA)
darkBorder: #2A2A2D      (novo)

// Nova cor de acento para IA
aiSecondary: #00C6FF     (novo)

// Cores de Prioridade Sutis
priorityLow: #00C853     (verde)
priorityMedium: #FFD600  (amarelo)
priorityHigh: #FF1744    (vermelho)
```

### 2. Atualização do Tema Escuro ✅

**Arquivo:** `lib/core/config/app_theme.dart`

**Mudanças:**
- ColorScheme.dark atualizado com novas cores
- background: #0E0E10
- surface: #18181B
- outline: #2A2A2D
- secondary: #00C6FF (aiSecondary)
- shadow: opacity 0.25 (mais sutil)

---

## 🔄 Próximas Tarefas

### 3. Modernizar Cards de Estatísticas

**Arquivo alvo:** `lib/features/companies/presentation/widgets/company_stats_card.dart`

**Mudanças necessárias:**
- [ ] Unificar estilo visual dos cards
- [ ] Fundo: `AppColors.darkCard` (#18181B)
- [ ] Ícones em azul claro: `AppColors.aiSecondary` (#00C6FF)
- [ ] Título em: `AppColors.darkText` (#EAEAEA)
- [ ] Número em destaque: `#FFFFFF`
- [ ] Separadores sutis: `AppColors.darkBorder` (#2A2A2D)
- [ ] Remover cores diferentes para cada métrica - manter coerência

**Código esperado:**
```dart
Container(
  decoration: BoxDecoration(
    color: AppColors.darkCard, // #18181B
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: AppColors.darkBorder, // #2A2A2D
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.15),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Column(
    children: [
      Icon(icon, color: AppColors.aiSecondary, size: 24), // #00C6FF
      Text(title, style: TextStyle(color: AppColors.darkText)), // #EAEAEA
      Text(value, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: bold)),
    ],
  ),
)
```

---

### 4. Substituir Blocos Coloridos por Ícones Circulares

**Arquivo alvo:** `lib/features/companies/presentation/widgets/company_quick_actions.dart`

**Mudanças necessárias:**

**De (atual):**
- Retângulos com fundo colorido sólido
- Nova Tarefa → azul sólido
- Agendar Reunião → roxo sólido
- Checklist → amarelo sólido
- Timeline → turquesa sólido

**Para (novo):**
- Ícones circulares sutis com rótulo abaixo

| Ação | Cor do Círculo | Ícone | Label |
|------|----------------|-------|-------|
| Nova Tarefa | rgba(0,114,255,0.2) | Icons.task_alt | Tarefa |
| Agendar Reunião | rgba(156,39,176,0.15) | Icons.event | Reunião |
| Checklist | rgba(0,200,83,0.15) | Icons.checklist | Checklist |
| Timeline | rgba(0,229,255,0.15) | Icons.timeline | Timeline |

**Código esperado:**
```dart
Widget _buildCircularAction({
  required IconData icon,
  required String label,
  required Color color,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedScale(
      scale: _pressed ? 0.98 : 1.0,
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: AppColors.darkText,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
```

---

### 5. Harmonizar Cores de Formulários

**Arquivos alvo:**
- `lib/features/tasks/presentation/pages/task_form_page_v2.dart`
- `lib/features/companies/presentation/pages/meeting_form_page.dart`

**Campos de texto:**
```dart
InputDecoration(
  filled: true,
  fillColor: AppColors.darkCard, // #18181B
  border: OutlineInputBorder(
    borderSide: BorderSide(color: AppColors.darkBorder), // #2A2A2D
  ),
  hintStyle: TextStyle(color: Color(0xFF777777)),
  labelStyle: TextStyle(color: AppColors.darkText), // #EAEAEA
)
```

**Botão "Sugerir com IA":**
```dart
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: AppColors.primary.withOpacity(0.15), // rgba(0,114,255,0.15)
    foregroundColor: AppColors.aiSecondary, // #00C6FF
    side: BorderSide(
      color: AppColors.primary.withOpacity(0.2), // Borda sutil
      width: 1,
    ),
    elevation: 0,
  ),
  child: Row(
    children: [
      Icon(Icons.auto_awesome, color: AppColors.aiSecondary),
      SizedBox(width: 8),
      Text('Sugerir com IA', style: TextStyle(color: AppColors.aiSecondary)),
    ],
  ),
)
```

---

### 6. Ajustar Indicadores de Prioridade

**Arquivos alvo:**
- Qualquer widget que exibe prioridades de tarefas

**Mudanças:**

**De (atual):**
- Cores sólidas e vibrantes

**Para (novo):**
- Fundo transparente com opacidade 0.2
- Borda suave
- Texto colorido

```dart
// Baixa
Container(
  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
  decoration: BoxDecoration(
    color: AppColors.priorityLow.withOpacity(0.2), // rgba(0,200,83,0.2)
    borderRadius: BorderRadius.circular(8),
    border: Border.all(
      color: AppColors.priorityLow.withOpacity(0.4),
      width: 1,
    ),
  ),
  child: Text(
    'Baixa',
    style: TextStyle(
      color: AppColors.priorityLow, // #00C853
      fontSize: 12,
      fontWeight: FontWeight.w600,
    ),
  ),
)

// Média
Container(
  color: AppColors.priorityMedium.withOpacity(0.2), // rgba(255,214,0,0.2)
  border: Border.all(color: AppColors.priorityMedium.withOpacity(0.4)),
  child: Text('Média', style: TextStyle(color: AppColors.priorityMedium)), // #FFD600
)

// Alta
Container(
  color: AppColors.priorityHigh.withOpacity(0.2), // rgba(255,23,68,0.2)
  border: Border.all(color: AppColors.priorityHigh.withOpacity(0.4)),
  child: Text('Alta', style: TextStyle(color: AppColors.priorityHigh)), // #FF1744
)
```

---

### 7. Adicionar Microanimações

**Mudanças globais:**

**Botões principais:**
```dart
AnimatedScale(
  scale: _isPressed ? 0.98 : 1.0,
  duration: const Duration(milliseconds: 150),
  curve: Curves.easeInOut,
  child: ElevatedButton(...),
)
```

**Cards com hover (se aplicável):**
```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 200),
  decoration: BoxDecoration(
    boxShadow: _isHovered
        ? [BoxShadow(color: AppColors.primary.withOpacity(0.1), blurRadius: 12)]
        : [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
  ),
)
```

**Ícones com feedback visual:**
```dart
IconButton(
  icon: AnimatedScale(
    scale: _isPressed ? 1.05 : 1.0,
    duration: const Duration(milliseconds: 100),
    child: Icon(Icons.add),
  ),
)
```

---

### 8. Responsividade Mobile

**GridView adaptativo para ações rápidas:**
```dart
GridView.count(
  crossAxisCount: MediaQuery.of(context).size.width > 400 ? 4 : 2,
  mainAxisSpacing: 16,
  crossAxisSpacing: 16,
  shrinkWrap: true,
  physics: const NeverScrollableScrollPhysics(),
  children: [
    _buildCircularAction(...),
    _buildCircularAction(...),
    _buildCircularAction(...),
    _buildCircularAction(...),
  ],
)
```

---

## 📊 Checklist de Implementação

### Fase 1: Cores e Tema ✅
- [x] Atualizar app_colors.dart com tons neutros
- [x] Atualizar app_theme.dart com novo ColorScheme
- [x] Adicionar cores de prioridade sutis
- [x] Adicionar aiSecondary para IA

### Fase 2: Componentes Visuais 🔄
- [ ] Modernizar CompanyStatsCard
- [ ] Refatorar CompanyQuickActions (ícones circulares)
- [ ] Harmonizar cores de formulários
- [ ] Ajustar indicadores de prioridade

### Fase 3: Interatividade 🔜
- [ ] Adicionar AnimatedScale nos botões
- [ ] Adicionar feedback hover nos cards
- [ ] Implementar transições suaves (Curves.easeInOut)

### Fase 4: Responsividade 🔜
- [ ] Grid adaptativo para ações rápidas
- [ ] Testar em mobile (<400px)
- [ ] Testar em tablets

---

## 🎯 Resultado Esperado

**Antes:**
- Cores saturadas (azul, roxo, amarelo, verde)
- Blocos retangulares grandes
- Sem coerência cromática
- Visual pesado e poluído

**Depois:**
- Tons neutros (#0E0E10, #18181B, #2A2A2D)
- Ícones circulares minimalistas
- Cores sutis com opacidade 0.15-0.2
- Visual limpo, sofisticado e fluido
- Inspirado em Linear, Notion e Arc Browser

---

## 📝 Notas

- **Duração das animações:** 150-250ms
- **Curve padrão:** Curves.easeInOut
- **Opacidade padrão:** 0.15-0.2 para fundos, 0.3-0.4 para bordas
- **Sombras:** rgba(0,0,0,0.15-0.25)
- **Ícones azuis:** #00C6FF (aiSecondary)
- **Bordas arredondadas:** 12-16px

---

**Data de início:** 2025-11-10
**Status:** 🔄 Em Progresso
**Responsável:** Claude Code
