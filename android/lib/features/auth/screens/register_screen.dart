import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/security/security_service.dart';
import '../../../core/localization/app_strings.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});
  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey     = GlobalKey<FormState>();
  final _nameCtrl    = TextEditingController();
  final _emailCtrl   = TextEditingController();
  final _passCtrl    = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscure1 = true, _obscure2 = true;
  bool _loading = false, _googleLoad = false;
  bool _accepted = false;

  bool get _hasLength  => _passCtrl.text.length >= 8;
  bool get _hasUpper   => RegExp(r'[A-Z]').hasMatch(_passCtrl.text);
  bool get _hasNumber  => RegExp(r'[0-9]').hasMatch(_passCtrl.text);
  bool get _hasSpecial => RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_passCtrl.text);

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_accepted) { _showError('Accepte les conditions d\'utilisation'); return; }
    setState(() => _loading = true);
    final result = await ref.read(authNotifierProvider.notifier).register(
      email: _emailCtrl.text, password: _passCtrl.text, fullName: _nameCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result.isSuccess) { context.go(AppConstants.routeOnboarding); }
    else { _showError(result.errorMessage!); }
  }

  Future<void> _googleRegister() async {
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
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Créer un compte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop())),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

              Text('Rejoins FitPro 🚀',
                  style: Theme.of(context).textTheme.displayMedium)
                  .animate().fadeIn(),
              const SizedBox(height: 6),
              Text('Gratuit — no carte bleue requise',
                  style: Theme.of(context).textTheme.bodyMedium)
                  .animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 28),

              // Prénom
              TextFormField(
                controller: _nameCtrl,
                textCapitalization: TextCapitalization.words,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Prénom et nom',
                  prefixIcon: Icon(Icons.person_outline, color: AppTheme.textHint)),
                validator: (v) => (v == null || v.trim().length < 2) ? 'Requis' : null,
              ).animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 12),

              // Email
              TextFormField(
                controller: _emailCtrl,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                textInputAction: TextInputAction.next,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Adresse email',
                  prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textHint)),
                validator: (v) => (v == null || !SecurityService.isValidEmail(v))
                    ? 'Email invalide' : null,
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 12),

              // Mot de passe
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscure1,
                textInputAction: TextInputAction.next,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textHint),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure1 ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined, color: AppTheme.textHint),
                    onPressed: () => setState(() => _obscure1 = !_obscure1))),
                validator: (v) => (v == null || !SecurityService.isValidPassword(v))
                    ? 'Mot de passe trop faible' : null,
              ).animate().fadeIn(delay: 250.ms),

              // Indicateurs force
              if (_passCtrl.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                _StrengthBar(hasLength: _hasLength, hasUpper: _hasUpper,
                    hasNumber: _hasNumber, hasSpecial: _hasSpecial),
              ],
              const SizedBox(height: 12),

              // Confirmation
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscure2,
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (_) => _register(),
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textHint),
                  suffixIcon: IconButton(
                    icon: Icon(_obscure2 ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined, color: AppTheme.textHint),
                    onPressed: () => setState(() => _obscure2 = !_obscure2))),
                validator: (v) => v != _passCtrl.text
                    ? 'Les mots de passe ne correspondent pas' : null,
              ).animate().fadeIn(delay: 300.ms),

              const SizedBox(height: 16),

              // CGU avec liens cliquables
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Checkbox(
                  value: _accepted,
                  onChanged: (v) => setState(() => _accepted = v ?? false),
                  activeColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4))),
                const SizedBox(width: 4),
                Expanded(child: Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: RichText(text: TextSpan(
                    style: const TextStyle(color: AppTheme.textSecondary,
                        fontSize: 13, height: 1.5),
                    children: [
                      const TextSpan(text: 'J\'accepte les '),
                      TextSpan(
                        text: 'Conditions générales',
                        style: const TextStyle(color: AppTheme.primary,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.push(AppConstants.routeTerms)),
                      const TextSpan(text: ' et la '),
                      TextSpan(
                        text: 'Politique de confidentialité',
                        style: const TextStyle(color: AppTheme.primary,
                            decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => context.push(AppConstants.routePrivacy)),
                    ]))))
              ]).animate().fadeIn(delay: 350.ms),

              const SizedBox(height: 20),

              // Bouton inscription
              ElevatedButton(
                onPressed: _loading ? null : _register,
                child: _loading
                    ? const SizedBox(height: 22, width: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : const Text('Créer mon compte'),
              ).animate().fadeIn(delay: 400.ms),

              const SizedBox(height: 24),
              Row(children: [
                const Expanded(child: Divider(color: AppTheme.border)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('ou', style: Theme.of(context).textTheme.bodySmall)),
                const Expanded(child: Divider(color: AppTheme.border)),
              ]),
              const SizedBox(height: 16),

              // Google
              OutlinedButton(
                onPressed: _googleLoad ? null : _googleRegister,
                child: _googleLoad
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(
                            color: AppTheme.primary, strokeWidth: 2))
                    : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Container(
                          width: 24, height: 24,
                          decoration: BoxDecoration(color: Colors.white,
                              borderRadius: BorderRadius.circular(4)),
                          child: const Center(child: Text('G',
                              style: TextStyle(color: Color(0xFF4285F4),
                                  fontWeight: FontWeight.w900, fontSize: 16)))),
                        const SizedBox(width: 12),
                        const Text('Continuer avec Google',
                            style: TextStyle(color: Colors.white, fontSize: 15)),
                      ]),
              ).animate().fadeIn(delay: 500.ms),

              const SizedBox(height: 24),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('Déjà un compte ?',
                    style: Theme.of(context).textTheme.bodyMedium),
                TextButton(
                  onPressed: () => context.pop(),
                  child: const Text('Se connecter')),
              ]).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 20),
            ]),
          ),
        ),
      ),
    );
  }
}

class _StrengthBar extends StatelessWidget {
  final bool hasLength, hasUpper, hasNumber, hasSpecial;
  const _StrengthBar({required this.hasLength, required this.hasUpper,
      required this.hasNumber, required this.hasSpecial});

  int get _score => (hasLength?1:0)+(hasUpper?1:0)+(hasNumber?1:0)+(hasSpecial?1:0);
  String get _label => ['Très faible','Faible','Moyen','Fort','Excellent'][_score];
  Color get _color => [const Color(0xFFFF4757),const Color(0xFFFF9800),
      const Color(0xFFFFCA28),AppTheme.secondary,AppTheme.secondary][_score];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text('Force : ', style: const TextStyle(color: Colors.white54, fontSize: 12)),
        Text(_label, style: TextStyle(color: _color, fontSize: 12,
            fontWeight: FontWeight.w600)),
        const Spacer(),
        Row(children: List.generate(4, (i) => Container(
          width: 24, height: 4,
          margin: const EdgeInsets.only(left: 3),
          decoration: BoxDecoration(
            color: i < _score ? _color : const Color(0xFF2A2A2A),
            borderRadius: BorderRadius.circular(2))))),
      ]),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 4, children: [
        _C('8+ caractères', hasLength),
        _C('Majuscule', hasUpper),
        _C('Chiffre', hasNumber),
        _C('Caractère spécial', hasSpecial),
      ]),
    ]));
}

class _C extends StatelessWidget {
  final String label; final bool met;
  const _C(this.label, this.met);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(met ? Icons.check_circle : Icons.radio_button_unchecked,
        size: 13, color: met ? AppTheme.secondary : Colors.white38),
    const SizedBox(width: 3),
    Text(label, style: TextStyle(fontSize: 11,
        color: met ? AppTheme.secondary : Colors.white38)),
  ]);
}
