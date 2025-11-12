import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../constants/app_constants.dart';

/// Provider do Supabase Client
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Serviço de configuração do Supabase
class SupabaseService {
  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConstants.supabaseUrl,
      anonKey: AppConstants.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
      ),
      realtimeClientOptions: const RealtimeClientOptions(
        logLevel: RealtimeLogLevel.info,
      ),
    );
  }

  /// Obtém o cliente Supabase
  static SupabaseClient get client => Supabase.instance.client;

  /// Obtém o usuário autenticado
  static User? get currentUser => client.auth.currentUser;

  /// Verifica se o usuário está autenticado
  static bool get isAuthenticated => currentUser != null;

  /// Stream de mudanças no estado de autenticação
  static Stream<AuthState> get authStateChanges =>
      client.auth.onAuthStateChange;

  /// Faz logout do usuário
  static Future<void> signOut() async {
    await client.auth.signOut();
  }
}
