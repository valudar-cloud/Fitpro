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

// ════════════════════════════════════════════════════════
// HOME — Dashboard principal
// ════════════════════════════════════════════════════════

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sProvider);
    final rpgProfile = ref.watch(rpgProfileProvider).valueOrNull;
    final levelInfo = ref.watch(playerLevelProvider);
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          // ─ AppBar ────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            expandedHeight: 0,
            title: Row(
              children: [
                const Text('🏋️',
                    style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                const Text('FitPro',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    )),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.notifications_outlined,
                      color: Colors.white70),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline,
                      color: Colors.white70),
                  onPressed: () => context.push(AppConstants.routeProfile),
                ),
              ],
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                const SizedBox(height: 16),

                // ─ Salutation ────────────────────────
                _GreetingSection(
                  userName: user?.userMetadata?['full_name']?.split(' ').first ?? 'Champion',
                  rpgProfile: rpgProfile,
                ).animate().fadeIn().slideY(begin: -0.1),

                const SizedBox(height: 20),

                // ─ XP Bar ────────────────────────────
                if (levelInfo != null)
                  XpBarWidget(levelInfo: levelInfo)
                      .animate().fadeIn(delay: 100.ms),

                const SizedBox(height: 20),

                // ─ Quêtes du jour ─────────────────────
                _DailyQuestsSummary()
                    .animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 20),

                // ─ Accès rapide ─────────────────────
                _QuickActions()
                    .animate().fadeIn(delay: 300.ms),

                const SizedBox(height: 20),

                // ─ Exercices recommandés ──────────────
                _RecommendedExercises()
                    .animate().fadeIn(delay: 400.ms),

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section salutation ───────────────────────────────
class _GreetingSection extends StatelessWidget {
  final String userName;
  final dynamic rpgProfile;

  const _GreetingSection({required this.userName, this.rpgProfile});

  String _greetingFr() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bonne après-midi';
    return 'Bonsoir';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${_greetingFr()}, $userName 👊',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          rpgProfile?.currentStreak != null && rpgProfile.currentStreak > 0
              ? '🔥 ${rpgProfile.currentStreak} jours de streak — continue !'
              : 'Prêt pour une nouvelle séance ?',
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

// ── Résumé quêtes quotidiennes ───────────────────────
class _DailyQuestsSummary extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(activeQuestsProvider);

    return questsAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (quests) {
        final daily = quests.where((q) => q.type.name == 'daily').toList();
        final done = daily.where((q) =>
          q.status.name == 'completed' || q.status.name == 'claimed'
        ).length;

        return GestureDetector(
          onTap: () => context.push(AppConstants.routeRpg),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFFF6B35).withOpacity(0.15),
                  const Color(0xFFFF9A3C).withOpacity(0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: const Color(0xFFFF6B35).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Text('⚔️', style: TextStyle(fontSize: 30)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Quêtes du jour',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      Text(
                        '$done / ${daily.length} complétées',
                        style: const TextStyle(
                            color: AppTheme.textSecondary, fontSize: 13),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: daily.isEmpty ? 0 : done / daily.length,
                          minHeight: 6,
                          backgroundColor: const Color(0xFF2A2A2A),
                          valueColor: const AlwaysStoppedAnimation(
                              Color(0xFFFF6B35)),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    color: Colors.white38, size: 16),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Actions rapides ──────────────────────────────────
class _QuickActions extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sProvider);

    final actions = [
      _Action('💪', 'Exercices', AppConstants.routeExercises,
          const Color(0xFF4ECDC4)),
      _Action('📅', 'Programme', AppConstants.routeCalendar,
          const Color(0xFFAB47BC)),
      _Action('⚔️', 'Quêtes', AppConstants.routeRpg,
          const Color(0xFFFFD700)),
      _Action('👤', 'Profil', AppConstants.routeProfile,
          const Color(0xFF4CAF50)),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Accès rapide',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            )),
        const SizedBox(height: 12),
        Row(
          children: actions
              .map((a) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _QuickActionBtn(action: a),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _Action {
  final String icon, label, route;
  final Color color;
  _Action(this.icon, this.label, this.route, this.color);
}

class _QuickActionBtn extends StatelessWidget {
  final _Action action;
  const _QuickActionBtn({required this.action});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(action.route),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: action.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: action.color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(action.icon, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Exercices recommandés ────────────────────────────
class _RecommendedExercises extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final exercises = ExercisesData.free().take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Exercices populaires',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                )),
            TextButton(
              onPressed: () => context.push(AppConstants.routeExercises),
              child: const Text('Voir tout',
                  style: TextStyle(color: AppTheme.primary, fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: exercises.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (context, i) {
            final ex = exercises[i];
            return GestureDetector(
              onTap: () => context.push(
                  '${AppConstants.routeExercises}/${ex.id}'),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF2A2A2A)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Color(ex.difficultyColor).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(ex.locationIcon,
                            style: const TextStyle(fontSize: 22)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ex.nameFr,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              )),
                          Text(
                            ex.muscleGroups.take(2).join(' · '),
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Color(ex.difficultyColor).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        ex.difficultyLabel('fr'),
                        style: TextStyle(
                          color: Color(ex.difficultyColor),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
