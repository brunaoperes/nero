import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/config/app_router.dart';
import 'core/config/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/services/fcm_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/supabase_service.dart';
import 'core/services/local_storage_service.dart';
import 'core/services/location_history_service.dart';
import 'core/services/location_cache_service.dart';
import 'core/errors/global_error_handler.dart';

void main() async {
  // Inicializar global error handler ANTES de tudo
  GlobalErrorHandler.initialize();

  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar formatação de datas brasileiras
  await initializeDateFormatting('pt_BR', null);

  // Inicializar Hive (banco local para modo offline)
  try {
    await LocalStorageService.initialize();
    debugPrint('✅ Hive (Local Storage) inicializado');
  } catch (e) {
    debugPrint('⚠️ Erro ao inicializar Hive: $e');
  }

  // Inicializar histórico de localizações
  try {
    await LocationHistoryService.initialize();
    debugPrint('✅ Histórico de Localizações inicializado');
  } catch (e) {
    debugPrint('⚠️ Erro ao inicializar histórico de localizações: $e');
  }

  // Inicializar cache de buscas de localização
  try {
    await LocationCacheService.initialize();
    debugPrint('✅ Cache de Localizações inicializado');
  } catch (e) {
    debugPrint('⚠️ Erro ao inicializar cache de localizações: $e');
  }

  // Configurar orientação preferencial (portrait)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Inicializar Supabase
  try {
    await SupabaseService.initialize();
    debugPrint('✅ Supabase inicializado com sucesso');
  } catch (e) {
    debugPrint('⚠️ Erro ao inicializar Supabase: $e');
    debugPrint('ℹ️ O app continuará funcionando em modo offline');
  }

  // Inicializar Firebase
  try {
    await Firebase.initializeApp();
    debugPrint('✅ Firebase inicializado com sucesso');
  } catch (e) {
    debugPrint('⚠️ Erro ao inicializar Firebase: $e');
    debugPrint('ℹ️ Configure o Firebase seguindo o guia FIREBASE_SETUP.md');
  }

  // Inicializar serviços de notificação
  try {
    final notificationService = NotificationService(); // Singleton
    await notificationService.initialize();
    await notificationService.requestPermission();
    debugPrint('✅ NotificationService inicializado');
  } catch (e) {
    debugPrint('⚠️ Erro ao inicializar NotificationService: $e');
  }

  // Inicializar FCM (Firebase Cloud Messaging)
  try {
    final fcmService = FCMService(); // Singleton
    await fcmService.initialize();
    debugPrint('✅ FCMService inicializado');
  } catch (e) {
    debugPrint('⚠️ Erro ao inicializar FCMService: $e');
    debugPrint('ℹ️ FCM não disponível - notificações push desabilitadas');
  }

  runApp(
    const ProviderScope(
      child: NeroApp(),
    ),
  );
}

class NeroApp extends ConsumerWidget {
  const NeroApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp.router(
      title: 'Nero',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      // Configuração de localização para suporte a pt_BR
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('pt', 'BR'),
        Locale('en', 'US'),
      ],
      locale: const Locale('pt', 'BR'),
    );
  }
}
