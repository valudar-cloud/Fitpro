import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:math' as math;

import '../providers/step_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_strings.dart';

// ════════════════════════════════════════════════════════
// ÉCRAN COMPTEUR DE PAS + CALORIES
// ════════════════════════════════════════════════════════

class StepsScreen extends ConsumerWidget {
  const StepsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(stepProvider);
    final historyAsync = ref.watch(stepsHistoryProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Mes pas 👟'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfo(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(children: [

          // ─ Anneau de progression ─────────────────
          _StepRing(data: data).animate().fadeIn().scale(
              duration: 800.ms, curve: Curves.elasticOut),

          const SizedBox(height: 24),

          // ─ Stats en grille ───────────────────────
          _StatsRow(data: data).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // ─ Statut activité ───────────────────────
          _ActivityStatus(status: data.status)
              .animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 24),

          // ─ Graphique 7 jours ─────────────────────
          historyAsync.when(
            loading: () => const SizedBox(
              height: 200,
              child: Center(child: CircularProgressIndicator(
                  color: AppTheme.primary))),
            error: (_, __) => const SizedBox.shrink(),
            data: (history) => _WeeklyChart(history: history)
                .animate().fadeIn(delay: 400.ms),
          ),

          const SizedBox(height: 24),

          // ─ Objectif quotidien ────────────────────
          _DailyGoalCard(data: data).animate().fadeIn(delay: 500.ms),

          const SizedBox(height: 24),

          // ─ Conseils santé ────────────────────────
          _HealthTips().animate().fadeIn(delay: 600.ms),

          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  void _showInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('À propos du compteur',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          'FitPro utilise le capteur de pas intégré de ton téléphone '
          '(podomètre natif).\n\n'
          '📊 Calories calculées selon ta formule :\n'
          'Cal = Pas × 0.04 × (ton poids / 70kg)\n\n'
          '📍 Distance : Pas × 0.75m (pas moyen adulte)\n\n'
          '🎯 Objectif : 10 000 pas/jour (recommandation OMS)',
          style: TextStyle(color: Colors.white70, height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK')),
        ],
      ),
    );
  }
}

// ── Anneau de progression ────────────────────────────
class _StepRing extends StatelessWidget {
  final StepData data;
  const _StepRing({required this.data});

  @override
  Widget build(BuildContext context) {
    final progress = data.progressToGoal;
    final color = data.goalReached
        ? AppTheme.secondary
        : AppTheme.primary;

    return Center(
      child: SizedBox(
        width: 220,
        height: 220,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Anneau de fond
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: 1.0,
                strokeWidth: 16,
                backgroundColor: AppTheme.border,
                valueColor: const AlwaysStoppedAnimation(Colors.transparent),
              ),
            ),
            // Anneau de progression
            SizedBox.expand(
              child: CircularProgressIndicator(
                value: progress,
                strokeWidth: 16,
                strokeCap: StrokeCap.round,
                backgroundColor: AppTheme.border,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            // Contenu central
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!data.isAvailable)
                  const Icon(Icons.sensors_off, color: Colors.white38, size: 36)
                else ...[
                  Text(
                    data.stepsToday.toString().replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                      (m) => '${m[1]} ',
                    ),
                    style: TextStyle(
                      color: color,
                      fontSize: 38,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -1,
                    ),
                  ),
                  const Text('PAS', style: TextStyle(
                      color: Colors.white54, fontSize: 13,
                      letterSpacing: 3, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  Text(
                    '${(progress * 100).toInt()}% de l\'objectif',
                    style: TextStyle(color: color.withOpacity(0.8), fontSize: 12),
                  ),
                ],
                if (!data.isAvailable)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      'Capteur\nnon disponible',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 13),
                    ),
                  ),
              ],
            ),
            // Badge objectif atteint
            if (data.goalReached)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.secondary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(
                        color: AppTheme.secondary.withOpacity(0.5),
                        blurRadius: 10)],
                  ),
                  child: const Text('⭐', style: TextStyle(fontSize: 16)),
                ).animate(onPlay: (c) => c.repeat(reverse: true))
                    .scale(begin: const Offset(0.9, 0.9),
                        end: const Offset(1.1, 1.1), duration: 800.ms),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Grille de stats ──────────────────────────────────
class _StatsRow extends StatelessWidget {
  final StepData data;
  const _StatsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      _StatCard(
        icon: '🔥',
        value: '${data.caloriesBurned.toStringAsFixed(0)}',
        label: 'Calories',
        unit: 'kcal',
        color: const Color(0xFFFF6B35),
      ),
      const SizedBox(width: 12),
      _StatCard(
        icon: '📍',
        value: data.distanceKm.toStringAsFixed(2),
        label: 'Distance',
        unit: 'km',
        color: const Color(0xFF4ECDC4),
      ),
      const SizedBox(width: 12),
      _StatCard(
        icon: '⏱️',
        value: '${_estimateMinutes(data.stepsToday)}',
        label: 'Durée est.',
        unit: 'min',
        color: const Color(0xFFAB47BC),
      ),
    ]);
  }

  // Estimation : ~100 pas/min en marche normale
  int _estimateMinutes(int steps) => (steps / 100).round();
}

class _StatCard extends StatelessWidget {
  final String icon, value, label, unit;
  final Color color;

  const _StatCard({
    required this.icon, required this.value,
    required this.label, required this.unit, required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 6),
        RichText(text: TextSpan(
          children: [
            TextSpan(text: value, style: TextStyle(
                color: color, fontSize: 20, fontWeight: FontWeight.w800)),
            TextSpan(text: ' $unit', style: TextStyle(
                color: color.withOpacity(0.7), fontSize: 11)),
          ],
        )),
        Text(label, style: const TextStyle(
            color: Colors.white38, fontSize: 11)),
      ]),
    ),
  );
}

// ── Statut activité ──────────────────────────────────
class _ActivityStatus extends StatelessWidget {
  final String status;
  const _ActivityStatus({required this.status});

  @override
  Widget build(BuildContext context) {
    final isWalking = status == 'walking';
    final color = isWalking ? AppTheme.secondary : Colors.white38;
    final label = isWalking ? '🚶 En mouvement' : '💤 Au repos';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        if (isWalking)
          Container(
            width: 8, height: 8,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              color: AppTheme.secondary,
              shape: BoxShape.circle,
              boxShadow: [BoxShadow(
                  color: AppTheme.secondary.withOpacity(0.6),
                  blurRadius: 6)],
            ),
          ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 600.ms)
              .then().fadeOut(duration: 600.ms),
        Text(label, style: TextStyle(
            color: color, fontWeight: FontWeight.w600, fontSize: 14)),
      ]),
    );
  }
}

// ── Graphique 7 jours ────────────────────────────────
class _WeeklyChart extends StatelessWidget {
  final List<Map<String, dynamic>> history;
  const _WeeklyChart({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    final days = List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final dateStr =
          '${date.year}-${date.month.toString().padLeft(2,'0')}-${date.day.toString().padLeft(2,'0')}';
      final match = history.where((h) => h['date'] == dateStr).firstOrNull;
      return (
        label: _dayLabel(date),
        steps: (match?['steps'] ?? 0) as int,
        calories: (match?['calories'] ?? 0.0) as double,
      );
    });

    final maxSteps = days.map((d) => d.steps).reduce(math.max);
    final maxY = math.max(maxSteps.toDouble(), StepData.dailyGoal.toDouble());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('7 derniers jours', style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 4),
        Text('Objectif : ${StepData.dailyGoal} pas/jour',
            style: const TextStyle(color: Colors.white38, fontSize: 12)),
        const SizedBox(height: 20),
        SizedBox(
          height: 160,
          child: BarChart(
            BarChartData(
              maxY: maxY * 1.2,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                    '${days[group.x].steps} pas\n',
                    const TextStyle(color: Colors.white,
                        fontWeight: FontWeight.w700, fontSize: 12),
                    children: [
                      TextSpan(
                        text: '${days[group.x].calories.toStringAsFixed(0)} kcal',
                        style: const TextStyle(
                            color: Color(0xFFFF6B35), fontSize: 11)),
                    ],
                  ),
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) => Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(days[value.toInt()].label,
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 10))),
                )),
                leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: StepData.dailyGoal.toDouble(),
                getDrawingHorizontalLine: (value) => FlLine(
                  color: value == StepData.dailyGoal
                      ? AppTheme.secondary.withOpacity(0.4)
                      : Colors.transparent,
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(7, (i) {
                final steps = days[i].steps;
                final reached = steps >= StepData.dailyGoal;
                return BarChartGroupData(x: i, barRods: [
                  BarChartRodData(
                    toY: steps.toDouble(),
                    color: reached ? AppTheme.secondary : AppTheme.primary,
                    width: 28,
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(6)),
                    backDrawRodData: BackgroundBarChartRodData(
                      show: true,
                      toY: maxY * 1.2,
                      color: AppTheme.border.withOpacity(0.3),
                    ),
                  ),
                ]);
              }),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _Legend(AppTheme.secondary, 'Objectif atteint'),
          const SizedBox(width: 20),
          _Legend(AppTheme.primary, 'En cours'),
          const SizedBox(width: 20),
          _Legend(AppTheme.secondary.withOpacity(0.4),
              '${StepData.dailyGoal} pas', isDashed: true),
        ]),
      ]),
    );
  }

  String _dayLabel(DateTime d) {
    const days = ['Dim', 'Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam'];
    return days[d.weekday % 7];
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDashed;
  const _Legend(this.color, this.label, {this.isDashed = false});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: isDashed ? 16 : 10, height: isDashed ? 2 : 10,
        decoration: BoxDecoration(
          color: color,
          borderRadius: isDashed ? null : BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 4),
      Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
    ],
  );
}

// ── Carte objectif ────────────────────────────────────
class _DailyGoalCard extends StatelessWidget {
  final StepData data;
  const _DailyGoalCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final remaining = (StepData.dailyGoal - data.stepsToday).clamp(0, 99999);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.goalReached
              ? [AppTheme.secondary.withOpacity(0.2), Colors.transparent]
              : [AppTheme.primary.withOpacity(0.15), Colors.transparent],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: data.goalReached
              ? AppTheme.secondary.withOpacity(0.4)
              : AppTheme.border,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(
            data.goalReached ? '🏆 Objectif atteint !' : '🎯 Objectif du jour',
            style: TextStyle(
              color: data.goalReached ? AppTheme.secondary : Colors.white,
              fontWeight: FontWeight.w700, fontSize: 16,
            ),
          ),
        ]),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: data.progressToGoal,
          minHeight: 10,
          backgroundColor: AppTheme.border,
          borderRadius: BorderRadius.circular(5),
          valueColor: AlwaysStoppedAnimation(
              data.goalReached ? AppTheme.secondary : AppTheme.primary),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${data.stepsToday} / ${StepData.dailyGoal} pas',
                style: const TextStyle(color: Colors.white70, fontSize: 13)),
            if (!data.goalReached)
              Text('$remaining pas restants',
                  style: const TextStyle(
                      color: AppTheme.primary, fontSize: 13,
                      fontWeight: FontWeight.w600)),
            if (data.goalReached)
              const Text('+50 XP bonus ! ⚡',
                  style: TextStyle(color: AppTheme.secondary,
                      fontSize: 13, fontWeight: FontWeight.w600)),
          ],
        ),
      ]),
    );
  }
}

// ── Conseils santé ────────────────────────────────────
class _HealthTips extends StatelessWidget {
  const _HealthTips();

  static const _tips = [
    ('🚶', '10 000 pas/jour', 'Recommandation OMS pour la santé cardiovasculaire'),
    ('🔥', 'Brûle plus de calories', 'Préfère les escaliers à l\'ascenseur'),
    ('💧', 'Hydrate-toi', 'Bois 250ml d\'eau tous les 2 000 pas'),
    ('😴', 'Récupération', 'La marche douce les jours de repos aide la récupération'),
  ];

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('💡 Conseils santé', style: TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 12),
        ..._tips.map((t) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Row(children: [
            Text(t.$1, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.$2, style: const TextStyle(
                    color: Colors.white, fontSize: 13,
                    fontWeight: FontWeight.w600)),
                Text(t.$3, style: const TextStyle(
                    color: Colors.white54, fontSize: 11)),
              ],
            )),
          ]),
        )),
      ],
    ),
  );
}
