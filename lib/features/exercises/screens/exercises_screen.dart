import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/exercises_data.dart';
import '../models/exercise_model.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/localization/app_strings.dart';

// ════════════════════════════════════════════════════════
// EXERCICES SCREEN — Filtres, recherche, adaptation blessures
// ════════════════════════════════════════════════════════

// Provider des blessures utilisateur
final userInjuriesProvider = FutureProvider<List<String>>((ref) async {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) return [];
  final data = await Supabase.instance.client
      .from('user_injuries')
      .select('injury_zone')
      .eq('user_id', uid)
      .eq('is_active', true);
  return data.map<String>((e) => e['injury_zone'] as String).toList();
});

// Provider abonnement premium
final isPremiumProvider = FutureProvider<bool>((ref) async {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) return false;
  final data = await Supabase.instance.client
      .from('subscriptions')
      .select('plan, status')
      .eq('user_id', uid)
      .single();
  return data['plan'] != 'free' && data['status'] == 'active';
});

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  final _searchCtrl = TextEditingController();

  String? _selectedGoal;
  String _selectedLocation = 'both';
  String? _selectedDifficulty;
  String _searchQuery = '';
  bool _showInjuryWarnings = true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sProvider);
    final injuriesAsync = ref.watch(userInjuriesProvider);
    final isPremiumAsync = ref.watch(isPremiumProvider);

    final injuries = injuriesAsync.valueOrNull ?? [];
    final isPremium = isPremiumAsync.valueOrNull ?? false;

    // Filtrage
    var exercises = ExercisesData.filter(
      goal: _selectedGoal,
      location: _selectedLocation == 'both' ? null : _selectedLocation,
      difficulty: _selectedDifficulty,
      injuries: _showInjuryWarnings ? [] : injuries,
      premiumUnlocked: isPremium,
    );

    // Recherche texte
    if (_searchQuery.isNotEmpty) {
      exercises = exercises
          .where((e) =>
              e.nameFr.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              e.nameEn.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              e.muscleGroups.any((m) =>
                  m.toLowerCase().contains(_searchQuery.toLowerCase())))
          .toList();
    }

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          // ─ AppBar + Recherche ────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            title: Text(s.exercisesTitle),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: s.searchExercise,
                    prefixIcon: const Icon(Icons.search, color: AppTheme.textHint),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, color: AppTheme.textHint),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                ),
              ),
            ),
          ),

          // ─ Filtres ───────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              children: [
                // Blessures active ?
                if (injuries.isNotEmpty)
                  _InjuryBanner(
                    count: injuries.length,
                    active: _showInjuryWarnings,
                    onToggle: () => setState(
                        () => _showInjuryWarnings = !_showInjuryWarnings),
                  ),

                // Filtres objectif
                _FilterRow(
                  label: 'Objectif',
                  options: const [
                    ('Tous', null),
                    ('💪 Renforcement', 'renforcement'),
                    ('🔥 Perte gras', 'perte_gras'),
                    ('🏋️ Prise muscle', 'prise_muscle'),
                  ],
                  selected: _selectedGoal,
                  onSelect: (v) => setState(() => _selectedGoal = v),
                ),

                // Filtres lieu
                _FilterRow(
                  label: 'Lieu',
                  options: const [
                    ('🌍 Tous', 'both'),
                    ('🏋️ Gym', 'gym'),
                    ('🏠 Maison', 'home'),
                  ],
                  selected: _selectedLocation,
                  onSelect: (v) =>
                      setState(() => _selectedLocation = v ?? 'both'),
                ),

                // Filtres difficulté
                _FilterRow(
                  label: 'Niveau',
                  options: const [
                    ('Tous', null),
                    ('🟢 Débutant', 'beginner'),
                    ('🟡 Intermédiaire', 'intermediate'),
                    ('🔴 Avancé', 'advanced'),
                  ],
                  selected: _selectedDifficulty,
                  onSelect: (v) => setState(() => _selectedDifficulty = v),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${exercises.length} exercice${exercises.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 13),
                      ),
                      if (!isPremium) ...[
                        const Spacer(),
                        GestureDetector(
                          onTap: () => context.push(AppConstants.routePaywall),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFFD700), Color(0xFFFF9800)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '🔓 Premium — +40 exercices',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─ Liste des exercices ───────────────────
          exercises.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('🔍', style: TextStyle(fontSize: 48)),
                        const SizedBox(height: 12),
                        const Text('Aucun exercice trouvé',
                            style: TextStyle(
                                color: Colors.white54, fontSize: 16)),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () => setState(() {
                            _selectedGoal = null;
                            _selectedLocation = 'both';
                            _selectedDifficulty = null;
                            _searchCtrl.clear();
                            _searchQuery = '';
                          }),
                          child: const Text('Réinitialiser les filtres'),
                        ),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final ex = exercises[index];
                        final hasWarning = injuries.isNotEmpty &&
                            ex.isContraindicated(injuries);
                        return _ExerciseCard(
                          exercise: ex,
                          hasInjuryWarning: hasWarning,
                          isPremium: isPremium,
                          onTap: () => context.push(
                              '${AppConstants.routeExercises}/${ex.id}'),
                        ).animate(delay: (index * 40).ms).fadeIn().slideY(
                              begin: 0.05,
                              duration: 300.ms,
                            );
                      },
                      childCount: exercises.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Bannière blessure active ──────────────────────────
class _InjuryBanner extends StatelessWidget {
  final int count;
  final bool active;
  final VoidCallback onToggle;

  const _InjuryBanner(
      {required this.count, required this.active, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: active
              ? AppTheme.danger.withOpacity(0.12)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? AppTheme.danger.withOpacity(0.4)
                : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            Text(active ? '🩹' : '👁️',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                active
                    ? '$count zone(s) douloureuse(s) — exercices déconseillés signalés'
                    : 'Affichage des exercices déconseillés activé',
                style: TextStyle(
                  color: active ? AppTheme.danger : Colors.white54,
                  fontSize: 12,
                ),
              ),
            ),
            Text(
              active ? 'Masquer' : 'Filtrer',
              style: TextStyle(
                color: active ? AppTheme.danger : AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Ligne de filtres ──────────────────────────────────
class _FilterRow extends StatelessWidget {
  final String label;
  final List<(String, String?)> options;
  final String? selected;
  final ValueChanged<String?> onSelect;

  const _FilterRow({
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final (text, value) = options[i];
          final isSelected = selected == value;
          return GestureDetector(
            onTap: () => onSelect(value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppTheme.primary.withOpacity(0.2)
                    : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? AppTheme.primary : Colors.white54,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Carte exercice ────────────────────────────────────
class _ExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final bool hasInjuryWarning;
  final bool isPremium;
  final VoidCallback onTap;

  const _ExerciseCard({
    required this.exercise,
    required this.hasInjuryWarning,
    required this.isPremium,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final diffColor = Color(exercise.difficultyColor);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasInjuryWarning
                ? AppTheme.danger.withOpacity(0.5)
                : AppTheme.border,
          ),
        ),
        child: Row(
          children: [
            // Icône / thumbnail
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: diffColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(exercise.locationIcon,
                      style: const TextStyle(fontSize: 28)),
                  if (!isPremium && exercise.isPremium)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFD700),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text('👑',
                            style: TextStyle(fontSize: 10)),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 14),

            // Infos
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          exercise.nameFr,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      if (hasInjuryWarning)
                        const Text('⚠️', style: TextStyle(fontSize: 16)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    exercise.muscleGroups.take(3).join(' · '),
                    style: const TextStyle(
                        color: Colors.white54, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _Tag(
                        exercise.difficultyLabel('fr'),
                        color: diffColor,
                      ),
                      const SizedBox(width: 6),
                      _Tag(
                        '${exercise.setsRecommended}×${exercise.repsRecommended}',
                        color: Colors.white24,
                        textColor: Colors.white54,
                      ),
                      if (exercise.caloriesPerMinute != null) ...[
                        const SizedBox(width: 6),
                        _Tag(
                          '🔥 ${exercise.caloriesPerMinute!.toStringAsFixed(0)} cal/min',
                          color: Colors.orange.withOpacity(0.15),
                          textColor: Colors.orange,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            const Icon(Icons.arrow_forward_ios,
                color: Colors.white24, size: 14),
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  final Color color;
  final Color textColor;

  const _Tag(this.text,
      {required this.color, this.textColor = Colors.white70});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }
}
