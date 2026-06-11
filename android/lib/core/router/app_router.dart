import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/register_screen.dart';
import '../../features/onboarding/screens/onboarding_screen.dart';
import '../../features/home/screens/home_screen.dart';
import '../../features/exercises/screens/exercises_screen.dart';
import '../../features/exercises/screens/exercise_detail_screen.dart';
import '../../features/calendar/screens/calendar_screen.dart';
import '../../features/rpg/screens/rpg_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/subscription/screens/paywall_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/legal/screens/legal_screens.dart';
import '../../features/steps/screens/steps_screen.dart';
import '../../features/abstinence/screens/abstinence_screen.dart';
import '../../features/nutrition/screens/nutrition_screen.dart';
import '../constants/app_constants.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppConstants.routeSplash,
    debugLogDiagnostics: false,

    redirect: (context, state) async {
      final user   = Supabase.instance.client.auth.currentUser;
      final isAuth = user != null;
      final loc    = state.matchedLocation;
      final isAuthPage = loc == AppConstants.routeLogin ||
          loc == AppConstants.routeRegister;

      if (!isAuth && !isAuthPage) return AppConstants.routeLogin;

      if (isAuth && !isAuthPage) {
        try {
          final profile = await Supabase.instance.client
              .from('profiles')
              .select('onboarding_completed')
              .eq('id', user.id)
              .single();
          if (!(profile['onboarding_completed'] ?? false) &&
              loc != AppConstants.routeOnboarding) {
            return AppConstants.routeOnboarding;
          }
        } catch (_) {}
      }

      if (isAuth && isAuthPage) return AppConstants.routeHome;
      return null;
    },

    routes: [
      GoRoute(path: AppConstants.routeSplash,
          builder: (_, __) => const _SplashScreen()),

      GoRoute(path: AppConstants.routeLogin,
          pageBuilder: (_, s) => _fade(s, const LoginScreen())),

      GoRoute(path: AppConstants.routeRegister,
          pageBuilder: (_, s) => _slide(s, const RegisterScreen())),

      GoRoute(path: AppConstants.routeOnboarding,
          pageBuilder: (_, s) => _slide(s, const OnboardingScreen())),

      GoRoute(path: AppConstants.routePaywall,
          pageBuilder: (_, s) => _slide(s, const PaywallScreen())),

      GoRoute(path: AppConstants.routeSettings,
          pageBuilder: (_, s) => _slide(s, const SettingsScreen())),

      GoRoute(path: AppConstants.routeTerms,
          pageBuilder: (_, s) => _slide(s, const TermsScreen())),

      GoRoute(path: AppConstants.routePrivacy,
          pageBuilder: (_, s) => _slide(s, const PrivacyScreen())),

      GoRoute(path: AppConstants.routeSteps,
          pageBuilder: (_, s) => _slide(s, const StepsScreen())),

      GoRoute(path: AppConstants.routeAbstinence,
          pageBuilder: (_, s) => _slide(s, const AbstinenceScreen())),

      GoRoute(path: AppConstants.routeNutrition,
          pageBuilder: (_, s) => _slide(s, const NutritionScreen())),

      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(path: AppConstants.routeHome,
              builder: (_, __) => const HomeScreen()),
          GoRoute(
            path: AppConstants.routeExercises,
            builder: (_, __) => const ExercisesScreen(),
            routes: [
              GoRoute(
                path: ':id',
                pageBuilder: (_, s) => _slide(s,
                    ExerciseDetailScreen(
                        exerciseId: s.pathParameters['id']!))),
            ]),
          GoRoute(path: AppConstants.routeCalendar,
              builder: (_, __) => const CalendarScreen()),
          GoRoute(path: AppConstants.routeRpg,
              builder: (_, __) => const RpgScreen()),
          GoRoute(path: AppConstants.routeProfile,
              builder: (_, __) => const ProfileScreen()),
        ],
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('😕', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 16),
          const Text('Page introuvable',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          const SizedBox(height: 24),
          TextButton(
            onPressed: () => context.go(AppConstants.routeHome),
            child: const Text('Retour à l\'accueil')),
        ])),
    ),
  );
});

class MainShell extends StatelessWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    final tabs = [
      AppConstants.routeHome, AppConstants.routeExercises,
      AppConstants.routeCalendar, AppConstants.routeRpg,
      AppConstants.routeProfile,
    ];
    int idx = tabs.indexWhere((t) => location.startsWith(t));
    if (idx == -1) idx = 0;

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Color(0xFF2A2A2A)))),
        child: BottomNavigationBar(
          currentIndex: idx,
          onTap: (i) => context.go(tabs[i]),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_outlined),
                activeIcon: Icon(Icons.home), label: 'Accueil'),
            BottomNavigationBarItem(icon: Icon(Icons.fitness_center_outlined),
                activeIcon: Icon(Icons.fitness_center), label: 'Exercices'),
            BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined),
                activeIcon: Icon(Icons.calendar_today), label: 'Programme'),
            BottomNavigationBarItem(icon: Icon(Icons.auto_awesome_outlined),
                activeIcon: Icon(Icons.auto_awesome), label: 'Quêtes'),
            BottomNavigationBarItem(icon: Icon(Icons.person_outline),
                activeIcon: Icon(Icons.person), label: 'Profil'),
          ],
        ),
      ),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();
  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1800),
        () { if (mounted) context.go(AppConstants.routeHome); });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF0D0D0D),
    body: Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 100, height: 100,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [Color(0xFFFF6B35), Color(0xFFFF9A3C)]),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [BoxShadow(
                color: const Color(0xFFFF6B35).withOpacity(0.5),
                blurRadius: 30, spreadRadius: 5)]),
          child: const Icon(Icons.fitness_center,
              color: Colors.white, size: 52)),
        const SizedBox(height: 24),
        const Text('FitPro', style: TextStyle(
            color: Colors.white, fontSize: 36,
            fontWeight: FontWeight.w800, letterSpacing: 2)),
        const SizedBox(height: 8),
        const Text('Forge ton corps. Dépasse tes limites.',
            style: TextStyle(color: Colors.white38, fontSize: 14)),
      ])),
  );
}

CustomTransitionPage _fade(GoRouterState s, Widget child) =>
    CustomTransitionPage(key: s.pageKey, child: child,
        transitionsBuilder: (_, a, __, c) =>
            FadeTransition(opacity: a, child: c));

CustomTransitionPage _slide(GoRouterState s, Widget child) =>
    CustomTransitionPage(key: s.pageKey, child: child,
        transitionsBuilder: (_, a, __, c) => SlideTransition(
            position: Tween<Offset>(
                begin: const Offset(1, 0), end: Offset.zero)
                .animate(CurvedAnimation(parent: a, curve: Curves.easeInOut)),
            child: c));
