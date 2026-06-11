import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../rpg/providers/rpg_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_strings.dart';
import '../../exercises/data/exercises_data.dart';
import '../../exercises/models/exercise_model.dart';

final _supabase = Supabase.instance.client;

// ── Providers ────────────────────────────────────────
final programsProvider = FutureProvider.autoDispose<List<Map<String,dynamic>>>((ref) async {
  final uid = _supabase.auth.currentUser?.id;
  if (uid == null) return [];
  return await _supabase.from('workout_programs')
      .select().eq('user_id', uid).eq('is_active', true);
});

final sessionDatesProvider = FutureProvider.autoDispose<Set<DateTime>>((ref) async {
  final uid = _supabase.auth.currentUser?.id;
  if (uid == null) return {};
  final data = await _supabase.from('workout_sessions')
      .select('date').eq('user_id', uid);
  return data.map<DateTime>((d) {
    final dt = DateTime.parse(d['date']);
    return DateTime(dt.year, dt.month, dt.day);
  }).toSet();
});

final restDatesProvider = FutureProvider.autoDispose<Map<DateTime, bool>>((ref) async {
  final uid = _supabase.auth.currentUser?.id;
  if (uid == null) return {};
  final data = await _supabase.from('rest_days')
      .select('date, is_active_recovery').eq('user_id', uid);
  return { for (final d in data)
    DateTime.parse(d['date']).toLocal().let((dt) => DateTime(dt.year, dt.month, dt.day)):
    d['is_active_recovery'] as bool };
});

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});
  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen>
    with SingleTickerProviderStateMixin {
  DateTime _focused = DateTime.now();
  DateTime _selected = DateTime.now();
  CalendarFormat _format = CalendarFormat.month;
  late TabController _tabs;

  @override
  void initState() { super.initState(); _tabs = TabController(length: 2, vsync: this); }
  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final sessions  = ref.watch(sessionDatesProvider).valueOrNull ?? {};
    final restDays  = ref.watch(restDatesProvider).valueOrNull ?? {};
    final rpg       = ref.watch(rpgProfileProvider).valueOrNull;
    final level     = ref.watch(playerLevelProvider);
    final selKey    = DateTime(_selected.year, _selected.month, _selected.day);
    final isSession = sessions.contains(selKey);
    final isRest    = restDays.containsKey(selKey);
    final isToday   = isSameDay(_selected, DateTime.now());

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Mon Programme'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
            tooltip: 'Créer un programme',
            onPressed: () => _showCreateProgram()),
        ],
        bottom: TabBar(
          controller: _tabs,
          tabs: const [Tab(text: 'CALENDRIER'), Tab(text: 'PROGRAMMES')],
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.white38,
          indicatorColor: AppTheme.primary,
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          // ── Onglet Calendrier ─────────────────────
          SingleChildScrollView(child: Column(children: [

            // Streak + XP mini
            if (rpg != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(children: [
                  _StreakBadge(rpg.currentStreak),
                  const SizedBox(width: 10),
                  if (level != null) Expanded(child: _MiniXpBar(level)),
                ])).animate().fadeIn(),

            // Calendrier
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: TableCalendar(
                firstDay: DateTime(DateTime.now().year - 1),
                lastDay: DateTime(DateTime.now().year + 2),
                focusedDay: _focused,
                selectedDayPredicate: (d) => isSameDay(d, _selected),
                calendarFormat: _format,
                startingDayOfWeek: StartingDayOfWeek.monday,
                onDaySelected: (sel, foc) => setState(() {
                  _selected = sel; _focused = foc; }),
                onFormatChanged: (f) => setState(() => _format = f),
                calendarStyle: CalendarStyle(
                  defaultTextStyle: const TextStyle(color: Colors.white70),
                  weekendTextStyle: const TextStyle(color: Colors.white54),
                  outsideDaysVisible: false,
                  todayDecoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.3),
                    shape: BoxShape.circle),
                  todayTextStyle: const TextStyle(
                      color: AppTheme.primary, fontWeight: FontWeight.w700),
                  selectedDecoration: const BoxDecoration(
                      color: AppTheme.primary, shape: BoxShape.circle),
                  selectedTextStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
                headerStyle: const HeaderStyle(
                  titleTextStyle: TextStyle(color: Colors.white,
                      fontSize: 16, fontWeight: FontWeight.w600),
                  leftChevronIcon: Icon(Icons.chevron_left, color: Colors.white),
                  rightChevronIcon: Icon(Icons.chevron_right, color: Colors.white),
                  formatButtonTextStyle: TextStyle(color: AppTheme.primary),
                  formatButtonDecoration: BoxDecoration(
                    border: Border.fromBorderSide(
                        BorderSide(color: AppTheme.primary)),
                    borderRadius: BorderRadius.all(Radius.circular(8))),
                ),
                daysOfWeekStyle: const DaysOfWeekStyle(
                  weekdayStyle: TextStyle(color: Colors.white38, fontSize: 12),
                  weekendStyle: TextStyle(color: Colors.white24, fontSize: 12)),
                calendarBuilders: CalendarBuilders(
                  markerBuilder: (_, date, __) {
                    final key = DateTime(date.year, date.month, date.day);
                    if (sessions.contains(key))
                      return Positioned(bottom: 4, child: _Dot(AppTheme.secondary));
                    if (restDays.containsKey(key))
                      return Positioned(bottom: 4, child: _Dot(
                          restDays[key]! ? const Color(0xFFAB47BC) : const Color(0xFF4ECDC4)));
                    return null;
                  },
                ),
              ),
            ),

            // Légende
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  _LegendItem(AppTheme.secondary, 'Séance'),
                  SizedBox(width: 16),
                  _LegendItem(Color(0xFF4ECDC4), 'Repos'),
                  SizedBox(width: 16),
                  _LegendItem(Color(0xFFAB47BC), 'Récup. active'),
                ])),

            const SizedBox(height: 16),

            // Détail du jour
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _DayDetail(
                day: _selected,
                isSession: isSession,
                isRest: isRest,
                isActiveRecovery: restDays[selKey] ?? false,
                isToday: isToday,
                onMarkSession: () => _markSession(),
                onMarkRest: () => _markRest(false),
                onMarkActiveRecovery: () => _markRest(true),
              )).animate().fadeIn(duration: 200.ms),

            const SizedBox(height: 80),
          ])),

          // ── Onglet Programmes ─────────────────────
          _ProgramsTab(onCreateTap: _showCreateProgram),
        ],
      ),
    );
  }

  Future<void> _markSession() async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;
    await _supabase.from('workout_sessions').upsert({
      'user_id': uid,
      'date': _selected.toIso8601String().substring(0,10),
      'completed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id, date');
    ref.invalidate(sessionDatesProvider);
    final result = await ref.read(rpgNotifierProvider.notifier)
        .onSessionCompleted(allExercisesDone: true, isPersonalRecord: false);
    if (mounted && result != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('💪 Séance validée ! +${result.xpGained} XP'),
        backgroundColor: AppTheme.primary, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
    }
  }

  Future<void> _markRest(bool isActive) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;
    await _supabase.from('rest_days').upsert({
      'user_id': uid,
      'date': _selected.toIso8601String().substring(0,10),
      'is_active_recovery': isActive,
    }, onConflict: 'user_id, date');
    ref.invalidate(restDatesProvider);
    await ref.read(rpgNotifierProvider.notifier)
        .onRestDayTaken(isActiveRecovery: isActive);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isActive
            ? '🧘 Récupération active ! +20 XP'
            : '😴 Repos marqué ! +15 XP'),
        backgroundColor: const Color(0xFF4ECDC4), behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
    }
  }

  void _showCreateProgram() => showModalBottomSheet(
    context: context, isScrollControlled: true,
    backgroundColor: AppTheme.surface,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
    builder: (_) => _CreateProgramSheet(onCreated: () {
      ref.invalidate(programsProvider);
      Navigator.pop(context);
    }));
}

// ── Onglet programmes ─────────────────────────────────
class _ProgramsTab extends ConsumerWidget {
  final VoidCallback onCreateTap;
  const _ProgramsTab({required this.onCreateTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programsAsync = ref.watch(programsProvider);
    return programsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      error: (_, __) => const Center(child: Text('Erreur', style: TextStyle(color: Colors.white54))),
      data: (programs) {
        if (programs.isEmpty) return Center(child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('📋', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            const Text('Aucun programme créé', style: TextStyle(color: Colors.white54, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Crée ton premier programme personnalisé',
                style: TextStyle(color: Colors.white38, fontSize: 13)),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onCreateTap,
              icon: const Icon(Icons.add),
              label: const Text('Créer un programme')),
          ]));

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: programs.length,
          itemBuilder: (_, i) => _ProgramCard(
            program: programs[i],
            onDelete: () async {
              await _supabase.from('workout_programs')
                  .update({'is_active': false}).eq('id', programs[i]['id']);
              ref.invalidate(programsProvider);
            },
            onAddExercise: () => _showAddExercise(context, programs[i]['id']),
          ));
      });
  }

  void _showAddExercise(BuildContext context, String programId) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddExerciseSheet(programId: programId));
  }
}

class _ProgramCard extends StatelessWidget {
  final Map<String,dynamic> program;
  final VoidCallback onDelete, onAddExercise;
  const _ProgramCard({required this.program, required this.onDelete,
      required this.onAddExercise});

  @override
  Widget build(BuildContext context) {
    final goal = program['goal'] ?? 'renforcement';
    final goalColor = {'renforcement': const Color(0xFF4ECDC4),
      'perte_gras': AppTheme.primary,
      'prise_muscle': const Color(0xFFAB47BC)}[goal] ?? AppTheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: goalColor.withOpacity(0.3))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(program['name'] ?? '',
              style: const TextStyle(color: Colors.white,
                  fontSize: 16, fontWeight: FontWeight.w600))),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white38, size: 20),
            onPressed: () => _confirmDelete(context)),
        ]),
        const SizedBox(height: 6),
        Row(children: [
          _Chip('${program['days_per_week']} j/sem', goalColor),
          const SizedBox(width: 8),
          _Chip('${program['duration_weeks']} semaines', goalColor),
        ]),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onAddExercise,
          icon: const Icon(Icons.fitness_center, size: 16),
          label: const Text('Ajouter des exercices', style: TextStyle(fontSize: 13)),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: goalColor.withOpacity(0.5)),
            minimumSize: const Size(double.infinity, 40))),
      ]));
  }

  void _confirmDelete(BuildContext context) => showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: AppTheme.surface,
      title: const Text('Supprimer ?', style: TextStyle(color: Colors.white)),
      content: Text('Supprimer "${program['name']}" ?',
          style: const TextStyle(color: Colors.white70)),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context),
            child: const Text('Annuler')),
        TextButton(onPressed: () { Navigator.pop(context); onDelete(); },
            child: const Text('Supprimer',
                style: TextStyle(color: AppTheme.danger))),
      ]));
}

class _Chip extends StatelessWidget {
  final String label; final Color color;
  const _Chip(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3))),
    child: Text(label, style: TextStyle(color: color, fontSize: 11,
        fontWeight: FontWeight.w600)));
}

// ── Fiche du jour sélectionné ─────────────────────────
class _DayDetail extends StatelessWidget {
  final DateTime day;
  final bool isSession, isRest, isActiveRecovery, isToday;
  final VoidCallback onMarkSession, onMarkRest, onMarkActiveRecovery;

  const _DayDetail({required this.day, required this.isSession,
      required this.isRest, required this.isActiveRecovery,
      required this.isToday, required this.onMarkSession,
      required this.onMarkRest, required this.onMarkActiveRecovery});

  @override
  Widget build(BuildContext context) {
    Color borderColor = AppTheme.border;
    if (isSession) borderColor = AppTheme.secondary.withOpacity(0.4);
    if (isRest) borderColor = const Color(0xFF4ECDC4).withOpacity(0.4);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface, borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(isToday ? "📅 Aujourd'hui" : "📅 ${_fmt(day)}",
              style: TextStyle(color: isToday ? AppTheme.primary : Colors.white,
                  fontWeight: FontWeight.w600, fontSize: 15)),
          const Spacer(),
          if (isSession) _Badge('✅ Séance faite', AppTheme.secondary),
          if (isRest) _Badge(
              isActiveRecovery ? '🧘 Récup. active' : '😴 Repos',
              const Color(0xFF4ECDC4)),
        ]),
        if (!isSession && !isRest) ...[
          const SizedBox(height: 14),
          Text(isToday ? 'Que fais-tu aujourd\'hui ?' : 'Aucune activité enregistrée',
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          if (isToday) ...[
            const SizedBox(height: 12),
            Row(children: [
              _ActionBtn('💪', 'Séance', AppTheme.primary, onMarkSession),
              const SizedBox(width: 8),
              _ActionBtn('😴', 'Repos', const Color(0xFF4ECDC4), onMarkRest),
              const SizedBox(width: 8),
              _ActionBtn('🧘', 'Récup.', const Color(0xFFAB47BC), onMarkActiveRecovery),
            ]),
          ],
        ],
      ]));
  }

  String _fmt(DateTime d) {
    const m = ['jan','fév','mars','avr','mai','juin','juil','août','sep','oct','nov','déc'];
    return '${d.day} ${m[d.month-1]} ${d.year}';
  }
}

class _Badge extends StatelessWidget {
  final String label; final Color color;
  const _Badge(this.label, this.color);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.4))),
    child: Text(label, style: TextStyle(color: color, fontSize: 11,
        fontWeight: FontWeight.w600)));
}

class _ActionBtn extends StatelessWidget {
  final String icon, label; final Color color; final VoidCallback onTap;
  const _ActionBtn(this.icon, this.label, this.color, this.onTap);
  @override
  Widget build(BuildContext context) => Expanded(child: GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3))),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 22)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: color, fontSize: 10,
            fontWeight: FontWeight.w600)),
      ]))));
}

// ── Widgets utilitaires ───────────────────────────────
class _Dot extends StatelessWidget {
  final Color color;
  const _Dot(this.color);
  @override
  Widget build(BuildContext context) => Container(
    width: 6, height: 6,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _LegendItem extends StatelessWidget {
  final Color color; final String label;
  const _LegendItem(this.color, this.label);
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 8, height: 8, decoration: BoxDecoration(
        color: color, shape: BoxShape.circle)),
    const SizedBox(width: 4),
    Text(label, style: const TextStyle(color: Colors.white38, fontSize: 10)),
  ]);
}

class _StreakBadge extends StatelessWidget {
  final int streak;
  const _StreakBadge(this.streak);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(
      color: AppTheme.primary.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.primary.withOpacity(0.3))),
    child: Column(children: [
      const Text('🔥', style: TextStyle(fontSize: 20)),
      Text('$streak', style: const TextStyle(
          color: AppTheme.primary, fontSize: 18, fontWeight: FontWeight.w800)),
      const Text('jours', style: TextStyle(color: Colors.white38, fontSize: 10)),
    ]));
}

class _MiniXpBar extends StatelessWidget {
  final dynamic levelInfo;
  const _MiniXpBar(this.levelInfo);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppTheme.surface, borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppTheme.border)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('Niveau ${levelInfo.level}', style: const TextStyle(
            color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
        Text('${levelInfo.xpRemainingForNextLevel} XP',
            style: const TextStyle(color: Colors.white38, fontSize: 11)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: levelInfo.progress, minHeight: 6,
          backgroundColor: const Color(0xFF2A2A2A),
          valueColor: const AlwaysStoppedAnimation(AppTheme.primary))),
    ]));
}

// ── Sheet création programme ──────────────────────────
class _CreateProgramSheet extends ConsumerStatefulWidget {
  final VoidCallback onCreated;
  const _CreateProgramSheet({required this.onCreated});
  @override
  ConsumerState<_CreateProgramSheet> createState() => _CreateProgramSheetState();
}

class _CreateProgramSheetState extends ConsumerState<_CreateProgramSheet> {
  final _nameCtrl = TextEditingController();
  String _goal = 'renforcement';
  int _daysPerWeek = 3, _durationWeeks = 4;
  bool _loading = false;

  @override
  Widget build(BuildContext context) => Padding(
    padding: EdgeInsets.only(left: 24, right: 24, top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24),
    child: SingleChildScrollView(child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Créer un programme', style: TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        TextField(
          controller: _nameCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Nom du programme',
            prefixIcon: Icon(Icons.fitness_center_outlined, color: AppTheme.textHint))),
        const SizedBox(height: 16),
        const Text('Objectif principal', style: TextStyle(
            color: Colors.white54, fontSize: 12)),
        const SizedBox(height: 8),
        Row(children: [
          for (final e in {
            'renforcement': ('💪', 'Renforcement'),
            'perte_gras': ('🔥', 'Perte gras'),
            'prise_muscle': ('🏋️', 'Masse'),
          }.entries)
            Expanded(child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: GestureDetector(
                onTap: () => setState(() => _goal = e.key),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    color: _goal == e.key
                        ? AppTheme.primary.withOpacity(0.2)
                        : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _goal == e.key ? AppTheme.primary : AppTheme.border,
                      width: _goal == e.key ? 1.5 : 1)),
                  child: Column(children: [
                    Text(e.value.$1, style: const TextStyle(fontSize: 18)),
                    Text(e.value.$2, style: TextStyle(
                        color: _goal == e.key ? AppTheme.primary : Colors.white54,
                        fontSize: 10)),
                  ]))))),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          Expanded(child: _Counter('Jours/sem', _daysPerWeek, 1, 6,
              (v) => setState(() => _daysPerWeek = v))),
          const SizedBox(width: 12),
          Expanded(child: _Counter('Semaines', _durationWeeks, 1, 16,
              (v) => setState(() => _durationWeeks = v))),
        ]),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: _loading ? null : _create,
          child: _loading
              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(
                  color: Colors.white, strokeWidth: 2))
              : const Text('Créer le programme')),
      ])));

  Future<void> _create() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;
    await _supabase.from('workout_programs').insert({
      'user_id': uid, 'name': _nameCtrl.text.trim(),
      'goal': _goal, 'days_per_week': _daysPerWeek,
      'duration_weeks': _durationWeeks, 'is_active': true,
    });
    widget.onCreated();
  }
}

class _Counter extends StatelessWidget {
  final String label; final int value, min, max;
  final ValueChanged<int> onChanged;
  const _Counter(this.label, this.value, this.min, this.max, this.onChanged);

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      const SizedBox(height: 6),
      Row(children: [
        IconButton(
          icon: const Icon(Icons.remove_circle_outline, color: AppTheme.primary),
          onPressed: value > min ? () => onChanged(value - 1) : null,
          padding: EdgeInsets.zero, constraints: const BoxConstraints()),
        const SizedBox(width: 8),
        Text('$value', style: const TextStyle(
            color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
          onPressed: value < max ? () => onChanged(value + 1) : null,
          padding: EdgeInsets.zero, constraints: const BoxConstraints()),
      ]),
    ]);
}

// ── Sheet ajout exercice au programme ─────────────────
class _AddExerciseSheet extends StatefulWidget {
  final String programId;
  const _AddExerciseSheet({required this.programId});
  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  String _search = '';
  int _dayOfWeek = 1; // Lundi
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    final exercises = ExercisesData.free().where((e) =>
      _search.isEmpty ||
      e.nameFr.toLowerCase().contains(_search.toLowerCase())).toList();

    const days = ['Lun','Mar','Mer','Jeu','Ven','Sam','Dim'];

    return DraggableScrollableSheet(
      initialChildSize: 0.9, maxChildSize: 0.95, minChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => Column(children: [
        Container(margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.white24,
              borderRadius: BorderRadius.circular(2))),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('Ajouter des exercices', style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
        const SizedBox(height: 12),
        // Sélection jour
        SizedBox(height: 36, child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: 7,
          itemBuilder: (_, i) => GestureDetector(
            onTap: () => setState(() => _dayOfWeek = i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: _dayOfWeek == i
                    ? AppTheme.primary.withOpacity(0.2) : AppTheme.surfaceLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: _dayOfWeek == i ? AppTheme.primary : AppTheme.border)),
              child: Text(days[i], style: TextStyle(
                  color: _dayOfWeek == i ? AppTheme.primary : Colors.white54,
                  fontSize: 13)))))),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (v) => setState(() => _search = v),
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Rechercher un exercice...',
              prefixIcon: Icon(Icons.search, color: AppTheme.textHint),
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12)))),
        const SizedBox(height: 8),
        Expanded(child: ListView.builder(
          controller: ctrl,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: exercises.length,
          itemBuilder: (_, i) {
            final ex = exercises[i];
            final sel = _selected.contains(ex.id);
            return GestureDetector(
              onTap: () => setState(() {
                sel ? _selected.remove(ex.id) : _selected.add(ex.id); }),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: sel ? AppTheme.primary.withOpacity(0.15) : AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: sel ? AppTheme.primary : AppTheme.border,
                      width: sel ? 1.5 : 1)),
                child: Row(children: [
                  Text(ex.locationIcon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(ex.nameFr, style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                      Text(ex.muscleGroups.take(2).join(' · '),
                          style: const TextStyle(color: Colors.white54, fontSize: 11)),
                    ])),
                  if (sel) const Icon(Icons.check_circle, color: AppTheme.primary),
                ])));
          })),
        if (_selected.isNotEmpty)
          Padding(padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => _addExercises(context),
              child: Text('Ajouter ${_selected.length} exercice${_selected.length>1?"s":""}'))),
      ]));
  }

  Future<void> _addExercises(BuildContext context) async {
    final uid = _supabase.auth.currentUser?.id;
    if (uid == null) return;
    // Créer le jour si absent
    final dayData = await _supabase.from('workout_days').insert({
      'program_id': widget.programId, 'user_id': uid,
      'day_of_week': _dayOfWeek, 'name': _dayLabel(_dayOfWeek),
    }).select().single();

    // Ajouter les exercices
    final exercises = _selected.toList().asMap().entries.map((e) => {
      'workout_day_id': dayData['id'],
      'exercise_id': e.value, 'order_index': e.key,
    }).toList();
    await _supabase.from('workout_day_exercises').insert(exercises);

    if (context.mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('✅ ${_selected.length} exercice${_selected.length>1?"s":""} ajouté${_selected.length>1?"s":""}'),
        backgroundColor: AppTheme.secondary, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
    }
  }

  String _dayLabel(int d) => ['Lundi','Mardi','Mercredi','Jeudi','Vendredi','Samedi','Dimanche'][d];
}

extension<T> on T { R let<R>(R Function(T) f) => f(this); }
