import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../../../core/services/supabase_service.dart';

/// Implementação do repositório de autenticação
class AuthRepositoryImpl implements AuthRepository {
  final SupabaseClient _supabaseClient;
  GoogleSignIn? _googleSignIn;

  AuthRepositoryImpl({
    SupabaseClient? supabaseClient,
    GoogleSignIn? googleSignIn,
  })  : _supabaseClient = supabaseClient ?? SupabaseService.client,
        _googleSignIn = googleSignIn;

  @override
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabaseClient.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      throw Exception('Erro ao fazer login: $e');
    }
  }

  @override
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  }) async {
    try {
      final response = await _supabaseClient.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
        },
      );

      // O trigger handle_new_user() cria automaticamente o registro na tabela users

      return response;
    } catch (e) {
      throw Exception('Erro ao criar conta: $e');
    }
  }

  @override
  Future<AuthResponse> signInWithGoogle() async {
    try {
      // Inicializar Google Sign-In apenas quando necessário
      _googleSignIn ??= GoogleSignIn();

      // Fazer login com Google
      final googleUser = await _googleSignIn!.signIn();
      if (googleUser == null) {
        throw Exception('Login cancelado pelo usuário');
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Erro ao obter tokens do Google');
      }

      // Autenticar no Supabase com o token do Google
      final response = await _supabaseClient.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      // O trigger handle_new_user() cria automaticamente o registro na primeira vez
      // Para atualizar avatar, usamos UPDATE (permitido pelo RLS)
      if (response.user != null && googleUser.photoUrl != null) {
        await _supabaseClient.from('users').update({
          'avatar_url': googleUser.photoUrl,
          'updated_at': DateTime.now().toIso8601String(),
        }).eq('id', response.user!.id);
      }

      return response;
    } catch (e) {
      throw Exception('Erro ao fazer login com Google: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _supabaseClient.auth.signOut();
      // Só tentar deslogar do Google se foi inicializado
      if (_googleSignIn != null) {
        await _googleSignIn!.signOut();
      }
    } catch (e) {
      throw Exception('Erro ao fazer logout: $e');
    }
  }

  @override
  User? getCurrentUser() {
    return _supabaseClient.auth.currentUser;
  }

  @override
  Stream<AuthState> get authStateChanges =>
      _supabaseClient.auth.onAuthStateChange;
}
