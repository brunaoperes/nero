import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../config/app_router.dart';
import '../constants/app_constants.dart';

/// Shell principal do app com bottom navigation bar SEMPRE PERSISTENTE
/// Recebe o child do ShellRoute e exibe a barra de navegação inferior
class MainShell extends ConsumerWidget {
  final Widget child;

  const MainShell({
    super.key,
    required this.child,
  });

  /// Determina o índice da bottom bar baseado na rota atual
  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;

    if (location.startsWith('/dashboard') || location == '/') {
      return 0;
    } else if (location.startsWith('/tasks')) {
      return 1;
    } else if (location.startsWith('/companies')) {
      return 2;
    } else if (location.startsWith('/finance')) {
      return 3;
    } else if (location.startsWith('/profile')) {
      return 4;
    }

    // Default: Home
    return 0;
  }

  /// Navega para a rota da aba selecionada
  void _onItemTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(AppConstants.routeDashboard);
        break;
      case 1:
        context.go('/tasks');
        break;
      case 2:
        context.go('/companies');
        break;
      case 3:
        context.go('/finance');
        break;
      case 4:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child, // Child vem do ShellRoute (página atual)
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0),
              width: 1,
            ),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onItemTapped(context, index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
          selectedItemColor: const Color(0xFF0072FF),
          unselectedItemColor: isDark
              ? const Color(0xFF757575)
              : const Color(0xFF8C8C8C),
          selectedFontSize: 12,
          unselectedFontSize: 12,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 24),
              activeIcon: Icon(Icons.home, size: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline, size: 24),
              activeIcon: Icon(Icons.check_circle, size: 24),
              label: 'Tarefas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.business_outlined, size: 24),
              activeIcon: Icon(Icons.business, size: 24),
              label: 'Empresas',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.account_balance_wallet_outlined, size: 24),
              activeIcon: Icon(Icons.account_balance_wallet, size: 24),
              label: 'Finanças',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 24),
              activeIcon: Icon(Icons.person, size: 24),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }
}
