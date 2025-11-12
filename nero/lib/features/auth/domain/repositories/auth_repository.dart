import 'package:supabase_flutter/supabase_flutter.dart';

/// Interface do repositório de autenticação
abstract class AuthRepository {
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? name,
  });

  Future<AuthResponse> signInWithGoogle();

  Future<void> signOut();

  User? getCurrentUser();

  Stream<AuthState> get authStateChanges;
}
