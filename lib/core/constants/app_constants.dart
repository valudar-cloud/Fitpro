// ════════════════════════════════════════════════════════
// CONSTANTES GLOBALES — FitPro
// ════════════════════════════════════════════════════════

class AppConstants {
  AppConstants._();

  // ── Produits abonnement (RevenueCat) ─────────────────
  static const String premiumMonthlyId   = 'fitpro_premium_monthly';
  static const String premiumAnnualId    = 'fitpro_premium_annual';
  static const String premiumEntitlement = 'premium';

  // ── Limites Freemium ──────────────────────────────────
  static const int freeExercisesLimit    = 20;
  static const int freeProgramsLimit     = 1;
  static const int freeGoalsLimit        = 1;

  // ── Paramètres RPG ────────────────────────────────────
  static const int maxLevel              = 50;
  static const int streakBonusDay        = 7;
  static const int streakBonusMonth      = 30;

  // ── Navigation routes ─────────────────────────────────
  static const String routeSplash        = '/';
  static const String routeLogin         = '/login';
  static const String routeRegister      = '/register';
  static const String routeOnboarding    = '/onboarding';
  static const String routeHome          = '/home';
  static const String routeExercises     = '/exercises';
  static const String routeExerciseDetail= '/exercises/:id';
  static const String routeCalendar      = '/calendar';
  static const String routeRpg           = '/rpg';
  static const String routeProfile       = '/profile';
  static const String routePaywall       = '/paywall';
  static const String routeSettings      = '/settings';

  // ── Durées d'animation ────────────────────────────────
  static const Duration animFast         = Duration(milliseconds: 200);
  static const Duration animNormal       = Duration(milliseconds: 350);
  static const Duration animSlow         = Duration(milliseconds: 600);

  // ── Clés SharedPreferences ────────────────────────────
  static const String prefLanguage       = 'language';
  static const String prefTheme          = 'theme';
  static const String prefOnboardingDone = 'onboarding_done';
  static const String prefLastSync       = 'last_sync';

  // ── Objectifs ─────────────────────────────────────────
  static const String goalRenforcement   = 'renforcement';
  static const String goalPerteGras      = 'perte_gras';
  static const String goalPriseMuscle    = 'prise_muscle';

  // ── Localisation ─────────────────────────────────────
  static const String langFr             = 'fr';
  static const String langEn             = 'en';
}
