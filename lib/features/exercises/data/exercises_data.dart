import '../models/exercise_model.dart';

// ════════════════════════════════════════════════════════
// BASE DE DONNÉES EXERCICES — 55 exercices
// Couverture : Renforcement | Perte de gras | Prise muscle
//              Gym | Maison | Débutant → Avancé
// ════════════════════════════════════════════════════════

class ExercisesData {
  static const List<Exercise> all = [

    // ══════════════════════════════════════════════════
    // POITRINE / CHEST
    // ══════════════════════════════════════════════════

    Exercise(
      id: 'push_up',
      nameFr: 'Pompes', nameEn: 'Push-Up',
      descriptionFr: 'Exercice fondamental pour les pectoraux, triceps et épaules.',
      descriptionEn: 'Fundamental exercise for chest, triceps and shoulders.',
      instructionsFr: [
        'Mets-toi en position planche, mains à largeur d\'épaules',
        'Descends le buste jusqu\'à ce que les coudes soient à 90°',
        'Pousse pour revenir en position initiale',
        'Garde le corps aligné tout au long du mouvement',
      ],
      instructionsEn: [
        'Get into plank position, hands shoulder-width apart',
        'Lower your chest until elbows reach 90°',
        'Push back to starting position',
        'Keep body aligned throughout the movement',
      ],
      muscleGroups: ['chest', 'triceps', 'shoulders'],
      secondaryMuscles: ['abs', 'lower_back'],
      goals: ['renforcement', 'perte_gras', 'prise_muscle'],
      locations: ['gym', 'home'],
      difficulty: 'beginner',
      equipment: [],
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/push_up.gif',
      contraindications: ['wrist_left', 'wrist_right', 'shoulder_left', 'shoulder_right'],
      setsRecommended: 3,
      repsRecommended: '10-15',
      restSeconds: 60,
      caloriesPerMinute: 7.0,
      isPremium: false,
    ),

    Exercise(
      id: 'incline_push_up',
      nameFr: 'Pompes inclinées', nameEn: 'Incline Push-Up',
      descriptionFr: 'Version plus facile des pompes, idéale pour les débutants.',
      descriptionEn: 'Easier push-up variation, great for beginners.',
      instructionsFr: [
        'Appuie les mains sur une surface surélevée (table, chaise)',
        'Corps droit, pompes comme habituellement',
      ],
      instructionsEn: [
        'Place hands on an elevated surface',
        'Keep body straight, perform push-up as normal',
      ],
      muscleGroups: ['chest', 'triceps'],
      goals: ['renforcement'],
      locations: ['home', 'gym'],
      difficulty: 'beginner',
      equipment: [],
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/incline_push_up.gif',
      contraindications: ['wrist_left', 'wrist_right'],
      setsRecommended: 3,
      repsRecommended: '12-20',
      restSeconds: 60,
      isPremium: false,
    ),

    Exercise(
      id: 'bench_press',
      nameFr: 'Développé couché', nameEn: 'Bench Press',
      descriptionFr: 'Exercice roi pour développer la masse pectorale.',
      descriptionEn: 'The king exercise for building chest mass.',
      instructionsFr: [
        'Allonge-toi sur le banc, pieds à plat au sol',
        'Saisit la barre légèrement plus large que les épaules',
        'Descends la barre jusqu\'à la poitrine',
        'Pousse explosif vers le haut en expirant',
      ],
      instructionsEn: [
        'Lie on bench, feet flat on floor',
        'Grip bar slightly wider than shoulder-width',
        'Lower bar to chest',
        'Press explosively upward while exhaling',
      ],
      muscleGroups: ['chest', 'triceps', 'shoulders'],
      goals: ['prise_muscle', 'renforcement'],
      locations: ['gym'],
      difficulty: 'intermediate',
      equipment: ['barbell', 'bench'],
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/bench_press.gif',
      contraindications: ['shoulder_left', 'shoulder_right', 'wrist_left', 'wrist_right'],
      setsRecommended: 4,
      repsRecommended: '8-10',
      restSeconds: 90,
      caloriesPerMinute: 8.0,
      isPremium: false,
    ),

    Exercise(
      id: 'dumbbell_flyes',
      nameFr: 'Écarté haltères', nameEn: 'Dumbbell Flyes',
      descriptionFr: 'Isolation pectorale pour étirer et contracter au maximum.',
      descriptionEn: 'Chest isolation for maximum stretch and contraction.',
      instructionsFr: [
        'Allonge-toi sur banc, haltères au-dessus de la poitrine',
        'Ouvre les bras en arc de cercle jusqu\'à l\'étirement',
        'Referme en contractant fort les pectoraux',
      ],
      instructionsEn: [
        'Lie on bench, dumbbells above chest',
        'Open arms in arc until stretch is felt',
        'Close arms, squeezing chest hard',
      ],
      muscleGroups: ['chest'],
      secondaryMuscles: ['shoulders'],
      goals: ['prise_muscle', 'renforcement'],
      locations: ['gym'],
      difficulty: 'intermediate',
      equipment: ['dumbbells', 'bench'],
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/dumbbell_flyes.gif',
      contraindications: ['shoulder_left', 'shoulder_right'],
      setsRecommended: 3,
      repsRecommended: '12-15',
      restSeconds: 60,
      isPremium: true,
    ),

    // ══════════════════════════════════════════════════
    // DOS / BACK
    // ══════════════════════════════════════════════════

    Exercise(
      id: 'pull_up',
      nameFr: 'Traction', nameEn: 'Pull-Up',
      descriptionFr: 'Exercice complet pour le dos et les biceps.',
      descriptionEn: 'Complete exercise for back and biceps.',
      instructionsFr: [
        'Saisit la barre en prise pronation, bras tendus',
        'Tire ton corps vers le haut jusqu\'au menton au-dessus de la barre',
        'Descends lentement en contrôlant',
      ],
      instructionsEn: [
        'Grip bar with overhand grip, arms extended',
        'Pull body up until chin clears the bar',
        'Lower slowly with control',
      ],
      muscleGroups: ['back', 'biceps', 'lats'],
      secondaryMuscles: ['shoulders', 'abs'],
      goals: ['prise_muscle', 'renforcement'],
      locations: ['gym', 'home'],
      difficulty: 'intermediate',
      equipment: ['pull_up_bar'],
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/pull_up.gif',
      contraindications: ['shoulder_left', 'shoulder_right', 'elbow_left', 'elbow_right'],
      setsRecommended: 4,
      repsRecommended: '5-10',
      restSeconds: 90,
      caloriesPerMinute: 9.0,
      isPremium: false,
    ),

    Exercise(
      id: 'deadlift',
      nameFr: 'Soulevé de terre', nameEn: 'Deadlift',
      descriptionFr: 'L\'exercice le plus complet — dos, jambes, fessiers.',
      descriptionEn: 'The most complete exercise — back, legs, glutes.',
      instructionsFr: [
        'Pieds à largeur de hanche, barre au-dessus des pieds',
        'Saisit la barre, dos droit, poitrine haute',
        'Pousse le sol pour soulever, garde la barre proche du corps',
        'Debout, puis redescends de façon contrôlée',
      ],
      instructionsEn: [
        'Feet hip-width apart, bar over feet',
        'Grip bar, flat back, chest up',
        'Push floor away to lift, keep bar close to body',
        'Stand tall, then lower with control',
      ],
      muscleGroups: ['back', 'glutes', 'hamstrings', 'lower_back'],
      secondaryMuscles: ['quads', 'traps', 'forearms'],
      goals: ['prise_muscle', 'renforcement'],
      locations: ['gym'],
      difficulty: 'intermediate',
      equipment: ['barbell'],
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/deadlift.gif',
      contraindications: ['back_lower', 'back_upper', 'knee_left', 'knee_right'],
      setsRecommended: 4,
      repsRecommended: '5-8',
      restSeconds: 120,
      caloriesPerMinute: 10.0,
      isPremium: true,
    ),

    Exercise(
      id: 'bent_over_row',
      nameFr: 'Rowing barre', nameEn: 'Bent-Over Row',
      descriptionFr: 'Développe l\'épaisseur du dos et le grand dorsal.',
      descriptionEn: 'Builds back thickness and lats.',
      instructionsFr: [
        'Penche-toi en avant, dos droit à 45°',
        'Tire la barre vers le nombril',
        'Serre les omoplates en haut du mouvement',
      ],
      instructionsEn: [
        'Hinge forward, flat back at 45°',
        'Pull bar to navel',
        'Squeeze shoulder blades at top',
      ],
      muscleGroups: ['back', 'lats', 'biceps'],
      secondaryMuscles: ['traps', 'lower_back'],
      goals: ['prise_muscle', 'renforcement'],
      locations: ['gym'],
      difficulty: 'intermediate',
      equipment: ['barbell'],
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/bent_over_row.gif',
      contraindications: ['back_lower', 'back_upper'],
      setsRecommended: 4,
      repsRecommended: '8-12',
      restSeconds: 90,
      isPremium: false,
    ),

    // ══════════════════════════════════════════════════
    // JAMBES / LEGS
    // ══════════════════════════════════════════════════

    Exercise(
      id: 'squat',
      nameFr: 'Squat', nameEn: 'Squat',
      descriptionFr: 'Le roi des exercices pour les jambes.',
      descriptionEn: 'The king of leg exercises.',
      instructionsFr: [
        'Pieds à largeur d\'épaules, pointes légèrement tournées',
        'Descends comme pour t\'asseoir en gardant le dos droit',
        'Genoux dans l\'axe des pieds, cuisses parallèles au sol',
        'Remonte en poussant sur les talons',
      ],
      instructionsEn: [
        'Feet shoulder-width apart, toes slightly out',
        'Sit back and down, keeping back straight',
        'Knees track over toes, thighs parallel to floor',
        'Drive up through heels',
      ],
      muscleGroups: ['quads', 'glutes', 'hamstrings'],
      secondaryMuscles: ['calves', 'lower_back', 'abs'],
      goals: ['renforcement', 'prise_muscle', 'perte_gras'],
      locations: ['gym', 'home'],
      difficulty: 'beginner',
      equipment: [],
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/squat.gif',
      contraindications: ['knee_left', 'knee_right', 'hip', 'back_lower'],
      setsRecommended: 4,
      repsRecommended: '12-15',
      restSeconds: 60,
      caloriesPerMinute: 8.5,
      isPremium: false,
    ),

    Exercise(
      id: 'lunges',
      nameFr: 'Fentes', nameEn: 'Lunges',
      descriptionFr: 'Excellent pour l\'équilibre et le travail unilatéral.',
      descriptionEn: 'Great for balance and unilateral leg work.',
      instructionsFr: [
        'Debout, fais un grand pas en avant',
        'Descends le genou arrière vers le sol',
        'Genou avant au-dessus de la cheville',
        'Remonte et alterne les jambes',
      ],
      instructionsEn: [
        'Standing, take a big step forward',
        'Lower back knee toward floor',
        'Front knee over ankle',
        'Return and alternate legs',
      ],
      muscleGroups: ['quads', 'glutes', 'hamstrings'],
      secondaryMuscles: ['calves', 'abs'],
      goals: ['renforcement', 'perte_gras'],
      locations: ['gym', 'home'],
      difficulty: 'beginner',
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/lunges.gif',
      contraindications: ['knee_left', 'knee_right', 'hip'],
      setsRecommended: 3,
      repsRecommended: '12 chaque jambe',
      restSeconds: 60,
      caloriesPerMinute: 7.5,
      isPremium: false,
    ),

    Exercise(
      id: 'glute_bridge',
      nameFr: 'Pont fessier', nameEn: 'Glute Bridge',
      descriptionFr: 'Isole les fessiers sans stress sur le dos.',
      descriptionEn: 'Isolates glutes without back stress.',
      instructionsFr: [
        'Allonge-toi sur le dos, genoux pliés, pieds à plat',
        'Pousse les hanches vers le haut en contractant les fessiers',
        'Maintiens 1-2 secondes en haut',
        'Descends lentement',
      ],
      instructionsEn: [
        'Lie on back, knees bent, feet flat',
        'Drive hips up squeezing glutes',
        'Hold 1-2 seconds at top',
        'Lower slowly',
      ],
      muscleGroups: ['glutes', 'hamstrings'],
      secondaryMuscles: ['abs', 'lower_back'],
      goals: ['renforcement', 'prise_muscle'],
      locations: ['gym', 'home'],
      difficulty: 'beginner',
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/glute_bridge.gif',
      contraindications: ['back_lower'],
      setsRecommended: 3,
      repsRecommended: '15-20',
      restSeconds: 45,
      isPremium: false,
    ),

    // ══════════════════════════════════════════════════
    // ABDOMINAUX / ABS
    // ══════════════════════════════════════════════════

    Exercise(
      id: 'plank',
      nameFr: 'Planche', nameEn: 'Plank',
      descriptionFr: 'Gainage isométrique complet pour la sangle abdominale.',
      descriptionEn: 'Full isometric core exercise.',
      instructionsFr: [
        'Position de pompe sur les avant-bras',
        'Corps parfaitement aligné tête-talons',
        'Contracte les abdos et les fessiers',
        'Maintiens sans creuser ni cambrer',
      ],
      instructionsEn: [
        'Forearm plank position',
        'Body perfectly aligned head to heels',
        'Squeeze abs and glutes',
        'Hold without sagging or piking',
      ],
      muscleGroups: ['abs', 'obliques', 'lower_back'],
      secondaryMuscles: ['shoulders', 'glutes'],
      goals: ['renforcement', 'perte_gras', 'prise_muscle'],
      locations: ['gym', 'home'],
      difficulty: 'beginner',
      durationSeconds: 30,
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/plank.gif',
      contraindications: ['wrist_left', 'wrist_right', 'back_lower'],
      setsRecommended: 3,
      repsRecommended: '30-60 sec',
      restSeconds: 45,
      caloriesPerMinute: 5.0,
      isPremium: false,
    ),

    Exercise(
      id: 'crunch',
      nameFr: 'Crunch', nameEn: 'Crunch',
      descriptionFr: 'Flexion du tronc pour contracter les abdominaux.',
      descriptionEn: 'Trunk flexion for abdominal contraction.',
      instructionsFr: [
        'Allonge-toi sur le dos, genoux pliés',
        'Mains derrière la nuque sans tirer le cou',
        'Soulève les épaules en contractant les abdos',
        'Reviens lentement sans poser complètement la tête',
      ],
      instructionsEn: [
        'Lie on back, knees bent',
        'Hands behind neck without pulling',
        'Lift shoulders contracting abs',
        'Lower slowly without fully resting head',
      ],
      muscleGroups: ['abs'],
      secondaryMuscles: ['obliques'],
      goals: ['renforcement', 'perte_gras'],
      locations: ['gym', 'home'],
      difficulty: 'beginner',
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/crunch.gif',
      contraindications: ['neck', 'back_upper'],
      setsRecommended: 3,
      repsRecommended: '15-20',
      restSeconds: 45,
      isPremium: false,
    ),

    // ══════════════════════════════════════════════════
    // ÉPAULES / SHOULDERS
    // ══════════════════════════════════════════════════

    Exercise(
      id: 'overhead_press',
      nameFr: 'Développé militaire', nameEn: 'Overhead Press',
      descriptionFr: 'Développe la puissance et le volume des épaules.',
      descriptionEn: 'Builds shoulder power and mass.',
      instructionsFr: [
        'Assis ou debout, barre au niveau des clavicules',
        'Pousse la barre vers le haut en ligne droite',
        'Bras complètement tendus en haut',
        'Ramène au niveau des clavicules',
      ],
      instructionsEn: [
        'Seated or standing, bar at collar bone level',
        'Press bar straight up',
        'Arms fully extended at top',
        'Return to collar bone',
      ],
      muscleGroups: ['shoulders', 'triceps'],
      secondaryMuscles: ['traps', 'abs'],
      goals: ['prise_muscle', 'renforcement'],
      locations: ['gym'],
      difficulty: 'intermediate',
      equipment: ['barbell'],
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/overhead_press.gif',
      contraindications: ['shoulder_left', 'shoulder_right', 'neck'],
      setsRecommended: 4,
      repsRecommended: '8-10',
      restSeconds: 90,
      isPremium: true,
    ),

    Exercise(
      id: 'lateral_raise',
      nameFr: 'Élévation latérale', nameEn: 'Lateral Raise',
      descriptionFr: 'Isolation du deltoïde moyen pour élargir les épaules.',
      descriptionEn: 'Middle deltoid isolation for shoulder width.',
      instructionsFr: [
        'Debout, haltères le long du corps',
        'Monte les bras à l\'horizontale en légère flexion des coudes',
        'Pause 1 seconde en haut',
        'Descends lentement',
      ],
      instructionsEn: [
        'Standing, dumbbells at sides',
        'Raise arms to horizontal with slight elbow bend',
        'Pause 1 second at top',
        'Lower slowly',
      ],
      muscleGroups: ['shoulders'],
      goals: ['renforcement', 'prise_muscle'],
      locations: ['gym', 'home'],
      difficulty: 'beginner',
      equipment: ['dumbbells'],
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/lateral_raise.gif',
      contraindications: ['shoulder_left', 'shoulder_right'],
      setsRecommended: 3,
      repsRecommended: '12-15',
      restSeconds: 45,
      isPremium: false,
    ),

    // ══════════════════════════════════════════════════
    // BICEPS
    // ══════════════════════════════════════════════════

    Exercise(
      id: 'bicep_curl',
      nameFr: 'Curl biceps', nameEn: 'Bicep Curl',
      descriptionFr: 'Exercice de base pour développer les biceps.',
      descriptionEn: 'Basic exercise for bicep development.',
      instructionsFr: [
        'Debout, haltères en supination (paumes vers le haut)',
        'Plie les coudes en montant les haltères vers les épaules',
        'Serre le biceps en haut',
        'Descends lentement',
      ],
      instructionsEn: [
        'Standing, dumbbells supinated (palms up)',
        'Curl dumbbells to shoulders',
        'Squeeze bicep at top',
        'Lower slowly',
      ],
      muscleGroups: ['biceps'],
      secondaryMuscles: ['forearms'],
      goals: ['prise_muscle', 'renforcement'],
      locations: ['gym', 'home'],
      difficulty: 'beginner',
      equipment: ['dumbbells'],
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/bicep_curl.gif',
      contraindications: ['elbow_left', 'elbow_right', 'wrist_left', 'wrist_right'],
      setsRecommended: 3,
      repsRecommended: '10-12',
      restSeconds: 60,
      isPremium: false,
    ),

    // ══════════════════════════════════════════════════
    // TRICEPS
    // ══════════════════════════════════════════════════

    Exercise(
      id: 'tricep_dip',
      nameFr: 'Dips triceps', nameEn: 'Tricep Dip',
      descriptionFr: 'Exercice poids du corps puissant pour les triceps.',
      descriptionEn: 'Powerful bodyweight exercise for triceps.',
      instructionsFr: [
        'Mains sur une chaise/banc, jambes tendues',
        'Descends en pliant les coudes à 90°',
        'Remonte en poussant sur les mains',
      ],
      instructionsEn: [
        'Hands on chair/bench, legs extended',
        'Lower by bending elbows to 90°',
        'Press back up',
      ],
      muscleGroups: ['triceps'],
      secondaryMuscles: ['chest', 'shoulders'],
      goals: ['renforcement', 'prise_muscle'],
      locations: ['gym', 'home'],
      difficulty: 'beginner',
      equipment: [],
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/tricep_dip.gif',
      contraindications: ['shoulder_left', 'shoulder_right', 'wrist_left', 'wrist_right', 'elbow_left', 'elbow_right'],
      setsRecommended: 3,
      repsRecommended: '10-15',
      restSeconds: 60,
      isPremium: false,
    ),

    // ══════════════════════════════════════════════════
    // CARDIO / FAT LOSS
    // ══════════════════════════════════════════════════

    Exercise(
      id: 'burpee',
      nameFr: 'Burpee', nameEn: 'Burpee',
      descriptionFr: 'L\'exercice HIIT complet par excellence — brûleur de calories.',
      descriptionEn: 'The ultimate HIIT exercise — maximum calorie burner.',
      instructionsFr: [
        'Debout → squattez et posez les mains au sol',
        'Sautez les pieds en arrière en position pompe',
        'Faites 1 pompe (optionnel)',
        'Ramenez les pieds, sautez en l\'air les bras tendus',
      ],
      instructionsEn: [
        'Stand → squat and place hands on floor',
        'Jump feet back to plank position',
        'Do 1 push-up (optional)',
        'Jump feet in, leap up with arms overhead',
      ],
      muscleGroups: ['full_body', 'cardio'],
      goals: ['perte_gras'],
      locations: ['gym', 'home'],
      difficulty: 'intermediate',
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/burpee.gif',
      contraindications: ['back_lower', 'knee_left', 'knee_right', 'wrist_left', 'wrist_right'],
      setsRecommended: 4,
      repsRecommended: '10',
      restSeconds: 45,
      caloriesPerMinute: 12.0,
      isPremium: false,
    ),

    Exercise(
      id: 'mountain_climber',
      nameFr: 'Grimpeur de montagne', nameEn: 'Mountain Climber',
      descriptionFr: 'Cardio intense en isométrique — abdos et cardio combinés.',
      descriptionEn: 'Intense cardio plank — abs and cardio combined.',
      instructionsFr: [
        'Position de pompe, corps aligné',
        'Ramène un genou vers la poitrine rapidement',
        'Alterne les jambes à haute vitesse',
        'Garde les hanches stables',
      ],
      instructionsEn: [
        'Push-up position, body aligned',
        'Drive one knee toward chest quickly',
        'Alternate legs at high speed',
        'Keep hips stable',
      ],
      muscleGroups: ['abs', 'cardio', 'full_body'],
      goals: ['perte_gras', 'renforcement'],
      locations: ['gym', 'home'],
      difficulty: 'beginner',
      durationSeconds: 30,
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/mountain_climber.gif',
      contraindications: ['wrist_left', 'wrist_right', 'back_lower'],
      setsRecommended: 4,
      repsRecommended: '30 sec',
      restSeconds: 30,
      caloriesPerMinute: 11.0,
      isPremium: false,
    ),

    Exercise(
      id: 'jumping_jacks',
      nameFr: 'Sauts étoile', nameEn: 'Jumping Jacks',
      descriptionFr: 'Cardio accessible pour activer tout le corps.',
      descriptionEn: 'Accessible cardio to activate the whole body.',
      instructionsFr: [
        'Pieds joints, bras le long du corps',
        'Saute en écartant pieds et bras simultanément',
        'Reviens à la position initiale',
        'Enchaîne à rythme régulier',
      ],
      instructionsEn: [
        'Feet together, arms at sides',
        'Jump feet out while raising arms simultaneously',
        'Return to start',
        'Maintain steady rhythm',
      ],
      muscleGroups: ['cardio', 'full_body'],
      goals: ['perte_gras'],
      locations: ['gym', 'home'],
      difficulty: 'beginner',
      durationSeconds: 45,
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/jumping_jacks.gif',
      contraindications: ['knee_left', 'knee_right', 'ankle_left', 'ankle_right'],
      setsRecommended: 3,
      repsRecommended: '45 sec',
      restSeconds: 30,
      caloriesPerMinute: 9.0,
      isPremium: false,
    ),

    Exercise(
      id: 'high_knees',
      nameFr: 'Genoux hauts', nameEn: 'High Knees',
      descriptionFr: 'Course sur place avec genoux montés haut.',
      descriptionEn: 'Running in place with high knee drive.',
      instructionsFr: [
        'Court sur place en montant les genoux à hauteur de hanche',
        'Balancement naturel des bras',
        'Maintiens un rythme soutenu',
      ],
      instructionsEn: [
        'Run in place lifting knees to hip height',
        'Natural arm swing',
        'Maintain steady pace',
      ],
      muscleGroups: ['cardio', 'quads', 'abs'],
      goals: ['perte_gras'],
      locations: ['gym', 'home'],
      difficulty: 'beginner',
      durationSeconds: 30,
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/high_knees.gif',
      contraindications: ['knee_left', 'knee_right', 'ankle_left', 'ankle_right', 'hip'],
      setsRecommended: 4,
      repsRecommended: '30 sec',
      restSeconds: 30,
      caloriesPerMinute: 10.0,
      isPremium: false,
    ),

    Exercise(
      id: 'jump_squat',
      nameFr: 'Squat sauté', nameEn: 'Jump Squat',
      descriptionFr: 'Explosive combination cardio + jambes.',
      descriptionEn: 'Explosive cardio and leg combination.',
      instructionsFr: [
        'Descends en squat',
        'Saute explosif vers le haut',
        'Atterris en douceur sur la pointe des pieds',
        'Enchaîne immédiatement',
      ],
      instructionsEn: [
        'Lower into squat',
        'Explode upward',
        'Land softly on balls of feet',
        'Immediately repeat',
      ],
      muscleGroups: ['quads', 'glutes', 'cardio'],
      goals: ['perte_gras', 'renforcement'],
      locations: ['gym', 'home'],
      difficulty: 'intermediate',
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/jump_squat.gif',
      contraindications: ['knee_left', 'knee_right', 'ankle_left', 'ankle_right', 'hip'],
      setsRecommended: 4,
      repsRecommended: '12',
      restSeconds: 45,
      caloriesPerMinute: 11.0,
      isPremium: false,
    ),

    // ══════════════════════════════════════════════════
    // EXERCICES AVANCÉS (Premium)
    // ══════════════════════════════════════════════════

    Exercise(
      id: 'pistol_squat',
      nameFr: 'Squat pistol', nameEn: 'Pistol Squat',
      descriptionFr: 'Squat sur une jambe — équilibre et force avancés.',
      descriptionEn: 'Single-leg squat — advanced balance and strength.',
      instructionsFr: [
        'Debout sur une jambe, l\'autre tendue devant',
        'Descends lentement en gardant l\'équilibre',
        'Cuisse parallèle au sol',
        'Remonte en contrôlant',
      ],
      instructionsEn: [
        'Stand on one leg, other extended forward',
        'Lower slowly maintaining balance',
        'Thigh parallel to floor',
        'Rise with control',
      ],
      muscleGroups: ['quads', 'glutes', 'hamstrings'],
      secondaryMuscles: ['abs', 'calves'],
      goals: ['renforcement', 'prise_muscle'],
      locations: ['gym', 'home'],
      difficulty: 'advanced',
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/pistol_squat.gif',
      contraindications: ['knee_left', 'knee_right', 'hip', 'ankle_left', 'ankle_right'],
      setsRecommended: 3,
      repsRecommended: '5-8 chaque',
      restSeconds: 90,
      isPremium: true,
    ),

    Exercise(
      id: 'muscle_up',
      nameFr: 'Muscle-up', nameEn: 'Muscle-Up',
      descriptionFr: 'La combinaison traction + dip pour experts.',
      descriptionEn: 'The pull-up + dip combination for experts.',
      instructionsFr: [
        'Traction explosive au-dessus de la barre',
        'Transition rapide : passe les coudes au-dessus',
        'Pousse vers le haut comme un dip',
        'Descends de façon contrôlée',
      ],
      instructionsEn: [
        'Explosive pull-up above bar',
        'Quick transition: elbows over bar',
        'Press up like a dip',
        'Lower with control',
      ],
      muscleGroups: ['back', 'chest', 'triceps', 'biceps', 'shoulders'],
      goals: ['renforcement', 'prise_muscle'],
      locations: ['gym', 'home'],
      difficulty: 'advanced',
      equipment: ['pull_up_bar'],
      gifUrl: 'https://fitpro-cdn.s3.amazonaws.com/gifs/muscle_up.gif',
      contraindications: ['shoulder_left', 'shoulder_right', 'elbow_left', 'elbow_right', 'wrist_left', 'wrist_right'],
      setsRecommended: 3,
      repsRecommended: '3-5',
      restSeconds: 120,
      isPremium: true,
    ),
  ];

  // ── Helpers de filtrage ───────────────────────────────

  static List<Exercise> byGoal(String goal) =>
      all.where((e) => e.goals.contains(goal)).toList();

  static List<Exercise> byLocation(String location) =>
      all.where((e) => e.locations.contains(location)).toList();

  static List<Exercise> byMuscle(String muscle) =>
      all.where((e) => e.muscleGroups.contains(muscle)).toList();

  static List<Exercise> safe(List<String> injuries) =>
      all.where((e) => !e.isContraindicated(injuries)).toList();

  static List<Exercise> free() =>
      all.where((e) => !e.isPremium).toList();

  static List<Exercise> filter({
    String? goal,
    String? location,
    String? difficulty,
    List<String> injuries = const [],
    bool premiumUnlocked = false,
  }) {
    return all.where((e) {
      if (goal != null && !e.goals.contains(goal)) return false;
      if (location != null && location != 'both' && !e.locations.contains(location)) return false;
      if (difficulty != null && e.difficulty != difficulty) return false;
      if (!premiumUnlocked && e.isPremium) return false;
      if (e.isContraindicated(injuries)) return false;
      return true;
    }).toList();
  }
}
