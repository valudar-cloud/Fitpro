import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/rpg_model.dart';

// ════════════════════════════════════════════════════════
// WIDGETS RPG
// ════════════════════════════════════════════════════════

// ── Barre d'XP animée ────────────────────────────────
class XpBarWidget extends StatelessWidget {
  final PlayerLevel levelInfo;

  const XpBarWidget({super.key, required this.levelInfo});

  @override
  Widget build(BuildContext context) {
    final rank = levelInfo.rank;
    final rankColor = Color(rank.colorValue);
    final isMax = levelInfo.level >= 50;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: rankColor.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Niveau ${levelInfo.level}',
                    style: TextStyle(
                      color: rankColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${rank.icon} ${rank.labelFr()}',
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: rankColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Text('⚡', style: TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      '${levelInfo.totalXp} XP',
                      style: TextStyle(
                        color: rankColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Barre de progression
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: levelInfo.progress,
              minHeight: 10,
              backgroundColor: const Color(0xFF2A2A2A),
              valueColor: AlwaysStoppedAnimation<Color>(rankColor),
            ),
          ).animate().scaleX(
            begin: 0,
            end: 1,
            duration: 800.ms,
            curve: Curves.easeOut,
            alignment: Alignment.centerLeft,
          ),
          const SizedBox(height: 8),
          if (!isMax)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${levelInfo.xpInCurrentLevel} / ${levelInfo.xpNeededForNextLevel} XP',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                Text(
                  '${levelInfo.xpRemainingForNextLevel} XP pour Lv ${levelInfo.level + 1}',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            )
          else
            const Center(
              child: Text(
                '☠️ Niveau maximum atteint !',
                style: TextStyle(
                  color: Color(0xFFE040FB),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Carte de quête ───────────────────────────────────
class QuestCardWidget extends StatelessWidget {
  final Quest quest;
  final VoidCallback? onClaim;

  const QuestCardWidget({super.key, required this.quest, this.onClaim});

  @override
  Widget build(BuildContext context) {
    final isCompleted = quest.status == QuestStatus.completed;
    final isClaimed   = quest.status == QuestStatus.claimed;
    final isLocked    = quest.status == QuestStatus.locked;
    final isFailed    = quest.status == QuestStatus.failed;

    Color borderColor = const Color(0xFF2A2A2A);
    if (isCompleted) borderColor = const Color(0xFF2ED573);
    if (isFailed)    borderColor = const Color(0xFF2A2A2A);
    if (isLocked)    borderColor = const Color(0xFF1A1A1A);

    return Opacity(
      opacity: isLocked || isFailed || isClaimed ? 0.5 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isCompleted ? 1.5 : 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _categoryColor(quest.category).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(quest.icon,
                      style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              // Contenu
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            quest.titleFr,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        // Badge XP
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '+${quest.xpReward} XP',
                            style: const TextStyle(
                              color: Color(0xFFFFD700),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      quest.descriptionFr,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 10),
                    // Barre de progression
                    Row(
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: quest.progress,
                              minHeight: 6,
                              backgroundColor: const Color(0xFF2A2A2A),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isCompleted
                                    ? const Color(0xFF2ED573)
                                    : _categoryColor(quest.category),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${quest.currentValue}/${quest.targetValue}',
                          style: const TextStyle(
                              color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Bouton claim
              if (isCompleted && onClaim != null) ...[
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: onClaim,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2ED573), Color(0xFF00C851)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      '🎁',
                      style: TextStyle(fontSize: 20),
                    ),
                  ).animate(
                    onPlay: (c) => c.repeat(reverse: true),
                  ).scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.05, 1.05),
                    duration: 700.ms,
                  ),
                ),
              ],
              if (isClaimed)
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('✅', style: TextStyle(fontSize: 22)),
                ),
              if (isLocked)
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text('🔒', style: TextStyle(fontSize: 20)),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _categoryColor(QuestCategory cat) {
    return const {
      QuestCategory.training:    Color(0xFFFF6B35),
      QuestCategory.recovery:    Color(0xFF4ECDC4),
      QuestCategory.consistency: Color(0xFFFFD700),
      QuestCategory.exploration: Color(0xFFAB47BC),
      QuestCategory.milestone:   Color(0xFF4CAF50),
      QuestCategory.challenge:   Color(0xFFFF4757),
    }[cat] ?? const Color(0xFF9E9E9E);
  }
}

// ── Dialog Level Up ──────────────────────────────────
class LevelUpDialog extends StatelessWidget {
  final int newLevel;
  final PlayerRank rank;
  final int xpGained;
  final int bonusXp;

  const LevelUpDialog({
    super.key,
    required this.newLevel,
    required this.rank,
    required this.xpGained,
    this.bonusXp = 0,
  });

  static Future<void> show(
    BuildContext context, {
    required int newLevel,
    required PlayerRank rank,
    required int xpGained,
    int bonusXp = 0,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => LevelUpDialog(
        newLevel: newLevel,
        rank: rank,
        xpGained: xpGained,
        bonusXp: bonusXp,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final rankColor = Color(rank.colorValue);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: rankColor, width: 2),
          boxShadow: [
            BoxShadow(
              color: rankColor.withOpacity(0.4),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(rank.icon,
                style: const TextStyle(fontSize: 64))
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 600.ms),
            const SizedBox(height: 16),
            const Text(
              '🎉 LEVEL UP !',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(),
            const SizedBox(height: 8),
            Text(
              'Niveau $newLevel',
              style: TextStyle(
                color: rankColor,
                fontSize: 36,
                fontWeight: FontWeight.w800,
              ),
            ).animate().scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: 8),
            Text(
              '${rank.icon} ${rank.labelFr()}',
              style: TextStyle(color: rankColor, fontSize: 18),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFD700).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('⚡', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: 8),
                  Text(
                    '+$xpGained XP${bonusXp > 0 ? ' + $bonusXp XP bonus' : ''}',
                    style: const TextStyle(
                      color: Color(0xFFFFD700),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Continuer 💪'),
              ),
            ),
          ],
        ),
      ).animate().scale(
        begin: const Offset(0.7, 0.7),
        end: const Offset(1.0, 1.0),
        duration: 400.ms,
        curve: Curves.elasticOut,
      ),
    );
  }
}

// ── Stats RPG rapides ────────────────────────────────
class StatsRpgWidget extends StatelessWidget {
  final RpgProfile profile;

  const StatsRpgWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBox(icon: '💪', value: '${profile.totalSessions}', label: 'Séances'),
        const SizedBox(width: 10),
        _StatBox(icon: '😴', value: '${profile.totalRestDays}', label: 'Repos'),
        const SizedBox(width: 10),
        _StatBox(icon: '✅', value: '${profile.questsCompleted}', label: 'Quêtes'),
        const SizedBox(width: 10),
        _StatBox(
          icon: '🏆',
          value: '${profile.longestStreak}j',
          label: 'Record',
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String icon, value, label;

  const _StatBox({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2A2A2A)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 16,
              ),
            ),
            Text(
              label,
              style: const TextStyle(color: Colors.white38, fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}
