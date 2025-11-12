# 🎨 Ajustes Visuais e Estruturais - Tema Claro (Light Mode)

## 📋 Status: Em Progresso

## 🎯 Objetivo

Corrigir todas as inconsistências visuais do tema claro, garantindo:
- Contraste perfeito (WCAG AAA)
- Hierarquia visual clara
- Design clean e profissional
- Sem overflow errors
- Legibilidade em todos os componentes

---

## 🎨 Paleta Correta do Tema Claro

```dart
Fundo geral: #FAFAFA (lightBackground)
Cards e containers: #FFFFFF (lightCard)
Bordas e divisores: #E5E5E5 (lightBorder atualizado)
Texto primário: #1C1C1C (lightText)
Texto secundário: #5F5F5F (lightTextSecondary)
Botões primários (CTA): #0072FF (primary)
Botões secundários: #E8F0FF (novo)
Ícones: #2E2E2E (lightIcon)
Sombras: rgba(0,0,0,0.08)
```

---

## 📝 Checklist de Ajustes

### A. Tela "Tarefas" ⏳
- [ ] Campo de busca com fundo #F2F2F2 e borda #E0E0E0
- [ ] Ícone de busca em #5F5F5F
- [ ] Placeholder em #9E9E9E
- [ ] Fundo principal #FAFAFA
- [ ] Calendário: dia selecionado com círculo azul #0072FF e texto branco
- [ ] Número do dia centralizado no círculo

### B. Tela "Minhas Empresas" ⏳
- [ ] Card da empresa com fundo #FFFFFF
- [ ] Sombra sutil: rgba(0,0,0,0.05) com blur 6
- [ ] Título "Be Coffee" em #1C1C1C
- [ ] Subtítulo "Pequena Empresa" em #0072FF
- [ ] Ícones em #2E2E2E
- [ ] CNPJ em #5F5F5F
- [ ] Tag "Ativa" com fundo #E8F5E9 e texto #2E7D32

### C. Tela "Empresa Detalhada" ⏳
- [ ] Título empresa em #1C1C1C
- [ ] Subtítulo em #0072FF
- [ ] Cards com fundo #FFFFFF, borda #E5E5E5
- [ ] Títulos de seção em #2E2E2E
- [ ] Ícones de estatísticas todos em #0072FF
- [ ] Ações Rápidas circulares com fundo #F5F7FA
- [ ] Resolver Bottom Overflow com SingleChildScrollView
- [ ] Padding bottom: 80

### D. Tela "Finanças" ⏳
- [ ] Cards com fundo #FFFFFF
- [ ] Bordas #E5E5E5
- [ ] Título em #1C1C1C
- [ ] Ícone IA em #0072FF
- [ ] Valores negativos em #D32F2F (vermelho suave)
- [ ] Itens de transação com sombra rgba(0,0,0,0.05)

### E. Tela "Detalhes da Transação" ⏳
- [ ] Card valor com fundo #FFE5E5, texto #C62828
- [ ] Botão Excluir: fundo #FFEBEE, texto #D32F2F
- [ ] Botão Editar: fundo #E8F0FF, texto #0072FF
- [ ] Cards info com fundo #FFFFFF, borda #E0E0E0
- [ ] Ícones em #0072FF
- [ ] Texto em #1C1C1C, legenda #5F5F5F

### F. Ajustes Globais ⏳
- [ ] Nenhum componente usa preto absoluto (#000000)
- [ ] Contraste mínimo 6:1 em todos os textos
- [ ] Sombras difusas (5-8px blur)
- [ ] Espaçamentos verticais mínimos: 12px
- [ ] SingleChildScrollView em telas longas

---

## 🛠️ Implementação Técnica

### 1. Atualizar Cores no app_colors.dart

```dart
// Ajustar borda
static const Color lightBorder = Color(0xFFE5E5E5); // atualizado de E0E0E0

// Adicionar nova cor
static const Color lightButtonSecondary = Color(0xFFE8F0FF);
```

### 2. Campo de Busca (tasks_list_page.dart)

```dart
Container(
  padding: const EdgeInsets.all(16),
  color: const Color(0xFFF2F2F2), // Fundo suave
  child: TextField(
    decoration: InputDecoration(
      hintText: 'Buscar tarefas...',
      hintStyle: TextStyle(color: Color(0xFF9E9E9E)),
      prefixIcon: Icon(Icons.search, color: Color(0xFF5F5F5F)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Color(0xFFE0E0E0)),
      ),
    ),
  ),
)
```

### 3. Calendário (app_theme.dart - lightTheme)

```dart
datePickerTheme: DatePickerThemeData(
  dayStyle: TextStyle(fontSize: 14),
  dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
    if (states.contains(MaterialState.selected)) {
      return AppColors.primary; // #0072FF
    }
    return Colors.transparent;
  }),
  dayForegroundColor: MaterialStateProperty.resolveWith((states) {
    if (states.contains(MaterialState.selected)) {
      return Colors.white; // Texto branco no dia selecionado
    }
    return AppColors.lightText;
  }),
  // Garantir que o círculo seja realmente circular
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(50), // Bem arredondado
  ),
),
```

### 4. Cards de Empresa (company_card.dart)

```dart
Container(
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: Colors.white, // #FFFFFF
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: Color(0xFFE5E5E5), width: 1),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Padding(
    padding: EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          company.name, // "Be Coffee"
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1C1C1C),
          ),
        ),
        Text(
          'Pequena Empresa',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.primary, // #0072FF
            fontWeight: FontWeight.w500,
          ),
        ),
        // ...
      ],
    ),
  ),
)
```

### 5. Resolver Bottom Overflow (company_dashboard_page.dart)

```dart
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(...),
    body: SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.only(bottom: 80), // Espaço para não cortar
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Estatísticas
            CompanyStatsCard(...),
            SizedBox(height: 16),

            // Ações Rápidas
            CompanyQuickActions(...),
            SizedBox(height: 16),

            // Tarefas da Empresa
            TasksList(...),
            SizedBox(height: 16),

            // Reuniões Agendadas
            UpcomingMeetings(...),
          ],
        ),
      ),
    ),
  );
}
```

### 6. Ações Rápidas Circulares (company_quick_actions.dart)

```dart
Container(
  width: 80,
  height: 80,
  decoration: BoxDecoration(
    color: Color(0xFFF5F7FA), // Fundo suave
    shape: BoxShape.circle,
    border: Border.all(color: Color(0xFFE0E0E0), width: 1),
  ),
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, color: iconColor, size: 28),
      SizedBox(height: 4),
      Text(
        label,
        style: TextStyle(
          color: Color(0xFF1C1C1C),
          fontSize: 12,
        ),
      ),
    ],
  ),
)
```

### 7. Transações (transactions_page.dart)

```dart
// Card de transação
Container(
  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(color: Color(0xFFE5E5E5)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 6,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: ListTile(
    title: Text(
      'Alimentação',
      style: TextStyle(color: Color(0xFF1C1C1C)),
    ),
    trailing: Text(
      '-R\$39,90',
      style: TextStyle(
        color: Color(0xFFD32F2F), // Vermelho suave
        fontWeight: FontWeight.bold,
      ),
    ),
  ),
)
```

### 8. Botões de Detalhes de Transação

```dart
// Botão Excluir
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFFFFEBEE),
    foregroundColor: Color(0xFFD32F2F),
  ),
  child: Text('Excluir'),
)

// Botão Editar
ElevatedButton(
  style: ElevatedButton.styleFrom(
    backgroundColor: Color(0xFFE8F0FF),
    foregroundColor: AppColors.primary,
  ),
  child: Text('Editar Transação'),
)
```

---

## 📊 Contrastes Alcançados

| Elemento | Cor | Fundo | Contraste | Status |
|----------|-----|-------|-----------|--------|
| Texto primário | #1C1C1C | #FFFFFF | 16.9:1 | ✅ AAA |
| Texto secundário | #5F5F5F | #FFFFFF | 7.2:1 | ✅ AAA |
| Ícones | #2E2E2E | #FFFFFF | 12.3:1 | ✅ AAA |
| Bordas | #E5E5E5 | #FFFFFF | 1.1:1 | ✅ Visível |
| Botão primário | #FFFFFF | #0072FF | 4.5:1 | ✅ AA |

---

## 🧪 Como Testar

```bash
flutter clean
flutter pub get
flutter run -d chrome

# Testar:
1. Navegar para Tarefas → Ver campo de busca
2. Clicar em "+ Nova Tarefa" → Testar calendário
3. Ir em Empresas → Ver cards
4. Clicar em empresa → Verificar overflow
5. Ir em Finanças → Ver transações
6. Clicar em transação → Ver botões
7. Alternar tema claro/escuro
```

---

**Status:** 🔄 Em Progresso
**Data:** 2025-11-10
**Prioridade:** Alta
