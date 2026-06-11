class AppConstants {
  AppConstants._();

  // Abonnement
  static const String premiumMonthlyId   = 'fitpro_499_monthly';
  static const String premiumAnnualId    = 'fitpro_4999_annual';
  static const String premiumEntitlement = 'premium';

  // Limites Freemium
  static const int freeExercisesLimit = 30;
  static const int freeProgramsLimit  = 1;

  // Routes
  static const String routeSplash        = '/';
  static const String routeLogin         = '/login';
  static const String routeRegister      = '/register';
  static const String routeOnboarding    = '/onboarding';
  static const String routeHome          = '/home';
  static const String routeExercises     = '/exercises';
  static const String routeCalendar      = '/calendar';
  static const String routeRpg           = '/rpg';
  static const String routeProfile       = '/profile';
  static const String routePaywall       = '/paywall';
  static const String routeSettings      = '/settings';
  static const String routeSteps         = '/steps';
  static const String routeAbstinence    = '/abstinence';
  static const String routeNutrition     = '/nutrition';
  static const String routeTerms         = '/terms';
  static const String routePrivacy       = '/privacy';

  // Animations
  static const Duration animFast   = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 350);
  static const Duration animSlow   = Duration(milliseconds: 600);

  // SharedPreferences
  static const String prefLanguage       = 'language';
  static const String prefOnboardingDone = 'onboarding_done';

  // Objectifs
  static const String goalRenforcement = 'renforcement';
  static const String goalPerteGras    = 'perte_gras';
  static const String goalPriseMuscle  = 'prise_muscle';

  // Langues
  static const String langFr = 'fr';
  static const String langEn = 'en';
}
