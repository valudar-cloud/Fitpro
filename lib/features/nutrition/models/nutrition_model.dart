// ════════════════════════════════════════════════════════
// MODÈLES NUTRITION
// ════════════════════════════════════════════════════════

class Food {
  final String id;
  final String nameFr;
  final String nameEn;
  final String category;       // viande, poisson, legume, feculant, etc.
  final String icon;
  final double calories;       // Pour 100g
  final double proteins;       // g pour 100g
  final double carbs;          // g pour 100g
  final double lipids;         // g pour 100g
  final double fiber;          // g pour 100g
  final Map<String, double> vitamins;  // nom → mg
  final Map<String, double> minerals;  // nom → mg
  final List<String> goals;   // prise_muscle, perte_gras, les deux
  final bool isCustom;
  final String? userId;        // null = aliment global, sinon custom user

  const Food({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    required this.category,
    required this.icon,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.lipids,
    this.fiber = 0,
    this.vitamins = const {},
    this.minerals = const {},
    this.goals = const ['prise_muscle', 'perte_gras'],
    this.isCustom = false,
    this.userId,
  });

  factory Food.fromJson(Map<String, dynamic> j) => Food(
    id: j['id'],
    nameFr: j['name_fr'],
    nameEn: j['name_en'] ?? j['name_fr'],
    category: j['category'] ?? 'autre',
    icon: j['icon'] ?? '🍽️',
    calories: (j['calories'] ?? 0).toDouble(),
    proteins: (j['proteins'] ?? 0).toDouble(),
    carbs: (j['carbs'] ?? 0).toDouble(),
    lipids: (j['lipids'] ?? 0).toDouble(),
    fiber: (j['fiber'] ?? 0).toDouble(),
    vitamins: Map<String, double>.from(j['vitamins'] ?? {}),
    minerals: Map<String, double>.from(j['minerals'] ?? {}),
    goals: List<String>.from(j['goals'] ?? []),
    isCustom: j['is_custom'] ?? false,
    userId: j['user_id'],
  );

  // Calcule les valeurs pour une quantité donnée
  double caloriesFor(double grams)  => calories  * grams / 100;
  double proteinsFor(double grams)  => proteins  * grams / 100;
  double carbsFor(double grams)     => carbs     * grams / 100;
  double lipidsFor(double grams)    => lipids    * grams / 100;
}

// ── Entrée journal alimentaire ────────────────────────
class MealLog {
  final String id;
  final String userId;
  final String foodId;
  final String foodName;
  final String foodIcon;
  final double grams;
  final double calories;
  final double proteins;
  final double carbs;
  final double lipids;
  final String mealType; // breakfast, lunch, dinner, snack
  final DateTime loggedAt;

  const MealLog({
    required this.id,
    required this.userId,
    required this.foodId,
    required this.foodName,
    required this.foodIcon,
    required this.grams,
    required this.calories,
    required this.proteins,
    required this.carbs,
    required this.lipids,
    required this.mealType,
    required this.loggedAt,
  });

  factory MealLog.fromJson(Map<String, dynamic> j) => MealLog(
    id: j['id'],
    userId: j['user_id'],
    foodId: j['food_id'],
    foodName: j['food_name'],
    foodIcon: j['food_icon'] ?? '🍽️',
    grams: (j['grams'] ?? 100).toDouble(),
    calories: (j['calories'] ?? 0).toDouble(),
    proteins: (j['proteins'] ?? 0).toDouble(),
    carbs: (j['carbs'] ?? 0).toDouble(),
    lipids: (j['lipids'] ?? 0).toDouble(),
    mealType: j['meal_type'] ?? 'lunch',
    loggedAt: DateTime.parse(j['logged_at']),
  );
}

// ── Résumé journalier ─────────────────────────────────
class DailySummary {
  final List<MealLog> logs;
  final double targetCalories;

  const DailySummary({required this.logs, required this.targetCalories});

  double get totalCalories  => logs.fold(0, (s, l) => s + l.calories);
  double get totalProteins  => logs.fold(0, (s, l) => s + l.proteins);
  double get totalCarbs     => logs.fold(0, (s, l) => s + l.carbs);
  double get totalLipids    => logs.fold(0, (s, l) => s + l.lipids);

  double get calorieProgress =>
      (totalCalories / targetCalories).clamp(0.0, 1.5);

  List<MealLog> byType(String type) =>
      logs.where((l) => l.mealType == type).toList();
}

// ── Recette personnalisée ─────────────────────────────
class CustomRecipe {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final String goal;           // prise_muscle, perte_gras, les deux
  final int servings;
  final List<RecipeIngredient> ingredients;
  final String? instructions;
  final DateTime createdAt;

  const CustomRecipe({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.goal,
    required this.servings,
    required this.ingredients,
    this.instructions,
    required this.createdAt,
  });

  double get totalCalories =>
      ingredients.fold(0, (s, i) => s + i.food.caloriesFor(i.grams));
  double get totalProteins =>
      ingredients.fold(0, (s, i) => s + i.food.proteinsFor(i.grams));
  double get totalCarbs =>
      ingredients.fold(0, (s, i) => s + i.food.carbsFor(i.grams));
  double get totalLipids =>
      ingredients.fold(0, (s, i) => s + i.food.lipidsFor(i.grams));

  double get caloriesPerServing => totalCalories / servings;
}

class RecipeIngredient {
  final Food food;
  final double grams;
  const RecipeIngredient({required this.food, required this.grams});
}
