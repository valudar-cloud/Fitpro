import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

// ════════════════════════════════════════════════════════
// LOCALISATION — Français + Anglais
// ════════════════════════════════════════════════════════

// Provider de la locale active
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('fr')) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final lang = prefs.getString(AppConstants.prefLanguage) ?? 'fr';
    state = Locale(lang);
  }

  Future<void> setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.prefLanguage, locale.languageCode);
    state = locale;
  }
}

// ── Classe de traductions ─────────────────────────────
class S {
  final String lang;
  const S(this.lang);

  bool get isFr => lang == 'fr';

  // ── Auth ──────────────────────────────────────────────
  String get loginTitle       => isFr ? 'Connexion'             : 'Login';
  String get registerTitle    => isFr ? 'Créer un compte'       : 'Create Account';
  String get emailLabel       => isFr ? 'Adresse email'         : 'Email address';
  String get passwordLabel    => isFr ? 'Mot de passe'          : 'Password';
  String get confirmPassword  => isFr ? 'Confirmer le mot de passe' : 'Confirm password';
  String get nameLabel        => isFr ? 'Prénom et nom'         : 'Full name';
  String get loginBtn         => isFr ? 'Se connecter'          : 'Sign in';
  String get registerBtn      => isFr ? 'S\'inscrire'           : 'Sign up';
  String get forgotPassword   => isFr ? 'Mot de passe oublié ?' : 'Forgot password?';
  String get noAccount        => isFr ? 'Pas de compte ?'       : 'No account?';
  String get hasAccount       => isFr ? 'Déjà un compte ?'      : 'Already have an account?';
  String get logout           => isFr ? 'Se déconnecter'        : 'Logout';
  String get orContinueWith   => isFr ? 'ou continuer avec'     : 'or continue with';

  // ── Onboarding ────────────────────────────────────────
  String get onboardingGoalTitle    => isFr ? 'Quel est ton objectif ?' : 'What is your goal?';
  String get onboardingLocationTitle=> isFr ? 'Où tu t\'entraînes ?'   : 'Where do you train?';
  String get onboardingInjuryTitle  => isFr ? 'As-tu des douleurs ?'   : 'Do you have any pain?';
  String get goalRenforcement       => isFr ? 'Renforcement musculaire': 'Muscle strengthening';
  String get goalPerteGras          => isFr ? 'Perte de graisse'        : 'Fat loss';
  String get goalPriseMuscle        => isFr ? 'Prise de muscle'         : 'Muscle gain';
  String get locationGym            => isFr ? 'Salle de gym'            : 'Gym';
  String get locationHome           => isFr ? 'À la maison'             : 'At home';
  String get locationBoth           => isFr ? 'Les deux'                : 'Both';
  String get noInjury               => isFr ? 'Aucune douleur'          : 'No pain';
  String get continueBtn            => isFr ? 'Continuer'               : 'Continue';
  String get startBtn               => isFr ? 'Commencer !'             : 'Let\'s go!';
  String get skipBtn                => isFr ? 'Passer'                  : 'Skip';

  // ── Navigation ────────────────────────────────────────
  String get navHome        => isFr ? 'Accueil'    : 'Home';
  String get navExercises   => isFr ? 'Exercices'  : 'Exercises';
  String get navCalendar    => isFr ? 'Programme'  : 'Program';
  String get navRpg         => isFr ? 'Quêtes'     : 'Quests';
  String get navProfile     => isFr ? 'Profil'     : 'Profile';

  // ── Exercices ─────────────────────────────────────────
  String get exercisesTitle     => isFr ? 'Exercices'           : 'Exercises';
  String get searchExercise     => isFr ? 'Rechercher...'       : 'Search...';
  String get filterAll          => isFr ? 'Tous'                : 'All';
  String get filterGym          => isFr ? 'Gym'                 : 'Gym';
  String get filterHome         => isFr ? 'Maison'              : 'Home';
  String get sets               => isFr ? 'Séries'              : 'Sets';
  String get reps               => isFr ? 'Répétitions'         : 'Reps';
  String get rest               => isFr ? 'Repos'               : 'Rest';
  String get muscles            => isFr ? 'Muscles'             : 'Muscles';
  String get difficulty         => isFr ? 'Difficulté'          : 'Difficulty';
  String get beginner           => isFr ? 'Débutant'            : 'Beginner';
  String get intermediate       => isFr ? 'Intermédiaire'       : 'Intermediate';
  String get advanced           => isFr ? 'Avancé'              : 'Advanced';
  String get premiumOnly        => isFr ? '🔒 Premium uniquement' : '🔒 Premium only';
  String get addToProgram       => isFr ? 'Ajouter au programme': 'Add to program';
  String get injuryWarning      => isFr ? '⚠️ Déconseillé avec ta douleur' : '⚠️ Not advised with your pain';

  // ── Calendrier ────────────────────────────────────────
  String get calendarTitle      => isFr ? 'Mon Programme'       : 'My Program';
  String get createProgram      => isFr ? 'Créer un programme'  : 'Create a program';
  String get restDay            => isFr ? '😴 Repos'            : '😴 Rest';
  String get trainingDay        => isFr ? '💪 Entraînement'     : '💪 Training';
  String get markRestDay        => isFr ? 'Marquer repos'       : 'Mark as rest';
  String get sessionDone        => isFr ? 'Séance terminée !'   : 'Session done!';
  String get weeklyProgram      => isFr ? 'Programme semaine'   : 'Weekly program';

  // ── RPG ───────────────────────────────────────────────
  String get rpgTitle           => isFr ? 'Mes Quêtes'          : 'My Quests';
  String get xpLabel            => isFr ? 'XP'                  : 'XP';
  String get levelLabel         => isFr ? 'Niveau'              : 'Level';
  String get streakLabel        => isFr ? 'Streak'              : 'Streak';
  String get questDaily         => isFr ? 'QUOTIDIEN'           : 'DAILY';
  String get questWeekly        => isFr ? 'HEBDO'               : 'WEEKLY';
  String get questAchievement   => isFr ? 'SUCCÈS'              : 'ACHIEVEMENTS';
  String get claimReward        => isFr ? 'Récupérer !'         : 'Claim!';
  String get questCompleted     => isFr ? 'Terminée ✅'          : 'Completed ✅';
  String get questLocked        => isFr ? '🔒 Verrouillée'      : '🔒 Locked';
  String get levelUp            => isFr ? '🎉 Level Up !'       : '🎉 Level Up!';
  String get xpGained           => isFr ? '+{n} XP gagné !'    : '+{n} XP earned!';
  String get sessionsLabel      => isFr ? 'Séances'             : 'Sessions';
  String get restDaysLabel      => isFr ? 'Jours repos'         : 'Rest days';
  String get questsDoneLabel    => isFr ? 'Quêtes faites'       : 'Quests done';

  // ── Abonnement ────────────────────────────────────────
  String get paywallTitle       => isFr ? 'Passe à Premium 🚀'  : 'Go Premium 🚀';
  String get paywallSubtitle    => isFr ? 'Débloques tout le potentiel de FitPro' : 'Unlock the full power of FitPro';
  String get monthlyPlan        => isFr ? 'Mensuel'             : 'Monthly';
  String get annualPlan         => isFr ? 'Annuel'              : 'Annual';
  String get bestValue          => isFr ? 'Meilleure offre'     : 'Best value';
  String get subscribeBtn       => isFr ? 'S\'abonner'          : 'Subscribe';
  String get restoreBtn         => isFr ? 'Restaurer mes achats': 'Restore purchases';
  String get cancelAnytime      => isFr ? 'Annulable à tout moment' : 'Cancel anytime';

  // ── Général ───────────────────────────────────────────
  String get save               => isFr ? 'Enregistrer'         : 'Save';
  String get cancel             => isFr ? 'Annuler'             : 'Cancel';
  String get delete             => isFr ? 'Supprimer'           : 'Delete';
  String get edit               => isFr ? 'Modifier'            : 'Edit';
  String get done               => isFr ? 'Terminer'            : 'Done';
  String get next               => isFr ? 'Suivant'             : 'Next';
  String get back               => isFr ? 'Retour'              : 'Back';
  String get loading            => isFr ? 'Chargement...'       : 'Loading...';
  String get error              => isFr ? 'Une erreur est survenue' : 'An error occurred';
  String get retry              => isFr ? 'Réessayer'           : 'Retry';
  String get yes                => isFr ? 'Oui'                 : 'Yes';
  String get no                 => isFr ? 'Non'                 : 'No';
  String get days               => isFr ? 'jours'               : 'days';
  String get seconds            => isFr ? 'sec'                 : 'sec';
  String get minutes            => isFr ? 'min'                 : 'min';

  // ── Zones corporelles (blessures) ────────────────────
  String injuryZone(String zone) {
    final map = isFr ? _injuryZonesFr : _injuryZonesEn;
    return map[zone] ?? zone;
  }

  static const Map<String, String> _injuryZonesFr = {
    'neck':            'Nuque / Cou',
    'shoulder_left':   'Épaule gauche',
    'shoulder_right':  'Épaule droite',
    'elbow_left':      'Coude gauche',
    'elbow_right':     'Coude droit',
    'wrist_left':      'Poignet gauche',
    'wrist_right':     'Poignet droit',
    'back_upper':      'Dos haut',
    'back_lower':      'Bas du dos',
    'hip':             'Hanche',
    'knee_left':       'Genou gauche',
    'knee_right':      'Genou droit',
    'ankle_left':      'Cheville gauche',
    'ankle_right':     'Cheville droite',
    'other':           'Autre',
  };

  static const Map<String, String> _injuryZonesEn = {
    'neck':            'Neck',
    'shoulder_left':   'Left shoulder',
    'shoulder_right':  'Right shoulder',
    'elbow_left':      'Left elbow',
    'elbow_right':     'Right elbow',
    'wrist_left':      'Left wrist',
    'wrist_right':     'Right wrist',
    'back_upper':      'Upper back',
    'back_lower':      'Lower back',
    'hip':             'Hip',
    'knee_left':       'Left knee',
    'knee_right':      'Right knee',
    'ankle_left':      'Left ankle',
    'ankle_right':     'Right ankle',
    'other':           'Other',
  };

  // ── Groupes musculaires ───────────────────────────────
  String muscleGroup(String key) {
    final map = isFr ? _musclesFr : _musclesEn;
    return map[key] ?? key;
  }

  static const Map<String, String> _musclesFr = {
    'chest':          'Pectoraux',
    'back':           'Dos',
    'shoulders':      'Épaules',
    'biceps':         'Biceps',
    'triceps':        'Triceps',
    'forearms':       'Avant-bras',
    'abs':            'Abdominaux',
    'obliques':       'Obliques',
    'glutes':         'Fessiers',
    'quads':          'Quadriceps',
    'hamstrings':     'Ischio-jambiers',
    'calves':         'Mollets',
    'lower_back':     'Bas du dos',
    'traps':          'Trapèzes',
    'lats':           'Grand dorsal',
    'full_body':      'Corps complet',
    'cardio':         'Cardio',
  };

  static const Map<String, String> _musclesEn = {
    'chest':          'Chest',
    'back':           'Back',
    'shoulders':      'Shoulders',
    'biceps':         'Biceps',
    'triceps':        'Triceps',
    'forearms':       'Forearms',
    'abs':            'Abs',
    'obliques':       'Obliques',
    'glutes':         'Glutes',
    'quads':          'Quads',
    'hamstrings':     'Hamstrings',
    'calves':         'Calves',
    'lower_back':     'Lower back',
    'traps':          'Traps',
    'lats':           'Lats',
    'full_body':      'Full body',
    'cardio':         'Cardio',
  };
}

// Provider de traductions
final sProvider = Provider<S>((ref) {
  final locale = ref.watch(localeProvider);
  return S(locale.languageCode);
});
