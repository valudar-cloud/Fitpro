import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/nutrition_model.dart';
import '../data/foods_data.dart';
import '../providers/nutrition_provider.dart';
import '../../../core/theme/app_theme.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});
  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() { _tabs.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Nutrition 🥗'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.primary),
            onPressed: () => _showAddFood(context),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          labelColor: AppTheme.primary,
          unselectedLabelColor: Colors.white38,
          indicatorColor: AppTheme.primary,
          tabs: const [
            Tab(text: 'AUJOURD\'HUI'),
            Tab(text: 'ALIMENTS'),
            Tab(text: 'RECETTES'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _TodayTab(),
          _FoodsTab(),
          _RecipesTab(),
        ],
      ),
    );
  }

  void _showAddFood(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddFoodSheet(),
    );
  }
}

// ════════════════════════════════════════════════════════
// ONGLET AUJOURD'HUI
// ════════════════════════════════════════════════════════

class _TodayTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dailyLogsProvider);

    return summaryAsync.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppTheme.primary)),
      error: (e, _) => Center(child: Text('Erreur: $e',
          style: const TextStyle(color: Colors.white54))),
      data: (summary) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [

          // ─ Résumé calories ───────────────────────
          _CaloriesRing(summary: summary).animate().fadeIn().scale(
              duration: 600.ms, curve: Curves.elasticOut),

          const SizedBox(height: 20),

          // ─ Macros ────────────────────────────────
          _MacrosRow(summary: summary).animate().fadeIn(delay: 150.ms),

          const SizedBox(height: 20),

          // ─ Repas du jour ────────────────────────
          _MealsList(summary: summary).animate().fadeIn(delay: 250.ms),

          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}

// ── Anneau calories ───────────────────────────────────
class _CaloriesRing extends StatelessWidget {
  final DailySummary summary;
  const _CaloriesRing({required this.summary});

  @override
  Widget build(BuildContext context) {
    final progress = summary.calorieProgress.clamp(0.0, 1.0);
    final over     = summary.totalCalories > summary.targetCalories;
    final color    = over ? AppTheme.danger : AppTheme.primary;
    final remain   = (summary.targetCalories - summary.totalCalories).abs();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(children: [
        Row(children: [
          // Anneau
          SizedBox(
            width: 100, height: 100,
            child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(
                value: progress, strokeWidth: 10,
                strokeCap: StrokeCap.round,
                backgroundColor: AppTheme.border,
                valueColor: AlwaysStoppedAnimation(color),
              ),
              Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text('${summary.totalCalories.toInt()}',
                    style: TextStyle(
                        color: color, fontSize: 20,
                        fontWeight: FontWeight.w800)),
                const Text('kcal', style: TextStyle(
                    color: Colors.white38, fontSize: 10)),
              ]),
            ]),
          ),
          const SizedBox(width: 20),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Objectif : ${summary.targetCalories.toInt()} kcal',
                  style: const TextStyle(color: Colors.white,
                      fontWeight: FontWeight.w600, fontSize: 14)),
              const SizedBox(height: 6),
              Text(
                over
                    ? '⚠️ +${remain.toInt()} kcal au-dessus'
                    : '✅ ${remain.toInt()} kcal restantes',
                style: TextStyle(
                    color: over ? AppTheme.danger : AppTheme.secondary,
                    fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress, minHeight: 8,
                  backgroundColor: AppTheme.border,
                  valueColor: AlwaysStoppedAnimation(color),
                ),
              ),
            ],
          )),
        ]),
      ]),
    );
  }
}

// ── Macros ────────────────────────────────────────────
class _MacrosRow extends StatefulWidget {
  final DailySummary summary;
  const _MacrosRow({required this.summary});
  @override
  State<_MacrosRow> createState() => _MacrosRowState();
}

class _MacrosRowState extends State<_MacrosRow> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final s = widget.summary;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('Macronutriments', style: TextStyle(
              color: Colors.white, fontWeight: FontWeight.w600, fontSize: 15)),
          GestureDetector(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.primary.withOpacity(0.4)),
              ),
              child: Row(children: [
                Text(_expanded ? 'Moins' : '+ Détails',
                    style: const TextStyle(
                        color: AppTheme.primary, fontSize: 12,
                        fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                Icon(_expanded ? Icons.expand_less : Icons.expand_more,
                    color: AppTheme.primary, size: 16),
              ]),
            ),
          ),
        ]),
        const SizedBox(height: 16),
        Row(children: [
          _MacroBar('🥩 Protéines', s.totalProteins, 150,
              const Color(0xFFFF6B35)),
          const SizedBox(width: 10),
          _MacroBar('🍚 Glucides', s.totalCarbs, 250,
              const Color(0xFF4ECDC4)),
          const SizedBox(width: 10),
          _MacroBar('🥑 Lipides', s.totalLipids, 70,
              const Color(0xFFAB47BC)),
        ]),
        // Détails expandables
        if (_expanded) ...[
          const Divider(color: AppTheme.border, height: 24),
          _DetailRow('🥩 Protéines',
              '${s.totalProteins.toStringAsFixed(1)}g',
              'Bâtissent et réparent les muscles. Objectif : 1.8-2.2g/kg de poids.',
              const Color(0xFFFF6B35)),
          _DetailRow('🍚 Glucides',
              '${s.totalCarbs.toStringAsFixed(1)}g',
              'Source d\'énergie principale. Carburant des séances et récupération.',
              const Color(0xFF4ECDC4)),
          _DetailRow('🥑 Lipides',
              '${s.totalLipids.toStringAsFixed(1)}g',
              'Essentiels pour les hormones et l\'absorption des vitamines liposolubles.',
              const Color(0xFFAB47BC)),
        ],
      ]),
    );
  }
}

class _MacroBar extends StatelessWidget {
  final String label;
  final double value, target;
  final Color color;
  const _MacroBar(this.label, this.value, this.target, this.color);

  @override
  Widget build(BuildContext context) => Expanded(child: Column(children: [
    Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10),
        textAlign: TextAlign.center),
    const SizedBox(height: 6),
    Text('${value.toStringAsFixed(0)}g',
        style: TextStyle(color: color, fontSize: 16,
            fontWeight: FontWeight.w700)),
    const SizedBox(height: 6),
    ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: LinearProgressIndicator(
        value: (value / target).clamp(0.0, 1.0), minHeight: 6,
        backgroundColor: AppTheme.border,
        valueColor: AlwaysStoppedAnimation(color),
      ),
    ),
    const SizedBox(height: 4),
    Text('/ ${target.toInt()}g',
        style: const TextStyle(color: Colors.white24, fontSize: 9)),
  ]));
}

class _DetailRow extends StatelessWidget {
  final String label, value, desc;
  final Color color;
  const _DetailRow(this.label, this.value, this.desc, this.color);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label.substring(0, 2), style: const TextStyle(fontSize: 20)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(label.substring(3), style: TextStyle(
              color: color, fontWeight: FontWeight.w600, fontSize: 13)),
          const Spacer(),
          Text(value, style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 14)),
        ]),
        Text(desc, style: const TextStyle(
            color: Colors.white38, fontSize: 11, height: 1.4)),
      ])),
    ]),
  );
}

// ── Liste des repas ───────────────────────────────────
class _MealsList extends ConsumerWidget {
  final DailySummary summary;
  const _MealsList({required this.summary});

  static const _mealTypes = [
    ('breakfast', '🌅', 'Petit-déjeuner'),
    ('lunch',     '☀️', 'Déjeuner'),
    ('dinner',    '🌙', 'Dîner'),
    ('snack',     '🍎', 'Collation'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(children: _mealTypes.map((meal) {
      final logs = summary.byType(meal.$1);
      final total = logs.fold(0.0, (s, l) => s + l.calories);

      return Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Row(children: [
            Text(meal.$2, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Text(meal.$3, style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600,
                fontSize: 15)),
            const Spacer(),
            Text('${total.toInt()} kcal',
                style: const TextStyle(
                    color: AppTheme.primary, fontSize: 13,
                    fontWeight: FontWeight.w600)),
          ]),
          children: [
            if (logs.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Aucun aliment ajouté',
                    style: TextStyle(color: Colors.white38, fontSize: 13)),
              )
            else
              ...logs.map((log) => _LogItem(log: log,
                  onDelete: () => ref
                      .read(nutritionNotifierProvider.notifier)
                      .removeLog(log.id))),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton.icon(
                onPressed: () => _showAddForMeal(context, meal.$1),
                icon: const Icon(Icons.add, size: 16),
                label: Text('Ajouter au ${meal.$3.toLowerCase()}'),
                style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primary),
              ),
            ),
          ],
        ),
      );
    }).toList());
  }

  void _showAddForMeal(BuildContext context, String mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddFoodSheet(preselectedMealType: mealType),
    );
  }
}

class _LogItem extends ConsumerWidget {
  final MealLog log;
  final VoidCallback onDelete;
  const _LogItem({required this.log, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) => ListTile(
    leading: Text(log.foodIcon, style: const TextStyle(fontSize: 24)),
    title: Text(log.foodName,
        style: const TextStyle(color: Colors.white, fontSize: 13)),
    subtitle: Text(
      '${log.grams.toInt()}g  •  P:${log.proteins.toStringAsFixed(1)}  '
      'G:${log.carbs.toStringAsFixed(1)}  L:${log.lipids.toStringAsFixed(1)}',
      style: const TextStyle(color: Colors.white38, fontSize: 11),
    ),
    trailing: Row(mainAxisSize: MainAxisSize.min, children: [
      Text('${log.calories.toInt()} kcal',
          style: const TextStyle(
              color: AppTheme.primary, fontWeight: FontWeight.w600,
              fontSize: 12)),
      IconButton(
        icon: const Icon(Icons.close, color: Colors.white24, size: 18),
        onPressed: onDelete,
      ),
    ]),
  );
}

// ════════════════════════════════════════════════════════
// ONGLET ALIMENTS
// ════════════════════════════════════════════════════════

class _FoodsTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_FoodsTab> createState() => _FoodsTabState();
}

class _FoodsTabState extends ConsumerState<_FoodsTab> {
  String _search = '';
  String _filter = 'tous';

  @override
  Widget build(BuildContext context) {
    var foods = _search.isNotEmpty
        ? FoodsData.search(_search)
        : FoodsData.all.where((f) =>
            f.category != 'recette_masse' &&
            f.category != 'recette_seche').toList();

    if (_filter == 'masse')  foods = foods.where((f) => f.goals.contains('prise_muscle')).toList();
    if (_filter == 'seche')  foods = foods.where((f) => f.goals.contains('perte_gras')).toList();

    return Column(children: [
      // Barre de recherche
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: TextField(
          onChanged: (v) => setState(() => _search = v),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Rechercher un aliment...',
            prefixIcon: const Icon(Icons.search, color: AppTheme.textHint),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 12),
            suffixIcon: _search.isNotEmpty ? IconButton(
              icon: const Icon(Icons.clear, color: AppTheme.textHint),
              onPressed: () => setState(() => _search = ''),
            ) : null,
          ),
        ),
      ),
      // Filtres
      SizedBox(height: 36, child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _FilterChip('tous', 'Tous', _filter, (v) => setState(() => _filter = v)),
          const SizedBox(width: 8),
          _FilterChip('masse', '💪 Prise de masse', _filter, (v) => setState(() => _filter = v)),
          const SizedBox(width: 8),
          _FilterChip('seche', '🔥 Perte de gras', _filter, (v) => setState(() => _filter = v)),
        ],
      )),
      const SizedBox(height: 8),
      Expanded(child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: foods.length,
        itemBuilder: (_, i) => _FoodCard(food: foods[i])
            .animate(delay: (i * 30).ms).fadeIn(),
      )),
    ]);
  }
}

class _FoodCard extends ConsumerWidget {
  final Food food;
  const _FoodCard({required this.food});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.border)),
        collapsedShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: AppTheme.border)),
        backgroundColor: AppTheme.surface,
        collapsedBackgroundColor: AppTheme.surface,
        leading: Text(food.icon, style: const TextStyle(fontSize: 26)),
        title: Text(food.nameFr, style: const TextStyle(
            color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${food.calories.toInt()} kcal  •  '
          'P:${food.proteins.toStringAsFixed(1)}g  '
          'G:${food.carbs.toStringAsFixed(1)}g  '
          'L:${food.lipids.toStringAsFixed(1)}g',
          style: const TextStyle(color: Colors.white54, fontSize: 11),
        ),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          GestureDetector(
            onTap: () => _addFood(context, ref),
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.add, color: AppTheme.primary, size: 18),
            ),
          ),
        ]),
        children: [_FoodDetails(food: food)],
      ),
    );
  }

  void _addFood(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddFoodSheet(preselectedFood: food),
    );
  }
}

// ── Détails nutritionnels expandables ─────────────────
class _FoodDetails extends StatelessWidget {
  final Food food;
  const _FoodDetails({required this.food});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Pour 100g :', style: TextStyle(
          color: Colors.white38, fontSize: 11)),
      const SizedBox(height: 10),
      Wrap(spacing: 8, runSpacing: 8, children: [
        _NutTag('🔥 ${food.calories.toInt()} kcal', const Color(0xFFFF6B35)),
        _NutTag('🥩 ${food.proteins.toStringAsFixed(1)}g protéines', const Color(0xFFFF6B35)),
        _NutTag('🍚 ${food.carbs.toStringAsFixed(1)}g glucides', const Color(0xFF4ECDC4)),
        _NutTag('🥑 ${food.lipids.toStringAsFixed(1)}g lipides', const Color(0xFFAB47BC)),
        if (food.fiber > 0)
          _NutTag('🌿 ${food.fiber.toStringAsFixed(1)}g fibres', const Color(0xFF2ED573)),
        ...food.vitamins.entries.map((e) =>
            _NutTag('💊 Vit.${e.key}: ${e.value.toStringAsFixed(1)}',
                const Color(0xFFFFD700))),
        ...food.minerals.entries.map((e) =>
            _NutTag('⚗️ ${e.key}: ${e.value.toStringAsFixed(0)}mg',
                Colors.white38)),
      ]),
    ]),
  );
}

class _NutTag extends StatelessWidget {
  final String label;
  final Color color;
  const _NutTag(this.label, this.color);

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(label, style: TextStyle(
        color: color, fontSize: 11, fontWeight: FontWeight.w500)),
  );
}

// ════════════════════════════════════════════════════════
// ONGLET RECETTES
// ════════════════════════════════════════════════════════

class _RecipesTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customAsync = ref.watch(customRecipesProvider);
    final builtIn = FoodsData.recipes();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Bouton créer recette
        ElevatedButton.icon(
          onPressed: () => _showCreateRecipe(context, ref),
          icon: const Icon(Icons.add),
          label: const Text('Créer ma recette'),
        ),
        const SizedBox(height: 20),

        // Recettes perso
        customAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (customs) {
            if (customs.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _SectionHeader('🍳 Mes recettes'),
                const SizedBox(height: 10),
                ...customs.map((r) => _CustomRecipeCard(
                    recipe: r,
                    onDelete: () => ref
                        .read(nutritionNotifierProvider.notifier)
                        .deleteRecipe(r['id']))),
                const SizedBox(height: 20),
              ],
            );
          },
        ),

        // Recettes prise de masse
        const _SectionHeader('💪 Prise de masse'),
        const SizedBox(height: 10),
        ...builtIn
            .where((f) => f.category == 'recette_masse')
            .map((f) => _RecipeCard(food: f)),

        const SizedBox(height: 20),

        // Recettes perte de gras
        const _SectionHeader('🔥 Perte de graisse'),
        const SizedBox(height: 10),
        ...builtIn
            .where((f) => f.category == 'recette_seche')
            .map((f) => _RecipeCard(food: f)),

        const SizedBox(height: 80),
      ],
    );
  }

  void _showCreateRecipe(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CreateRecipeSheet(),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) => Text(title,
      style: const TextStyle(color: Colors.white,
          fontSize: 16, fontWeight: FontWeight.w700));
}

class _RecipeCard extends ConsumerWidget {
  final Food food;
  const _RecipeCard({required this.food});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    child: ExpansionTile(
      tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppTheme.border)),
      collapsedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppTheme.border)),
      backgroundColor: AppTheme.surface,
      collapsedBackgroundColor: AppTheme.surface,
      leading: Text(food.icon, style: const TextStyle(fontSize: 28)),
      title: Text(food.nameFr, style: const TextStyle(
          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text('${food.calories.toInt()} kcal/portion',
          style: const TextStyle(color: AppTheme.primary, fontSize: 12)),
      trailing: GestureDetector(
        onTap: () => _addToLog(context, ref),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.2), shape: BoxShape.circle),
          child: const Icon(Icons.add, color: AppTheme.primary, size: 18)),
      ),
      children: [_FoodDetails(food: food)],
    ),
  );

  void _addToLog(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context, backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _AddFoodSheet(preselectedFood: food),
    );
  }
}

class _CustomRecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;
  final VoidCallback onDelete;
  const _CustomRecipeCard({required this.recipe, required this.onDelete});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: AppTheme.surface, borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.secondary.withOpacity(0.3))),
    child: Row(children: [
      Text(recipe['icon'] ?? '🍽️',
          style: const TextStyle(fontSize: 28)),
      const SizedBox(width: 12),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(recipe['name'], style: const TextStyle(
              color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
          Text('${recipe['calories']?.toInt()} kcal  •  '
              'P:${(recipe['proteins'] ?? 0).toStringAsFixed(0)}g  '
              'G:${(recipe['carbs'] ?? 0).toStringAsFixed(0)}g',
              style: const TextStyle(color: Colors.white54, fontSize: 11)),
        ],
      )),
      IconButton(
        icon: const Icon(Icons.delete_outline, color: Colors.white24, size: 20),
        onPressed: onDelete),
    ]),
  );
}

// ════════════════════════════════════════════════════════
// SHEETS
// ════════════════════════════════════════════════════════

class _AddFoodSheet extends ConsumerStatefulWidget {
  final Food? preselectedFood;
  final String? preselectedMealType;
  const _AddFoodSheet({this.preselectedFood, this.preselectedMealType});

  @override
  ConsumerState<_AddFoodSheet> createState() => _AddFoodSheetState();
}

class _AddFoodSheetState extends ConsumerState<_AddFoodSheet> {
  Food? _food;
  String _mealType = 'lunch';
  double _grams = 100;
  String _search = '';
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _food     = widget.preselectedFood;
    _mealType = widget.preselectedMealType ?? 'lunch';
  }

  @override
  Widget build(BuildContext context) {
    final cals = _food?.caloriesFor(_grams) ?? 0;
    final prot = _food?.proteinsFor(_grams) ?? 0;
    final carb = _food?.carbsFor(_grams) ?? 0;
    final lip  = _food?.lipidsFor(_grams) ?? 0;

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      expand: false,
      builder: (_, ctrl) => Column(children: [
        Container(margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.white24,
                borderRadius: BorderRadius.circular(2))),
        const Padding(padding: EdgeInsets.symmetric(horizontal: 24),
          child: Text('Ajouter un aliment', style: TextStyle(
              color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700))),
        Expanded(child: SingleChildScrollView(
          controller: ctrl,
          padding: const EdgeInsets.all(20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

            if (_food == null) ...[
              TextField(
                onChanged: (v) => setState(() => _search = v),
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Rechercher un aliment...',
                  prefixIcon: Icon(Icons.search, color: AppTheme.textHint))),
              const SizedBox(height: 12),
              ...FoodsData.search(_search.isEmpty ? 'a' : _search)
                  .take(8)
                  .map((f) => GestureDetector(
                    onTap: () => setState(() { _food = f; _search = ''; }),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 6),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.border)),
                      child: Row(children: [
                        Text(f.icon, style: const TextStyle(fontSize: 22)),
                        const SizedBox(width: 10),
                        Expanded(child: Text(f.nameFr, style: const TextStyle(
                            color: Colors.white, fontSize: 13))),
                        Text('${f.calories.toInt()} kcal/100g',
                            style: const TextStyle(
                                color: Colors.white38, fontSize: 11)),
                      ]),
                    ))),
            ] else ...[
              // Aliment sélectionné
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.4))),
                child: Row(children: [
                  Text(_food!.icon, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_food!.nameFr,
                      style: const TextStyle(color: Colors.white,
                          fontWeight: FontWeight.w600))),
                  TextButton(
                    onPressed: () => setState(() => _food = null),
                    child: const Text('Changer')),
                ]),
              ),
              const SizedBox(height: 16),

              // Quantité
              const Text('Quantité (grammes)',
                  style: TextStyle(color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 8),
              Row(children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: AppTheme.primary),
                  onPressed: _grams > 10
                      ? () => setState(() => _grams -= 10) : null),
                Expanded(child: Text('${_grams.toInt()}g',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white,
                        fontSize: 24, fontWeight: FontWeight.w700))),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline,
                      color: AppTheme.primary),
                  onPressed: () => setState(() => _grams += 10)),
              ]),
              Slider(
                value: _grams, min: 10, max: 500, divisions: 49,
                activeColor: AppTheme.primary,
                onChanged: (v) => setState(() => _grams = v)),

              // Aperçu calories
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.surface, borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _MacroMini('🔥', '${cals.toInt()}', 'kcal'),
                    _MacroMini('🥩', '${prot.toStringAsFixed(1)}', 'Prot.'),
                    _MacroMini('🍚', '${carb.toStringAsFixed(1)}', 'Gluc.'),
                    _MacroMini('🥑', '${lip.toStringAsFixed(1)}', 'Lip.'),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Type de repas
              const Text('Repas', style: TextStyle(
                  color: Colors.white54, fontSize: 12)),
              const SizedBox(height: 8),
              Row(children: [
                for (final m in [
                  ('breakfast', '🌅', 'Petit-dej'),
                  ('lunch', '☀️', 'Déjeuner'),
                  ('dinner', '🌙', 'Dîner'),
                  ('snack', '🍎', 'Collation'),
                ])
                  Expanded(child: GestureDetector(
                    onTap: () => setState(() => _mealType = m.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: _mealType == m.$1
                            ? AppTheme.primary.withOpacity(0.2)
                            : AppTheme.surfaceLight,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: _mealType == m.$1
                                ? AppTheme.primary : AppTheme.border)),
                      child: Column(children: [
                        Text(m.$2, style: const TextStyle(fontSize: 16)),
                        Text(m.$3, style: TextStyle(
                            color: _mealType == m.$1
                                ? AppTheme.primary : Colors.white54,
                            fontSize: 9)),
                      ])),
                  )),
              ]),
              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(height: 20, width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text('Ajouter (${cals.toInt()} kcal)')),
            ],
          ]),
        )),
      ]),
    );
  }

  Future<void> _submit() async {
    if (_food == null) return;
    setState(() => _loading = true);
    await ref.read(nutritionNotifierProvider.notifier).logFood(
        food: _food!, grams: _grams, mealType: _mealType);
    if (mounted) Navigator.pop(context);
  }
}

class _MacroMini extends StatelessWidget {
  final String icon, value, label;
  const _MacroMini(this.icon, this.value, this.label);
  @override
  Widget build(BuildContext context) => Column(children: [
    Text(icon, style: const TextStyle(fontSize: 16)),
    Text(value, style: const TextStyle(
        color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700)),
    Text(label, style: const TextStyle(color: Colors.white38, fontSize: 9)),
  ]);
}

// ── Sheet créer recette ───────────────────────────────
class _CreateRecipeSheet extends ConsumerStatefulWidget {
  @override
  ConsumerState<_CreateRecipeSheet> createState() =>
      _CreateRecipeSheetState();
}

class _CreateRecipeSheetState extends ConsumerState<_CreateRecipeSheet> {
  final _nameCtrl    = TextEditingController();
  final _instrCtrl   = TextEditingController();
  final _calCtrl     = TextEditingController(text: '0');
  final _protCtrl    = TextEditingController(text: '0');
  final _carbCtrl    = TextEditingController(text: '0');
  final _lipCtrl     = TextEditingController(text: '0');
  String _icon = '🍽️';
  String _goal = 'les_deux';
  int _servings = 1;
  bool _loading = false;

  static const _icons = ['🍽️','🥗','🍳','🥣','🍲','🥘','🍱','🌮','🥙','🥚'];

  @override
  Widget build(BuildContext context) => DraggableScrollableSheet(
    initialChildSize: 0.9,
    maxChildSize: 0.97,
    minChildSize: 0.5,
    expand: false,
    builder: (_, ctrl) => Column(children: [
      Container(margin: const EdgeInsets.symmetric(vertical: 12),
          width: 40, height: 4,
          decoration: BoxDecoration(color: Colors.white24,
              borderRadius: BorderRadius.circular(2))),
      const Text('Créer une recette', style: TextStyle(
          color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
      Expanded(child: SingleChildScrollView(
        controller: ctrl,
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // Icône
          Wrap(spacing: 8, runSpacing: 8,
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
                      color: _icon == ic ? AppTheme.primary : AppTheme.border)),
                child: Center(child: Text(ic,
                    style: const TextStyle(fontSize: 22)))),
            )).toList()),
          const SizedBox(height: 16),

          _Field(_nameCtrl, 'Nom de la recette', Icons.restaurant_menu),
          const SizedBox(height: 12),
          _Field(_instrCtrl, 'Instructions (optionnel)',
              Icons.format_list_numbered, maxLines: 4),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: _NumField(_calCtrl, 'Calories', 'kcal')),
            const SizedBox(width: 8),
            Expanded(child: _NumField(_protCtrl, 'Protéines', 'g')),
          ]),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _NumField(_carbCtrl, 'Glucides', 'g')),
            const SizedBox(width: 8),
            Expanded(child: _NumField(_lipCtrl, 'Lipides', 'g')),
          ]),
          const SizedBox(height: 16),

          // Objectif
          Row(children: [
            for (final e in {
              'prise_muscle': ('💪', 'Masse'),
              'perte_gras': ('🔥', 'Sèche'),
              'les_deux': ('⚖️', 'Les deux'),
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
                          color: _goal == e.key ? AppTheme.primary : AppTheme.border)),
                    child: Column(children: [
                      Text(e.value.$1, style: const TextStyle(fontSize: 18)),
                      Text(e.value.$2, style: TextStyle(
                          color: _goal == e.key ? AppTheme.primary : Colors.white54,
                          fontSize: 10)),
                    ])))),
          ]),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _loading ? null : _create,
            child: _loading
                ? const SizedBox(height: 20, width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2))
                : const Text('Créer la recette')),
        ]),
      )),
    ]),
  );

  Future<void> _create() async {
    if (_nameCtrl.text.trim().isEmpty) return;
    setState(() => _loading = true);
    await ref.read(nutritionNotifierProvider.notifier).createRecipe(
      name: _nameCtrl.text.trim(),
      icon: _icon,
      goal: _goal,
      instructions: _instrCtrl.text.trim(),
      servings: _servings,
      calories: double.tryParse(_calCtrl.text) ?? 0,
      proteins: double.tryParse(_protCtrl.text) ?? 0,
      carbs: double.tryParse(_carbCtrl.text) ?? 0,
      lipids: double.tryParse(_lipCtrl.text) ?? 0,
    );
    if (mounted) Navigator.pop(context);
  }
}

class _Field extends StatelessWidget {
  final TextEditingController ctrl;
  final String label;
  final IconData icon;
  final int maxLines;
  const _Field(this.ctrl, this.label, this.icon, {this.maxLines = 1});

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl, maxLines: maxLines,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppTheme.textHint)));
}

class _NumField extends StatelessWidget {
  final TextEditingController ctrl;
  final String label, unit;
  const _NumField(this.ctrl, this.label, this.unit);

  @override
  Widget build(BuildContext context) => TextField(
    controller: ctrl,
    keyboardType: TextInputType.number,
    style: const TextStyle(color: Colors.white),
    decoration: InputDecoration(
        labelText: label,
        suffixText: unit,
        suffixStyle: const TextStyle(color: Colors.white38)));
}

class _FilterChip extends StatelessWidget {
  final String value, label, current;
  final ValueChanged<String> onTap;
  const _FilterChip(this.value, this.label, this.current, this.onTap);

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onTap(value),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: current == value
            ? AppTheme.primary.withOpacity(0.2) : AppTheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
            color: current == value ? AppTheme.primary : AppTheme.border)),
      child: Text(label, style: TextStyle(
          color: current == value ? AppTheme.primary : Colors.white54,
          fontSize: 13,
          fontWeight: current == value ? FontWeight.w600 : FontWeight.w400))));
}
