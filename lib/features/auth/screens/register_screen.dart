import 'package:flutter/material.dart';
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
  final _formKey    = GlobalKey<FormState>();
  final _nameCtrl   = TextEditingController();
  final _emailCtrl  = TextEditingController();
  final _passCtrl   = TextEditingController();
  final _confirmCtrl= TextEditingController();

  bool _obscurePass     = true;
  bool _obscureConfirm  = true;
  bool _isLoading       = false;
  bool _acceptedTerms   = false;

  // Indicateurs force du mot de passe
  bool get _hasLength   => _passCtrl.text.length >= 8;
  bool get _hasUpper    => RegExp(r'[A-Z]').hasMatch(_passCtrl.text);
  bool get _hasNumber   => RegExp(r'[0-9]').hasMatch(_passCtrl.text);
  bool get _hasSpecial  => RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(_passCtrl.text);

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose();
    _passCtrl.dispose(); _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_acceptedTerms) {
      _showError('Accepte les conditions d\'utilisation');
      return;
    }
    setState(() => _isLoading = true);

    final result = await ref.read(authNotifierProvider.notifier).register(
      email: _emailCtrl.text,
      password: _passCtrl.text,
      fullName: _nameCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.isSuccess) {
      context.go(AppConstants.routeOnboarding);
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
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(s.registerTitle),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ─ Intro ───────────────────────────
                Text(
                  'Crée ton compte\ngratuit 🚀',
                  style: Theme.of(context).textTheme.displayMedium,
                ).animate().fadeIn(),

                const SizedBox(height: 6),
                Text(
                  'Démarre ton aventure fitness dès aujourd\'hui',
                  style: Theme.of(context).textTheme.bodyMedium,
                ).animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 32),

                // ─ Champs ──────────────────────────
                TextFormField(
                  controller: _nameCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: s.nameLabel,
                    prefixIcon: const Icon(Icons.person_outline,
                        color: AppTheme.textHint),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'Prénom requis';
                    }
                    if (v.trim().length < 2) return 'Trop court';
                    return null;
                  },
                ).animate().fadeIn(delay: 150.ms).slideX(begin: -0.1),

                const SizedBox(height: 14),

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
                    if (v == null || v.isEmpty) return 'Email requis';
                    if (!SecurityService.isValidEmail(v)) {
                      return 'Email invalide';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 200.ms).slideX(begin: -0.1),

                const SizedBox(height: 14),

                // Mot de passe + indicateurs force
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  textInputAction: TextInputAction.next,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (_) => setState(() {}),
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
                    if (v == null || v.isEmpty) return 'Mot de passe requis';
                    if (!SecurityService.isValidPassword(v)) {
                      return 'Mot de passe trop faible';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 250.ms).slideX(begin: -0.1),

                // Indicateurs force
                if (_passCtrl.text.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  _PasswordStrengthIndicator(
                    hasLength: _hasLength,
                    hasUpper: _hasUpper,
                    hasNumber: _hasNumber,
                    hasSpecial: _hasSpecial,
                  ).animate().fadeIn(),
                ],

                const SizedBox(height: 14),

                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: s.confirmPassword,
                    prefixIcon: const Icon(Icons.lock_outline,
                        color: AppTheme.textHint),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: AppTheme.textHint,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v != _passCtrl.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms).slideX(begin: -0.1),

                const SizedBox(height: 20),

                // ─ CGU ─────────────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _acceptedTerms,
                      onChanged: (v) =>
                          setState(() => _acceptedTerms = v ?? false),
                      activeColor: AppTheme.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _acceptedTerms = !_acceptedTerms),
                        child: const Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'J\'accepte les conditions d\'utilisation et la politique de confidentialité',
                            style: TextStyle(
                                color: AppTheme.textSecondary, fontSize: 13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 350.ms),

                const SizedBox(height: 24),

                // ─ Bouton inscription ──────────────
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Text(s.registerBtn),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                const SizedBox(height: 20),

                // ─ Déjà un compte ──────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(s.hasAccount,
                        style: Theme.of(context).textTheme.bodyMedium),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(s.loginBtn),
                    ),
                  ],
                ).animate().fadeIn(delay: 500.ms),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Indicateur force mot de passe ────────────────────
class _PasswordStrengthIndicator extends StatelessWidget {
  final bool hasLength, hasUpper, hasNumber, hasSpecial;

  const _PasswordStrengthIndicator({
    required this.hasLength,
    required this.hasUpper,
    required this.hasNumber,
    required this.hasSpecial,
  });

  int get _score =>
      (hasLength ? 1 : 0) +
      (hasUpper ? 1 : 0) +
      (hasNumber ? 1 : 0) +
      (hasSpecial ? 1 : 0);

  String get _label => ['Faible', 'Moyen', 'Bon', 'Fort', 'Excellent'][_score];
  Color get _color => [
    AppTheme.danger,
    const Color(0xFFFF9800),
    const Color(0xFFFFCA28),
    AppTheme.secondary,
    AppTheme.secondary,
  ][_score];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Force : ',
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
              Text(_label,
                  style: TextStyle(
                      color: _color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Row(
                children: List.generate(
                  4,
                  (i) => Container(
                    width: 24,
                    height: 4,
                    margin: const EdgeInsets.only(left: 3),
                    decoration: BoxDecoration(
                      color: i < _score ? _color : const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              _Criteria('8+ caractères', hasLength),
              _Criteria('Majuscule', hasUpper),
              _Criteria('Chiffre', hasNumber),
              _Criteria('Caractère spécial', hasSpecial),
            ],
          ),
        ],
      ),
    );
  }
}

class _Criteria extends StatelessWidget {
  final String label;
  final bool met;
  const _Criteria(this.label, this.met);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle : Icons.radio_button_unchecked,
          size: 14,
          color: met ? AppTheme.secondary : Colors.white38,
        ),
        const SizedBox(width: 4),
        Text(label,
            style: TextStyle(
              fontSize: 11,
              color: met ? AppTheme.secondary : Colors.white38,
            )),
      ],
    );
  }
}
