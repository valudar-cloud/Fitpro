// ════════════════════════════════════════════════════════
// MODÈLE ABSTINENCE
// ════════════════════════════════════════════════════════

class AbstinenceTracker {
  final String id;
  final String userId;
  final String name;
  final String icon;
  final String category;
  final DateTime startDate;
  final bool isActive;
  final String? customNote;
  final DateTime createdAt;

  const AbstinenceTracker({
    required this.id,
    required this.userId,
    required this.name,
    required this.icon,
    required this.category,
    required this.startDate,
    this.isActive = true,
    this.customNote,
    required this.createdAt,
  });

  // ── Durée depuis le début ─────────────────────────────
  Duration get elapsed => DateTime.now().difference(startDate);

  int get days    => elapsed.inDays;
  int get hours   => elapsed.inHours % 24;
  int get minutes => elapsed.inMinutes % 60;
  int get seconds => elapsed.inSeconds % 60;

  String get elapsedLabel {
    if (days > 0) return '$days j ${hours}h';
    if (hours > 0) return '${hours}h ${minutes}min';
    return '${minutes}min ${seconds}s';
  }

  // Score de progression (0-100)
  double progressScore(int targetDays) =>
      (days / targetDays).clamp(0.0, 1.0);

  factory AbstinenceTracker.fromJson(Map<String, dynamic> j) =>
      AbstinenceTracker(
        id: j['id'],
        userId: j['user_id'],
        name: j['name'],
        icon: j['icon'] ?? '🚫',
        category: j['category'] ?? 'custom',
        startDate: DateTime.parse(j['start_date']),
        isActive: j['is_active'] ?? true,
        customNote: j['custom_note'],
        createdAt: DateTime.parse(j['created_at']),
      );

  Map<String, dynamic> toJson() => {
    'user_id': userId,
    'name': name,
    'icon': icon,
    'category': category,
    'start_date': startDate.toIso8601String(),
    'is_active': isActive,
    'custom_note': customNote,
  };

  AbstinenceTracker copyWith({
    String? name, String? icon, DateTime? startDate,
    bool? isActive, String? customNote,
  }) => AbstinenceTracker(
    id: id, userId: userId,
    name: name ?? this.name,
    icon: icon ?? this.icon,
    category: category,
    startDate: startDate ?? this.startDate,
    isActive: isActive ?? this.isActive,
    customNote: customNote ?? this.customNote,
    createdAt: createdAt,
  );
}

// ── Données d'un template d'abstinence ───────────────
class AbstinenceTemplate {
  final String id;
  final String category;
  final String icon;
  final String nameFr;
  final String nameEn;
  final String descriptionFr;
  final int targetDays;           // Objectif recommandé en jours
  final List<AbstinenceBenefit> benefits;

  const AbstinenceTemplate({
    required this.id,
    required this.category,
    required this.icon,
    required this.nameFr,
    required this.nameEn,
    required this.descriptionFr,
    required this.targetDays,
    required this.benefits,
  });
}

// ── Bienfait à un moment précis ──────────────────────
class AbstinenceBenefit {
  final int afterMinutes; // Délai en minutes depuis l'arrêt
  final String emoji;
  final String titleFr;
  final String descFr;

  const AbstinenceBenefit({
    required this.afterMinutes,
    required this.emoji,
    required this.titleFr,
    required this.descFr,
  });

  bool isUnlocked(Duration elapsed) =>
      elapsed.inMinutes >= afterMinutes;

  String get timeLabel {
    if (afterMinutes < 60) return '$afterMinutes min';
    if (afterMinutes < 1440) return '${afterMinutes ~/ 60}h';
    if (afterMinutes < 10080) return '${afterMinutes ~/ 1440}j';
    if (afterMinutes < 43200) return '${afterMinutes ~/ 10080} sem';
    return '${afterMinutes ~/ 43200} mois';
  }
}
