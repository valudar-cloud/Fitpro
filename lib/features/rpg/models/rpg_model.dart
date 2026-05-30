// ════════════════════════════════════════════════════════
// MODÈLES RPG — XP, Niveaux, Quêtes
// ════════════════════════════════════════════════════════

// ── Rangs / Titres ────────────────────────────────────
enum PlayerRank {
  initie,       // Lv 1-2
  novice,       // Lv 3-4
  apprenti,     // Lv 5-6
  guerrier,     // Lv 7-9
  athlete,      // Lv 10-14
  champion,     // Lv 15-19
  expert,       // Lv 20-24
  maitre,       // Lv 25-29
  grandMaitre,  // Lv 30-39
  legende,      // Lv 40-49
  immortel,     // Lv 50
}

extension PlayerRankExt on PlayerRank {
  String labelFr() => const {
    PlayerRank.initie: 'Initié',
    PlayerRank.novice: 'Novice',
    PlayerRank.apprenti: 'Apprenti',
    PlayerRank.guerrier: 'Guerrier',
    PlayerRank.athlete: 'Athlète',
    PlayerRank.champion: 'Champion',
    PlayerRank.expert: 'Expert',
    PlayerRank.maitre: 'Maître',
    PlayerRank.grandMaitre: 'Grand Maître',
    PlayerRank.legende: 'Légende',
    PlayerRank.immortel: '☠ Immortel',
  }[this]!;

  String labelEn() => const {
    PlayerRank.initie: 'Initiate',
    PlayerRank.novice: 'Novice',
    PlayerRank.apprenti: 'Apprentice',
    PlayerRank.guerrier: 'Warrior',
    PlayerRank.athlete: 'Athlete',
    PlayerRank.champion: 'Champion',
    PlayerRank.expert: 'Expert',
    PlayerRank.maitre: 'Master',
    PlayerRank.grandMaitre: 'Grand Master',
    PlayerRank.legende: 'Legend',
    PlayerRank.immortel: '☠ Immortal',
  }[this]!;

  String get icon => const {
    PlayerRank.initie: '🌱',
    PlayerRank.novice: '⚡',
    PlayerRank.apprenti: '🔥',
    PlayerRank.guerrier: '⚔️',
    PlayerRank.athlete: '🏃',
    PlayerRank.champion: '🏆',
    PlayerRank.expert: '💎',
    PlayerRank.maitre: '👑',
    PlayerRank.grandMaitre: '🌟',
    PlayerRank.legende: '🦅',
    PlayerRank.immortel: '☠️',
  }[this]!;

  // Couleur associée au rang
  int get colorValue => const {
    PlayerRank.initie: 0xFF78909C,
    PlayerRank.novice: 0xFF66BB6A,
    PlayerRank.apprenti: 0xFF29B6F6,
    PlayerRank.guerrier: 0xFFAB47BC,
    PlayerRank.athlete: 0xFFFF7043,
    PlayerRank.champion: 0xFFFFCA28,
    PlayerRank.expert: 0xFF26C6DA,
    PlayerRank.maitre: 0xFFEC407A,
    PlayerRank.grandMaitre: 0xFFEF5350,
    PlayerRank.legende: 0xFFFFD700,
    PlayerRank.immortel: 0xFFE040FB,
  }[this]!;
}

// ── Niveau ────────────────────────────────────────────
class PlayerLevel {
  final int level;
  final int totalXp;          // XP totale accumulée
  final int xpForCurrentLevel; // XP au début du niveau actuel
  final int xpForNextLevel;   // XP nécessaire pour le prochain niveau
  final PlayerRank rank;

  const PlayerLevel({
    required this.level,
    required this.totalXp,
    required this.xpForCurrentLevel,
    required this.xpForNextLevel,
    required this.rank,
  });

  /// Progression dans le niveau actuel (0.0 → 1.0)
  double get progress {
    if (level >= 50) return 1.0;
    final needed = xpForNextLevel - xpForCurrentLevel;
    final current = totalXp - xpForCurrentLevel;
    return (current / needed).clamp(0.0, 1.0);
  }

  int get xpInCurrentLevel => totalXp - xpForCurrentLevel;
  int get xpNeededForNextLevel => xpForNextLevel - xpForCurrentLevel;
  int get xpRemainingForNextLevel => xpForNextLevel - totalXp;
}

// ── Types de quêtes ───────────────────────────────────
enum QuestType {
  daily,      // Se réinitialise chaque jour
  weekly,     // Se réinitialise chaque semaine
  monthly,    // Se réinitialise chaque mois
  achievement, // Une seule fois, permanent
}

enum QuestCategory {
  training,   // Séances, exercices
  recovery,   // Jours de repos, étirements
  consistency, // Régularité, streaks
  exploration, // Découvrir nouveaux exercices
  milestone,   // Jalons (niveaux, sessions totales)
  challenge,   // Défis spéciaux
}

enum QuestStatus {
  locked,     // Pas encore débloquée (niveau requis)
  available,  // Disponible
  inProgress, // En cours
  completed,  // Terminée, XP à collecter
  claimed,    // XP déjà récupérée
  failed,     // Expirée sans être complétée (daily/weekly)
}

// ── Quête ─────────────────────────────────────────────
class Quest {
  final String id;
  final String titleFr;
  final String titleEn;
  final String descriptionFr;
  final String descriptionEn;
  final String icon;
  final QuestType type;
  final QuestCategory category;
  final int xpReward;
  final int targetValue;         // Valeur cible (ex: 3 séances)
  final int currentValue;        // Progression actuelle
  final QuestStatus status;
  final int requiredLevel;       // Niveau min pour débloquer
  final DateTime? expiresAt;
  final DateTime? completedAt;
  final List<String> conditions; // Conditions en texte lisible

  const Quest({
    required this.id,
    required this.titleFr,
    required this.titleEn,
    required this.descriptionFr,
    required this.descriptionEn,
    required this.icon,
    required this.type,
    required this.category,
    required this.xpReward,
    required this.targetValue,
    this.currentValue = 0,
    this.status = QuestStatus.available,
    this.requiredLevel = 1,
    this.expiresAt,
    this.completedAt,
    this.conditions = const [],
  });

  double get progress => (currentValue / targetValue).clamp(0.0, 1.0);
  bool get isCompleted => currentValue >= targetValue;
  bool get isExpired => expiresAt != null && DateTime.now().isAfter(expiresAt!);

  Quest copyWith({
    int? currentValue,
    QuestStatus? status,
    DateTime? completedAt,
  }) {
    return Quest(
      id: id,
      titleFr: titleFr,
      titleEn: titleEn,
      descriptionFr: descriptionFr,
      descriptionEn: descriptionEn,
      icon: icon,
      type: type,
      category: category,
      xpReward: xpReward,
      targetValue: targetValue,
      currentValue: currentValue ?? this.currentValue,
      status: status ?? this.status,
      requiredLevel: requiredLevel,
      expiresAt: expiresAt,
      completedAt: completedAt ?? this.completedAt,
      conditions: conditions,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'current_value': currentValue,
    'status': status.name,
    'completed_at': completedAt?.toIso8601String(),
  };
}

// ── Sources de XP ─────────────────────────────────────
class XpSource {
  final String labelFr;
  final String labelEn;
  final int amount;
  final String icon;
  final DateTime earnedAt;

  const XpSource({
    required this.labelFr,
    required this.labelEn,
    required this.amount,
    required this.icon,
    required this.earnedAt,
  });

  static const Map<String, int> rewards = {
    'complete_session': 50,        // Séance terminée
    'all_exercises_done': 25,      // Tous les exercices faits
    'rest_day_taken': 15,          // Jour de repos respecté
    'rest_day_active': 20,         // Récupération active (étirements)
    'streak_7_days': 100,          // Streak 7 jours
    'streak_30_days': 500,         // Streak 30 jours
    'new_personal_record': 30,     // Nouveau record perso
    'first_session': 75,           // Première séance
    'quest_daily': 30,             // Quête quotidienne
    'quest_weekly': 80,            // Quête hebdomadaire
    'quest_achievement': 200,      // Succès permanent
    'level_up_bonus': 50,          // Bonus de level up
    'perfect_week': 150,           // Semaine parfaite (tous les jours prévus)
    'comeback': 40,                // Retour après 7j d'absence
  };
}

// ── Profil RPG complet ────────────────────────────────
class RpgProfile {
  final String userId;
  final int totalXp;
  final int currentLevel;
  final PlayerRank rank;
  final int currentStreak;    // Jours consécutifs
  final int longestStreak;
  final int totalSessions;
  final int totalRestDays;
  final int questsCompleted;
  final List<String> unlockedBadges;
  final DateTime lastSessionAt;
  final DateTime? lastRestDayAt;

  const RpgProfile({
    required this.userId,
    required this.totalXp,
    required this.currentLevel,
    required this.rank,
    required this.currentStreak,
    required this.longestStreak,
    required this.totalSessions,
    required this.totalRestDays,
    required this.questsCompleted,
    required this.unlockedBadges,
    required this.lastSessionAt,
    this.lastRestDayAt,
  });

  factory RpgProfile.fromJson(Map<String, dynamic> json) => RpgProfile(
    userId: json['user_id'],
    totalXp: json['total_xp'] ?? 0,
    currentLevel: json['current_level'] ?? 1,
    rank: PlayerRank.values.firstWhere(
      (r) => r.name == (json['rank'] ?? 'initie'),
      orElse: () => PlayerRank.initie,
    ),
    currentStreak: json['current_streak'] ?? 0,
    longestStreak: json['longest_streak'] ?? 0,
    totalSessions: json['total_sessions'] ?? 0,
    totalRestDays: json['total_rest_days'] ?? 0,
    questsCompleted: json['quests_completed'] ?? 0,
    unlockedBadges: List<String>.from(json['unlocked_badges'] ?? []),
    lastSessionAt: DateTime.parse(json['last_session_at'] ?? DateTime.now().toIso8601String()),
    lastRestDayAt: json['last_rest_day_at'] != null
        ? DateTime.parse(json['last_rest_day_at'])
        : null,
  );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'total_xp': totalXp,
    'current_level': currentLevel,
    'rank': rank.name,
    'current_streak': currentStreak,
    'longest_streak': longestStreak,
    'total_sessions': totalSessions,
    'total_rest_days': totalRestDays,
    'quests_completed': questsCompleted,
    'unlocked_badges': unlockedBadges,
    'last_session_at': lastSessionAt.toIso8601String(),
    'last_rest_day_at': lastRestDayAt?.toIso8601String(),
  };
}
