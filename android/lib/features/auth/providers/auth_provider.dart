import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/security/security_service.dart';

// ════════════════════════════════════════════════════════
// AUTH PROVIDER — Login, Register, Google OAuth, Logout
// ════════════════════════════════════════════════════════

final supabase = Supabase.instance.client;

final authStateProvider = StreamProvider<AuthState>((ref) =>
    supabase.auth.onAuthStateChange);

final currentUserProvider = Provider<User?>((ref) =>
    supabase.auth.currentUser);

final isAuthenticatedProvider = Provider<bool>((ref) =>
    ref.watch(currentUserProvider) != null);

class AuthNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  // ─ Inscription email ─────────────────────────────────
  Future<AuthResult> register({
    required String email,
    required String password,
    required String fullName,
  }) async {
    state = const AsyncLoading();
    if (!SecurityService.isValidEmail(email)) {
      state = const AsyncData(null);
      return AuthResult.error('Email invalide');
    }
    if (!SecurityService.isValidPassword(password)) {
      state = const AsyncData(null);
      return AuthResult.error(
          'Mot de passe : 8+ caractères, 1 majuscule, 1 chiffre, 1 spécial');
    }
    try {
      final response = await supabase.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {'full_name': SecurityService.sanitizeInput(fullName)},
      );
      state = const AsyncData(null);
      if (response.user == null) return AuthResult.error('Inscription échouée');
      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      state = const AsyncData(null);
      return AuthResult.error(_mapError(e.message));
    } catch (e) {
      state = const AsyncData(null);
      return AuthResult.error('Erreur Supabase: $e');
    }
  }

  // ─ Connexion email ───────────────────────────────────
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
      final response = await supabase.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      state = const AsyncData(null);
      if (response.user == null) return AuthResult.error('Identifiants incorrects');
      return AuthResult.success(response.user!);
    } on AuthException catch (e) {
      state = const AsyncData(null);
      return AuthResult.error(_mapError(e.message));
    } catch (e) {
      state = const AsyncData(null);
      return AuthResult.error('Erreur Supabase: $e');
    }
  }

  // ─ Connexion Google ──────────────────────────────────
  Future<AuthResult> loginWithGoogle() async {
    state = const AsyncLoading();
    try {
      await supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'fitpro://login-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      state = const AsyncData(null);
      // Le redirect gère la suite via deep link
      return AuthResult.success(null);
    } on AuthException catch (e) {
      state = const AsyncData(null);
      return AuthResult.error(_mapError(e.message));
    } catch (e) {
      state = const AsyncData(null);
      return AuthResult.error('Google Sign-In indisponible: $e');
    }
  }

  // ─ Mot de passe oublié ───────────────────────────────
  Future<AuthResult> resetPassword(String email) async {
    if (!SecurityService.isValidEmail(email)) {
      return AuthResult.error('Email invalide');
    }
    try {
      await supabase.auth.resetPasswordForEmail(
        email.trim().toLowerCase(),
        redirectTo: 'fitpro://reset-password',
      );
      return AuthResult.success(null);
    } on AuthException catch (e) {
      return AuthResult.error(_mapError(e.message));
    }
  }

  // ─ Déconnexion ───────────────────────────────────────
  Future<void> logout() async {
    await supabase.auth.signOut();
    await SecurityService.deleteAll();
  }

  // ─ Mapping erreurs ───────────────────────────────────
  String _mapError(String message) {
    if (message.contains('Invalid login')) return 'Email ou mot de passe incorrect';
    if (message.contains('Email not confirmed')) return 'Email non confirmé — désactive cette option dans Supabase > Auth > Providers > Email';
    if (message.contains('User already registered')) return 'Cet email est déjà utilisé';
    if (message.contains('Password should be')) return 'Mot de passe trop court (min 6 caractères)';
    if (message.contains('rate limit')) return 'Trop de tentatives, réessaie plus tard';
    if (message.contains('signup_disabled')) return 'Inscriptions désactivées temporairement';
    return 'Erreur Supabase: $message';
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, void>(
    AuthNotifier.new);

class AuthResult {
  final User? user;
  final String? errorMessage;
  bool get isSuccess => errorMessage == null;
  const AuthResult._({this.user, this.errorMessage});
  factory AuthResult.success(User? user) => AuthResult._(user: user);
  factory AuthResult.error(String msg) => AuthResult._(errorMessage: msg);
}
