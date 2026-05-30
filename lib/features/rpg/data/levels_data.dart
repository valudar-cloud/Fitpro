import '../models/rpg_model.dart';

// ════════════════════════════════════════════════════════
// TABLE DES NIVEAUX — Courbe d'XP progressive (style RPG)
// ════════════════════════════════════════════════════════
//
// Formule : xp_niveau_n = 100 * n * (1 + 0.15 * n)
// Résultat : progression douce au début, challenge en fin
//
class LevelsData {

  /// XP totale requise pour ATTEINDRE chaque niveau
  static const List<int> _xpThresholds = [
    0,      // Lv 1  — Début
    100,    // Lv 2
    250,    // Lv 3
    460,    // Lv 4
    730,    // Lv 5
    1075,   // Lv 6
    1505,   // Lv 7
    2030,   // Lv 8
    2665,   // Lv 9
    3420,   // Lv 10
    4310,   // Lv 11
    5350,   // Lv 12
    6550,   // Lv 13
    7925,   // Lv 14
    9490,   // Lv 15
    11260,  // Lv 16
    13250,  // Lv 17
    15475,  // Lv 18
    17950,  // Lv 19
    20690,  // Lv 20
    23710,  // Lv 21
    27025,  // Lv 22
    30650,  // Lv 23
    34600,  // Lv 24
    38890,  // Lv 25
    43540,  // Lv 26
    48560,  // Lv 27
    53965,  // Lv 28
    59770,  // Lv 29
    65990,  // Lv 30
    72640,  // Lv 31
    79730,  // Lv 32
    87275,  // Lv 33
    95285,  // Lv 34
    103775, // Lv 35
    112760, // Lv 36
    122250, // Lv 37
    132260, // Lv 38
    142800, // Lv 39
    153885, // Lv 40
    165525, // Lv 41
    177730, // Lv 42
    190510, // Lv 43
    203875, // Lv 44
    217835, // Lv 45
    232400, // Lv 46
    247580, // Lv 47
    263385, // Lv 48
    279825, // Lv 49
    296910, // Lv 50 — MAX
  ];

  static const int maxLevel = 50;

  /// Calcule le niveau et les infos complètes depuis l'XP totale
  static PlayerLevel fromXp(int totalXp) {
    int level = 1;

    for (int i = 1; i < _xpThresholds.length; i++) {
      if (totalXp >= _xpThresholds[i]) {
        level = i + 1;
      } else {
        break;
      }
    }

    level = level.clamp(1, maxLevel);

    final xpForCurrent = _xpThresholds[level - 1];
    final xpForNext = level >= maxLevel
        ? _xpThresholds[maxLevel - 1]
        : _xpThresholds[level];

    return PlayerLevel(
      level: level,
      totalXp: totalXp,
      xpForCurrentLevel: xpForCurrent,
      xpForNextLevel: xpForNext,
      rank: _rankForLevel(level),
    );
  }

  /// Rang associé à un niveau
  static PlayerRank _rankForLevel(int level) {
    if (level >= 50) return PlayerRank.immortel;
    if (level >= 40) return PlayerRank.legende;
    if (level >= 30) return PlayerRank.grandMaitre;
    if (level >= 25) return PlayerRank.maitre;
    if (level >= 20) return PlayerRank.expert;
    if (level >= 15) return PlayerRank.champion;
    if (level >= 10) return PlayerRank.athlete;
    if (level >= 7)  return PlayerRank.guerrier;
    if (level >= 5)  return PlayerRank.apprenti;
    if (level >= 3)  return PlayerRank.novice;
    return PlayerRank.initie;
  }

  /// XP requise pour passer au prochain niveau
  static int xpToNextLevel(int currentLevel) {
    if (currentLevel >= maxLevel) return 0;
    return _xpThresholds[currentLevel] - _xpThresholds[currentLevel - 1];
  }

  /// Messages de level up (FR + EN)
  static Map<String, String> levelUpMessage(int newLevel, bool isFr) {
    final messages = isFr ? _levelUpFr : _levelUpEn;
    final rank = _rankForLevel(newLevel);

    return {
      'title': isFr
          ? '🎉 Niveau $newLevel atteint !'
          : '🎉 Level $newLevel reached!',
      'subtitle': isFr
          ? 'Tu es maintenant ${rank.icon} ${rank.labelFr()}'
          : 'You are now ${rank.icon} ${rank.labelEn()}',
      'message': messages[newLevel] ?? (isFr
          ? 'Continue sur ta lancée, tu es inarrêtable !'
          : 'Keep going, you\'re unstoppable!'),
    };
  }

  static const Map<int, String> _levelUpFr = {
    2:  'Les premiers pas sont toujours les plus importants. Bravo !',
    3:  'Tu commences à prendre tes marques. Continue !',
    5:  'Apprenti confirmé ! Tes muscles commencent à mémoriser les mouvements.',
    7:  'Guerrier en formation ! Tu n\'abandonnes pas, c\'est ça qui compte.',
    10: '🏃 Athlète ! Tu as atteint un cap important. 10 niveaux parcourus !',
    15: '🏆 Champion ! La régularité est ta plus grande force.',
    20: '💎 Expert ! 20 niveaux... tu fais partie de l\'élite.',
    25: '👑 Maître ! Peu de gens atteignent ce niveau. Respect.',
    30: '🌟 Grand Maître ! Ton corps est une machine bien huilée.',
    40: '🦅 Légende ! Ton parcours inspire les autres.',
    50: '☠️ IMMORTEL ! Le sommet absolu. Tu es dans la légende.',
  };

  static const Map<int, String> _levelUpEn = {
    2:  'First steps are always the most important. Well done!',
    3:  'You\'re finding your rhythm. Keep it up!',
    5:  'Confirmed Apprentice! Your muscles are learning the moves.',
    7:  'Warrior in training! Not giving up is what counts.',
    10: '🏃 Athlete! You\'ve hit a major milestone. 10 levels done!',
    15: '🏆 Champion! Consistency is your greatest strength.',
    20: '💎 Expert! 20 levels... you\'re part of the elite.',
    25: '👑 Master! Few people reach this level. Respect.',
    30: '🌟 Grand Master! Your body is a well-oiled machine.',
    40: '🦅 Legend! Your journey inspires others.',
    50: '☠️ IMMORTAL! The absolute summit. You are the legend.',
  };

  /// Paliers de niveaux avec récompenses spéciales
  static const Map<int, Map<String, dynamic>> levelRewards = {
    5:  {'type': 'unlock_exercises', 'value': 'intermediate', 'icon': '🔓'},
    10: {'type': 'unlock_challenge_mode', 'icon': '⚡'},
    15: {'type': 'custom_avatar_frame', 'icon': '🖼️'},
    20: {'type': 'unlock_exercises', 'value': 'advanced', 'icon': '🔓'},
    25: {'type': 'premium_trial', 'value': 7, 'icon': '👑'},
    30: {'type': 'special_badge', 'value': 'iron_will', 'icon': '🏅'},
    40: {'type': 'special_badge', 'value': 'legend_badge', 'icon': '🦅'},
    50: {'type': 'special_badge', 'value': 'immortal_badge', 'icon': '☠️'},
  };
}
