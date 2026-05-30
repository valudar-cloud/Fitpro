import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/security/security_service.dart';

// ════════════════════════════════════════════════════════
// AUTH PROVIDER — Session, Login, Register, Logout
// ════════════════════════════════════════════════════════

final _supabase = Supabase.instance.client;

// ── Stream de la session active ───────────────────────
final authStateProvider = StreamProvider<AuthState>((ref) {
  return _supabase.auth.onAuthStateChange;
});

// ── Utilisateur courant ───────────────────────────────
final currentUserProvider = Provider<User?>((ref) {
  return _supabase.auth.currentUser;
});

// ── État d'authentification (connecté ou non) ─────────
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// ── Notifier Auth ─────────────────────────────────────
class AuthNotifier extends AsyncNotifier<void> {

  @override
  Future<void> build() async {}

  // ─ Inscription ────────────────────────────────────────
  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncLoading();

    // Validation sécurité
    if (!SecurityService.isValidEmail(email)) {
      state = const AsyncData(null);
      return AuthResult.error('Email invalide');
    }
    if (!SecurityService.isValidPassword(password)) {
      state = const AsyncData(null);
      return AuthResult.error(
        'Le mot de passe doit contenir 8+ caractères, '
        '1 majuscule, 1 chiffre et 1 caractère spécial',
      );
    }

    try {
      final response = await _supabase.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {
          'full_name': SecurityService.sanitizeInput(fullName),
        },
      );

      if (response.user == null) {
        state = const AsyncData(null);
        return AuthResult.error('Inscription échouée');
      }

      state = const AsyncData(null);
      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      state = const AsyncData(null);
      return AuthResult.error(_mapAuthError(e.message));
    } catch (e) {
      state = const AsyncData(null);
      return AuthResult.error('Erreur inattendue');
    }
  }

  // ─ Connexion ──────────────────────────────────────────
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    if (!SecurityService.isValidEmail(email)) {
      state = const AsyncData(null);
      return AuthResult.error('Email invalide');
    }

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );

      if (response.user == null) {
        state = const AsyncData(null);
        return AuthResult.error('Identifiants incorrects');
      }

      state = const AsyncData(null);
      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      state = const AsyncData(null);
      return AuthResult.error(_mapAuthError(e.message));
    } catch (e) {
      state = const AsyncData(null);
      return AuthResult.error('Erreur inattendue');
    }
  }

  // ─ Mot de passe oublié ────────────────────────────────
  Future<AuthResult> resetPassword(String email) async {
    if (!SecurityService.isValidEmail(email)) {
      return AuthResult.error('Email invalide');
    }
    try {
      await _supabase.auth.resetPasswordForEmail(
        email.trim().toLowerCase(),
        redirectTo: 'fitpro://reset-password',
      );
      return AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.error(_mapAuthError(e.message));
    }
  }

  // ─ Déconnexion ────────────────────────────────────────
  Future<void> logout() async {
    await _supabase.auth.signOut();
    await SecurityService.delete(SecurityService.keySessionToken);
  }

  // ─ Mapping erreurs Supabase ───────────────────────────
  String _mapAuthError(String message) {
    if (message.contains('Invalid login')) return 'Email ou mot de passe incorrect';
    if (message.contains('Email not confirmed')) return 'Confirme ton email d\'abord';
    if (message.contains('User already registered')) return 'Cet email est déjà utilisé';
    if (message.contains('Password should be')) return 'Mot de passe trop court';
    if (message.contains('rate limit')) return 'Trop de tentatives, réessaie plus tard';
    return 'Erreur de connexion';
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(
  AuthNotifier.new,
);

// ── Résultat Auth ─────────────────────────────────────
class AuthResult {
  final User? user;
  final String? errorMessage;
  bool get isSuccess => errorMessage == null;

  const AuthResult._({this.user, this.errorMessage});
  factory AuthResult.success(User? user) => AuthResult._(user: user);
  factory AuthResult.error(String msg) => AuthResult._(errorMessage: msg);
}
