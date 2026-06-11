import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_strings.dart';

// ════════════════════════════════════════════════════════
// ONBOARDING — 3 étapes : Objectif → Lieu → Douleurs
// ════════════════════════════════════════════════════════

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Sélections
  String? _selectedGoal;
  String? _selectedLocation;
  final Set<String> _selectedInjuries = {};
  bool _isSaving = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: AppConstants.animNormal,
        curve: Curves.easeInOut,
      );
    } else {
      _save();
    }
  }

  bool _canProceed() {
    if (_currentPage == 0) return _selectedGoal != null;
    if (_currentPage == 1) return _selectedLocation != null;
    return true; // Les douleurs sont optionnelles
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      // Sauvegarder le profil
      await Supabase.instance.client.from('profiles').update({
        'goal': _selectedGoal,
        'workout_location': _selectedLocation,
        'onboarding_completed': true,
      }).eq('id', userId);

      // Sauvegarder les blessures
      if (_selectedInjuries.isNotEmpty) {
        final injuries = _selectedInjuries.map((zone) => {
          'user_id': userId,
          'injury_zone': zone,
          'severity': 'mild',
        }).toList();
        await Supabase.instance.client.from('user_injuries').insert(injuries);
      }

      // Créer le profil RPG initial
      await Supabase.instance.client.from('rpg_profiles').upsert({
        'user_id': userId,
        'total_xp': 75, // Bonus première connexion
        'current_level': 1,
        'rank': 'initie',
        'current_streak': 0,
        'longest_streak': 0,
        'total_sessions': 0,
        'total_rest_days': 0,
        'quests_completed': 0,
        'last_session_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id');

      if (mounted) context.go(AppConstants.routeHome);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erreur lors de la sauvegarde'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: Column(
          children: [
            // ─ Indicateur de progression ─────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentPage > 0)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => _pageController.previousPage(
                        duration: AppConstants.animNormal,
                        curve: Curves.easeInOut,
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  AnimatedSmoothIndicator(
                    activeIndex: _currentPage,
                    count: 3,
                    effect: const WormEffect(
                      activeDotColor: AppTheme.primary,
                      dotColor: AppTheme.border,
                      dotHeight: 8,
                      dotWidth: 24,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go(AppConstants.routeHome),
                    child: Text(s.skipBtn,
                        style: const TextStyle(color: AppTheme.textSecondary)),
                  ),
                ],
              ),
            ),

            // ─ Pages ─────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _GoalPage(
                    selected: _selectedGoal,
                    onSelect: (g) => setState(() => _selectedGoal = g),
                  ),
                  _LocationPage(
                    selected: _selectedLocation,
                    onSelect: (l) => setState(() => _selectedLocation = l),
                  ),
                  _InjuriesPage(
                    selected: _selectedInjuries,
                    onToggle: (zone) => setState(() {
                      if (_selectedInjuries.contains(zone)) {
                        _selectedInjuries.remove(zone);
                      } else {
                        _selectedInjuries.add(zone);
                      }
                    }),
                  ),
                ],
              ),
            ),

            // ─ Bouton suivant ────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
              child: ElevatedButton(
                onPressed: _canProceed() && !_isSaving ? _next : null,
                child: _isSaving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(_currentPage < 2 ? s.continueBtn : s.startBtn),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Page 1 : Objectif ────────────────────────────────
class _GoalPage extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _GoalPage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('🎯', style: TextStyle(fontSize: 48))
              .animate().scale(duration: 500.ms, curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text('Quel est ton\nobjectif principal ?',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 8),
          Text('Tu pourras le changer à tout moment.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 40),
          ...[
            _GoalOption(
              id: AppConstants.goalRenforcement,
              icon: '💪',
              title: 'Renforcement musculaire',
              subtitle: 'Tonifier, renforcer, sculpter',
              color: const Color(0xFF4ECDC4),
              selected: selected,
              onSelect: onSelect,
            ),
            const SizedBox(height: 14),
            _GoalOption(
              id: AppConstants.goalPerteGras,
              icon: '🔥',
              title: 'Perte de graisse',
              subtitle: 'Brûler les calories, affiner',
              color: const Color(0xFFFF6B35),
              selected: selected,
              onSelect: onSelect,
            ),
            const SizedBox(height: 14),
            _GoalOption(
              id: AppConstants.goalPriseMuscle,
              icon: '🏋️',
              title: 'Prise de masse',
              subtitle: 'Développer, grossir, muscler',
              color: const Color(0xFFAB47BC),
              selected: selected,
              onSelect: onSelect,
            ),
          ].animate(interval: 100.ms).slideX(begin: 0.3).fadeIn(),
        ],
      ),
    );
  }
}

class _GoalOption extends StatelessWidget {
  final String id, icon, title, subtitle;
  final Color color;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _GoalOption({
    required this.id, required this.icon, required this.title,
    required this.subtitle, required this.color,
    required this.selected, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == id;
    return GestureDetector(
      onTap: () => onSelect(id),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.15) : AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? color : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? color : Colors.white,
                      )),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: color, size: 24),
          ],
        ),
      ),
    );
  }
}

// ── Page 2 : Lieu ─────────────────────────────────────
class _LocationPage extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelect;

  const _LocationPage({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('📍', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('Où tu t\'entraînes ?',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 8),
          Text('Tes exercices s\'adapteront à ton lieu.',
              style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 40),
          _LocationCard(id: 'gym', icon: '🏋️', title: 'Salle de sport',
              subtitle: 'Accès aux machines et poids libres',
              selected: selected, onSelect: onSelect),
          const SizedBox(height: 14),
          _LocationCard(id: 'home', icon: '🏠', title: 'À la maison',
              subtitle: 'Avec ou sans équipement',
              selected: selected, onSelect: onSelect),
          const SizedBox(height: 14),
          _LocationCard(id: 'both', icon: '🌍', title: 'Les deux',
              subtitle: 'Gym et maison selon mes jours',
              selected: selected, onSelect: onSelect),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final String id, icon, title, subtitle;
  final String? selected;
  final ValueChanged<String> onSelect;

  const _LocationCard({
    required this.id, required this.icon, required this.title,
    required this.subtitle, required this.selected, required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == id;
    return GestureDetector(
      onTap: () => onSelect(id),
      child: AnimatedContainer(
        duration: AppConstants.animFast,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.15)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? AppTheme.primary : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 36)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected ? AppTheme.primary : Colors.white,
                      )),
                  Text(subtitle,
                      style: const TextStyle(
                          color: AppTheme.textSecondary, fontSize: 13)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}

// ── Page 3 : Douleurs / Blessures ────────────────────
class _InjuriesPage extends StatelessWidget {
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _InjuriesPage({required this.selected, required this.onToggle});

  static const List<Map<String, String>> _zones = [
    {'id': 'neck',           'label': 'Nuque / Cou',       'icon': '🔴'},
    {'id': 'shoulder_left',  'label': 'Épaule gauche',     'icon': '🔴'},
    {'id': 'shoulder_right', 'label': 'Épaule droite',     'icon': '🔴'},
    {'id': 'elbow_left',     'label': 'Coude gauche',      'icon': '🟠'},
    {'id': 'elbow_right',    'label': 'Coude droit',       'icon': '🟠'},
    {'id': 'wrist_left',     'label': 'Poignet gauche',    'icon': '🟠'},
    {'id': 'wrist_right',    'label': 'Poignet droit',     'icon': '🟠'},
    {'id': 'back_upper',     'label': 'Dos haut',          'icon': '🔴'},
    {'id': 'back_lower',     'label': 'Bas du dos',        'icon': '🔴'},
    {'id': 'hip',            'label': 'Hanche',            'icon': '🟠'},
    {'id': 'knee_left',      'label': 'Genou gauche',      'icon': '🔴'},
    {'id': 'knee_right',     'label': 'Genou droit',       'icon': '🔴'},
    {'id': 'ankle_left',     'label': 'Cheville gauche',   'icon': '🟡'},
    {'id': 'ankle_right',    'label': 'Cheville droite',   'icon': '🟡'},
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text('🩹', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text('As-tu des douleurs\nou blessures ?',
              style: Theme.of(context).textTheme.displayMedium),
          const SizedBox(height: 8),
          Text(
            'Les exercices contre-indiqués seront signalés ou masqués.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.8,
              ),
              itemCount: _zones.length,
              itemBuilder: (context, i) {
                final zone = _zones[i];
                final isSelected = selected.contains(zone['id']);
                return GestureDetector(
                  onTap: () => onToggle(zone['id']!),
                  child: AnimatedContainer(
                    duration: AppConstants.animFast,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.danger.withOpacity(0.15)
                          : AppTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? AppTheme.danger : AppTheme.border,
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const SizedBox(width: 10),
                        Text(zone['icon']!,
                            style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            zone['label']!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isSelected
                                  ? AppTheme.danger
                                  : Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (selected.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '⚠️ ${selected.length} zone(s) sélectionnée(s) — tes exercices seront filtrés',
                style: const TextStyle(
                    color: AppTheme.danger, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
}
