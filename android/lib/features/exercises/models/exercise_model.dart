// ════════════════════════════════════════════════════════
// MODÈLE EXERCICE
// ════════════════════════════════════════════════════════

class Exercise {
  final String id;
  final String nameFr;
  final String nameEn;
  final String descriptionFr;
  final String descriptionEn;
  final List<String> instructionsFr;
  final List<String> instructionsEn;
  final List<String> muscleGroups;
  final List<String> secondaryMuscles;
  final List<String> goals;           // renforcement, perte_gras, prise_muscle
  final List<String> locations;       // gym, home
  final String difficulty;            // beginner, intermediate, advanced
  final List<String> equipment;
  final String? gifUrl;
  final String? thumbnailUrl;
  final List<String> contraindications; // zones blessures à risque
  final int? durationSeconds;
  final int setsRecommended;
  final String repsRecommended;
  final int restSeconds;
  final double? caloriesPerMinute;
  final bool isPremium;

  const Exercise({
    required this.id,
    required this.nameFr,
    required this.nameEn,
    required this.descriptionFr,
    required this.descriptionEn,
    required this.instructionsFr,
    required this.instructionsEn,
    required this.muscleGroups,
    this.secondaryMuscles = const [],
    required this.goals,
    required this.locations,
    required this.difficulty,
    this.equipment = const [],
    this.gifUrl,
    this.thumbnailUrl,
    this.contraindications = const [],
    this.durationSeconds,
    this.setsRecommended = 3,
    this.repsRecommended = '10-12',
    this.restSeconds = 60,
    this.caloriesPerMinute,
    this.isPremium = false,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) => Exercise(
    id: json['id'],
    nameFr: json['name_fr'],
    nameEn: json['name_en'],
    descriptionFr: json['description_fr'] ?? '',
    descriptionEn: json['description_en'] ?? '',
    instructionsFr: List<String>.from(json['instructions_fr'] ?? []),
    instructionsEn: List<String>.from(json['instructions_en'] ?? []),
    muscleGroups: List<String>.from(json['muscle_groups'] ?? []),
    secondaryMuscles: List<String>.from(json['secondary_muscles'] ?? []),
    goals: List<String>.from(json['goals'] ?? []),
    locations: List<String>.from(json['locations'] ?? []),
    difficulty: json['difficulty'] ?? 'beginner',
    equipment: List<String>.from(json['equipment'] ?? []),
    gifUrl: json['gif_url'],
    thumbnailUrl: json['thumbnail_url'],
    contraindications: List<String>.from(json['contraindications'] ?? []),
    durationSeconds: json['duration_seconds'],
    setsRecommended: json['sets_recommended'] ?? 3,
    repsRecommended: json['reps_recommended'] ?? '10-12',
    restSeconds: json['rest_seconds'] ?? 60,
    caloriesPerMinute: json['calories_per_minute']?.toDouble(),
    isPremium: json['is_premium'] ?? false,
  );

  /// Vérifie si l'exercice est contre-indiqué pour les blessures de l'utilisateur
  bool isContraindicated(List<String> userInjuries) {
    return contraindications.any((c) => userInjuries.contains(c));
  }

  String name(String lang) => lang == 'fr' ? nameFr : nameEn;
  String description(String lang) => lang == 'fr' ? descriptionFr : descriptionEn;
  List<String> instructions(String lang) =>
      lang == 'fr' ? instructionsFr : instructionsEn;

  // Difficulté traduite
  String difficultyLabel(String lang) {
    final map = lang == 'fr'
        ? {'beginner': 'Débutant', 'intermediate': 'Intermédiaire', 'advanced': 'Avancé'}
        : {'beginner': 'Beginner', 'intermediate': 'Intermediate', 'advanced': 'Advanced'};
    return map[difficulty] ?? difficulty;
  }

  // Couleur de difficulté
  int get difficultyColor => {
    'beginner':     0xFF2ED573,
    'intermediate': 0xFFFFCA28,
    'advanced':     0xFFFF4757,
  }[difficulty] ?? 0xFF2ED573;

  // Icône de lieu
  String get locationIcon => locations.length > 1 ? '🌍'
      : locations.contains('gym') ? '🏋️' : '🏠';
}
