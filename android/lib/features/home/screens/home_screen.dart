import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_strings.dart';
import '../../rpg/providers/rpg_provider.dart';
import '../../rpg/widgets/rpg_widgets.dart';
import '../../exercises/data/exercises_data.dart';
import '../../steps/widgets/step_counter_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s          = ref.watch(sProvider);
    final rpgProfile = ref.watch(rpgProfileProvider).valueOrNull;
    final levelInfo  = ref.watch(playerLevelProvider);
    final user       = Supabase.instance.client.auth.currentUser;
    final firstName  = user?.userMetadata?['full_name']
            ?.toString().split(' ').first ?? 'Champion';

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            expandedHeight: 0,
            title: Row(children: [
              const Text('🏋️', style: TextStyle(fontSize: 22)),
              const SizedBox(width: 8),
              const Text('FitPro', style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.restaurant_outlined, color: Colors.white70),
                tooltip: 'Nutrition',
                onPressed: () => context.push(AppConstants.routeNutrition)),
              IconButton(
                icon: const Icon(Icons.person_outline, color: Colors.white70),
                onPressed: () => context.push(AppConstants.routeProfile)),
            ]),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),

                // Salutation
                _Greeting(firstName: firstName,
                    streak: rpgProfile?.currentStreak ?? 0)
                    .animate().fadeIn().slideY(begin: -0.1),
                const SizedBox(height: 20),

                // XP Bar
                if (levelInfo != null)
                  XpBarWidget(levelInfo: levelInfo)
                      .animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 14),

                // Compteur de pas
                const StepCounterWidget()
                    .animate().fadeIn(delay: 150.ms),
                const SizedBox(height: 14),

                // Quêtes du jour
                _DailyQuestCard()
                    .animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 20),

                // Accès rapide — 6 modules
                _QuickActions()
                    .animate().fadeIn(delay: 250.ms),
                const SizedBox(height: 20),

                // Stats RPG
                if (rpgProfile != null)
                  StatsRpgWidget(profile: rpgProfile)
                      .animate().fadeIn(delay: 300.ms),
                const SizedBox(height: 20),

                // Exercices populaires
                _RecommendedExercises()
                    .animate().fadeIn(delay: 350.ms),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Salutation ────────────────────────────────────────
class _Greeting extends StatelessWidget {
  final String firstName;
  final int streak;
  const _Greeting({required this.firstName, required this.streak});

  String get _greet {
    final h = DateTime.now().hour;
    if (h < 12) return 'Bonjour';
    if (h < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$_greet, $firstName 👊', style: const TextStyle(
          color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
      const SizedBox(height: 4),
      Text(streak > 0
          ? '🔥 $streak jours de streak — continue !'
          : 'Prêt pour une nouvelle séance ?',
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
    ]);
}

// ── Quêtes du jour ─────────────────────────────────────
class _DailyQuestCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = ref.watch(activeQuestsProvider);
    return q.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (quests) {
        final daily = quests.where((q) => q.type.name == 'daily').toList();
        final done  = daily.where((q) =>
            q.status.name == 'completed' ||
            q.status.name == 'claimed').length;

        return GestureDetector(
          onTap: () => context.push(AppConstants.routeRpg),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                AppTheme.primary.withOpacity(0.15),
                const Color(0xFFFF9A3C).withOpacity(0.08)]),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.primary.withOpacity(0.3))),
            child: Row(children: [
              const Text('⚔️', style: TextStyle(fontSize: 30)),
              const SizedBox(width: 14),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Quêtes du jour', style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600,
                      fontSize: 15)),
                  Text('$done / ${daily.length} complétées',
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                  const SizedBox(height: 8),
                  ClipRRect(borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: daily.isEmpty ? 0 : done / daily.length,
                      minHeight: 6,
                      backgroundColor: const Color(0xFF2A2A2A),
                      valueColor: const AlwaysStoppedAnimation(AppTheme.primary))),
                ])),
              const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
            ])));
      });
  }
}

// ── Accès rapide — 6 modules ──────────────────────────
class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final actions = [
      _A('💪', 'Exercices',    AppConstants.routeExercises,   const Color(0xFF4ECDC4)),
      _A('📅', 'Programme',    AppConstants.routeCalendar,    const Color(0xFFAB47BC)),
      _A('🥗', 'Nutrition',    AppConstants.routeNutrition,   const Color(0xFF2ED573)),
      _A('👟', 'Mes pas',      AppConstants.routeSteps,       const Color(0xFF4ECDC4)),
      _A('🚫', 'Abstinences',  AppConstants.routeAbstinence,  const Color(0xFFFF4757)),
      _A('⚔️', 'Quêtes',       AppConstants.routeRpg,         const Color(0xFFFFD700)),
    ];

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Accès rapide', style: TextStyle(
          color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 1.3,
        children: actions.map((a) => GestureDetector(
          onTap: () => context.push(a.route),
          child: Container(
            decoration: BoxDecoration(
              color: a.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: a.color.withOpacity(0.3))),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(a.icon, style: const TextStyle(fontSize: 26)),
                const SizedBox(height: 6),
                Text(a.label, style: const TextStyle(
                    color: Colors.white70, fontSize: 11,
                    fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center),
              ])),
        )).toList()),
    ]);
  }
}

class _A { final String icon, label, route; final Color color;
  _A(this.icon, this.label, this.route, this.color); }

// ── Exercices recommandés ─────────────────────────────
class _RecommendedExercises extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final exos = ExercisesData.free().take(4).toList();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Exercices populaires', style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16)),
        TextButton(
          onPressed: () => context.push(AppConstants.routeExercises),
          child: const Text('Voir tout',
              style: TextStyle(color: AppTheme.primary, fontSize: 13))),
      ]),
      const SizedBox(height: 12),
      ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: exos.length,
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemBuilder: (_, i) {
          final ex = exos[i];
          return GestureDetector(
            onTap: () => context.push(
                '${AppConstants.routeExercises}/${ex.id}'),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border)),
              child: Row(children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: Color(ex.difficultyColor).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(ex.locationIcon,
                      style: const TextStyle(fontSize: 22)))),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ex.nameFr, style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600,
                        fontSize: 14)),
                    Text(ex.muscleGroups.take(2).join(' · '),
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                  ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Color(ex.difficultyColor).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8)),
                  child: Text(ex.difficultyLabel('fr'), style: TextStyle(
                      color: Color(ex.difficultyColor),
                      fontSize: 11, fontWeight: FontWeight.w600))),
              ]));
        }),
    ]);
  }
}
