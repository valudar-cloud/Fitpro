import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_strings.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey   = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl  = TextEditingController();
  bool _obscure    = true;
  bool _loading    = false;
  bool _googleLoad = false;

  @override
  void dispose() { _emailCtrl.dispose(); _passCtrl.dispose(); super.dispose(); }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final result = await ref.read(authNotifierProvider.notifier).login(
      email: _emailCtrl.text, password: _passCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) { context.go(AppConstants.routeHome); }
    else { _showError(result.errorMessage!); }
  }

  Future<void> _googleLogin() async {
    setState(() => _googleLoad = true);
    final result = await ref.read(authNotifierProvider.notifier).loginWithGoogle();
    if (!mounted) return;
    setState(() => _googleLoad = false);
    if (!result.isSuccess) _showError(result.errorMessage!);
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: AppTheme.danger,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

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
              // Logo
              Center(child: Column(children: [
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.primary, Color(0xFFFF9A3C)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4),
                        blurRadius: 20, offset: const Offset(0, 8))]),
                  child: const Icon(Icons.fitness_center, color: Colors.white, size: 40)),
                const SizedBox(height: 16),
                const Text('FitPro', style: TextStyle(fontSize: 32,
                    fontWeight: FontWeight.w700, color: Colors.white)),
              ]).animate().fadeIn(duration: 600.ms).slideY(begin: -0.2)),

              const SizedBox(height: 48),
              Text(s.loginTitle, style: Theme.of(context).textTheme.displayMedium)
                  .animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 6),
              Text('Reprends là où tu t\'étais arrêté',
                  style: Theme.of(context).textTheme.bodyMedium)
                  .animate().fadeIn(delay: 300.ms),
              const SizedBox(height: 32),

              // Formulaire
              Form(key: _formKey, child: Column(children: [
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Adresse email',
                    prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textHint)),
                  validator: (v) => (v == null || !v.contains('@')) ? 'Email invalide' : null,
                ).animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _login(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textHint),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                          color: AppTheme.textHint),
                      onPressed: () => setState(() => _obscure = !_obscure))),
                  validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
                ).animate().fadeIn(delay: 400.ms),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => _showForgotPassword(context),
                    child: const Text('Mot de passe oublié ?',
                        style: TextStyle(fontSize: 13)))),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(height: 22, width: 22,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                      : const Text('Se connecter'),
                ).animate().fadeIn(delay: 500.ms),
              ])),

              const SizedBox(height: 28),
              // Séparateur
              Row(children: [
                const Expanded(child: Divider(color: AppTheme.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('ou', style: Theme.of(context).textTheme.bodySmall)),
                const Expanded(child: Divider(color: AppTheme.border)),
              ]),
              const SizedBox(height: 20),

              // Bouton Google
              OutlinedButton(
                onPressed: _googleLoad ? null : _googleLogin,
                child: _googleLoad
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2))
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4)),
                          child: const Center(
                            child: Text('G', style: TextStyle(
                                color: Color(0xFF4285F4),
                                fontWeight: FontWeight.w900,
                                fontSize: 16)))),
                        const SizedBox(width: 12),
                        const Text('Continuer avec Google',
                            style: TextStyle(color: Colors.white, fontSize: 15)),
                      ]),
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 32),
              // Inscription
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Pas de compte ?',
                    style: Theme.of(context).textTheme.bodyMedium),
                TextButton(
                  onPressed: () => context.push(AppConstants.routeRegister),
                  child: const Text('S\'inscrire')),
              ]).animate().fadeIn(delay: 700.ms),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showForgotPassword(BuildContext context) {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          left: 24, right: 24, top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Mot de passe oublié', style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Entre ton email pour recevoir un lien de réinitialisation.',
              style: TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 16),
          TextField(
            controller: ctrl,
            keyboardType: TextInputType.emailAddress,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textHint))),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final result = await ref.read(authNotifierProvider.notifier)
                  .resetPassword(ctrl.text);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(result.isSuccess
                      ? '📧 Email envoyé !' : result.errorMessage!),
                  backgroundColor: result.isSuccess ? AppTheme.secondary : AppTheme.danger));
              }
            },
            child: const Text('Envoyer le lien')),
        ]),
      ),
    );
  }
}
