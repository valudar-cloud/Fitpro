import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/abstinence_model.dart';
import '../data/abstinence_data.dart';
import '../providers/abstinence_provider.dart';
import '../../../core/theme/app_theme.dart';

class AbstinenceScreen extends ConsumerWidget {
  const AbstinenceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(abstinenceListProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Abstinences 🚫'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
            onPressed: () => _showAddSheet(context, ref),
          ),
        ],
      ),
      body: listAsync.when(
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppTheme.primary)),
        error: (e, _) => Center(
            child: Text('Erreur: $e',
                style: const TextStyle(color: Colors.white54))),
        data: (list) {
          if (list.isEmpty) {
            return _EmptyState(onAdd: () => _showAddSheet(context, ref));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            itemBuilder: (_, i) => _TrackerCard(tracker: list[i])
                .animate(delay: (i * 80).ms).fadeIn().slideY(begin: 0.1),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddSheet(context, ref),
        backgroundColor: AppTheme.primary,
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle abstinence'),
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddAbstinenceSheet(),
    );
  }
}

// ── Carte tracker avec timer live ────────────────────
class _TrackerCard extends ConsumerStatefulWidget {
  final AbstinenceTracker tracker;
  const _TrackerCard({required this.tracker});

  @override
  ConsumerState<_TrackerCard> createState() => _TrackerCardState();
}

class _TrackerCardState extends ConsumerState<_TrackerCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Rafraîchit chaque seconde pour le compteur live
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Color get _color {
    final days = widget.tracker.days;
    if (days >= 30) return AppTheme.secondary;
    if (days >= 7)  return const Color(0xFF4ECDC4);
    if (days >= 1)  return AppTheme.primary;
    return Colors.white54;
  }

  @override
  Widget build(BuildContext context) {
    final t    = widget.tracker;
    final tmpl = AbstinenceData.findById(t.category);
    final unlockedBenefits = tmpl?.benefits
        .where((b) => b.isUnlocked(t.elapsed))
        .length ?? 0;
    final totalBenefits = tmpl?.benefits.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _color.withOpacity(0.3)),
      ),
      child: Column(children: [
        // ─ Header ──────────────────────────────────
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            // Icône avec anneau
            Stack(alignment: Alignment.center, children: [
              SizedBox(
                width: 58, height: 58,
                child: CircularProgressIndicator(
                  value: tmpl != null
                      ? t.progressScore(tmpl.targetDays) : 0,
                  strokeWidth: 4,
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation(_color),
                ),
              ),
              Text(t.icon, style: const TextStyle(fontSize: 26)),
            ]),
            const SizedBox(width: 14),

            // Nom + compteur
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t.name, style: const TextStyle(
                    color: Colors.white, fontSize: 16,
                    fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                Text(
                  '${t.days} j • ${t.hours}h • ${t.minutes}min • ${t.seconds}s',
                  style: TextStyle(
                      color: _color, fontSize: 13,
                      fontWeight: FontWeight.w600),
                ),
                if (tmpl != null)
                  Text(
                    '$unlockedBenefits/$totalBenefits bienfaits débloqués',
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 11),
                  ),
              ],
            )),

            // Menu
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white38),
              color: AppTheme.surfaceLight,
              onSelected: (v) => _handleMenu(context, v),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'benefits',
                    child: _MenuItem('⭐', 'Voir les bienfaits')),
                const PopupMenuItem(value: 'rename',
                    child: _MenuItem('✏️', 'Renommer')),
                const PopupMenuItem(value: 'date',
                    child: _MenuItem('📅', 'Modifier la date')),
                const PopupMenuItem(value: 'reset',
                    child: _MenuItem('🔄', 'Rechute — remettre à zéro')),
                const PopupMenuItem(value: 'delete',
                    child: _MenuItem('🗑️', 'Supprimer')),
              ],
            ),
          ]),
        ),

        // ─ Barre de progression ──────────────────────
        if (tmpl != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Column(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: t.progressScore(tmpl.targetDays),
                  minHeight: 6,
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation(_color),
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Objectif : ${tmpl.targetDays} jours',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11)),
                  Text(
                    t.days >= tmpl.targetDays
                        ? '🏆 Objectif atteint !'
                        : '${tmpl.targetDays - t.days} jours restants',
                    style: TextStyle(
                        color: t.days >= tmpl.targetDays
                            ? AppTheme.secondary : Colors.white38,
                        fontSize: 11,
                        fontWeight: t.days >= tmpl.targetDays
                            ? FontWeight.w600 : FontWeight.w400),
                  ),
                ],
              ),
            ]),
          ),
      ]),
    );
  }

  void _handleMenu(BuildContext context, String action) {
    final notifier = ref.read(abstinenceNotifierProvider.notifier);
    switch (action) {
      case 'benefits':
        _showBenefits(context);
        break;
      case 'rename':
        _showRename(context, notifier);
        break;
      case 'date':
        _showDatePicker(context, notifier);
        break;
      case 'reset':
        _confirmReset(context, notifier);
        break;
      case 'delete':
        _confirmDelete(context, notifier);
        break;
    }
  }

  void _showBenefits(BuildContext context) {
    final tmpl = AbstinenceData.findById(widget.tracker.category);
    if (tmpl == null) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _BenefitsSheet(
          tracker: widget.tracker, template: tmpl),
    );
  }

  void _showRename(BuildContext context, AbstinenceNotifier n) {
    final ctrl = TextEditingController(text: widget.tracker.name);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Renommer',
            style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(labelText: 'Nouveau nom'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              n.rename(widget.tracker.id, ctrl.text.trim());
              Navigator.pop(context);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(
      BuildContext context, AbstinenceNotifier n) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: widget.tracker.startDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (_, child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(primary: AppTheme.primary)),
        child: child!),
    );
    if (picked != null) await n.updateStartDate(widget.tracker.id, picked);
  }

  void _confirmReset(BuildContext context, AbstinenceNotifier n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('⚠️ Rechute', style: TextStyle(color: Colors.white)),
        content: const Text(
            'Le compteur va être remis à zéro. C\'est ok — chaque tentative compte.',
            style: TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () {
              n.reset(widget.tracker.id);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger),
            child: const Text('Remettre à zéro'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AbstinenceNotifier n) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.surface,
        title: const Text('Supprimer ?', style: TextStyle(color: Colors.white)),
        content: Text('Supprimer "${widget.tracker.name}" ?',
            style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context),
              child: const Text('Annuler')),
          TextButton(
            onPressed: () {
              n.delete(widget.tracker.id);
              Navigator.pop(context);
            },
            child: const Text('Supprimer',
                style: TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }
}

// ── Sheet bienfaits ───────────────────────────────────
class _BenefitsSheet extends StatelessWidget {
  final AbstinenceTracker tracker;
  final AbstinenceTemplate template;

  const _BenefitsSheet(
      {required this.tracker, required this.template});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      expand: false,
      builder: (_, ctrl) => Column(children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(children: [
            Text(template.icon,
                style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(template.nameFr,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700)),
                  Text(template.descriptionFr,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12)),
                ]),
            ),
          ]),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            controller: ctrl,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: template.benefits.length,
            itemBuilder: (_, i) {
              final b = template.benefits[i];
              final unlocked = b.isUnlocked(tracker.elapsed);
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: unlocked
                      ? AppTheme.secondary.withOpacity(0.1)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: unlocked
                        ? AppTheme.secondary.withOpacity(0.4)
                        : AppTheme.border,
                  ),
                ),
                child: Row(children: [
                  Column(children: [
                    Text(unlocked ? b.emoji : '🔒',
                        style: const TextStyle(fontSize: 28)),
                    const SizedBox(height: 4),
                    Text(b.timeLabel,
                        style: TextStyle(
                            color: unlocked
                                ? AppTheme.secondary : Colors.white38,
                            fontSize: 10,
                            fontWeight: FontWeight.w600)),
                  ]),
                  const SizedBox(width: 14),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.titleFr,
                          style: TextStyle(
                              color: unlocked
                                  ? Colors.white : Colors.white38,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      const SizedBox(height: 3),
                      Text(b.descFr,
                          style: TextStyle(
                              color: unlocked
                                  ? Colors.white60 : Colors.white24,
                              fontSize: 12,
                              height: 1.4)),
                    ],
                  )),
                ]),
              );
            }),
        ),
      ]),
    );
  }
}

// ── Sheet ajout abstinence ────────────────────────────
class _AddAbstinenceSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AddAbstinenceSheet> createState() =>
      _AddAbstinenceSheetState();
}

class _AddAbstinenceSheetState extends ConsumerState<_AddAbstinenceSheet> {
  final _nameCtrl = TextEditingController();
  String _icon = '🚫';
  String? _selectedCategory;
  bool _isCustom = false;
  bool _loading = false;

  static const _icons = [
    '🚫','🚬','🍺','🔞','✋','📱','☕','🍭','🎮','🍕',
    '💊','🎰','😡','😰','🍔','🥤','🧁','🎯','⚡','🌿',
  ];

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => Column(children: [
        Container(
          margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40, height: 4,
          decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('+ Nouvelle abstinence',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700)),
        ),
        Expanded(child: SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Choix template ou custom
              Row(children: [
                Expanded(child: _TabBtn('Templates', !_isCustom,
                    () => setState(() => _isCustom = false))),
                const SizedBox(width: 10),
                Expanded(child: _TabBtn('Personnalisé', _isCustom,
                    () => setState(() => _isCustom = true))),
              ]),
              const SizedBox(height: 20),

              if (!_isCustom) ...[
                // Grille de templates
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: AbstinenceData.templates.length,
                  itemBuilder: (_, i) {
                    final tmpl = AbstinenceData.templates[i];
                    final selected = _selectedCategory == tmpl.id;
                    return GestureDetector(
                      onTap: () => setState(() {
                        _selectedCategory = tmpl.id;
                        _nameCtrl.text = tmpl.nameFr;
                        _icon = tmpl.icon;
                      }),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primary.withOpacity(0.2)
                              : AppTheme.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primary : AppTheme.border,
                            width: selected ? 1.5 : 1,
                          ),
                        ),
                        child: Row(children: [
                          Text(tmpl.icon,
                              style: const TextStyle(fontSize: 22)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(tmpl.nameFr,
                                style: TextStyle(
                                    color: selected
                                        ? AppTheme.primary : Colors.white70,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500)),
                          ),
                        ]),
                      ),
                    );
                  },
                ),
              ] else ...[
                // Sélection icône
                const Text('Choisis une icône',
                    style: TextStyle(
                        color: Colors.white54, fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: _icons.map((ic) => GestureDetector(
                    onTap: () => setState(() => _icon = ic),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: _icon == ic
                            ? AppTheme.primary.withOpacity(0.2)
                            : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: _icon == ic
                              ? AppTheme.primary : AppTheme.border,
                        ),
                      ),
                      child: Center(
                          child: Text(ic,
                              style: const TextStyle(fontSize: 22))),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameCtrl,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'abstinence',
                    hintText: 'Ex: Réseaux sociaux, Alcool...',
                    prefixIcon: Icon(Icons.edit_outlined,
                        color: AppTheme.textHint),
                  ),
                ),
              ],

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _create,
                child: _loading
                    ? const SizedBox(
                        height: 20, width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : const Text('Commencer le compteur'),
              ),
            ],
          ),
        )),
      ]),
    );
  }

  Future<void> _create() async {
    final name = _nameCtrl.text.trim();
    if (name.isEmpty && _isCustom) return;
    if (!_isCustom && _selectedCategory == null) return;

    setState(() => _loading = true);
    await ref.read(abstinenceNotifierProvider.notifier).create(
      name: name.isNotEmpty
          ? name
          : AbstinenceData.findById(_selectedCategory!)?.nameFr ?? name,
      icon: _icon,
      category: _isCustom ? 'custom' : (_selectedCategory ?? 'custom'),
      startDate: DateTime.now(),
    );
    if (mounted) Navigator.pop(context);
  }
}

// ── Widgets utilitaires ───────────────────────────────
class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🚫', style: TextStyle(fontSize: 64)),
      const SizedBox(height: 16),
      const Text('Aucun compteur actif',
          style: TextStyle(color: Colors.white, fontSize: 18,
              fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      const Text(
          'Commence à tracker tes abstinences\npour voir les bienfaits s\'accumuler',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white54, fontSize: 14)),
      const SizedBox(height: 24),
      ElevatedButton.icon(
        onPressed: onAdd,
        icon: const Icon(Icons.add),
        label: const Text('Ajouter une abstinence')),
    ]),
  );
}

class _MenuItem extends StatelessWidget {
  final String emoji, label;
  const _MenuItem(this.emoji, this.label);

  @override
  Widget build(BuildContext context) => Row(children: [
    Text(emoji, style: const TextStyle(fontSize: 18)),
    const SizedBox(width: 10),
    Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
  ]);
}

class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn(this.label, this.active, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(vertical: 12),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active
            ? AppTheme.primary.withOpacity(0.2) : AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: active ? AppTheme.primary : AppTheme.border,
            width: active ? 1.5 : 1)),
      child: Text(label,
          style: TextStyle(
              color: active ? AppTheme.primary : Colors.white54,
              fontWeight: FontWeight.w600)),
    ),
  );
}
