/// Constantes globais do aplicativo Nero
class AppConstants {
  AppConstants._();

  // App Info
  static const String appName = 'Nero';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'Gestor Pessoal Inteligente';

  // API & Backend
  static const String supabaseUrl = 'https://yyxrgfwezgffncxuhkvo.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl5eHJnZndlemdmZm5jeHVoa3ZvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjI1MjcxNTMsImV4cCI6MjA3ODEwMzE1M30.RZ4SxzoKKm6Covrr1zNC02Jozxjsuquvv4zGWyMhx48';

  // AI Backend (Node.js + OpenAI)
  static const String backendUrl = 'http://localhost:3000';
  static const String backendApiUrl = 'http://localhost:3000/api';
  static const String backendApiKey = 'Vz8NtOJMUBmySTWqhDYF7ljigPAR3n1Q';

  // Storage Keys
  static const String keyThemeMode = 'theme_mode';
  static const String keyLanguage = 'language';
  static const String keyOnboardingCompleted = 'onboarding_completed';
  static const String keyEntrepreneurMode = 'entrepreneur_mode';
  static const String keyUserId = 'user_id';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Cache Duration
  static const Duration cacheDuration = Duration(minutes: 5);

  // Notification Channels
  static const String notificationChannelId = 'nero_notifications';
  static const String notificationChannelName = 'Nero Notifications';
  static const String aiNotificationChannelId = 'nero_ai_notifications';
  static const String aiNotificationChannelName = 'Nero AI Suggestions';

  // Routes
  static const String routeSplash = '/';
  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeOnboarding = '/onboarding';
  static const String routeDashboard = '/dashboard';
  static const String routeTasks = '/tasks';
  static const String routeTaskDetail = '/tasks/:id';
  static const String routeCompanies = '/companies';
  static const String routeCompanyDetail = '/companies/:id';
  static const String routeFinance = '/finance';
  static const String routeReports = '/reports';
  static const String routeSettings = '/settings';
  static const String routeProfile = '/profile';

  // Task Origins
  static const String taskOriginPersonal = 'personal';
  static const String taskOriginCompany = 'company';
  static const String taskOriginAI = 'ai';
  static const String taskOriginRecurring = 'recurring';

  // Company Types
  static const String companyTypeMEI = 'mei';
  static const String companyTypeSmall = 'small';
  static const String companyTypeServices = 'services';

  // Transaction Categories
  static const List<String> expenseCategories = [
    'Alimentação',
    'Transporte',
    'Moradia',
    'Saúde',
    'Educação',
    'Lazer',
    'Vestuário',
    'Outros',
  ];

  static const List<String> incomeCategories = [
    'Salário',
    'Freelance',
    'Investimentos',
    'Vendas',
    'Outros',
  ];

  // AI Configuration
  static const int maxAIRecommendationsPerDay = 5;
  static const Duration aiRecommendationCooldown = Duration(hours: 2);

  // Offline Sync
  static const int maxOfflineActions = 1000;
  static const Duration syncInterval = Duration(minutes: 15);
}
