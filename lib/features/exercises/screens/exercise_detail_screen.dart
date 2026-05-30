import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gif_view/gif_view.dart';

import '../data/exercises_data.dart';
import '../models/exercise_model.dart';
import '../../rpg/providers/rpg_provider.dart';
import '../screens/exercises_screen.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_strings.dart';

class ExerciseDetailScreen extends ConsumerWidget {
  final String exerciseId;
  const ExerciseDetailScreen({super.key, required this.exerciseId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(sProvider);
    final lang = s.lang;
    final injuries = ref.watch(userInjuriesProvider).valueOrNull ?? [];
    final isPremium = ref.watch(isPremiumProvider).valueOrNull ?? false;

    final exercise = ExercisesData.all.firstWhere(
      (e) => e.id == exerciseId,
      orElse: () => ExercisesData.all.first,
    );

    final hasWarning = exercise.isContraindicated(injuries);
    final isLocked = exercise.isPremium && !isPremium;

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: CustomScrollView(
        slivers: [
          // ─ AppBar avec GIF ───────────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppTheme.bgDark,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // GIF animé
                  if (exercise.gifUrl != null && !isLocked)
                    GifView.network(
                      exercise.gifUrl!,
                      fit: BoxFit.cover,
                      frameRate: 15,
                      errorBuilder: (_, __, ___) => _PlaceholderGif(exercise),
                    )
                  else
                    _PlaceholderGif(exercise),

                  // Gradient bas → haut pour lisibilité
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [Color(0xFF0D0D0D), Colors.transparent],
                        stops: [0.0, 0.6],
                      ),
                    ),
                  ),

                  // Badge Premium
                  if (isLocked)
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('👑', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 8),
                          const Text(
                            'Contenu Premium',
                            style: TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Warning blessure
                  if (hasWarning)
                    Positioned(
                      top: 80,
                      left: 0,
                      right: 0,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.danger.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          children: [
                            Text('⚠️'),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Déconseillé avec tes douleurs actuelles',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─ Contenu ──────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // Nom + difficulté
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            exercise.name(lang),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            exercise.description(lang),
                            style: const TextStyle(
                                color: Colors.white60, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(exercise.difficultyColor).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: Color(exercise.difficultyColor)
                                .withOpacity(0.4)),
                      ),
                      child: Text(
                        exercise.difficultyLabel(lang),
                        style: TextStyle(
                          color: Color(exercise.difficultyColor),
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Stats en grille
                _StatsGrid(exercise: exercise),

                const SizedBox(height: 24),

                // Muscles travaillés
                _Section(
                  title: s.muscles,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...exercise.muscleGroups.map((m) => _MuscleChip(
                            label: s.muscleGroup(m),
                            isPrimary: true,
                          )),
                      ...exercise.secondaryMuscles.map((m) => _MuscleChip(
                            label: s.muscleGroup(m),
                            isPrimary: false,
                          )),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Instructions pas à pas
                _Section(
                  title: lang == 'fr' ? 'Instructions' : 'Instructions',
                  child: Column(
                    children: exercise.instructions(lang)
                        .asMap()
                        .entries
                        .map((e) => _InstructionStep(
                              step: e.key + 1,
                              text: e.value,
                            ))
                        .toList(),
                  ),
                ),

                // Équipement nécessaire
                if (exercise.equipment.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _Section(
                    title: lang == 'fr'
                        ? 'Équipement nécessaire'
                        : 'Required equipment',
                    child: Wrap(
                      spacing: 8,
                      children: exercise.equipment
                          .map((e) => Chip(
                                label: Text(e,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12)),
                                backgroundColor: AppTheme.surfaceLight,
                                side: const BorderSide(
                                    color: AppTheme.border),
                              ))
                          .toList(),
                    ),
                  ),
                ],

                // Contre-indications
                if (exercise.contraindications.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  _Section(
                    title: '⚠️ ${lang == 'fr' ? 'Contre-indications' : 'Contraindications'}',
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: exercise.contraindications
                          .map((c) => Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppTheme.danger.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: AppTheme.danger.withOpacity(0.3)),
                                ),
                                child: Text(
                                  s.injuryZone(c),
                                  style: const TextStyle(
                                    color: AppTheme.danger,
                                    fontSize: 12,
                                  ),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                ],

                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),

      // ─ Bouton Ajouter au programme ───────────────
      bottomNavigationBar: isLocked
          ? _PremiumCTA()
          : _AddToProgramBar(exercise: exercise),
    );
  }
}

// ── Grille de stats ───────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final Exercise exercise;
  const _StatsGrid({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 3,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.4,
      children: [
        _StatCell('Séries', '${exercise.setsRecommended}', '💪'),
        _StatCell('Reps', exercise.repsRecommended, '🔁'),
        _StatCell('Repos', '${exercise.restSeconds}s', '⏱️'),
        _StatCell('Lieu', exercise.locationIcon, '📍'),
        if (exercise.caloriesPerMinute != null)
          _StatCell(
              'Cal/min',
              exercise.caloriesPerMinute!.toStringAsFixed(0),
              '🔥'),
        _StatCell(
          'Objectifs',
          '${exercise.goals.length}',
          '🎯',
        ),
      ],
    );
  }
}

class _StatCell extends StatelessWidget {
  final String label, value, icon;
  const _StatCell(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              )),
          Text(label,
              style:
                  const TextStyle(color: Colors.white38, fontSize: 10)),
        ],
      ),
    );
  }
}

// ── Section avec titre ────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            )),
        const SizedBox(height: 12),
        child,
      ],
    );
  }
}

// ── Étape d'instruction ───────────────────────────────
class _InstructionStep extends StatelessWidget {
  final int step;
  final String text;
  const _InstructionStep({required this.step, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppTheme.primary.withOpacity(0.5)),
            ),
            child: Center(
              child: Text('$step',
                  style: const TextStyle(
                    color: AppTheme.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text,
                  style: const TextStyle(
                      color: Colors.white70, fontSize: 14, height: 1.5)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chip muscle ───────────────────────────────────────
class _MuscleChip extends StatelessWidget {
  final String label;
  final bool isPrimary;
  const _MuscleChip({required this.label, required this.isPrimary});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPrimary
            ? AppTheme.primary.withOpacity(0.15)
            : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPrimary
              ? AppTheme.primary.withOpacity(0.4)
              : AppTheme.border,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isPrimary ? AppTheme.primary : Colors.white54,
          fontSize: 12,
          fontWeight: isPrimary ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
    );
  }
}

// ── Placeholder GIF ───────────────────────────────────
class _PlaceholderGif extends StatelessWidget {
  final Exercise exercise;
  const _PlaceholderGif(this.exercise);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(exercise.locationIcon,
                style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 12),
            Text(exercise.nameFr,
                style: const TextStyle(
                    color: Colors.white54, fontSize: 16)),
          ],
        ),
      ),
    );
  }
}

// ── Barre Ajouter au programme ───────────────────────
class _AddToProgramBar extends ConsumerWidget {
  final Exercise exercise;
  const _AddToProgramBar({required this.exercise});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: ElevatedButton.icon(
        onPressed: () => _showAddToProgram(context),
        icon: const Icon(Icons.add),
        label: const Text('Ajouter au programme'),
      ),
    );
  }

  void _showAddToProgram(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ajouter ${exercise.nameFr} à...',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 20),
            // TODO: liste des jours du programme
            const Text('Sélectionne un jour de ton programme',
                style: TextStyle(color: Colors.white54)),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ── CTA Premium ───────────────────────────────────────
class _PremiumCTA extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        border: Border(top: BorderSide(color: AppTheme.border)),
      ),
      child: ElevatedButton(
        onPressed: () => context.push(AppConstants.routePaywall),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFFFD700),
          foregroundColor: Colors.black,
        ),
        child: const Text('👑 Débloquer avec Premium'),
      ),
    );
  }
}

extension on BuildContext {
  void push(String route) => Navigator.of(this).pushNamed(route);
}
