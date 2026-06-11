import '../models/rpg_model.dart';

// ════════════════════════════════════════════════════════
// CATALOGUE DES QUÊTES — Quotidiennes, Hebdo, Achievements
// ════════════════════════════════════════════════════════

class QuestsData {

  // ── QUÊTES QUOTIDIENNES ─────────────────────────────
  static List<Quest> dailyQuests() => [
    const Quest(
      id: 'daily_session',
      titleFr: 'Soldat du jour',
      titleEn: 'Daily Soldier',
      descriptionFr: 'Complète 1 séance d\'entraînement aujourd\'hui',
      descriptionEn: 'Complete 1 training session today',
      icon: '⚔️',
      type: QuestType.daily,
      category: QuestCategory.training,
      xpReward: 50,
      targetValue: 1,
    ),
    const Quest(
      id: 'daily_exercises',
      titleFr: 'Triptyque',
      titleEn: 'Triptych',
      descriptionFr: 'Réalise 3 exercices différents aujourd\'hui',
      descriptionEn: 'Complete 3 different exercises today',
      icon: '🔱',
      type: QuestType.daily,
      category: QuestCategory.training,
      xpReward: 35,
      targetValue: 3,
    ),
    const Quest(
      id: 'daily_rest',
      titleFr: 'Gardien du repos',
      titleEn: 'Rest Guardian',
      descriptionFr: 'Respecte ton jour de repos prévu au programme',
      descriptionEn: 'Respect your scheduled rest day',
      icon: '😴',
      type: QuestType.daily,
      category: QuestCategory.recovery,
      xpReward: 20,
      targetValue: 1,
    ),
    const Quest(
      id: 'daily_stretching',
      titleFr: 'Serpent souple',
      titleEn: 'Flexible Serpent',
      descriptionFr: 'Fais 10 min d\'étirements (jour de repos ou non)',
      descriptionEn: 'Do 10 min of stretching (rest day or not)',
      icon: '🐍',
      type: QuestType.daily,
      category: QuestCategory.recovery,
      xpReward: 25,
      targetValue: 1,
    ),
    const Quest(
      id: 'daily_hydration',
      titleFr: 'Source de vie',
      titleEn: 'Life Spring',
      descriptionFr: 'Enregistre ta consommation d\'eau (2L min)',
      descriptionEn: 'Log your water intake (2L min)',
      icon: '💧',
      type: QuestType.daily,
      category: QuestCategory.recovery,
      xpReward: 15,
      targetValue: 1,
    ),
  ];

  // ── QUÊTES HEBDOMADAIRES ────────────────────────────
  static List<Quest> weeklyQuests() => [
    const Quest(
      id: 'weekly_sessions_3',
      titleFr: 'Trio gagnant',
      titleEn: 'Winning Trio',
      descriptionFr: 'Complète 3 séances cette semaine',
      descriptionEn: 'Complete 3 sessions this week',
      icon: '🔥',
      type: QuestType.weekly,
      category: QuestCategory.training,
      xpReward: 80,
      targetValue: 3,
    ),
    const Quest(
      id: 'weekly_sessions_5',
      titleFr: 'Machine de guerre',
      titleEn: 'War Machine',
      descriptionFr: 'Complète 5 séances cette semaine',
      descriptionEn: 'Complete 5 sessions this week',
      icon: '⚙️',
      type: QuestType.weekly,
      category: QuestCategory.training,
      xpReward: 150,
      targetValue: 5,
      requiredLevel: 5,
    ),
    const Quest(
      id: 'weekly_rest_days',
      titleFr: 'Équilibre parfait',
      titleEn: 'Perfect Balance',
      descriptionFr: 'Prends 2 jours de repos cette semaine',
      descriptionEn: 'Take 2 rest days this week',
      icon: '☯️',
      type: QuestType.weekly,
      category: QuestCategory.recovery,
      xpReward: 60,
      targetValue: 2,
    ),
    const Quest(
      id: 'weekly_new_exercise',
      titleFr: 'Explorateur',
      titleEn: 'Explorer',
      descriptionFr: 'Essaie 2 exercices que tu n\'as jamais faits',
      descriptionEn: 'Try 2 exercises you\'ve never done',
      icon: '🗺️',
      type: QuestType.weekly,
      category: QuestCategory.exploration,
      xpReward: 70,
      targetValue: 2,
    ),
    const Quest(
      id: 'weekly_full_body',
      titleFr: 'Corps complet',
      titleEn: 'Full Body',
      descriptionFr: 'Travaille 4 groupes musculaires différents cette semaine',
      descriptionEn: 'Work 4 different muscle groups this week',
      icon: '💪',
      type: QuestType.weekly,
      category: QuestCategory.training,
      xpReward: 90,
      targetValue: 4,
    ),
    const Quest(
      id: 'weekly_active_recovery',
      titleFr: 'Récupération active',
      titleEn: 'Active Recovery',
      descriptionFr: 'Fais du stretching 3 fois cette semaine',
      descriptionEn: 'Stretch 3 times this week',
      icon: '🧘',
      type: QuestType.weekly,
      category: QuestCategory.recovery,
      xpReward: 55,
      targetValue: 3,
    ),
    const Quest(
      id: 'weekly_perfect_program',
      titleFr: 'Programme respecté',
      titleEn: 'Program Respected',
      descriptionFr: 'Suis ton programme à 100% sans sauter de séance',
      descriptionEn: 'Follow your program 100% without skipping a session',
      icon: '✅',
      type: QuestType.weekly,
      category: QuestCategory.consistency,
      xpReward: 200,
      targetValue: 1,
      requiredLevel: 3,
    ),
  ];

  // ── SUCCÈS (ACHIEVEMENTS) — one-time ────────────────
  static List<Quest> achievements() => [

    // ─ Premières fois ────────────────────────────────
    const Quest(
      id: 'ach_first_session',
      titleFr: 'Premier sang',
      titleEn: 'First Blood',
      descriptionFr: 'Complète ta toute première séance',
      descriptionEn: 'Complete your very first session',
      icon: '🩸',
      type: QuestType.achievement,
      category: QuestCategory.milestone,
      xpReward: 75,
      targetValue: 1,
    ),
    const Quest(
      id: 'ach_first_rest',
      titleFr: 'La sagesse du repos',
      titleEn: 'Wisdom of Rest',
      descriptionFr: 'Prends ton premier jour de repos',
      descriptionEn: 'Take your first rest day',
      icon: '🌙',
      type: QuestType.achievement,
      category: QuestCategory.recovery,
      xpReward: 30,
      targetValue: 1,
    ),
    const Quest(
      id: 'ach_first_program',
      titleFr: 'Architecte',
      titleEn: 'Architect',
      descriptionFr: 'Crée ton premier programme personnel',
      descriptionEn: 'Create your first personal program',
      icon: '📋',
      type: QuestType.achievement,
      category: QuestCategory.milestone,
      xpReward: 50,
      targetValue: 1,
    ),

    // ─ Sessions totales ──────────────────────────────
    const Quest(
      id: 'ach_sessions_10',
      titleFr: 'Série de 10',
      titleEn: 'Series of 10',
      descriptionFr: 'Cumule 10 séances au total',
      descriptionEn: 'Accumulate 10 total sessions',
      icon: '🔟',
      type: QuestType.achievement,
      category: QuestCategory.milestone,
      xpReward: 100,
      targetValue: 10,
    ),
    const Quest(
      id: 'ach_sessions_50',
      titleFr: 'Mi-chemin',
      titleEn: 'Halfway There',
      descriptionFr: 'Cumule 50 séances au total',
      descriptionEn: 'Accumulate 50 total sessions',
      icon: '⭐',
      type: QuestType.achievement,
      category: QuestCategory.milestone,
      xpReward: 250,
      targetValue: 50,
    ),
    const Quest(
      id: 'ach_sessions_100',
      titleFr: 'Centurion',
      titleEn: 'Centurion',
      descriptionFr: '100 séances. Tu es un warrior.',
      descriptionEn: '100 sessions. You are a warrior.',
      icon: '🏛️',
      type: QuestType.achievement,
      category: QuestCategory.milestone,
      xpReward: 500,
      targetValue: 100,
    ),
    const Quest(
      id: 'ach_sessions_365',
      titleFr: 'Annuel',
      titleEn: 'Annual',
      descriptionFr: '365 séances. Une année entière de combats.',
      descriptionEn: '365 sessions. An entire year of battles.',
      icon: '📅',
      type: QuestType.achievement,
      category: QuestCategory.milestone,
      xpReward: 1500,
      targetValue: 365,
    ),

    // ─ Streaks ───────────────────────────────────────
    const Quest(
      id: 'ach_streak_7',
      titleFr: 'Semaine de feu',
      titleEn: 'Week of Fire',
      descriptionFr: 'Maintiens un streak de 7 jours actifs',
      descriptionEn: 'Maintain a 7-day active streak',
      icon: '🔥',
      type: QuestType.achievement,
      category: QuestCategory.consistency,
      xpReward: 100,
      targetValue: 7,
    ),
    const Quest(
      id: 'ach_streak_30',
      titleFr: 'Inébranlable',
      titleEn: 'Unshakeable',
      descriptionFr: '30 jours de streak. Personne ne t\'arrête.',
      descriptionEn: '30-day streak. Nobody stops you.',
      icon: '🗡️',
      type: QuestType.achievement,
      category: QuestCategory.consistency,
      xpReward: 500,
      targetValue: 30,
    ),
    const Quest(
      id: 'ach_streak_100',
      titleFr: 'Légende vivante',
      titleEn: 'Living Legend',
      descriptionFr: '100 jours consécutifs. Tu es au-dessus.',
      descriptionEn: '100 consecutive days. You are above.',
      icon: '👑',
      type: QuestType.achievement,
      category: QuestCategory.consistency,
      xpReward: 2000,
      targetValue: 100,
    ),

    // ─ Jours de repos ────────────────────────────────
    const Quest(
      id: 'ach_rest_master',
      titleFr: 'Maître du repos',
      titleEn: 'Rest Master',
      descriptionFr: 'Prends 30 jours de repos au total',
      descriptionEn: 'Take 30 rest days total',
      icon: '😌',
      type: QuestType.achievement,
      category: QuestCategory.recovery,
      xpReward: 150,
      targetValue: 30,
    ),
    const Quest(
      id: 'ach_active_recovery_10',
      titleFr: 'Récupération pro',
      titleEn: 'Pro Recovery',
      descriptionFr: 'Fais 10 séances de récupération active (étirements)',
      descriptionEn: 'Do 10 active recovery sessions (stretching)',
      icon: '🧘',
      type: QuestType.achievement,
      category: QuestCategory.recovery,
      xpReward: 120,
      targetValue: 10,
    ),

    // ─ Exploration ───────────────────────────────────
    const Quest(
      id: 'ach_explorer_20',
      titleFr: 'Grand explorateur',
      titleEn: 'Grand Explorer',
      descriptionFr: 'Essaie 20 exercices différents',
      descriptionEn: 'Try 20 different exercises',
      icon: '🗺️',
      type: QuestType.achievement,
      category: QuestCategory.exploration,
      xpReward: 200,
      targetValue: 20,
    ),
    const Quest(
      id: 'ach_all_goals',
      titleFr: 'Triple menace',
      titleEn: 'Triple Threat',
      descriptionFr: 'Complète une séance pour chacun des 3 objectifs',
      descriptionEn: 'Complete a session for each of the 3 goals',
      icon: '🎯',
      type: QuestType.achievement,
      category: QuestCategory.exploration,
      xpReward: 180,
      targetValue: 3,
    ),

    // ─ Défis spéciaux ────────────────────────────────
    const Quest(
      id: 'ach_comeback',
      titleFr: 'Le retour du roi',
      titleEn: 'Return of the King',
      descriptionFr: 'Reviens t\'entraîner après 7 jours d\'absence',
      descriptionEn: 'Return to train after 7 days of absence',
      icon: '👊',
      type: QuestType.achievement,
      category: QuestCategory.challenge,
      xpReward: 80,
      targetValue: 1,
    ),
    const Quest(
      id: 'ach_injury_overcomer',
      titleFr: 'Indestructible',
      titleEn: 'Indestructible',
      descriptionFr: 'Complète 20 séances malgré une douleur enregistrée',
      descriptionEn: 'Complete 20 sessions despite a recorded pain',
      icon: '🛡️',
      type: QuestType.achievement,
      category: QuestCategory.challenge,
      xpReward: 300,
      targetValue: 20,
    ),
    const Quest(
      id: 'ach_perfect_month',
      titleFr: 'Mois parfait',
      titleEn: 'Perfect Month',
      descriptionFr: 'Suis ton programme à 100% sur 4 semaines consécutives',
      descriptionEn: 'Follow your program 100% for 4 consecutive weeks',
      icon: '💯',
      type: QuestType.achievement,
      category: QuestCategory.challenge,
      xpReward: 600,
      targetValue: 4,
      requiredLevel: 10,
    ),

    // ─ Quêtes de jours de repos spéciales ────────────
    const Quest(
      id: 'ach_mindful_rest',
      titleFr: 'Esprit serein',
      titleEn: 'Serene Mind',
      descriptionFr: 'Fais 5 séances de méditation les jours de repos',
      descriptionEn: 'Do 5 meditation sessions on rest days',
      icon: '🧠',
      type: QuestType.achievement,
      category: QuestCategory.recovery,
      xpReward: 150,
      targetValue: 5,
    ),
    const Quest(
      id: 'ach_rest_week',
      titleFr: 'Semaine de décharge',
      titleEn: 'Deload Week',
      descriptionFr: 'Complète une semaine de décharge complète (7 jours de repos)',
      descriptionEn: 'Complete a full deload week (7 rest days in a row)',
      icon: '🔄',
      type: QuestType.achievement,
      category: QuestCategory.recovery,
      xpReward: 200,
      targetValue: 7,
      requiredLevel: 15,
    ),
  ];

  // ── QUÊTES CONTEXTUELLES (générées dynamiquement) ──
  //
  // Ces quêtes s'adaptent au profil de l'utilisateur :
  // objectif, niveau, douleurs, historique
  //
  static List<Quest> contextualQuests({
    required String goal,           // renforcement | perte_gras | prise_muscle
    required int playerLevel,
    required bool hasInjury,
    required int totalSessions,
    required int currentStreak,
  }) {
    final quests = <Quest>[];

    // Quête selon l'objectif principal
    if (goal == 'perte_gras') {
      quests.add(const Quest(
        id: 'ctx_cardio_week',
        titleFr: 'Bruler la graisse',
        titleEn: 'Burn the Fat',
        descriptionFr: 'Complète 3 séances cardio cette semaine',
        descriptionEn: 'Complete 3 cardio sessions this week',
        icon: '🏃',
        type: QuestType.weekly,
        category: QuestCategory.training,
        xpReward: 100,
        targetValue: 3,
      ));
    } else if (goal == 'prise_muscle') {
      quests.add(const Quest(
        id: 'ctx_heavy_week',
        titleFr: 'Semaine lourde',
        titleEn: 'Heavy Week',
        descriptionFr: 'Augmente tes charges sur 2 exercices cette semaine',
        descriptionEn: 'Increase your weight on 2 exercises this week',
        icon: '🏋️',
        type: QuestType.weekly,
        category: QuestCategory.training,
        xpReward: 110,
        targetValue: 2,
      ));
    } else if (goal == 'renforcement') {
      quests.add(const Quest(
        id: 'ctx_form_week',
        titleFr: 'Maîtrise technique',
        titleEn: 'Technical Mastery',
        descriptionFr: 'Réalise 2 exercices avec une technique parfaite',
        descriptionEn: 'Perform 2 exercises with perfect technique',
        icon: '🎯',
        type: QuestType.weekly,
        category: QuestCategory.training,
        xpReward: 90,
        targetValue: 2,
      ));
    }

    // Quête spéciale pour les blessures
    if (hasInjury) {
      quests.add(const Quest(
        id: 'ctx_injury_care',
        titleFr: 'Guerrier blessé',
        titleEn: 'Wounded Warrior',
        descriptionFr: 'Complète 3 séances adaptées à ta blessure sans douleur',
        descriptionEn: 'Complete 3 sessions adapted to your injury without pain',
        icon: '🩹',
        type: QuestType.weekly,
        category: QuestCategory.recovery,
        xpReward: 120,
        targetValue: 3,
      ));
    }

    // Quête de comeback si longue absence
    if (totalSessions > 10 && currentStreak == 0) {
      quests.add(const Quest(
        id: 'ctx_comeback',
        titleFr: 'Le phénix',
        titleEn: 'The Phoenix',
        descriptionFr: 'Reprends l\'entraînement — complète 2 séances cette semaine',
        descriptionEn: 'Resume training — complete 2 sessions this week',
        icon: '🔥',
        type: QuestType.weekly,
        category: QuestCategory.challenge,
        xpReward: 130,
        targetValue: 2,
      ));
    }

    // Quête de progression niveau intermédiaire
    if (playerLevel >= 5 && playerLevel < 10) {
      quests.add(const Quest(
        id: 'ctx_intermediate_challenge',
        titleFr: 'Dépasse tes limites',
        titleEn: 'Push Your Limits',
        descriptionFr: 'Essaie 1 exercice de niveau intermédiaire cette semaine',
        descriptionEn: 'Try 1 intermediate-level exercise this week',
        icon: '📈',
        type: QuestType.weekly,
        category: QuestCategory.challenge,
        xpReward: 85,
        targetValue: 1,
      ));
    }

    return quests;
  }
}
