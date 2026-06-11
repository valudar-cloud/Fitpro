import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/nutrition_model.dart';
import '../data/foods_data.dart';

final _db = Supabase.instance.client;

// ── Journal du jour ───────────────────────────────────
final dailyLogsProvider =
    FutureProvider.autoDispose<DailySummary>((ref) async {
  final uid = _db.auth.currentUser?.id;
  if (uid == null) return DailySummary(logs: [], targetCalories: 2000);

  final today = DateTime.now();
  final dateStr =
      '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

  final data = await _db
      .from('meal_logs')
      .select()
      .eq('user_id', uid)
      .eq('date', dateStr)
      .order('logged_at');

  final logs = data.map((d) => MealLog.fromJson(d)).toList();

  // Récupérer l'objectif calorique du profil
  double target = 2000;
  try {
    final profile = await _db
        .from('profiles')
        .select('goal, weight_kg')
        .eq('id', uid)
        .single();
    final goal   = profile['goal'] ?? 'maintien';
    final weight = (profile['weight_kg'] ?? 70).toDouble();
    target = FoodsData.calorieTargets(goal, weightKg: weight)[goal] ?? 2000;
  } catch (_) {}

  return DailySummary(logs: logs, targetCalories: target);
});

// ── Recettes perso ────────────────────────────────────
final customRecipesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final uid = _db.auth.currentUser?.id;
  if (uid == null) return [];
  return await _db
      .from('custom_recipes')
      .select()
      .eq('user_id', uid)
      .order('created_at', ascending: false);
});

// ── Notifier ──────────────────────────────────────────
class NutritionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  // Ajouter un aliment au journal
  Future<void> logFood({
    required Food food,
    required double grams,
    required String mealType,
  }) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;

    final today = DateTime.now();
    final dateStr =
        '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';

    await _db.from('meal_logs').insert({
      'user_id':   uid,
      'food_id':   food.id,
      'food_name': food.nameFr,
      'food_icon': food.icon,
      'grams':     grams,
      'calories':  food.caloriesFor(grams),
      'proteins':  food.proteinsFor(grams),
      'carbs':     food.carbsFor(grams),
      'lipids':    food.lipidsFor(grams),
      'meal_type': mealType,
      'date':      dateStr,
      'logged_at': DateTime.now().toIso8601String(),
    });
    ref.invalidate(dailyLogsProvider);
  }

  // Supprimer une entrée
  Future<void> removeLog(String logId) async {
    await _db.from('meal_logs').delete().eq('id', logId);
    ref.invalidate(dailyLogsProvider);
  }

  // Créer une recette perso
  Future<void> createRecipe({
    required String name,
    required String icon,
    required String goal,
    required String instructions,
    required int servings,
    required double calories,
    required double proteins,
    required double carbs,
    required double lipids,
  }) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;
    await _db.from('custom_recipes').insert({
      'user_id':      uid,
      'name':         name,
      'icon':         icon,
      'goal':         goal,
      'servings':     servings,
      'calories':     calories,
      'proteins':     proteins,
      'carbs':        carbs,
      'lipids':       lipids,
      'instructions': instructions,
    });
    ref.invalidate(customRecipesProvider);
  }

  // Supprimer une recette perso
  Future<void> deleteRecipe(String id) async {
    await _db.from('custom_recipes').delete().eq('id', id);
    ref.invalidate(customRecipesProvider);
  }
}

final nutritionNotifierProvider =
    AsyncNotifierProvider<NutritionNotifier, void>(NutritionNotifier.new);
