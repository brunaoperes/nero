import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';
import '../../features/dashboard/presentation/pages/dashboard_page_v2.dart';
import '../../features/tasks/presentation/pages/tasks_list_page.dart';
import '../../features/tasks/presentation/pages/task_detail_page.dart';
import '../../features/companies/presentation/pages/companies_list_page.dart';
import '../../features/finance/presentation/pages/transactions_page.dart';
import '../../features/finance/presentation/pages/add_transaction_page_new.dart';
import '../../features/finance/presentation/pages/finance_reports_page.dart';
import '../../features/finance/presentation/pages/transaction_detail_page.dart';
import '../../features/finance/presentation/pages/settings_management_page.dart';
import '../../features/ai/presentation/pages/ai_recommendations_page.dart';
import '../../features/open_finance/presentation/pages/bank_connections_page.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/settings_page.dart';
import '../../features/profile/presentation/pages/change_password_page.dart';
import '../../features/profile/presentation/pages/accessibility_settings_page.dart';
import '../../features/profile/presentation/pages/security_page.dart';
import '../../features/profile/presentation/pages/notifications_page.dart';
import '../../features/profile/presentation/pages/theme_page.dart';
import '../../features/profile/presentation/pages/language_page.dart';
import '../../features/profile/presentation/pages/integrations_page.dart';
import '../../features/profile/presentation/pages/backup_page.dart';
import '../../features/profile/presentation/pages/help_center_page.dart';
import '../../features/profile/presentation/pages/feedback_page.dart';
import '../../features/profile/presentation/pages/privacy_policy_page.dart';
import '../../features/search/presentation/pages/global_search_page.dart';
import '../../features/companies/presentation/pages/company_form_page.dart';
import '../constants/app_constants.dart';
import '../services/supabase_service.dart';
import '../presentation/main_shell.dart';

/// Provider para o índice da navegação atual (movido do main_shell)
final currentNavigationIndexProvider = StateProvider<int>((ref) => 0);

/// Provider do GoRouter
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.routeSplash,
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuthenticated = SupabaseService.isAuthenticated;
      final isGoingToAuth = state.matchedLocation.startsWith('/login') ||
          state.matchedLocation.startsWith('/register');

      // Se não está autenticado e não está indo para auth, redireciona para login
      if (!isAuthenticated && !isGoingToAuth) {
        return AppConstants.routeLogin;
      }

      // Se está autenticado e está indo para auth, redireciona para dashboard
      if (isAuthenticated && isGoingToAuth) {
        return AppConstants.routeDashboard;
      }

      // TODO: Verificar se completou onboarding
      // Se está autenticado, não completou onboarding e não está indo para onboarding
      // return AppConstants.routeOnboarding;

      return null; // Nenhum redirecionamento
    },
    routes: [
      // Auth Routes
      GoRoute(
        path: AppConstants.routeLogin,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppConstants.routeRegister,
        name: 'register',
        builder: (context, state) => const RegisterPage(),
      ),

      // Onboarding Route
      GoRoute(
        path: AppConstants.routeOnboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),

      // Splash Route (Inicial)
      GoRoute(
        path: AppConstants.routeSplash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),

      // =====================================
      // SHELL ROUTE - BARRA INFERIOR FIXA
      // =====================================
      ShellRoute(
        builder: (context, state, child) {
          return MainShell(child: child);
        },
        routes: [
          // Dashboard (Home)
          GoRoute(
            path: AppConstants.routeDashboard,
            name: 'dashboard',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const DashboardPageV2(),
            ),
          ),

          // Tasks Routes
          GoRoute(
            path: '/tasks',
            name: 'tasks',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const TasksListPage(),
            ),
            routes: [
              GoRoute(
                path: 'detail/:id',
                name: 'task-detail',
                builder: (context, state) {
                  final taskId = state.pathParameters['id']!;
                  return TaskDetailPage(taskId: taskId);
                },
              ),
            ],
          ),

          // Companies Routes
          GoRoute(
            path: '/companies',
            name: 'companies',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const CompaniesListPage(),
            ),
            routes: [
              GoRoute(
                path: 'new',
                name: 'new-company',
                builder: (context, state) => const CompanyFormPage(),
              ),
            ],
          ),

          // Finance Routes (dentro da shell)
          GoRoute(
            path: '/finance',
            name: 'finance',
            pageBuilder: (context, state) {
              final extra = state.extra as Map<String, dynamic>?;
              final accountFilter = extra?['accountFilter'] as String?;
              return NoTransitionPage(
                child: TransactionsPage(accountFilter: accountFilter),
              );
            },
            routes: [
              GoRoute(
                path: 'add',
                name: 'add-transaction',
                builder: (context, state) => const AddTransactionPageNew(),
              ),
              GoRoute(
                path: 'detail/:id',
                name: 'transaction-detail',
                builder: (context, state) {
                  final transactionId = state.pathParameters['id']!;
                  return TransactionDetailPage(transactionId: transactionId);
                },
              ),
              GoRoute(
                path: 'edit/:id',
                name: 'edit-transaction',
                builder: (context, state) {
                  final transactionId = state.pathParameters['id']!;
                  return AddTransactionPageNew(transactionId: transactionId);
                },
              ),
              GoRoute(
                path: 'reports',
                name: 'finance-reports',
                builder: (context, state) => const FinanceReportsPage(),
              ),
              GoRoute(
                path: 'settings',
                name: 'finance-settings',
                builder: (context, state) => const SettingsManagementPage(),
              ),
            ],
          ),

          // Profile Routes
          GoRoute(
            path: '/profile',
            name: 'profile',
            pageBuilder: (context, state) => NoTransitionPage(
              child: const ProfilePage(),
            ),
            routes: [
              GoRoute(
                path: 'edit',
                name: 'edit-profile',
                builder: (context, state) => const EditProfilePage(),
              ),
              GoRoute(
                path: 'change-password',
                name: 'change-password',
                builder: (context, state) => const ChangePasswordPage(),
              ),
              GoRoute(
                path: 'security',
                name: 'security',
                builder: (context, state) => const SecurityPage(),
              ),
              GoRoute(
                path: 'notifications',
                name: 'notifications',
                builder: (context, state) => const NotificationsPage(),
              ),
              GoRoute(
                path: 'theme',
                name: 'theme',
                builder: (context, state) => const ThemePage(),
              ),
              GoRoute(
                path: 'language',
                name: 'language',
                builder: (context, state) => const LanguagePage(),
              ),
              GoRoute(
                path: 'integrations',
                name: 'integrations',
                builder: (context, state) => const IntegrationsPage(),
              ),
              GoRoute(
                path: 'backup',
                name: 'backup',
                builder: (context, state) => const BackupPage(),
              ),
              GoRoute(
                path: 'help',
                name: 'help-center',
                builder: (context, state) => const HelpCenterPage(),
              ),
              GoRoute(
                path: 'feedback',
                name: 'feedback',
                builder: (context, state) => const FeedbackPage(),
              ),
              GoRoute(
                path: 'privacy',
                name: 'privacy-policy',
                builder: (context, state) => const PrivacyPolicyPage(),
              ),
            ],
          ),

          // Search (dentro da shell)
          GoRoute(
            path: '/search',
            name: 'search',
            builder: (context, state) => const GlobalSearchPage(),
          ),

          // Settings (dentro da shell)
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsPage(),
            routes: [
              GoRoute(
                path: 'accessibility',
                name: 'accessibility-settings',
                builder: (context, state) => const AccessibilitySettingsPage(),
              ),
            ],
          ),
          // AI Routes (dentro da shell)
          GoRoute(
            path: '/ai/recommendations',
            name: 'ai-recommendations',
            builder: (context, state) => const AIRecommendationsPage(),
          ),

          // Open Finance Routes (dentro da shell)
          GoRoute(
            path: '/bank-connections',
            name: 'bank-connections',
            builder: (context, state) => const BankConnectionsPage(),
          ),

          // Reports Routes (dentro da shell)
          GoRoute(
            path: '/reports',
            name: 'reports',
            builder: (context, state) => const ReportsPage(),
          ),
        ],
      ),
    ],
  );
});

/// Página de Splash inicial
class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _checkAuthAndNavigate();
  }

  Future<void> _checkAuthAndNavigate() async {
    // Aguarda um momento para garantir que o Supabase foi inicializado
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Verifica se o usuário está autenticado
    final isAuthenticated = SupabaseService.isAuthenticated;

    if (isAuthenticated) {
      // Se autenticado, vai para o dashboard
      context.go(AppConstants.routeDashboard);
    } else {
      // Se não autenticado, vai para login
      context.go(AppConstants.routeLogin);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
