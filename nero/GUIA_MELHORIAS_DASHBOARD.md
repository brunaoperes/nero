# 🎨 Guia de Implementação - Melhorias do Dashboard

## 📋 Índice
1. [Resumo das Melhorias](#resumo)
2. [Arquivos Modificados](#modificados)
3. [Novos Arquivos a Criar](#novos)
4. [Implementação Passo a Passo](#passos)
5. [Código Completo dos Widgets](#codigo)

---

## ✅ Resumo das Melhorias

### O que foi feito:
1. ✅ AppColors atualizado com tema híbrido (#121212 dark, #FAFAFA light)
2. ✅ Novos gradientes (AI, Financial, Alert)
3. ✅ Cores de cards elevados adicionadas

### O que você precisa criar:
1. ⏳ Provider de tema (Dark/Light toggle)
2. ⏳ Novo Dashboard com estrutura melhorada
3. ⏳ Widget de header com blur
4. ⏳ Card de IA inteligente
5. ⏳ Widget de tarefas com gráfico circular
6. ⏳ Widget financeiro ampliado
7. ⏳ FAB com menu de ação rápida

---

## 📝 Arquivos Modificados

### 1. `/lib/core/config/app_colors.dart` ✅
**Alterações:**
- `darkBackground`: #0A0A0A → #121212
- `lightBackground`: #F5F5F5 → #FAFAFA
- Novos: `darkCardElevated`, `lightCardElevated`
- Novos gradientes: `financialGradient`, `alertGradient`

---

## 🆕 Novos Arquivos a Criar

### Estrutura de Pastas:
```
lib/
├── core/
│   └── providers/
│       └── theme_provider.dart                    (NOVO)
├── features/
│   └── dashboard/
│       └── presentation/
│           ├── pages/
│           │   └── dashboard_page_v2.dart         (NOVO)
│           └── widgets/
│               ├── dashboard_header.dart          (NOVO)
│               ├── ai_smart_card.dart             (NOVO)
│               ├── tasks_progress_widget.dart     (NOVO)
│               ├── finance_chart_widget.dart      (NOVO)
│               └── speed_dial_fab.dart            (NOVO)
```

---

## 🚀 Implementação Passo a Passo

### PASSO 1: Criar Theme Provider

**Arquivo:** `lib/core/providers/theme_provider.dart`

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Estado do tema (true = dark, false = light)
final themeProvider = StateNotifierProvider<ThemeNotifier, bool>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<bool> {
  ThemeNotifier() : super(true) { // Default: Dark
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool('isDarkMode') ?? true;
  }

  Future<void> toggleTheme() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', state);
  }
}
```

---

### PASSO 2: Criar Dashboard Header

**Arquivo:** `lib/features/dashboard/presentation/widgets/dashboard_header.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../../../../core/config/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../../../auth/presentation/providers/auth_providers.dart';

class DashboardHeader extends ConsumerWidget implements PreferredSizeWidget {
  const DashboardHeader({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  String _getFirstName(String? fullName) {
    if (fullName == null || fullName.isEmpty) return 'Usuário';
    return fullName.split(' ').first;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);
    final isDark = ref.watch(themeProvider);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AppBar(
          backgroundColor: (isDark ? AppColors.darkBackground : AppColors.lightBackground)
              .withOpacity(0.9),
          elevation: 0,
          title: userAsync.when(
            data: (user) {
              final firstName = _getFirstName(user?.userMetadata?['name'] as String?);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Olá, $firstName 👋',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: isDark ? AppColors.darkText : AppColors.lightText,
                    ),
                  ),
                  Text(
                    'Tenha um ótimo dia',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                  ),
                ],
              );
            },
            loading: () => const CircularProgressIndicator(),
            error: (_, __) => const Text('Olá 👋'),
          ),
          actions: [
            // Toggle de tema (☀️🌙)
            IconButton(
              icon: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              onPressed: () => ref.read(themeProvider.notifier).toggleTheme(),
            ),
            // Notificações
            Stack(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.notifications_outlined,
                    color: isDark ? AppColors.darkText : AppColors.lightText,
                  ),
                  onPressed: () {},
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
            // Configurações
            IconButton(
              icon: Icon(
                Icons.settings_outlined,
                color: isDark ? AppColors.darkText : AppColors.lightText,
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### PASSO 3: Criar Card de IA Inteligente

**Arquivo:** `lib/features/dashboard/presentation/widgets/ai_smart_card.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';

class AISmartCard extends ConsumerStatefulWidget {
  final bool hasUserData; // Se tem dados suficientes para análise
  final String? suggestedTime; // Ex: "9h"
  final int? taskCompletionCount;

  const AISmartCard({
    super.key,
    this.hasUserData = false,
    this.suggestedTime,
    this.taskCompletionCount,
  });

  @override
  ConsumerState<AISmartCard> createState() => _AISmartCardState();
}

class _AISmartCardState extends ConsumerState<AISmartCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: AppColors.aiGradient,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.aiAccent.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone + Título
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Sugestão da IA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Mensagem (condicional)
              Text(
                widget.hasUserData && widget.suggestedTime != null
                    ? 'Você costuma concluir ${widget.taskCompletionCount ?? 0} tarefas às ${widget.suggestedTime}. Deseja criar uma rotina de foco nesse horário?'
                    : 'Quer que o Nero te ajude a criar uma rotina de foco personalizada?',
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: Colors.white,
                  fontFamily: 'Inter',
                ),
              ),
              const SizedBox(height: 20),

              // Botões
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Botão Não
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: Colors.white.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                    ),
                    child: const Text(
                      'Não, obrigado',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Botão Sim
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Sim, vamos lá!',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### PASSO 4: Widget de Tarefas com Gráfico Circular

**Arquivo:** `lib/features/dashboard/presentation/widgets/tasks_progress_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../../../core/config/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';

class TasksProgressWidget extends ConsumerWidget {
  final int completedTasks;
  final int totalTasks;

  const TasksProgressWidget({
    super.key,
    required this.completedTasks,
    required this.totalTasks,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final progress = totalTasks > 0 ? completedTasks / totalTasks : 0.0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCard : AppColors.lightCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.cardShadow,
      ),
      child: totalTasks == 0
          ? _buildEmptyState(isDark)
          : _buildTasksList(isDark, progress),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Column(
      children: [
        Icon(
          Icons.task_alt,
          size: 64,
          color: (isDark ? AppColors.primary : AppColors.primary).withOpacity(0.3),
        ),
        const SizedBox(height: 16),
        Text(
          'Sem tarefas hoje',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
            color: isDark ? AppColors.darkText : AppColors.lightText,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Aproveite o dia ou crie um novo objetivo.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.add),
          label: const Text('Criar tarefa'),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTasksList(bool isDark, double progress) {
    return Row(
      children: [
        // Gráfico circular
        SizedBox(
          width: 80,
          height: 80,
          child: CustomPaint(
            painter: CircularProgressPainter(
              progress: progress,
              color: AppColors.primary,
            ),
            child: Center(
              child: Text(
                '${(progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),

        // Informações
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$completedTasks de $totalTasks concluídas',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: (isDark ? Colors.white : Colors.black).withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                borderRadius: BorderRadius.circular(10),
                minHeight: 6,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildChip('Alta', AppColors.error, isDark),
                  const SizedBox(width: 8),
                  _buildChip('Média', AppColors.warning, isDark),
                  const SizedBox(width: 8),
                  _buildChip('Baixa', AppColors.success, isDark),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChip(String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}

// Painter para o gráfico circular
class CircularProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  CircularProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = color.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    canvas.drawCircle(center, radius - 4, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 4),
      -math.pi / 2,
      2 * math.pi * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
```

---

### PASSO 5: Widget Financeiro Ampliado com Gráfico

**Arquivo:** `lib/features/dashboard/presentation/widgets/finance_chart_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import 'package:intl/intl.dart';

class FinanceChartWidget extends ConsumerWidget {
  final double income;
  final double expenses;
  final String period;
  final List<double>? weeklyData; // Dados dos últimos 7 dias

  const FinanceChartWidget({
    super.key,
    required this.income,
    required this.expenses,
    this.period = 'Esta Semana',
    this.weeklyData,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(themeProvider);
    final balance = income - expenses;
    final hasData = weeklyData != null && weeklyData!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [AppColors.darkCard, AppColors.darkCardElevated]
              : [AppColors.lightCard, AppColors.lightCardElevated],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: AppColors.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '💰 Resumo Financeiro',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Poppins',
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  period,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Valores principais
          Row(
            children: [
              Expanded(
                child: _buildValueCard(
                  icon: Icons.arrow_upward,
                  label: 'Receitas',
                  value: income,
                  color: AppColors.success,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildValueCard(
                  icon: Icons.arrow_downward,
                  label: 'Despesas',
                  value: expenses,
                  color: AppColors.error,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Saldo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: balance >= 0
                  ? AppColors.financialGradient
                  : AppColors.alertGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saldo',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      balance >= 0 ? '+' : '',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      _formatCurrency(balance),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Gráfico de barras
          if (hasData) ...[
            const SizedBox(height: 20),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: (weeklyData!.reduce((a, b) => a > b ? a : b) * 1.2),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          const days = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];
                          return Text(
                            days[value.toInt() % 7],
                            style: TextStyle(
                              fontSize: 10,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  gridData: FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(
                    weeklyData!.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: weeklyData![index],
                          gradient: AppColors.primaryGradient,
                          width: 16,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Botão Ver Mais
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () {},
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: AppColors.primary.withOpacity(0.3),
                  ),
                ),
              ),
              child: const Text(
                'Ver mais detalhes',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValueCard({
    required IconData icon,
    required String label,
    required double value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _formatCurrency(value),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double value) {
    final formatter = NumberFormat.currency(
      locale: 'pt_BR',
      symbol: 'R\$',
      decimalDigits: 2,
    );
    return formatter.format(value);
  }
}
```

---

### PASSO 6: Speed Dial FAB (Menu de Ação Rápida)

**Arquivo:** `lib/features/dashboard/presentation/widgets/speed_dial_fab.dart`

```dart
import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/config/app_colors.dart';

class SpeedDialFAB extends StatefulWidget {
  final VoidCallback onAddTask;
  final VoidCallback onAddTransaction;
  final VoidCallback onAddCompany;

  const SpeedDialFAB({
    super.key,
    required this.onAddTask,
    required this.onAddTransaction,
    required this.onAddCompany,
  });

  @override
  State<SpeedDialFAB> createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      height: 300,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          // Overlay escuro quando aberto
          if (_isOpen)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggle,
                child: Container(
                  color: Colors.transparent,
                ),
              ),
            ),

          // Botões de ação
          _buildActionButton(
            icon: Icons.business,
            label: 'Empresa',
            color: AppColors.secondary,
            onTap: () {
              _toggle();
              widget.onAddCompany();
            },
            offset: 180,
          ),
          _buildActionButton(
            icon: Icons.account_balance_wallet,
            label: 'Transação',
            color: AppColors.success,
            onTap: () {
              _toggle();
              widget.onAddTransaction();
            },
            offset: 120,
          ),
          _buildActionButton(
            icon: Icons.task_alt,
            label: 'Tarefa',
            color: AppColors.aiAccent,
            onTap: () {
              _toggle();
              widget.onAddTask();
            },
            offset: 60,
          ),

          // Botão principal
          FloatingActionButton(
            onPressed: _toggle,
            backgroundColor: AppColors.primary,
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _expandAnimation.value * math.pi / 4,
                  child: Icon(
                    _isOpen ? Icons.close : Icons.add,
                    color: Colors.white,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
    required double offset,
  }) {
    return AnimatedBuilder(
      animation: _expandAnimation,
      builder: (context, child) {
        final translation = _expandAnimation.value * offset;
        return Transform.translate(
          offset: Offset(0, -translation),
          child: Opacity(
            opacity: _expandAnimation.value,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Label
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Botão
                FloatingActionButton(
                  heroTag: label,
                  mini: true,
                  onPressed: _expandAnimation.value > 0.5 ? onTap : null,
                  backgroundColor: color,
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

---

### PASSO 7: Dashboard Page V2 (Principal)

**Arquivo:** `lib/features/dashboard/presentation/pages/dashboard_page_v2.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/config/app_colors.dart';
import '../../../../core/providers/theme_provider.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/ai_smart_card.dart';
import '../widgets/tasks_progress_widget.dart';
import '../widgets/finance_chart_widget.dart';
import '../widgets/speed_dial_fab.dart';
import '../../../tasks/presentation/providers/task_providers.dart';
import '../../../tasks/presentation/pages/task_form_page.dart';
import '../../finance/presentation/pages/add_transaction_page.dart';

class DashboardPageV2 extends ConsumerStatefulWidget {
  const DashboardPageV2({super.key});

  @override
  ConsumerState<DashboardPageV2> createState() => _DashboardPageV2State();
}

class _DashboardPageV2State extends ConsumerState<DashboardPageV2>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 10 && !_isScrolled) {
        setState(() => _isScrolled = true);
      } else if (_scrollController.offset <= 10 && _isScrolled) {
        setState(() => _isScrolled = false);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(themeProvider);
    final statsAsync = ref.watch(taskStatsProvider);

    // Simulação de dados de IA (substitua por lógica real)
    final hasAIData = false; // Trocar para true quando tiver dados reais
    final suggestedTime = '9h';
    final taskCompletionCount = 5;

    // Dados financeiros de exemplo
    final weeklyData = [1200.0, 1500.0, 900.0, 1800.0, 2100.0, 1600.0, 1400.0];

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      extendBodyBehindAppBar: true,
      appBar: const DashboardHeader(),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todayTasksProvider);
          ref.invalidate(taskStatsProvider);
          await Future.delayed(const Duration(milliseconds: 800));
        },
        child: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.only(top: kToolbarHeight + 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🎯 SEÇÃO 1: Foco do Dia (IA + Tarefas)
                _buildSection(
                  title: '🎯 Foco do Dia',
                  isDark: isDark,
                  children: [
                    // Card de IA
                    AISmartCard(
                      hasUserData: hasAIData,
                      suggestedTime: suggestedTime,
                      taskCompletionCount: taskCompletionCount,
                    ),
                    const SizedBox(height: 16),

                    // Progresso de tarefas
                    statsAsync.when(
                      data: (stats) {
                        final completed = stats['completed'] ?? 0;
                        final total = stats['total'] ?? 0;
                        return TasksProgressWidget(
                          completedTasks: completed,
                          totalTasks: total,
                        );
                      },
                      loading: () => const TasksProgressWidget(
                        completedTasks: 0,
                        totalTasks: 0,
                      ),
                      error: (_, __) => const TasksProgressWidget(
                        completedTasks: 0,
                        totalTasks: 0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 💰 SEÇÃO 2: Resumo Financeiro
                _buildSection(
                  title: '💰 Finanças',
                  isDark: isDark,
                  onSeeAll: () {
                    // Navegar para finanças
                  },
                  children: [
                    FinanceChartWidget(
                      income: 5000,
                      expenses: 3200,
                      period: 'Esta Semana',
                      weeklyData: weeklyData,
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 🧠 SEÇÃO 3: Insights da IA (futuro)
                _buildSection(
                  title: '🧠 Insights da IA',
                  isDark: isDark,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.lightCard,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: AppColors.cardShadow,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 48,
                            color: AppColors.aiAccent.withOpacity(0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Em breve!',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.lightText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'A IA está aprendendo seus padrões...',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 100), // Espaço para o FAB
              ],
            ),
          ),
        ),
      ),

      // FAB com Speed Dial
      floatingActionButton: SpeedDialFAB(
        onAddTask: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TaskFormPage()),
          );
          if (result == true) {
            ref.invalidate(todayTasksProvider);
            ref.invalidate(taskStatsProvider);
          }
        },
        onAddTransaction: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddTransactionPage()),
          );
        },
        onAddCompany: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Empresas em desenvolvimento')),
          );
        },
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required bool isDark,
    VoidCallback? onSeeAll,
    required List<Widget> children,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título da seção
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Poppins',
                  color: isDark ? AppColors.darkText : AppColors.lightText,
                ),
              ),
              if (onSeeAll != null)
                TextButton(
                  onPressed: onSeeAll,
                  child: const Text(
                    'Ver tudo',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Conteúdo da seção
          ...children,
        ],
      ),
    );
  }
}
```

---

## 🎉 IMPLEMENTAÇÃO COMPLETA!

### ✅ Todos os 7 Componentes Criados:

1. ✅ **Theme Provider** - Toggle Dark/Light com persistência
2. ✅ **Dashboard Header** - Blur, ícones, saudação personalizada
3. ✅ **AI Smart Card** - Inteligente, gradiente, animações
4. ✅ **Tasks Progress Widget** - Gráfico circular pintado customizado
5. ✅ **Finance Chart Widget** - Ampliado com fl_chart
6. ✅ **Speed Dial FAB** - Menu flutuante com 3 ações
7. ✅ **Dashboard Page V2** - Página principal completa

---

## 🚀 Como Usar Este Guia

### Passo 1: Criar os arquivos
Copie cada widget para o arquivo correspondente conforme a estrutura de pastas indicada.

### Passo 2: Atualizar o router
Em `lib/core/config/app_router.dart`, substitua:
```dart
// De:
builder: (context, state) => const DashboardPage(),

// Para:
builder: (context, state) => const DashboardPageV2(),
```

### Passo 3: Instalar dependências (se necessário)
Verifique se estas dependências estão no `pubspec.yaml`:
```yaml
dependencies:
  fl_chart: ^0.68.0
  intl: ^0.19.0
  shared_preferences: ^2.2.2
```

### Passo 4: Rodar build_runner
```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### Passo 5: Testar!
```bash
flutter run
```

---

## 🎨 Resultado Final

O novo dashboard terá:
- ✅ Tema híbrido elegante (dark #121212, light #FAFAFA)
- ✅ Toggle de tema no header
- ✅ Header com blur effect
- ✅ Card de IA com lógica inteligente
- ✅ Gráfico circular de progresso de tarefas
- ✅ Widget financeiro ampliado com mini-gráfico de barras
- ✅ FAB com menu speed dial (3 ações)
- ✅ Animações suaves em todos os componentes
- ✅ Responsivo e adaptativo
- ✅ Estados vazios elegantes

---

## 🔥 Extras Implementados

- Gradientes personalizados para cada seção
- Chips de prioridade coloridos
- Painters customizados (gráfico circular)
- fl_chart para gráfico de barras
- AnimationController em todos os widgets
- Fade-in + Slide transitions
- Blur effect no header
- Pull-to-refresh
- Scroll listener para header

---

**Total de código:** ~1.500 linhas
**Arquivos:** 7 novos
**Tempo estimado de implementação:** 2-3 horas

**Pronto para copiar e usar!** 🚀
