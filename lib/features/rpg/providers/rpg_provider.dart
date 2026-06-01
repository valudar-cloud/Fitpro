import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/rpg_model.dart';
import '../data/levels_data.dart';
import '../data/quests_data.dart';

// ════════════════════════════════════════════════════════
// PROVIDER RPG — XP, niveaux, quêtes, streaks
// ════════════════════════════════════════════════════════

final supabaseClient = Supabase.instance.client;

// ── Provider du profil RPG ────────────────────────────
final rpgProfileProvider = StreamProvider.autoDispose<RpgProfile?>((ref) {
  final userId = supabaseClient.auth.currentUser?.id;
  if (userId == null) return Stream.value(null);

  return supabaseClient
      .from('rpg_profiles')
      .stream(primaryKey: ['user_id'])
      .eq('user_id', userId)
      .map((data) => data.isEmpty ? null : RpgProfile.fromJson(data.first));
});

// ── Provider du niveau calculé ────────────────────────
final playerLevelProvider = Provider.autoDispose<PlayerLevel?>((ref) {
  final profile = ref.watch(rpgProfileProvider).valueOrNull;
  if (profile == null) return null;
  return LevelsData.fromXp(profile.totalXp);
});

// ── Provider des quêtes actives ───────────────────────
final activeQuestsProvider = FutureProvider.autoDispose<List<Quest>>((ref) async {
  final userId = supabaseClient.auth.currentUser?.id;
  if (userId == null) return [];

  final profile = ref.watch(rpgProfileProvider).valueOrNull;

  // Récupérer la progression des quêtes depuis Supabase
  final data = await supabaseClient
      .from('user_quests')
      .select()
      .eq('user_id', userId)
      .inFilter('status', ['available', 'in_progress', 'completed']);

  // Construire la map de progression
  final progressMap = <String, Map<String, dynamic>>{};
  for (final row in data) {
    progressMap[row['quest_id']] = row;
  }

  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final weekStart = todayStart.subtract(Duration(days: now.weekday - 1));

  // Construire les quêtes avec progression
  List<Quest> buildQuestsWithProgress(List<Quest> templates) {
    return templates.map((q) {
      final progress = progressMap[q.id];
      if (progress == null) return q;

      return q.copyWith(
        currentValue: progress['current_value'] ?? 0,
        status: QuestStatus.values.firstWhere(
          (s) => s.name == progress['status'],
          orElse: () => QuestStatus.available,
        ),
        completedAt: progress['completed_at'] != null
            ? DateTime.parse(progress['completed_at'])
            : null,
      );
    }).toList();
  }

  final daily = buildQuestsWithProgress(QuestsData.dailyQuests());
  final weekly = buildQuestsWithProgress(QuestsData.weeklyQuests());
  final achieves = buildQuestsWithProgress(QuestsData.achievements())
      .where((q) => q.status != QuestStatus.claimed)
      .toList();

  // Quêtes contextuelles si profil disponible
  List<Quest> contextual = [];
  if (profile != null) {
    final profileData = await supabaseClient
        .from('profiles')
        .select('goal')
        .eq('id', userId)
        .single();

    contextual = buildQuestsWithProgress(
      QuestsData.contextualQuests(
        goal: profileData['goal'] ?? 'renforcement',
        playerLevel: profile.currentLevel,
        hasInjury: false, // À récupérer depuis user_injuries
        totalSessions: profile.totalSessions,
        currentStreak: profile.currentStreak,
      ),
    );
  }

  return [...daily, ...weekly, ...contextual, ...achieves];
});

// ── Notifier principal RPG ────────────────────────────
class RpgNotifier extends AsyncNotifier<void> {

  @override
  Future<void> build() async {}

  // ─ Ajouter de l'XP ─────────────────────────────────
  Future<LevelUpResult?> addXp(String source) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return null;

    final amount = XpSource.rewards[source] ?? 0;
    if (amount <= 0) return null;

    // Récupérer le profil actuel
    final data = await supabaseClient
        .from('rpg_profiles')
        .select()
        .eq('user_id', userId)
        .single();

    final profile = RpgProfile.fromJson(data);
    final oldLevel = LevelsData.fromXp(profile.totalXp);
    final newTotalXp = profile.totalXp + amount;
    final newLevel = LevelsData.fromXp(newTotalXp);

    // Mettre à jour en BDD
    await supabaseClient.from('rpg_profiles').update({
      'total_xp': newTotalXp,
      'current_level': newLevel.level,
      'rank': newLevel.rank.name,
      'updated_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId);

    // Enregistrer dans l'historique XP
    await supabaseClient.from('xp_history').insert({
      'user_id': userId,
      'amount': amount,
      'source': source,
      'earned_at': DateTime.now().toIso8601String(),
    });

    // Level up ?
    if (newLevel.level > oldLevel.level) {
      // Bonus XP de level up
      await supabaseClient.from('rpg_profiles').update({
        'total_xp': newTotalXp + XpSource.rewards['level_up_bonus']!,
      }).eq('user_id', userId);

      return LevelUpResult(
        newLevel: newLevel.level,
        rank: newLevel.rank,
        xpGained: amount,
        bonusXp: XpSource.rewards['level_up_bonus']!,
      );
    }

    return LevelUpResult(
      newLevel: newLevel.level,
      rank: newLevel.rank,
      xpGained: amount,
      didLevelUp: false,
    );
  }

  // ─ Enregistrer une séance terminée ─────────────────
  Future<LevelUpResult?> onSessionCompleted({
    required bool allExercisesDone,
    required bool isPersonalRecord,
  }) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return null;

    int totalXp = XpSource.rewards['complete_session']!;
    if (allExercisesDone) totalXp += XpSource.rewards['all_exercises_done']!;
    if (isPersonalRecord) totalXp += XpSource.rewards['new_personal_record']!;

    // Mettre à jour le streak
    await _updateStreak(userId);

    // Mettre à jour le compteur de séances
    await supabaseClient.rpc('increment_total_sessions', params: {'uid': userId});

    // Mettre à jour les quêtes concernées
    await _updateQuestProgress(userId, 'session_completed', 1);
    if (allExercisesDone) {
      await _updateQuestProgress(userId, 'all_exercises_done', 1);
    }

    // Vérifier et accorder les XP
    return addXp('complete_session');
  }

  // ─ Enregistrer un jour de repos ────────────────────
  Future<void> onRestDayTaken({bool isActiveRecovery = false}) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return;

    final xpSource = isActiveRecovery ? 'rest_day_active' : 'rest_day_taken';

    await supabaseClient.from('rpg_profiles').update({
      'total_rest_days': supabaseClient.rpc('increment_rest_days'),
      'last_rest_day_at': DateTime.now().toIso8601String(),
    }).eq('user_id', userId);

    await _updateQuestProgress(userId, 'rest_day_taken', 1);
    await addXp(xpSource);
  }

  // ─ Collecter la récompense d'une quête ─────────────
  Future<int> claimQuestReward(Quest quest) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) return 0;
    if (quest.status != QuestStatus.completed) return 0;

    // Marquer comme réclamée
    await supabaseClient.from('user_quests').upsert({
      'user_id': userId,
      'quest_id': quest.id,
      'status': 'claimed',
      'claimed_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id, quest_id');

    // Incrémenter quests_completed
    await supabaseClient.rpc('increment_quests_completed', params: {'uid': userId});

    // Donner l'XP
    final source = 'quest_${quest.type.name}';
    await supabaseClient.from('xp_history').insert({
      'user_id': userId,
      'amount': quest.xpReward,
      'source': source,
      'quest_id': quest.id,
      'earned_at': DateTime.now().toIso8601String(),
    });

    await supabaseClient.from('rpg_profiles').update({
      'total_xp': supabaseClient.rpc('add_xp', params: {
        'uid': userId,
        'amount': quest.xpReward,
      }),
    }).eq('user_id', userId);

    return quest.xpReward;
  }

  // ─ Mise à jour du streak ────────────────────────────
  Future<void> _updateStreak(String userId) async {
    final data = await supabaseClient
        .from('rpg_profiles')
        .select('current_streak, longest_streak, last_session_at')
        .eq('user_id', userId)
        .single();

    final lastSession = data['last_session_at'] != null
        ? DateTime.parse(data['last_session_at'])
        : null;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    int newStreak = data['current_streak'] ?? 0;

    if (lastSession != null) {
      final lastDay = DateTime(lastSession.year, lastSession.month, lastSession.day);
      final diff = today.difference(lastDay).inDays;

      if (diff == 1) {
        newStreak += 1; // Continuité
      } else if (diff > 1) {
        newStreak = 1; // Streak brisé
      }
      // diff == 0 → même jour, pas de changement
    } else {
      newStreak = 1; // Première séance
    }

    final longestStreak = data['longest_streak'] ?? 0;

    await supabaseClient.from('rpg_profiles').update({
      'current_streak': newStreak,
      'longest_streak': newStreak > longestStreak ? newStreak : longestStreak,
      'last_session_at': now.toIso8601String(),
    }).eq('user_id', userId);

    // Bonus streak
    if (newStreak == 7) await addXp('streak_7_days');
    if (newStreak == 30) await addXp('streak_30_days');
  }

  // ─ Mise à jour progression quêtes ──────────────────
  Future<void> _updateQuestProgress(
    String userId,
    String trigger,
    int increment,
  ) async {
    // Récupérer les quêtes actives liées au trigger
    await supabaseClient.rpc('update_quest_progress', params: {
      'uid': userId,
      'trigger_name': trigger,
      'increment_by': increment,
    });
  }
}

final rpgNotifierProvider = AsyncNotifierProvider<RpgNotifier, void>(
  RpgNotifier.new,
);

// ── Résultat de level up ──────────────────────────────
class LevelUpResult {
  final int newLevel;
  final PlayerRank rank;
  final int xpGained;
  final int bonusXp;
  final bool didLevelUp;

  const LevelUpResult({
    required this.newLevel,
    required this.rank,
    required this.xpGained,
    this.bonusXp = 0,
    this.didLevelUp = true,
  });
}
