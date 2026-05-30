import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../auth/providers/auth_provider.dart';
import '../../rpg/providers/rpg_provider.dart';
import '../../rpg/models/rpg_model.dart';
import '../../rpg/data/levels_data.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/constants/app_constants.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final rpgProfile = ref.watch(rpgProfileProvider).valueOrNull;
    final levelInfo = ref.watch(playerLevelProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(s.navProfile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettings(context, ref, s),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [

            // ─ Header profil ──────────────────────
            _ProfileHeader(
              user: user,
              rpgProfile: rpgProfile,
              levelInfo: levelInfo,
            ),

            const SizedBox(height: 24),

            // ─ Stats générales ────────────────────
            if (rpgProfile != null)
              _StatsSection(profile: rpgProfile),

            const SizedBox(height: 24),

            // ─ Objectif actuel ────────────────────
            _GoalCard(),

            const SizedBox(height: 16),

            // ─ Gestion des blessures ──────────────
            _InjuriesCard(),

            const SizedBox(height: 16),

            // ─ Langue ────────────────────────────
            _LanguageCard(),

            const SizedBox(height: 16),

            // ─ Abonnement ────────────────────────
            _SubscriptionCard(),

            const SizedBox(height: 24),

            // ─ Déconnexion ───────────────────────
            OutlinedButton.icon(
              onPressed: () async {
                await ref.read(authNotifierProvider.notifier).logout();
                if (context.mounted) context.go(AppConstants.routeLogin);
              },
              icon: const Icon(Icons.logout, color: AppTheme.danger),
              label: Text(s.logout,
                  style: const TextStyle(color: AppTheme.danger)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.danger),
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showSettings(BuildContext context, WidgetRef ref, S s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => _SettingsSheet(),
    );
  }
}

// ── Header profil ─────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final dynamic user;
  final RpgProfile? rpgProfile;
  final dynamic levelInfo;

  const _ProfileHeader(
      {required this.user, this.rpgProfile, this.levelInfo});

  @override
  Widget build(BuildContext context) {
    final rank = rpgProfile != null
        ? LevelsData.fromXp(rpgProfile!.totalXp).rank
        : PlayerRank.initie;
    final rankColor = Color(rank.colorValue);
    final level = levelInfo?.level ?? 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [rankColor.withOpacity(0.2), Colors.transparent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rankColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: rankColor, width: 2),
                  color: AppTheme.surface,
                ),
                child: Center(
                  child: Text(rank.icon,
                      style: const TextStyle(fontSize: 32)),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: rankColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Lv $level',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.userMetadata?['full_name'] ?? 'Athlète',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  user?.email ?? '',
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  '${rank.icon} ${rank.labelFr()}',
                  style: TextStyle(
                      color: rankColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section stats ─────────────────────────────────────
class _StatsSection extends StatelessWidget {
  final RpgProfile profile;
  const _StatsSection({required this.profile});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('💪', '${profile.totalSessions}', 'Séances'),
      ('🔥', '${profile.currentStreak}j', 'Streak actuel'),
      ('🏆', '${profile.longestStreak}j', 'Record streak'),
      ('😴', '${profile.totalRestDays}', 'Jours repos'),
      ('✅', '${profile.questsCompleted}', 'Quêtes'),
      ('⚡', '${profile.totalXp}', 'XP total'),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.2,
      ),
      itemCount: stats.length,
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(stats[i].$1, style: const TextStyle(fontSize: 20)),
            Text(stats[i].$2,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16)),
            Text(stats[i].$3,
                style: const TextStyle(
                    color: Colors.white38, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

// ── Carte objectif ────────────────────────────────────
class _GoalCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ProfileCard(
      title: 'Mon objectif',
      icon: '🎯',
      onTap: () {},
      child: FutureBuilder(
        future: Supabase.instance.client
            .from('profiles')
            .select('goal, workout_location')
            .eq('id', Supabase.instance.client.auth.currentUser?.id ?? '')
            .single(),
        builder: (_, snap) {
          if (!snap.hasData) return const SizedBox.shrink();
          final goal = snap.data!['goal'] ?? 'renforcement';
          final loc = snap.data!['workout_location'] ?? 'both';
          final goalMap = {
            'renforcement': '💪 Renforcement musculaire',
            'perte_gras': '🔥 Perte de graisse',
            'prise_muscle': '🏋️ Prise de masse',
          };
          final locMap = {
            'gym': '🏋️ Salle de sport',
            'home': '🏠 Maison',
            'both': '🌍 Gym + Maison',
          };
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(goalMap[goal] ?? goal,
                  style: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.w600)),
              Text(locMap[loc] ?? loc,
                  style: const TextStyle(
                      color: Colors.white54, fontSize: 13)),
            ],
          );
        },
      ),
    );
  }
}

// ── Carte blessures ───────────────────────────────────
class _InjuriesCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _ProfileCard(
      title: 'Mes douleurs / blessures',
      icon: '🩹',
      onTap: () {},
      child: FutureBuilder(
        future: Supabase.instance.client
            .from('user_injuries')
            .select('injury_zone')
            .eq('user_id', Supabase.instance.client.auth.currentUser?.id ?? '')
            .eq('is_active', true),
        builder: (_, snap) {
          if (!snap.hasData) return const SizedBox.shrink();
          final injuries = snap.data as List;
          if (injuries.isEmpty) {
            return const Text('Aucune douleur enregistrée',
                style: TextStyle(color: Colors.white54, fontSize: 13));
          }
          return Wrap(
            spacing: 6,
            runSpacing: 6,
            children: injuries.map((i) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
              ),
              child: Text(
                ref.read(sProvider).injuryZone(i['injury_zone']),
                style: const TextStyle(color: AppTheme.danger, fontSize: 11),
              ),
            )).toList(),
          );
        },
      ),
    );
  }
}

// ── Carte langue ──────────────────────────────────────
class _LanguageCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return _ProfileCard(
      title: 'Langue / Language',
      icon: '🌍',
      onTap: () {},
      child: Row(
        children: [
          _LangBtn('🇫🇷 Français', 'fr', locale.languageCode == 'fr', ref),
          const SizedBox(width: 10),
          _LangBtn('🇬🇧 English', 'en', locale.languageCode == 'en', ref),
        ],
      ),
    );
  }
}

class _LangBtn extends ConsumerWidget {
  final String label, code;
  final bool selected;
  const _LangBtn(this.label, this.code, this.selected, WidgetRef ref)
      : super();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () =>
          ref.read(localeProvider.notifier).setLocale(Locale(code)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected
              ? AppTheme.primary.withOpacity(0.2)
              : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
          ),
        ),
        child: Text(label,
            style: TextStyle(
              color: selected ? AppTheme.primary : Colors.white54,
              fontSize: 13,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w400,
            )),
      ),
    );
  }
}

// ── Carte abonnement ──────────────────────────────────
class _SubscriptionCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: Supabase.instance.client
          .from('subscriptions')
          .select('plan, status, current_period_end')
          .eq('user_id',
              Supabase.instance.client.auth.currentUser?.id ?? '')
          .single(),
      builder: (_, snap) {
        final plan = snap.data?['plan'] ?? 'free';
        final isPremium = plan != 'free';

        return _ProfileCard(
          title: 'Abonnement',
          icon: isPremium ? '👑' : '🆓',
          onTap: isPremium ? null : () => context.push(AppConstants.routePaywall),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isPremium ? 'Premium actif' : 'Gratuit',
                    style: TextStyle(
                      color: isPremium
                          ? const Color(0xFFFFD700)
                          : Colors.white54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (!isPremium)
                    const Text(
                      'Passe à Premium pour tout débloquer',
                      style: TextStyle(
                          color: Colors.white38, fontSize: 12),
                    ),
                ],
              ),
              const Spacer(),
              if (!isPremium)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF9800)],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('Upgrade',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      )),
                ),
            ],
          ),
        );
      },
    );
  }
}

// ── Widget carte générique ────────────────────────────
class _ProfileCard extends StatelessWidget {
  final String title, icon;
  final Widget child;
  final VoidCallback? onTap;

  const _ProfileCard({
    required this.title,
    required this.icon,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(icon, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Text(title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    )),
                if (onTap != null) ...[
                  const Spacer(),
                  const Icon(Icons.chevron_right,
                      color: Colors.white24, size: 18),
                ],
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

// ── Sheet paramètres ──────────────────────────────────
class _SettingsSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Paramètres',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          _SettingItem(Icons.notifications_outlined, 'Notifications', () {}),
          _SettingItem(Icons.security_outlined, 'Sécurité & confidentialité', () {}),
          _SettingItem(Icons.help_outline, 'Aide & Support', () {}),
          _SettingItem(Icons.info_outline, 'À propos de FitPro', () {}),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}

class _SettingItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingItem(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white54),
      title: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 14)),
      trailing: const Icon(Icons.chevron_right, color: Colors.white24),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
