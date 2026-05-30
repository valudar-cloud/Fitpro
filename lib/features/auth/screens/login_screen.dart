import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_strings.dart';

// ════════════════════════════════════════════════════════
// ÉCRAN LOGIN
// ════════════════════════════════════════════════════════

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscurePass = true;
  bool _isLoading   = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final result = await ref.read(authNotifierProvider.notifier).login(
      email: _emailCtrl.text,
      password: _passCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      context.go(AppConstants.routeHome);
    } else {
      _showError(result.errorMessage!);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 60),

              // ─ Logo ──────────────────────────────────
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppTheme.primary, Color(0xFFFF9A3C)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primary.withOpacity(0.4),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.fitness_center,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'FitPro',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2),
              ),

              const SizedBox(height: 48),

              // ─ Titre ─────────────────────────────────
              Text(
                s.loginTitle,
                style: Theme.of(context).textTheme.displayMedium,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 6),
              Text(
                s.isFr
                    ? 'Reprends là où tu t\'étais arrêté'
                    : 'Pick up where you left off',
                style: Theme.of(context).textTheme.bodyMedium,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 36),

              // ─ Formulaire ────────────────────────────
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Email
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: s.emailLabel,
                        prefixIcon: const Icon(Icons.email_outlined,
                            color: AppTheme.textHint),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return s.isFr ? 'Email requis' : 'Email required';
                        }
                        if (!v.contains('@')) {
                          return s.isFr ? 'Email invalide' : 'Invalid email';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 350.ms).slideX(begin: -0.1),

                    const SizedBox(height: 16),

                    // Mot de passe
                    TextFormField(
                      controller: _passCtrl,
                      obscureText: _obscurePass,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _login(),
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        labelText: s.passwordLabel,
                        prefixIcon: const Icon(Icons.lock_outline,
                            color: AppTheme.textHint),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePass
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppTheme.textHint,
                          ),
                          onPressed: () =>
                              setState(() => _obscurePass = !_obscurePass),
                        ),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) {
                          return s.isFr
                              ? 'Mot de passe requis'
                              : 'Password required';
                        }
                        return null;
                      },
                    ).animate().fadeIn(delay: 400.ms).slideX(begin: -0.1),

                    // Mot de passe oublié
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push('/forgot-password'),
                        child: Text(s.forgotPassword,
                            style: const TextStyle(fontSize: 13)),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Bouton connexion
                    ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              ),
                            )
                          : Text(s.loginBtn),
                    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ─ Séparateur ────────────────────────────
              Row(
                children: [
                  const Expanded(child: Divider(color: AppTheme.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(s.orContinueWith,
                        style: Theme.of(context).textTheme.bodySmall),
                  ),
                  const Expanded(child: Divider(color: AppTheme.border)),
                ],
              ),

              const SizedBox(height: 24),

              // ─ Bouton Google ─────────────────────────
              OutlinedButton.icon(
                onPressed: () {/* TODO: Google OAuth */},
                icon: const Text('G',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF4285F4))),
                label: Text(
                  s.isFr ? 'Continuer avec Google' : 'Continue with Google',
                  style: const TextStyle(color: Colors.white),
                ),
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 40),

              // ─ Lien inscription ───────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(s.noAccount,
                      style: Theme.of(context).textTheme.bodyMedium),
                  TextButton(
                    onPressed: () => context.push(AppConstants.routeRegister),
                    child: Text(s.registerBtn),
                  ),
                ],
              ).animate().fadeIn(delay: 700.ms),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
