import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../rpg/providers/rpg_provider.dart';
import '../../rpg/widgets/rpg_widgets.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/constants/app_constants.dart';

// ════════════════════════════════════════════════════════
// CALENDRIER — Programme personnel + Jours de repos
// ════════════════════════════════════════════════════════

// Modèle journée de programme
class ProgramDay {
  final DateTime date;
  final bool isRestDay;
  final bool isCompleted;
  final bool isActiveRecovery;
  final List<String> exerciseIds;
  final String? programName;

  const ProgramDay({
    required this.date,
    this.isRestDay = false,
    this.isCompleted = false,
    this.isActiveRecovery = false,
    this.exerciseIds = const [],
    this.programName,
  });
}

// Provider des données calendrier
final calendarDataProvider = FutureProvider.autoDispose<Map<DateTime, ProgramDay>>((ref) async {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) return {};

  final now = DateTime.now();
  final start = DateTime(now.year, now.month, 1);
  final end = DateTime(now.year, now.month + 2, 0);

  final data = await Supabase.instance.client
      .from('workout_sessions')
      .select('date, workout_day_id, completed_at')
      .eq('user_id', uid)
      .gte('date', start.toIso8601String())
      .lte('date', end.toIso8601String());

  final restData = await Supabase.instance.client
      .from('rest_days')
      .select('date, is_active_recovery')
      .eq('user_id', uid)
      .gte('date', start.toIso8601String())
      .lte('date', end.toIso8601String());

  final result = <DateTime, ProgramDay>{};

  for (final session in data) {
    final date = DateTime.parse(session['date']).toLocal();
    final key = DateTime(date.year, date.month, date.day);
    result[key] = ProgramDay(
      date: key,
      isCompleted: session['completed_at'] != null,
    );
  }

  for (final rest in restData) {
    final date = DateTime.parse(rest['date']).toLocal();
    final key = DateTime(date.year, date.month, date.day);
    result[key] = ProgramDay(
      date: key,
      isRestDay: true,
      isActiveRecovery: rest['is_active_recovery'] ?? false,
    );
  }

  return result;
});

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sProvider);
    final calendarData = ref.watch(calendarDataProvider).valueOrNull ?? {};
    final rpgProfile = ref.watch(rpgProfileProvider).valueOrNull;
    final levelInfo = ref.watch(playerLevelProvider);

    final today = DateTime.now();
    final selectedData = calendarData[DateTime(
        _selectedDay.year, _selectedDay.month, _selectedDay.day)];

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: Text(s.calendarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: s.createProgram,
            onPressed: () => _showCreateProgram(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [

            // ─ Streak + XP résumé ─────────────────
            if (rpgProfile != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Row(
                  children: [
                    _StreakCard(streak: rpgProfile.currentStreak),
                    const SizedBox(width: 10),
                    if (levelInfo != null)
                      Expanded(
                        flex: 2,
                        child: _MiniXpBar(levelInfo: levelInfo),
                      ),
                  ],
                ),
              ).animate().fadeIn(),

            const SizedBox(height: 12),

            // ─ Calendrier ────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: TableCalendar(
                firstDay: DateTime(today.year - 1),
                lastDay: DateTime(today.year + 2),
                focusedDay: _focusedDay,
                selectedDayPredicate: (d) => isSameDay(d, _selectedDay),
                calendarFormat: _format,
                startingDayOfWeek: StartingDayOfWeek.monday,
                locale: s.lang == 'fr' ? 'fr_FR' : 'en_US',

                onDaySelected: (selected, focused) {
                  setState(() {
                    _selectedDay = selected;
                    _focusedDay = focused;
                  });
                },

                onFormatChanged: (format) =>
                    setState(() => _format = format),

                calendarStyle: CalendarStyle(
                  defaultTextStyle: const TextStyle(color: Colors.white70),
                  weekendTextStyle: const TextStyle(color: Colors.white54),
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  todayTextStyle: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.w700),
                  selectedDecoration: const BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                  markerDecoration: const BoxDecoration(
                    color: AppTheme.secondary,
                    shape: BoxShape.circle,
                  ),
                ),

                headerStyle: HeaderStyle(
                  formatButtonTextStyle:
                      const TextStyle(color: AppTheme.primary, fontSize: 13),
                  formatButtonDecoration: BoxDecoration(
                    border: Border.all(color: AppTheme.primary),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  titleTextStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600),
                  leftChevronIcon:
                      const Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon:
                      const Icon(Icons.chevron_right, color: Colors.white),
                ),

                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white38, fontSize: 12),
                  weekendStyle: TextStyle(color: Colors.white24, fontSize: 12),
                ),

                // Marqueurs sur les jours
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (context, date, events) {
                    final key = DateTime(date.year, date.month, date.day);
                    final dayData = calendarData[key];
                    if (dayData == null) return null;

                    return Positioned(
                      bottom: 4,
                      child: _DayMarker(dayData: dayData),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ─ Détail du jour sélectionné ─────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _DayDetail(
                day: _selectedDay,
                dayData: selectedData,
                onMarkRest: () => _markRestDay(false),
                onMarkActiveRecovery: () => _markRestDay(true),
                onMarkDone: () => _markSessionDone(),
              ),
            ).animate().fadeIn(duration: 200.ms),

            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ─ Marquer jour de repos ─────────────────────────
  Future<void> _markRestDay(bool isActive) async {
    final uid = Supabase.instance.client.auth.currentUser?.id;
    if (uid == null) return;

    await Supabase.instance.client.from('rest_days').upsert({
      'user_id': uid,
      'date': _selectedDay.toIso8601String().substring(0, 10),
      'is_active_recovery': isActive,
    }, onConflict: 'user_id, date');

    // XP pour le repos
    await ref
        .read(rpgNotifierProvider.notifier)
        .onRestDayTaken(isActiveRecovery: isActive);

    ref.invalidate(calendarDataProvider);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isActive
              ? '🧘 Récupération active enregistrée ! +20 XP'
              : '😴 Jour de repos marqué ! +15 XP'),
          backgroundColor: const Color(0xFF4ECDC4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  // ─ Marquer séance terminée ───────────────────────
  Future<void> _markSessionDone() async {
    final result = await ref
        .read(rpgNotifierProvider.notifier)
        .onSessionCompleted(
          allExercisesDone: true,
          isPersonalRecord: false,
        );

    ref.invalidate(calendarDataProvider);

    if (mounted && result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('💪 Séance validée ! +${result.xpGained} XP'),
          backgroundColor: AppTheme.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  void _showCreateProgram(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CreateProgramSheet(),
    );
  }
}

// ── Carte streak ──────────────────────────────────────
class _StreakCard extends StatelessWidget {
  final int streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFF6B35).withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: const Color(0xFFFF6B35).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 24)),
          Text(
            '$streak',
            style: const TextStyle(
              color: Color(0xFFFF6B35),
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const Text('jours',
              style: TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

// ── Mini barre XP ─────────────────────────────────────
class _MiniXpBar extends StatelessWidget {
  final dynamic levelInfo;
  const _MiniXpBar({required this.levelInfo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Niveau ${levelInfo.level}',
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13),
              ),
              Text(
                '${levelInfo.xpRemainingForNextLevel} XP',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: levelInfo.progress,
              minHeight: 6,
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor: const AlwaysStoppedAnimation(AppTheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Détail du jour ────────────────────────────────────
class _DayDetail extends StatelessWidget {
  final DateTime day;
  final ProgramDay? dayData;
  final VoidCallback onMarkRest;
  final VoidCallback onMarkActiveRecovery;
  final VoidCallback onMarkDone;

  const _DayDetail({
    required this.day,
    this.dayData,
    required this.onMarkRest,
    required this.onMarkActiveRecovery,
    required this.onMarkDone,
  });

  @override
  Widget build(BuildContext context) {
    final isToday = isSameDay(day, DateTime.now());
    final isPast = day.isBefore(DateTime.now());

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isToday
              ? AppTheme.primary.withOpacity(0.4)
              : AppTheme.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête
          Row(
            children: [
              Text(
                isToday ? "Aujourd'hui" : _formatDate(day),
                style: TextStyle(
                  color: isToday ? AppTheme.primary : Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              if (dayData?.isCompleted == true)
                const _StatusBadge('✅ Séance faite', Color(0xFF2ED573)),
              if (dayData?.isRestDay == true)
                _StatusBadge(
                  dayData!.isActiveRecovery
                      ? '🧘 Récupération active'
                      : '😴 Repos',
                  const Color(0xFF4ECDC4),
                ),
            ],
          ),

          if (dayData == null && isToday) ...[
            const SizedBox(height: 16),
            const Text('Que fais-tu aujourd\'hui ?',
                style: TextStyle(color: Colors.white54, fontSize: 13)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _ActionBtn(
                    icon: '💪',
                    label: 'Séance faite',
                    color: AppTheme.primary,
                    onTap: onMarkDone,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionBtn(
                    icon: '😴',
                    label: 'Repos',
                    color: const Color(0xFF4ECDC4),
                    onTap: onMarkRest,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionBtn(
                    icon: '🧘',
                    label: 'Récup. active',
                    color: const Color(0xFFAB47BC),
                    onTap: onMarkActiveRecovery,
                  ),
                ),
              ],
            ),
          ],

          if (dayData == null && !isToday && !isPast) ...[
            const SizedBox(height: 12),
            const Text('Journée non planifiée.',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime d) {
    const months = [
      'jan', 'fév', 'mars', 'avr', 'mai', 'juin',
      'juil', 'août', 'sep', 'oct', 'nov', 'déc'
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  const _StatusBadge(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final String icon, label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(label,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: color, fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

// ── Marqueur jour ─────────────────────────────────────
class _DayMarker extends StatelessWidget {
  final ProgramDay dayData;
  const _DayMarker({required this.dayData});

  @override
  Widget build(BuildContext context) {
    if (dayData.isCompleted) {
      return const _Dot(Color(0xFF2ED573));
    } else if (dayData.isRestDay) {
      return const _Dot(Color(0xFF4ECDC4));
    }
    return const _Dot(Color(0xFFFF6B35));
  }
}

class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);

  @override
  Widget build(BuildContext context) => Container(
        width: 6, height: 6,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

// ── Sheet création programme ──────────────────────────
class _CreateProgramSheet extends ConsumerStatefulWidget {
  const _CreateProgramSheet();

  @override
  ConsumerState<_CreateProgramSheet> createState() =>
      _CreateProgramSheetState();
}

class _CreateProgramSheetState extends ConsumerState<_CreateProgramSheet> {
  final _nameCtrl = TextEditingController();
  int _daysPerWeek = 3;
  int _durationWeeks = 4;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Créer un programme',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              labelText: 'Nom du programme',
              prefixIcon: Icon(Icons.fitness_center_outlined,
                  color: AppTheme.textHint),
            ),
          ),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _Counter(
              label: 'Jours / semaine',
              value: _daysPerWeek,
              min: 1, max: 6,
              onChanged: (v) => setState(() => _daysPerWeek = v),
            )),
            const SizedBox(width: 12),
            Expanded(child: _Counter(
              label: 'Durée (semaines)',
              value: _durationWeeks,
              min: 1, max: 16,
              onChanged: (v) => setState(() => _durationWeeks = v),
            )),
          ]),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () async {
              if (_nameCtrl.text.isEmpty) return;
              final uid = Supabase.instance.client.auth.currentUser?.id;
              if (uid == null) return;

              await Supabase.instance.client.from('workout_programs').insert({
                'user_id': uid,
                'name': _nameCtrl.text.trim(),
                'days_per_week': _daysPerWeek,
                'duration_weeks': _durationWeeks,
              });

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Créer le programme'),
          ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  final String label;
  final int value, min, max;
  final ValueChanged<int> onChanged;

  const _Counter({
    required this.label, required this.value,
    required this.min, required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primary),
              onPressed: value > min ? () => onChanged(value - 1) : null,
              padding: EdgeInsets.zero,
            ),
            Text('$value',
                style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
              onPressed: value < max ? () => onChanged(value + 1) : null,
              padding: EdgeInsets.zero,
            ),
          ],
        ),
      ],
    );
  }
}
