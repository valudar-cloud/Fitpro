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
    final user = supabase.auth.currentUser;
    final rpg = ref.watch(rpgProfileProvider).valueOrNull;
    final level = ref.watch(playerLevelProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(s.navProfile),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => context.push(AppConstants.routeSettings)),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          // ─ Header ──────────────────────────────
          _ProfileHeader(user: user, rpgProfile: rpg, levelInfo: level),
          const SizedBox(height: 20),

          // ─ Stats ───────────────────────────────
          if (rpg != null) _StatsGrid(profile: rpg),
          const SizedBox(height: 20),

          // ─ Objectif ────────────────────────────
          _GoalCard(),
          const SizedBox(height: 12),

          // ─ Blessures / Douleurs ────────────────
          _InjuriesCard(),
          const SizedBox(height: 12),

          // ─ Langue ─────────────────────────────
          _LanguageCard(),
          const SizedBox(height: 12),

          // ─ Abonnement ─────────────────────────
          _SubscriptionCard(),
          const SizedBox(height: 24),

          // ─ Légal ──────────────────────────────
          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => context.push(AppConstants.routeTerms),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.border),
                minimumSize: const Size(0, 44)),
              child: const Text('CGU', style: TextStyle(fontSize: 12)))),
            const SizedBox(width: 10),
            Expanded(child: OutlinedButton(
              onPressed: () => context.push(AppConstants.routePrivacy),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.border),
                minimumSize: const Size(0, 44)),
              child: const Text('Confidentialité', style: TextStyle(fontSize: 12)))),
          ]),
          const SizedBox(height: 12),

          // ─ Déconnexion ─────────────────────────
          OutlinedButton.icon(
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) context.go(AppConstants.routeLogin);
            },
            icon: const Icon(Icons.logout, color: AppTheme.danger),
            label: const Text('Se déconnecter',
                style: TextStyle(color: AppTheme.danger)),
            style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppTheme.danger))),

          const SizedBox(height: 40),
        ]),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final dynamic user, rpgProfile, levelInfo;
  const _ProfileHeader({required this.user, this.rpgProfile, this.levelInfo});

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
            colors: [rankColor.withOpacity(0.2), Colors.transparent]),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: rankColor.withOpacity(0.3))),
      child: Row(children: [
        Stack(children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: rankColor, width: 2),
                color: AppTheme.surface),
            child: Center(child: Text(rank.icon,
                style: const TextStyle(fontSize: 32)))),
          Positioned(bottom: 0, right: 0, child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: rankColor,
                borderRadius: BorderRadius.circular(8)),
            child: Text('Lv $level', style: const TextStyle(
                color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)))),
        ]),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(user?.userMetadata?['full_name'] ?? 'Athlète',
              style: const TextStyle(color: Colors.white,
                  fontSize: 20, fontWeight: FontWeight.w700)),
          Text(user?.email ?? '',
              style: const TextStyle(color: Colors.white54, fontSize: 12)),
          const SizedBox(height: 4),
          Text('${rank.icon} ${rank.labelFr()}',
              style: TextStyle(color: rankColor, fontWeight: FontWeight.w600)),
        ])),
      ]),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final RpgProfile profile;
  const _StatsGrid({required this.profile});

  @override
  Widget build(BuildContext context) {
    final stats = [
      ('💪', '${profile.totalSessions}', 'Séances'),
      ('🔥', '${profile.currentStreak}j', 'Streak'),
      ('🏆', '${profile.longestStreak}j', 'Record'),
      ('😴', '${profile.totalRestDays}', 'Repos'),
      ('✅', '${profile.questsCompleted}', 'Quêtes'),
      ('⚡', '${profile.totalXp}', 'XP total'),
    ];
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, mainAxisSpacing: 10, crossAxisSpacing: 10,
          childAspectRatio: 1.2),
      itemCount: stats.length,
      itemBuilder: (_, i) => Container(
        decoration: BoxDecoration(color: AppTheme.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(stats[i].$1, style: const TextStyle(fontSize: 20)),
          Text(stats[i].$2, style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16)),
          Text(stats[i].$3, style: const TextStyle(
              color: Colors.white38, fontSize: 10)),
        ])));
  }
}

class _GoalCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Card(
      title: 'Mon objectif', icon: '🎯',
      onTap: () => _editGoal(context, ref),
      child: FutureBuilder(
        future: supabase.from('profiles')
            .select('goal, workout_location')
            .eq('id', supabase.auth.currentUser?.id ?? '').single(),
        builder: (_, snap) {
          if (!snap.hasData) return const _LoadingRow();
          final goal = snap.data!['goal'] ?? 'renforcement';
          final loc  = snap.data!['workout_location'] ?? 'both';
          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(_goalLabel(goal), style: const TextStyle(
                color: AppTheme.primary, fontWeight: FontWeight.w600)),
            Text(_locLabel(loc), style: const TextStyle(
                color: Colors.white54, fontSize: 13)),
          ]);
        }),
    );
  }

  String _goalLabel(String g) => {
    'renforcement': '💪 Renforcement musculaire',
    'perte_gras': '🔥 Perte de graisse',
    'prise_muscle': '🏋️ Prise de masse',
  }[g] ?? g;

  String _locLabel(String l) => {
    'gym': '🏋️ Salle de sport',
    'home': '🏠 Maison',
    'both': '🌍 Gym + Maison',
  }[l] ?? l;

  void _editGoal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _EditGoalSheet());
  }
}

class _EditGoalSheet extends ConsumerStatefulWidget {
  const _EditGoalSheet();
  @override
  ConsumerState<_EditGoalSheet> createState() => _EditGoalSheetState();
}

class _EditGoalSheetState extends ConsumerState<_EditGoalSheet> {
  String? _goal;
  String _loc = 'both';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    final data = await supabase.from('profiles')
        .select('goal, workout_location').eq('id', uid).single();
    setState(() {
      _goal = data['goal'];
      _loc  = data['workout_location'] ?? 'both';
    });
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(24),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      const Text('Modifier mon objectif', style: TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      const SizedBox(height: 20),
      for (final entry in {
        'renforcement': '💪 Renforcement musculaire',
        'perte_gras': '🔥 Perte de graisse',
        'prise_muscle': '🏋️ Prise de masse',
      }.entries)
        _ChoiceBtn(entry.value, _goal == entry.key,
            () => setState(() => _goal = entry.key)),
      const SizedBox(height: 16),
      const Text('Lieu d\'entraînement', style: TextStyle(
          color: Colors.white54, fontSize: 13)),
      const SizedBox(height: 8),
      Row(children: [
        for (final entry in {
          'gym': '🏋️ Gym', 'home': '🏠 Maison', 'both': '🌍 Les deux'
        }.entries)
          Expanded(child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: _ChoiceBtn(entry.value, _loc == entry.key,
                () => setState(() => _loc = entry.key)),
          )),
      ]),
      const SizedBox(height: 20),
      ElevatedButton(
        onPressed: () async {
          final uid = supabase.auth.currentUser?.id;
          if (uid == null || _goal == null) return;
          await supabase.from('profiles').update({
            'goal': _goal, 'workout_location': _loc}).eq('id', uid);
          if (context.mounted) Navigator.pop(context);
        },
        child: const Text('Enregistrer')),
    ]),
  );
}

class _ChoiceBtn extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ChoiceBtn(this.label, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary.withOpacity(0.2) : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: selected ? AppTheme.primary : AppTheme.border,
            width: selected ? 1.5 : 1)),
      child: Text(label, textAlign: TextAlign.center, style: TextStyle(
          color: selected ? AppTheme.primary : Colors.white70,
          fontSize: 13, fontWeight: FontWeight.w500))));
}

class _InjuriesCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _Card(
      title: 'Mes douleurs / blessures', icon: '🩹',
      onTap: () => _manageInjuries(context, ref),
      child: FutureBuilder(
        future: supabase.from('user_injuries')
            .select('injury_zone')
            .eq('user_id', supabase.auth.currentUser?.id ?? '')
            .eq('is_active', true),
        builder: (_, snap) {
          if (!snap.hasData) return const _LoadingRow();
          final list = snap.data as List;
          if (list.isEmpty) return const Text(
              'Aucune douleur enregistrée',
              style: TextStyle(color: Colors.white54, fontSize: 13));
          return Wrap(spacing: 6, runSpacing: 6,
            children: list.map((i) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.danger.withOpacity(0.3))),
              child: Text(ref.read(sProvider).injuryZone(i['injury_zone']),
                  style: const TextStyle(color: AppTheme.danger, fontSize: 11)),
            )).toList());
        }),
    );
  }

  void _manageInjuries(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => const _InjuriesSheet());
  }
}

class _InjuriesSheet extends ConsumerStatefulWidget {
  const _InjuriesSheet();
  @override
  ConsumerState<_InjuriesSheet> createState() => _InjuriesSheetState();
}

class _InjuriesSheetState extends ConsumerState<_InjuriesSheet> {
  Set<String> _active = {};
  bool _loading = true;

  static const _zones = [
    ('neck', 'Nuque / Cou'), ('shoulder_left', 'Épaule gauche'),
    ('shoulder_right', 'Épaule droite'), ('elbow_left', 'Coude gauche'),
    ('elbow_right', 'Coude droit'), ('wrist_left', 'Poignet gauche'),
    ('wrist_right', 'Poignet droit'), ('back_upper', 'Dos haut'),
    ('back_lower', 'Bas du dos'), ('hip', 'Hanche'),
    ('knee_left', 'Genou gauche'), ('knee_right', 'Genou droit'),
    ('ankle_left', 'Cheville gauche'), ('ankle_right', 'Cheville droite'),
  ];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    final data = await supabase.from('user_injuries')
        .select('injury_zone').eq('user_id', uid).eq('is_active', true);
    setState(() {
      _active = {for (final d in data) d['injury_zone'] as String};
      _loading = false;
    });
  }

  Future<void> _save() async {
    final uid = supabase.auth.currentUser?.id;
    if (uid == null) return;
    await supabase.from('user_injuries')
        .update({'is_active': false}).eq('user_id', uid);
    if (_active.isNotEmpty) {
      await supabase.from('user_injuries').insert(
        _active.map((z) => {'user_id': uid, 'injury_zone': z,
            'severity': 'mild', 'is_active': true}).toList());
    }
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.85,
    maxChildSize: 0.95,
    minChildSize: 0.5,
    expand: false,
    builder: (_, ctrl) => Column(children: [
      Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40, height: 4,
        decoration: BoxDecoration(color: Colors.white24,
            borderRadius: BorderRadius.circular(2))),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: Text('Mes douleurs & blessures', style: TextStyle(
            color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
      const Padding(
        padding: EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Text('Sélectionne les zones douloureuses. Les exercices déconseillés seront signalés.',
            style: TextStyle(color: Colors.white54, fontSize: 13))),
      Expanded(child: _loading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primary))
          : GridView.builder(
              controller: ctrl,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, mainAxisSpacing: 8,
                  crossAxisSpacing: 8, childAspectRatio: 3),
              itemCount: _zones.length,
              itemBuilder: (_, i) {
                final (id, label) = _zones[i];
                final active = _active.contains(id);
                return GestureDetector(
                  onTap: () => setState(() {
                    active ? _active.remove(id) : _active.add(id);
                  }),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: active ? AppTheme.danger.withOpacity(0.15) : AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: active ? AppTheme.danger : AppTheme.border,
                          width: active ? 1.5 : 1)),
                    child: Row(children: [
                      const SizedBox(width: 10),
                      Text(active ? '🔴' : '⚪', style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 8),
                      Expanded(child: Text(label, style: TextStyle(
                          color: active ? AppTheme.danger : Colors.white70,
                          fontSize: 12, fontWeight: FontWeight.w500))),
                    ])));
              })),
      Padding(
        padding: const EdgeInsets.all(20),
        child: ElevatedButton(
          onPressed: _save,
          child: Text(_active.isEmpty
              ? 'Aucune douleur — enregistrer'
              : 'Enregistrer (${_active.length} zone${_active.length > 1 ? "s" : ""})'))),
    ]),
  );
}

class _LanguageCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    return _Card(
      title: 'Langue / Language', icon: '🌍',
      child: Row(children: [
        _LangBtn('🇫🇷 Français', 'fr', locale.languageCode == 'fr', ref),
        const SizedBox(width: 10),
        _LangBtn('🇬🇧 English', 'en', locale.languageCode == 'en', ref),
      ]));
  }
}

class _LangBtn extends ConsumerWidget {
  final String label, code;
  final bool selected;
  const _LangBtn(this.label, this.code, this.selected, WidgetRef ref) : super();

  @override
  Widget build(BuildContext context, WidgetRef ref) => GestureDetector(
    onTap: () => ref.read(localeProvider.notifier).setLocale(Locale(code)),
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? AppTheme.primary.withOpacity(0.2) : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: selected ? AppTheme.primary : AppTheme.border)),
      child: Text(label, style: TextStyle(
          color: selected ? AppTheme.primary : Colors.white54,
          fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.w400))));
}

class _SubscriptionCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: supabase.from('subscriptions')
          .select('plan, status').eq('user_id',
          supabase.auth.currentUser?.id ?? '').single(),
      builder: (_, snap) {
        final plan = snap.data?['plan'] ?? 'free';
        final isPremium = plan != 'free';
        return _Card(
          title: 'Abonnement', icon: isPremium ? '👑' : '🆓',
          onTap: isPremium ? null : () => context.push(AppConstants.routePaywall),
          child: Row(children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isPremium ? '✅ Premium actif' : 'Gratuit',
                  style: TextStyle(
                      color: isPremium ? const Color(0xFFFFD700) : Colors.white54,
                      fontWeight: FontWeight.w600)),
              if (!isPremium) const Text('Passe à Premium pour tout débloquer',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
            ]),
            const Spacer(),
            if (!isPremium) GestureDetector(
              onTap: () => context.push(AppConstants.routePaywall),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF9800)]),
                  borderRadius: BorderRadius.circular(10)),
                child: const Text('Upgrade', style: TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w700, fontSize: 12)))),
          ]));
      });
  }
}

// ── Widgets utilitaires ──────────────────────────────
class _Card extends StatelessWidget {
  final String title, icon;
  final Widget child;
  final VoidCallback? onTap;
  const _Card({required this.title, required this.icon,
      required this.child, this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppTheme.surface, borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(icon, style: const TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Text(title, style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14)),
          if (onTap != null) ...[
            const Spacer(),
            const Icon(Icons.chevron_right, color: Colors.white24, size: 18)],
        ]),
        const SizedBox(height: 12),
        child,
      ])));
}

class _LoadingRow extends StatelessWidget {
  const _LoadingRow();
  @override
  Widget build(BuildContext context) => const SizedBox(
      height: 20,
      child: Center(child: CircularProgressIndicator(
          strokeWidth: 2, color: AppTheme.primary)));
}
