import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../models/rpg_model.dart';
import '../providers/rpg_provider.dart';
import '../data/levels_data.dart';
import '../widgets/xp_bar_widget.dart';
import '../widgets/quest_card_widget.dart';
import '../widgets/level_up_dialog.dart';
import '../widgets/stats_rpg_widget.dart';

// ════════════════════════════════════════════════════════
// ÉCRAN RPG — Profil, XP, Quêtes, Stats
// ════════════════════════════════════════════════════════

class RpgScreen extends ConsumerStatefulWidget {
  const RpgScreen({super.key});

  @override
  ConsumerState<RpgScreen> createState() => _RpgScreenState();
}

class _RpgScreenState extends ConsumerState<RpgScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(rpgProfileProvider);
    final levelInfo = ref.watch(playerLevelProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: profileAsync.when(
        loading: () => const _RpgLoadingSkeleton(),
        error: (e, _) => Center(
          child: Text('Erreur: $e', style: const TextStyle(color: Colors.white)),
        ),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          return _buildBody(profile, levelInfo);
        },
      ),
    );
  }

  Widget _buildBody(RpgProfile profile, PlayerLevel? levelInfo) {
    return CustomScrollView(
      slivers: [
        // ─ Header RPG ──────────────────────────────────
        SliverAppBar(
          expandedHeight: 280,
          pinned: true,
          backgroundColor: const Color(0xFF0D0D0D),
          flexibleSpace: FlexibleSpaceBar(
            background: _RpgHeader(profile: profile, levelInfo: levelInfo),
          ),
        ),

        // ─ XP Bar ──────────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: levelInfo != null
                ? XpBarWidget(levelInfo: levelInfo)
                : const SizedBox.shrink(),
          ),
        ),

        // ─ Stats rapides ───────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: StatsRpgWidget(profile: profile),
          ),
        ),

        // ─ Onglets Quêtes ─────────────────────────────
        SliverPersistentHeader(
          pinned: true,
          delegate: _TabBarDelegate(
            tabBar: TabBar(
              controller: _tabController,
              labelColor: const Color(0xFFFF6B35),
              unselectedLabelColor: Colors.white38,
              indicatorColor: const Color(0xFFFF6B35),
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: 'QUOTIDIEN'),
                Tab(text: 'HEBDO'),
                Tab(text: 'SUCCÈS'),
              ],
            ),
          ),
        ),

        // ─ Contenu des quêtes ──────────────────────────
        SliverFillRemaining(
          child: TabBarView(
            controller: _tabController,
            children: [
              _QuestList(type: QuestType.daily),
              _QuestList(type: QuestType.weekly),
              _QuestList(type: QuestType.achievement),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Header RPG avec rang et avatar ───────────────────
class _RpgHeader extends StatelessWidget {
  final RpgProfile profile;
  final PlayerLevel? levelInfo;

  const _RpgHeader({required this.profile, this.levelInfo});

  @override
  Widget build(BuildContext context) {
    final rank = levelInfo?.rank ?? PlayerRank.initie;
    final rankColor = Color(rank.colorValue);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            rankColor.withOpacity(0.3),
            const Color(0xFF0D0D0D),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Avatar avec anneau de rang
            Stack(
              alignment: Alignment.center,
              children: [
                // Anneau animé
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: rankColor, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: rankColor.withOpacity(0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                ),
                // Avatar
                CircleAvatar(
                  radius: 50,
                  backgroundColor: const Color(0xFF1A1A2E),
                  child: Text(
                    rank.icon,
                    style: const TextStyle(fontSize: 40),
                  ),
                ),
                // Badge niveau
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: rankColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: rankColor.withOpacity(0.6),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      'LV ${levelInfo?.level ?? 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ).animate().scale(duration: 600.ms, curve: Curves.elasticOut),

            const SizedBox(height: 16),

            // Titre de rang
            Text(
              '${rank.icon} ${rank.labelFr()}',
              style: TextStyle(
                color: rankColor,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
              ),
            ).animate().fadeIn(delay: 200.ms),

            // Streak
            if (profile.currentStreak > 0)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B35).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFFF6B35).withOpacity(0.4),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        '${profile.currentStreak} jours de streak',
                        style: const TextStyle(
                          color: Color(0xFFFF6B35),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(delay: 400.ms),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Liste des quêtes par type ─────────────────────────
class _QuestList extends ConsumerWidget {
  final QuestType type;

  const _QuestList({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final questsAsync = ref.watch(activeQuestsProvider);

    return questsAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
      ),
      error: (e, _) => Center(
        child: Text('Erreur: $e', style: const TextStyle(color: Colors.white54)),
      ),
      data: (quests) {
        final filtered = quests
            .where((q) => q.type == type)
            .toList()
          ..sort((a, b) {
            // Ordre : completed > in_progress > available > locked > claimed
            final order = {
              QuestStatus.completed: 0,
              QuestStatus.inProgress: 1,
              QuestStatus.available: 2,
              QuestStatus.locked: 3,
              QuestStatus.claimed: 4,
              QuestStatus.failed: 5,
            };
            return (order[a.status] ?? 2).compareTo(order[b.status] ?? 2);
          });

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('✅', style: TextStyle(fontSize: 48)),
                const SizedBox(height: 12),
                Text(
                  type == QuestType.daily
                      ? 'Toutes les quêtes du jour sont terminées !'
                      : type == QuestType.weekly
                          ? 'Toutes les quêtes de la semaine sont terminées !'
                          : 'Continue à progresser pour débloquer des succès',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 14),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: filtered.length,
          itemBuilder: (context, index) => QuestCardWidget(
            quest: filtered[index],
            onClaim: () async {
              final xp = await ref
                  .read(rpgNotifierProvider.notifier)
                  .claimQuestReward(filtered[index]);

              if (context.mounted && xp > 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Text('⚡ '),
                        Text('+$xp XP gagné !'),
                      ],
                    ),
                    backgroundColor: const Color(0xFFFF6B35),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              }
            },
          ).animate(delay: (index * 80).ms).slideX(begin: 0.3).fadeIn(),
        );
      },
    );
  }
}

// ── Tab Bar Delegate ──────────────────────────────────
class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  _TabBarDelegate({required this.tabBar});

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: const Color(0xFF0D0D0D),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(covariant SliverPersistentHeaderDelegate oldDelegate) => false;
}

// ── Skeleton loading ──────────────────────────────────
class _RpgLoadingSkeleton extends StatelessWidget {
  const _RpgLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFFF6B35)),
    );
  }
}
