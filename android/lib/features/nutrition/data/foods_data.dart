import '../models/nutrition_model.dart';

// ════════════════════════════════════════════════════════
// BASE ALIMENTS — 80+ aliments avec macros complets
// ════════════════════════════════════════════════════════

class FoodsData {
  static const List<Food> all = [

    // ════════ PROTÉINES ANIMALES ════════

    Food(id:'poulet_blanc', nameFr:'Blanc de poulet', nameEn:'Chicken breast',
      category:'viande', icon:'🍗', calories:165, proteins:31, carbs:0, lipids:3.6,
      vitamins:{'B3': 13.7, 'B6': 1.0}, minerals:{'Phosphore': 220},
      goals:['prise_muscle','perte_gras']),

    Food(id:'oeuf_entier', nameFr:'Œuf entier', nameEn:'Whole egg',
      category:'oeuf', icon:'🥚', calories:155, proteins:13, carbs:1.1, lipids:11,
      vitamins:{'B12': 1.1, 'D': 2.0, 'A': 140}, minerals:{'Fer': 1.8},
      goals:['prise_muscle','perte_gras']),

    Food(id:'blanc_oeuf', nameFr:'Blanc d\'œuf', nameEn:'Egg white',
      category:'oeuf', icon:'🥚', calories:52, proteins:11, carbs:0.7, lipids:0.2,
      goals:['prise_muscle','perte_gras']),

    Food(id:'thon_boite', nameFr:'Thon en boîte (eau)', nameEn:'Canned tuna',
      category:'poisson', icon:'🐟', calories:116, proteins:26, carbs:0, lipids:1,
      vitamins:{'B12': 2.5, 'D': 4.0}, minerals:{'Sélénium': 80},
      goals:['prise_muscle','perte_gras']),

    Food(id:'saumon', nameFr:'Saumon', nameEn:'Salmon',
      category:'poisson', icon:'🐟', calories:208, proteins:20, carbs:0, lipids:13,
      vitamins:{'D': 11.0, 'B12': 3.2, 'Oméga3': 2300},
      goals:['prise_muscle','perte_gras']),

    Food(id:'cabillaud', nameFr:'Cabillaud', nameEn:'Cod',
      category:'poisson', icon:'🐟', calories:82, proteins:18, carbs:0, lipids:0.7,
      vitamins:{'B12': 1.0}, goals:['perte_gras','prise_muscle']),

    Food(id:'boeuf_maigre', nameFr:'Bœuf maigre (5% MG)', nameEn:'Lean beef',
      category:'viande', icon:'🥩', calories:140, proteins:26, carbs:0, lipids:4,
      vitamins:{'B12': 2.1, 'B3': 5.0}, minerals:{'Fer': 3.0, 'Zinc': 5.0},
      goals:['prise_muscle']),

    Food(id:'dinde', nameFr:'Dinde', nameEn:'Turkey',
      category:'viande', icon:'🍗', calories:135, proteins:30, carbs:0, lipids:1.0,
      vitamins:{'B3': 11.0, 'B6': 0.9},
      goals:['prise_muscle','perte_gras']),

    Food(id:'crevettes', nameFr:'Crevettes', nameEn:'Shrimp',
      category:'poisson', icon:'🦐', calories:99, proteins:24, carbs:0, lipids:0.3,
      goals:['perte_gras','prise_muscle']),

    Food(id:'cottage_cheese', nameFr:'Cottage cheese', nameEn:'Cottage cheese',
      category:'laitier', icon:'🧀', calories:98, proteins:11, carbs:3.4, lipids:4.3,
      vitamins:{'B12': 0.4}, goals:['prise_muscle','perte_gras']),

    Food(id:'fromage_blanc_0', nameFr:'Fromage blanc 0%', nameEn:'Quark 0%',
      category:'laitier', icon:'🥛', calories:49, proteins:8, carbs:4, lipids:0.1,
      goals:['perte_gras','prise_muscle']),

    Food(id:'skyr', nameFr:'Skyr nature', nameEn:'Skyr plain',
      category:'laitier', icon:'🥛', calories:63, proteins:11, carbs:4, lipids:0.2,
      goals:['prise_muscle','perte_gras']),

    Food(id:'whey', nameFr:'Whey protéine', nameEn:'Whey protein',
      category:'supplement', icon:'💪', calories:385, proteins:80, carbs:7, lipids:4,
      goals:['prise_muscle']),

    // ════════ FÉCULENTS & GLUCIDES ════════

    Food(id:'riz_blanc', nameFr:'Riz blanc cuit', nameEn:'Cooked white rice',
      category:'feculent', icon:'🍚', calories:130, proteins:2.7, carbs:28, lipids:0.3,
      goals:['prise_muscle','perte_gras']),

    Food(id:'riz_complet', nameFr:'Riz complet cuit', nameEn:'Cooked brown rice',
      category:'feculent', icon:'🍚', calories:112, proteins:2.6, carbs:23, lipids:0.9,
      fiber:1.8, goals:['prise_muscle','perte_gras']),

    Food(id:'avoine', nameFr:'Flocons d\'avoine', nameEn:'Oats',
      category:'feculent', icon:'🌾', calories:368, proteins:13, carbs:58, lipids:7,
      fiber:10, vitamins:{'B1': 0.8}, minerals:{'Magnésium': 177},
      goals:['prise_muscle','perte_gras']),

    Food(id:'patate_douce', nameFr:'Patate douce cuite', nameEn:'Sweet potato',
      category:'legume', icon:'🍠', calories:90, proteins:2, carbs:21, lipids:0.1,
      fiber:3, vitamins:{'A': 961, 'C': 20},
      goals:['prise_muscle','perte_gras']),

    Food(id:'pomme_de_terre', nameFr:'Pomme de terre cuite', nameEn:'Potato',
      category:'legume', icon:'🥔', calories:87, proteins:1.9, carbs:20, lipids:0.1,
      vitamins:{'C': 13, 'B6': 0.3},
      goals:['prise_muscle','perte_gras']),

    Food(id:'quinoa', nameFr:'Quinoa cuit', nameEn:'Cooked quinoa',
      category:'feculent', icon:'🌾', calories:120, proteins:4.4, carbs:21, lipids:1.9,
      fiber:2.8, goals:['prise_muscle','perte_gras']),

    Food(id:'pates_completes', nameFr:'Pâtes complètes cuites', nameEn:'Whole pasta',
      category:'feculent', icon:'🍝', calories:132, proteins:5, carbs:26, lipids:0.5,
      fiber:3.5, goals:['prise_muscle']),

    Food(id:'lentilles', nameFr:'Lentilles cuites', nameEn:'Cooked lentils',
      category:'legumineuse', icon:'🥘', calories:116, proteins:9, carbs:20, lipids:0.4,
      fiber:8, minerals:{'Fer': 3.3},
      goals:['prise_muscle','perte_gras']),

    Food(id:'pois_chiches', nameFr:'Pois chiches cuits', nameEn:'Chickpeas',
      category:'legumineuse', icon:'🥘', calories:164, proteins:8.9, carbs:27, lipids:2.6,
      fiber:7.6, goals:['prise_muscle','perte_gras']),

    Food(id:'haricots_noirs', nameFr:'Haricots noirs cuits', nameEn:'Black beans',
      category:'legumineuse', icon:'🥘', calories:132, proteins:8.9, carbs:24, lipids:0.5,
      fiber:8.7, goals:['prise_muscle','perte_gras']),

    Food(id:'pain_complet', nameFr:'Pain complet', nameEn:'Whole grain bread',
      category:'feculent', icon:'🍞', calories:247, proteins:9, carbs:41, lipids:3.4,
      fiber:7, goals:['prise_muscle']),

    // ════════ LÉGUMES ════════

    Food(id:'brocoli', nameFr:'Brocoli cuit', nameEn:'Cooked broccoli',
      category:'legume', icon:'🥦', calories:35, proteins:2.4, carbs:7, lipids:0.4,
      fiber:2.6, vitamins:{'C': 65, 'K': 102, 'B9': 63},
      goals:['prise_muscle','perte_gras']),

    Food(id:'epinards', nameFr:'Épinards crus', nameEn:'Raw spinach',
      category:'legume', icon:'🥬', calories:23, proteins:2.9, carbs:3.6, lipids:0.4,
      fiber:2.2, vitamins:{'K': 483, 'A': 469, 'C': 28, 'B9': 194},
      minerals:{'Fer': 2.7, 'Magnésium': 79},
      goals:['prise_muscle','perte_gras']),

    Food(id:'tomate', nameFr:'Tomate', nameEn:'Tomato',
      category:'legume', icon:'🍅', calories:18, proteins:0.9, carbs:3.9, lipids:0.2,
      vitamins:{'C': 14, 'A': 42, 'Lycopène': 2573},
      goals:['prise_muscle','perte_gras']),

    Food(id:'concombre', nameFr:'Concombre', nameEn:'Cucumber',
      category:'legume', icon:'🥒', calories:16, proteins:0.7, carbs:3.6, lipids:0.1,
      goals:['perte_gras']),

    Food(id:'poivron', nameFr:'Poivron rouge', nameEn:'Red bell pepper',
      category:'legume', icon:'🫑', calories:31, proteins:1, carbs:6, lipids:0.3,
      vitamins:{'C': 128, 'A': 157, 'B6': 0.3},
      goals:['prise_muscle','perte_gras']),

    Food(id:'courgette', nameFr:'Courgette cuite', nameEn:'Zucchini',
      category:'legume', icon:'🥒', calories:17, proteins:1.2, carbs:3.5, lipids:0.2,
      vitamins:{'C': 17}, goals:['perte_gras']),

    Food(id:'asperges', nameFr:'Asperges', nameEn:'Asparagus',
      category:'legume', icon:'🌿', calories:20, proteins:2.2, carbs:3.9, lipids:0.1,
      vitamins:{'K': 42, 'B9': 52, 'C': 7},
      goals:['prise_muscle','perte_gras']),

    Food(id:'chou_kale', nameFr:'Chou kale', nameEn:'Kale',
      category:'legume', icon:'🥬', calories:49, proteins:4.3, carbs:9, lipids:0.9,
      vitamins:{'K': 817, 'C': 120, 'A': 241},
      goals:['prise_muscle','perte_gras']),

    Food(id:'champignons', nameFr:'Champignons de Paris', nameEn:'Mushrooms',
      category:'legume', icon:'🍄', calories:22, proteins:3.1, carbs:3.3, lipids:0.3,
      vitamins:{'B3': 3.6, 'B2': 0.4, 'D': 0.2},
      goals:['prise_muscle','perte_gras']),

    Food(id:'avocat', nameFr:'Avocat', nameEn:'Avocado',
      category:'fruit', icon:'🥑', calories:160, proteins:2, carbs:9, lipids:15,
      fiber:6.7, vitamins:{'K': 21, 'B9': 81, 'C': 10, 'E': 2.1},
      minerals:{'Potassium': 485},
      goals:['prise_muscle','perte_gras']),

    // ════════ FRUITS ════════

    Food(id:'banane', nameFr:'Banane', nameEn:'Banana',
      category:'fruit', icon:'🍌', calories:89, proteins:1.1, carbs:23, lipids:0.3,
      vitamins:{'B6': 0.4, 'C': 9}, minerals:{'Potassium': 358},
      goals:['prise_muscle']),

    Food(id:'pomme', nameFr:'Pomme', nameEn:'Apple',
      category:'fruit', icon:'🍎', calories:52, proteins:0.3, carbs:14, lipids:0.2,
      fiber:2.4, vitamins:{'C': 5}, goals:['perte_gras']),

    Food(id:'myrtilles', nameFr:'Myrtilles', nameEn:'Blueberries',
      category:'fruit', icon:'🫐', calories:57, proteins:0.7, carbs:14, lipids:0.3,
      vitamins:{'C': 10, 'K': 19}, goals:['prise_muscle','perte_gras']),

    Food(id:'orange', nameFr:'Orange', nameEn:'Orange',
      category:'fruit', icon:'🍊', calories:47, proteins:0.9, carbs:12, lipids:0.1,
      vitamins:{'C': 53, 'B9': 30}, goals:['perte_gras','prise_muscle']),

    Food(id:'fraises', nameFr:'Fraises', nameEn:'Strawberries',
      category:'fruit', icon:'🍓', calories:32, proteins:0.7, carbs:7.7, lipids:0.3,
      vitamins:{'C': 59}, goals:['perte_gras']),

    // ════════ GRAISSES SAINES ════════

    Food(id:'huile_olive', nameFr:'Huile d\'olive', nameEn:'Olive oil',
      category:'matiere_grasse', icon:'🫒', calories:884, proteins:0, carbs:0, lipids:100,
      vitamins:{'E': 14, 'K': 60}, goals:['prise_muscle','perte_gras']),

    Food(id:'amandes', nameFr:'Amandes', nameEn:'Almonds',
      category:'oleagineux', icon:'🌰', calories:579, proteins:21, carbs:22, lipids:50,
      fiber:12, vitamins:{'E': 25}, minerals:{'Magnésium': 270, 'Calcium': 264},
      goals:['prise_muscle','perte_gras']),

    Food(id:'noix', nameFr:'Noix', nameEn:'Walnuts',
      category:'oleagineux', icon:'🌰', calories:654, proteins:15, carbs:14, lipids:65,
      vitamins:{'Oméga3': 9080, 'B6': 0.5},
      goals:['prise_muscle','perte_gras']),

    Food(id:'beurre_cacahuete', nameFr:'Beurre de cacahuète', nameEn:'Peanut butter',
      category:'oleagineux', icon:'🥜', calories:588, proteins:25, carbs:20, lipids:50,
      goals:['prise_muscle']),

    // ════════ RECETTES PRISE DE MASSE ════════

    Food(id:'recipe_riz_poulet', nameFr:'Bowl riz + poulet + légumes',
      nameEn:'Rice chicken veggie bowl',
      category:'recette_masse', icon:'🍱',
      calories:420, proteins:45, carbs:48, lipids:6,
      fiber:5, goals:['prise_muscle']),

    Food(id:'recipe_avoine_banane', nameFr:'Porridge avoine banane + whey',
      nameEn:'Oat banana whey porridge',
      category:'recette_masse', icon:'🥣',
      calories:480, proteins:40, carbs:62, lipids:8,
      fiber:6, goals:['prise_muscle']),

    Food(id:'recipe_omelette_patate', nameFr:'Omelette 4 œufs + patate douce',
      nameEn:'4-egg omelette + sweet potato',
      category:'recette_masse', icon:'🍳',
      calories:510, proteins:38, carbs:45, lipids:18,
      goals:['prise_muscle']),

    Food(id:'recipe_boeuf_quinoa', nameFr:'Bœuf maigre + quinoa + brocoli',
      nameEn:'Lean beef quinoa broccoli',
      category:'recette_masse', icon:'🥗',
      calories:450, proteins:48, carbs:40, lipids:8,
      fiber:6, goals:['prise_muscle']),

    Food(id:'recipe_smoothie_masse', nameFr:'Smoothie prise de masse',
      nameEn:'Mass gain smoothie',
      category:'recette_masse', icon:'🥤',
      calories:600, proteins:50, carbs:75, lipids:10,
      goals:['prise_muscle']),

    Food(id:'recipe_pates_thon', nameFr:'Pâtes complètes + thon + tomates',
      nameEn:'Whole pasta tuna tomatoes',
      category:'recette_masse', icon:'🍝',
      calories:390, proteins:38, carbs:52, lipids:4,
      goals:['prise_muscle']),

    // ════════ RECETTES PERTE DE GRAS ════════

    Food(id:'recipe_salade_poulet', nameFr:'Salade poulet grillé + avocat',
      nameEn:'Grilled chicken avocado salad',
      category:'recette_seche', icon:'🥗',
      calories:280, proteins:35, carbs:8, lipids:12,
      fiber:6, goals:['perte_gras']),

    Food(id:'recipe_saumon_asperges', nameFr:'Saumon vapeur + asperges',
      nameEn:'Steamed salmon asparagus',
      category:'recette_seche', icon:'🐟',
      calories:220, proteins:28, carbs:6, lipids:10,
      goals:['perte_gras']),

    Food(id:'recipe_bowl_legumes', nameFr:'Buddha bowl légumes + skyr',
      nameEn:'Veggie buddha bowl skyr',
      category:'recette_seche', icon:'🥣',
      calories:240, proteins:22, carbs:30, lipids:4,
      fiber:10, goals:['perte_gras']),

    Food(id:'recipe_omelette_legumes', nameFr:'Omelette blancs d\'œufs + légumes',
      nameEn:'Egg white veggie omelette',
      category:'recette_seche', icon:'🍳',
      calories:180, proteins:25, carbs:12, lipids:3,
      goals:['perte_gras']),

    Food(id:'recipe_soupe_legumes', nameFr:'Soupe de légumes maison',
      nameEn:'Homemade vegetable soup',
      category:'recette_seche', icon:'🍲',
      calories:120, proteins:8, carbs:20, lipids:1.5,
      fiber:8, goals:['perte_gras']),

    Food(id:'recipe_skyr_fruits', nameFr:'Skyr + fruits rouges + amandes',
      nameEn:'Skyr red fruits almonds',
      category:'recette_seche', icon:'🥛',
      calories:200, proteins:18, carbs:20, lipids:5,
      goals:['perte_gras']),
  ];

  // ── Filtres ────────────────────────────────────────
  static List<Food> forGoal(String goal) =>
      all.where((f) => f.goals.contains(goal)).toList();

  static List<Food> byCategory(String cat) =>
      all.where((f) => f.category == cat).toList();

  static List<Food> search(String query) {
    final q = query.toLowerCase();
    return all.where((f) =>
        f.nameFr.toLowerCase().contains(q) ||
        f.nameEn.toLowerCase().contains(q)).toList();
  }

  static List<Food> recipes() =>
      all.where((f) =>
          f.category == 'recette_masse' ||
          f.category == 'recette_seche').toList();

  // Objectifs caloriques recommandés
  static Map<String, double> calorieTargets(String goal,
      {double weightKg = 70}) {
    return {
      'prise_muscle': weightKg * 35,   // +15% TDEE
      'perte_gras':   weightKg * 26,   // -20% TDEE
      'maintien':     weightKg * 30,
    };
  }

  // Répartition macros recommandée (% des calories)
  static Map<String, Map<String, double>> macroSplit = {
    'prise_muscle': {'proteines': 0.30, 'glucides': 0.50, 'lipides': 0.20},
    'perte_gras':   {'proteines': 0.40, 'glucides': 0.35, 'lipides': 0.25},
    'maintien':     {'proteines': 0.25, 'glucides': 0.50, 'lipides': 0.25},
  };
}
