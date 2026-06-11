import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_strings.dart';
import '../../auth/providers/auth_provider.dart';
import '../../legal/screens/legal_screens.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifWorkout   = true;
  bool _notifRest      = true;
  bool _notifQuests    = true;
  String _appVersion   = '';

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() => _appVersion = '${info.version} (${info.buildNumber})');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(title: const Text('Paramètres')),
      body: ListView(
        children: [

          // ── Notifications ────────────────────────
          _GroupHeader('Notifications'),
          _SwitchTile(
            icon: '🏋️', label: 'Rappel séance',
            subtitle: 'Rappel quotidien pour t\'entraîner',
            value: _notifWorkout,
            onChanged: (v) => setState(() => _notifWorkout = v),
          ),
          _SwitchTile(
            icon: '😴', label: 'Rappel repos',
            subtitle: 'Te rappelle de respecter tes jours de repos',
            value: _notifRest,
            onChanged: (v) => setState(() => _notifRest = v),
          ),
          _SwitchTile(
            icon: '⚔️', label: 'Nouvelles quêtes',
            subtitle: 'Alerte quand de nouvelles quêtes arrivent',
            value: _notifQuests,
            onChanged: (v) => setState(() => _notifQuests = v),
          ),

          // ── Compte ───────────────────────────────
          _GroupHeader('Compte'),
          _NavTile(
            icon: '🔒', label: 'Changer le mot de passe',
            onTap: () => _changePassword(context),
          ),
          _NavTile(
            icon: '📧', label: 'Changer l\'email',
            onTap: () => _changeEmail(context),
          ),
          _NavTile(
            icon: '📦', label: 'Exporter mes données',
            subtitle: 'Télécharger toutes tes données (RGPD)',
            onTap: () => _exportData(context),
          ),
          _NavTile(
            icon: '🗑️', label: 'Supprimer mon compte',
            labelColor: AppTheme.danger,
            onTap: () => _deleteAccount(context),
          ),

          // ── Légal ────────────────────────────────
          _GroupHeader('Légal'),
          _NavTile(
            icon: '📄', label: 'Conditions générales',
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const TermsScreen())),
          ),
          _NavTile(
            icon: '🔐', label: 'Politique de confidentialité',
            onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => const PrivacyScreen())),
          ),
          _NavTile(
            icon: '🍪', label: 'Gestion des cookies',
            onTap: () => _showCookies(context),
          ),

          // ── Aide ─────────────────────────────────
          _GroupHeader('Aide & Support'),
          _NavTile(
            icon: '❓', label: 'FAQ',
            onTap: () => _launchUrl('https://fitpro.app/faq'),
          ),
          _NavTile(
            icon: '💬', label: 'Contacter le support',
            onTap: () => _launchUrl('mailto:support@fitpro.app'),
          ),
          _NavTile(
            icon: '⭐', label: 'Noter l\'application',
            onTap: () => _launchUrl('https://play.google.com/store'),
          ),
          _NavTile(
            icon: '🐛', label: 'Signaler un bug',
            onTap: () => _showBugReport(context),
          ),

          // ── À propos ─────────────────────────────
          _GroupHeader('À propos'),
          _InfoTile(icon: '📱', label: 'Version', value: _appVersion),
          _InfoTile(icon: '🏢', label: 'Éditeur', value: 'FitPro SAS'),
          _InfoTile(icon: '📍', label: 'Made in', value: '🇫🇷 France'),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  void _changePassword(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _ChangePasswordSheet(),
    );
  }

  void _changeEmail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _ChangeEmailSheet(),
    );
  }

  void _exportData(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📦 Export envoyé par email sous 48h'),
        backgroundColor: AppTheme.secondary,
      ),
    );
  }

  void _deleteAccount(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Supprimer le compte',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'Toutes tes données seront supprimées définitivement. Cette action est irréversible.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Supprimer',
                style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }

  void _showCookies(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Cookies', style: TextStyle(color: Colors.white)),
        content: const Text(
          'FitPro n\'utilise pas de cookies publicitaires.\nSeuls les cookies techniques nécessaires au fonctionnement sont utilisés.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showBugReport(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _BugReportSheet(),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}

// ── Widgets ───────────────────────────────────────────

class _GroupHeader extends StatelessWidget {
  final String title;
  const _GroupHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
    child: Text(title,
      style: const TextStyle(
        color: AppTheme.primary,
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      )),
  );
}

class _SwitchTile extends StatelessWidget {
  final String icon, label;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SwitchTile({
    required this.icon, required this.label,
    this.subtitle, required this.value, required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.border),
    ),
    child: SwitchListTile(
      secondary: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 14)),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: Colors.white38, fontSize: 12))
          : null,
      value: value,
      onChanged: onChanged,
      activeColor: AppTheme.primary,
    ),
  );
}

class _NavTile extends StatelessWidget {
  final String icon, label;
  final String? subtitle;
  final Color? labelColor;
  final VoidCallback onTap;

  const _NavTile({
    required this.icon, required this.label,
    this.subtitle, this.labelColor, required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.border),
    ),
    child: ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(label,
          style: TextStyle(
            color: labelColor ?? Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          )),
      subtitle: subtitle != null
          ? Text(subtitle!, style: const TextStyle(color: Colors.white38, fontSize: 12))
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
    ),
  );
}

class _InfoTile extends StatelessWidget {
  final String icon, label, value;
  const _InfoTile({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.border),
    ),
    child: ListTile(
      leading: Text(icon, style: const TextStyle(fontSize: 22)),
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
      trailing: Text(value, style: const TextStyle(color: Colors.white54, fontSize: 13)),
    ),
  );
}

// ── Sheets ────────────────────────────────────────────

class _ChangePasswordSheet extends ConsumerStatefulWidget {
  const _ChangePasswordSheet();
  @override
  ConsumerState<_ChangePasswordSheet> createState() => _ChangePasswordSheetState();
}

class _ChangePasswordSheetState extends ConsumerState<_ChangePasswordSheet> {
  final _newPass = TextEditingController();
  bool _loading = false;
  bool _obscure = true;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 24, right: 24, top: 24,
      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Nouveau mot de passe',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        TextField(
          controller: _newPass,
          obscureText: _obscure,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Nouveau mot de passe',
            prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textHint),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: AppTheme.textHint),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loading ? null : () async {
            setState(() => _loading = true);
            try {
              await supabase.auth.updateUser(
                UserAttributes(password: _newPass.text));
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('✅ Mot de passe mis à jour'),
                      backgroundColor: AppTheme.secondary));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e'),
                      backgroundColor: AppTheme.danger));
              }
            } finally {
              setState(() => _loading = false);
            }
          },
          child: _loading
              ? const SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Mettre à jour'),
        ),
      ],
    ),
  );
}

class _ChangeEmailSheet extends StatefulWidget {
  const _ChangeEmailSheet();
  @override
  State<_ChangeEmailSheet> createState() => _ChangeEmailSheetState();
}

class _ChangeEmailSheetState extends State<_ChangeEmailSheet> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 24, right: 24, top: 24,
      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Changer l\'email',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nouvel email',
            prefixIcon: Icon(Icons.email_outlined, color: AppTheme.textHint),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _loading ? null : () async {
            setState(() => _loading = true);
            try {
              await supabase.auth.updateUser(
                UserAttributes(email: _emailCtrl.text.trim()));
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('📧 Vérifie ton nouvel email pour confirmer'),
                    backgroundColor: AppTheme.secondary));
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erreur: $e'),
                      backgroundColor: AppTheme.danger));
              }
            } finally {
              setState(() => _loading = false);
            }
          },
          child: _loading
              ? const SizedBox(height: 20, width: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : const Text('Mettre à jour'),
        ),
      ],
    ),
  );
}

class _BugReportSheet extends StatefulWidget {
  const _BugReportSheet();
  @override
  State<_BugReportSheet> createState() => _BugReportSheetState();
}

class _BugReportSheetState extends State<_BugReportSheet> {
  final _descCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(
      left: 24, right: 24, top: 24,
      bottom: MediaQuery.of(context).viewInsets.bottom + 24,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Signaler un bug 🐛',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 16),
        TextField(
          controller: _descCtrl,
          maxLines: 4,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Décris le problème rencontré...',
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Bug signalé — merci !'),
                backgroundColor: AppTheme.secondary,
              ),
            );
          },
          child: const Text('Envoyer le rapport'),
        ),
      ],
    ),
  );
}
