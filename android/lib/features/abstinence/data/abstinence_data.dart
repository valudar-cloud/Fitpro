import '../models/abstinence_model.dart';

// ════════════════════════════════════════════════════════
// TEMPLATES D'ABSTINENCE — Bienfaits scientifiques
// ════════════════════════════════════════════════════════

class AbstinenceData {
  static const List<AbstinenceTemplate> templates = [

    // ── 🚬 TABAC ──────────────────────────────────────
    AbstinenceTemplate(
      id: 'tabac',
      category: 'tabac',
      icon: '🚬',
      nameFr: 'Tabac / Cigarettes',
      nameEn: 'Tobacco / Cigarettes',
      descriptionFr: 'Arrêter de fumer transforme ton corps en quelques heures seulement.',
      targetDays: 365,
      benefits: [
        AbstinenceBenefit(afterMinutes: 20, emoji: '❤️',
            titleFr: 'Tension artérielle', descFr: 'Ta tension et ta fréquence cardiaque reviennent à la normale.'),
        AbstinenceBenefit(afterMinutes: 480, emoji: '🫁',
            titleFr: 'Monoxyde de carbone', descFr: 'Le CO dans ton sang est réduit de moitié. L\'oxygène circule mieux.'),
        AbstinenceBenefit(afterMinutes: 1440, emoji: '💪',
            titleFr: 'Risque cardiaque -50%', descFr: 'Le risque d\'infarctus commence à chuter significativement.'),
        AbstinenceBenefit(afterMinutes: 2880, emoji: '👃',
            titleFr: 'Goût et odorat', descFr: 'Tes sens du goût et de l\'odorat commencent à se régénérer.'),
        AbstinenceBenefit(afterMinutes: 4320, emoji: '🏃',
            titleFr: 'Respiration', descFr: 'Tu respires plus facilement. Les voies respiratoires se dilatent.'),
        AbstinenceBenefit(afterMinutes: 10080, emoji: '🌿',
            titleFr: 'Nicotine éliminée', descFr: 'La nicotine est totalement éliminée de ton organisme.'),
        AbstinenceBenefit(afterMinutes: 43200, emoji: '🫀',
            titleFr: 'Circulation +', descFr: 'Circulation sanguine améliorée. Mains et pieds moins froids.'),
        AbstinenceBenefit(afterMinutes: 129600, emoji: '🔬',
            titleFr: 'Cils bronchiques', descFr: 'Les cils bronchiques se régénèrent — meilleure défense contre les infections.'),
        AbstinenceBenefit(afterMinutes: 525600, emoji: '🎯',
            titleFr: 'Risque AVC -50%', descFr: 'Le risque d\'AVC est réduit de moitié après 1 an.'),
        AbstinenceBenefit(afterMinutes: 2628000, emoji: '🏆',
            titleFr: 'Risque cardiaque = non-fumeur', descFr: 'Après 5 ans, ton risque cardiaque est identique à celui d\'un non-fumeur.'),
      ],
    ),

    // ── 🍺 ALCOOL ─────────────────────────────────────
    AbstinenceTemplate(
      id: 'alcool',
      category: 'alcool',
      icon: '🍺',
      nameFr: 'Alcool',
      nameEn: 'Alcohol',
      descriptionFr: 'L\'abstinence d\'alcool régénère le foie et améliore drastiquement le sommeil.',
      targetDays: 90,
      benefits: [
        AbstinenceBenefit(afterMinutes: 1440, emoji: '😴',
            titleFr: 'Meilleur sommeil', descFr: 'Dès le premier jour, ton sommeil profond s\'améliore.'),
        AbstinenceBenefit(afterMinutes: 2880, emoji: '💧',
            titleFr: 'Hydratation', descFr: 'Ton corps est mieux hydraté. Peau plus lumineuse.'),
        AbstinenceBenefit(afterMinutes: 7200, emoji: '🧠',
            titleFr: 'Clarté mentale', descFr: 'Concentration et mémoire nettement améliorées.'),
        AbstinenceBenefit(afterMinutes: 10080, emoji: '⚡',
            titleFr: 'Énergie +', descFr: 'Énergie en hausse. Moins de fatigue chronique.'),
        AbstinenceBenefit(afterMinutes: 43200, emoji: '🫀',
            titleFr: 'Foie en régénération', descFr: 'Le foie commence à se régénérer significativement.'),
        AbstinenceBenefit(afterMinutes: 129600, emoji: '💪',
            titleFr: 'Performances sportives', descFr: 'Récupération musculaire accélérée. Testostérone normalisée.'),
        AbstinenceBenefit(afterMinutes: 259200, emoji: '❤️',
            titleFr: 'Tension artérielle', descFr: 'Tension artérielle réduite. Risque cardiovasculaire diminué.'),
        AbstinenceBenefit(afterMinutes: 525600, emoji: '🔬',
            titleFr: 'Foie restauré', descFr: 'Le foie est entièrement restauré si pas de cirrhose préalable.'),
      ],
    ),

    // ── 🔞 PORNOGRAPHIE ───────────────────────────────
    AbstinenceTemplate(
      id: 'porno',
      category: 'porno',
      icon: '🔞',
      nameFr: 'Pornographie',
      nameEn: 'Pornography',
      descriptionFr: 'Reboot dopaminergique — récupère ta motivation et ta sensibilité.',
      targetDays: 90,
      benefits: [
        AbstinenceBenefit(afterMinutes: 10080, emoji: '⚡',
            titleFr: 'Dopamine +', descFr: 'Tes récepteurs dopaminergiques commencent à se resensibiliser.'),
        AbstinenceBenefit(afterMinutes: 20160, emoji: '🧠',
            titleFr: 'Clarté mentale', descFr: 'Brouillard mental réduit. Meilleure concentration.'),
        AbstinenceBenefit(afterMinutes: 43200, emoji: '💪',
            titleFr: 'Testostérone +', descFr: 'Taux de testostérone en hausse après 3 semaines d\'abstinence.'),
        AbstinenceBenefit(afterMinutes: 86400, emoji: '🤝',
            titleFr: 'Relations sociales', descFr: 'Amélioration de la confiance en soi et des interactions sociales.'),
        AbstinenceBenefit(afterMinutes: 129600, emoji: '❤️',
            titleFr: 'Sensibilité restaurée', descFr: 'Sensibilité aux plaisirs réels du quotidien restaurée.'),
        AbstinenceBenefit(afterMinutes: 259200, emoji: '🏆',
            titleFr: 'Reboot complet', descFr: 'Reboot cérébral complet. Motivation et drive au maximum.'),
      ],
    ),

    // ── ✋ MASTURBATION / NoFap ──────────────────────
    AbstinenceTemplate(
      id: 'nofap',
      category: 'nofap',
      icon: '✋',
      nameFr: 'NoFap',
      nameEn: 'NoFap',
      descriptionFr: 'Économie d\'énergie vitale — confiance, focus et énergie décuplés.',
      targetDays: 90,
      benefits: [
        AbstinenceBenefit(afterMinutes: 10080, emoji: '⚡',
            titleFr: 'Énergie', descFr: 'Énergie et vitalité augmentées sensiblement.'),
        AbstinenceBenefit(afterMinutes: 20160, emoji: '💪',
            titleFr: 'Testostérone', descFr: 'Pic de testostérone documenté autour de 7 jours.'),
        AbstinenceBenefit(afterMinutes: 43200, emoji: '🧠',
            titleFr: 'Focus & clarté', descFr: 'Concentration et clarté mentale améliorées.'),
        AbstinenceBenefit(afterMinutes: 86400, emoji: '😎',
            titleFr: 'Confiance en soi', descFr: 'Confiance en soi et charisme augmentés.'),
        AbstinenceBenefit(afterMinutes: 129600, emoji: '🏃',
            titleFr: 'Performances sportives', descFr: 'Endurance et performances sportives améliorées.'),
        AbstinenceBenefit(afterMinutes: 259200, emoji: '🏆',
            titleFr: 'Superpuissances NoFap', descFr: 'Motivation, discipline et attraction à leur peak.'),
      ],
    ),

    // ── 📱 RÉSEAUX SOCIAUX ────────────────────────────
    AbstinenceTemplate(
      id: 'reseaux_sociaux',
      category: 'tech',
      icon: '📱',
      nameFr: 'Réseaux sociaux',
      nameEn: 'Social media',
      descriptionFr: 'Retrouve ton attention, ta créativité et ta sérénité.',
      targetDays: 30,
      benefits: [
        AbstinenceBenefit(afterMinutes: 1440, emoji: '😌',
            titleFr: 'Anxiété réduite', descFr: 'Baisse significative de l\'anxiété et du stress social.'),
        AbstinenceBenefit(afterMinutes: 2880, emoji: '⏰',
            titleFr: 'Temps retrouvé', descFr: 'En moyenne 2h/jour retrouvées pour des activités enrichissantes.'),
        AbstinenceBenefit(afterMinutes: 10080, emoji: '🧠',
            titleFr: 'Attention améliorée', descFr: 'Capacité de concentration profonde restaurée.'),
        AbstinenceBenefit(afterMinutes: 43200, emoji: '😊',
            titleFr: 'Estime de soi', descFr: 'Moins de comparaison sociale. Meilleure estime de soi.'),
        AbstinenceBenefit(afterMinutes: 86400, emoji: '🎨',
            titleFr: 'Créativité +', descFr: 'Explosion de créativité et de nouvelles idées.'),
      ],
    ),

    // ── ☕ CAFÉINE ─────────────────────────────────────
    AbstinenceTemplate(
      id: 'cafeine',
      category: 'substance',
      icon: '☕',
      nameFr: 'Caféine',
      nameEn: 'Caffeine',
      descriptionFr: 'Retrouve ton énergie naturelle et améliore la qualité de ton sommeil.',
      targetDays: 30,
      benefits: [
        AbstinenceBenefit(afterMinutes: 5760, emoji: '💊',
            titleFr: 'Sevrage passé', descFr: 'Les symptômes de sevrage (maux de tête) s\'atténuent.'),
        AbstinenceBenefit(afterMinutes: 20160, emoji: '😴',
            titleFr: 'Sommeil profond', descFr: 'Qualité du sommeil profond améliorée.'),
        AbstinenceBenefit(afterMinutes: 43200, emoji: '⚡',
            titleFr: 'Énergie naturelle', descFr: 'Ton énergie naturelle se stabilise sans pics ni crashes.'),
        AbstinenceBenefit(afterMinutes: 86400, emoji: '🧠',
            titleFr: 'Sensibilité caffeine', descFr: 'Tes récepteurs à adénosine sont restaurés — la caféine refera effet.'),
      ],
    ),

    // ── 🍭 SUCRE ──────────────────────────────────────
    AbstinenceTemplate(
      id: 'sucre',
      category: 'alimentation',
      icon: '🍭',
      nameFr: 'Sucre raffiné',
      nameEn: 'Refined sugar',
      descriptionFr: 'Stabilise ta glycémie, réduis l\'inflammation et perds de la graisse.',
      targetDays: 30,
      benefits: [
        AbstinenceBenefit(afterMinutes: 1440, emoji: '📊',
            titleFr: 'Glycémie stable', descFr: 'Ta glycémie commence à se stabiliser sans pics et crashes.'),
        AbstinenceBenefit(afterMinutes: 10080, emoji: '🔥',
            titleFr: 'Perte de graisse', descFr: 'Le corps commence à brûler les graisses stockées.'),
        AbstinenceBenefit(afterMinutes: 43200, emoji: '✨',
            titleFr: 'Peau améliorée', descFr: 'Acné et inflammation cutanée réduits.'),
        AbstinenceBenefit(afterMinutes: 86400, emoji: '🧠',
            titleFr: 'Humeur stable', descFr: 'Fin des sautes d\'humeur liées aux variations glycémiques.'),
        AbstinenceBenefit(afterMinutes: 129600, emoji: '💪',
            titleFr: 'Masse musculaire', descFr: 'Meilleure récupération musculaire et composition corporelle.'),
      ],
    ),

    // ── 🎮 JEUX VIDÉO ─────────────────────────────────
    AbstinenceTemplate(
      id: 'jeux_video',
      category: 'tech',
      icon: '🎮',
      nameFr: 'Jeux vidéo excessifs',
      nameEn: 'Excessive gaming',
      descriptionFr: 'Reprends le contrôle de ton temps et de ta productivité.',
      targetDays: 30,
      benefits: [
        AbstinenceBenefit(afterMinutes: 1440, emoji: '⏰',
            titleFr: 'Temps libre', descFr: 'En moyenne 3-4h/jour retrouvées.'),
        AbstinenceBenefit(afterMinutes: 10080, emoji: '😴',
            titleFr: 'Sommeil réparé', descFr: 'Rythme circadien restauré. Meilleur endormissement.'),
        AbstinenceBenefit(afterMinutes: 43200, emoji: '🎯',
            titleFr: 'Focus & objectifs', descFr: 'Capacité à poursuivre des objectifs à long terme améliorée.'),
        AbstinenceBenefit(afterMinutes: 86400, emoji: '🤝',
            titleFr: 'Relations sociales', descFr: 'Relations réelles enrichies. Interactions sociales augmentées.'),
      ],
    ),

    // ── 🍕 JUNK FOOD ──────────────────────────────────
    AbstinenceTemplate(
      id: 'junk_food',
      category: 'alimentation',
      icon: '🍕',
      nameFr: 'Junk food / Fast food',
      nameEn: 'Junk food',
      descriptionFr: 'Moins d\'inflammation, meilleure énergie et composition corporelle.',
      targetDays: 30,
      benefits: [
        AbstinenceBenefit(afterMinutes: 1440, emoji: '🌿',
            titleFr: 'Inflammation réduite', descFr: 'Les marqueurs inflammatoires commencent à baisser.'),
        AbstinenceBenefit(afterMinutes: 10080, emoji: '⚡',
            titleFr: 'Énergie stable', descFr: 'Énergie stable sans pics post-repas.'),
        AbstinenceBenefit(afterMinutes: 43200, emoji: '🔥',
            titleFr: 'Perte de graisse', descFr: 'Perte de graisse viscérale amorcée.'),
        AbstinenceBenefit(afterMinutes: 86400, emoji: '🧠',
            titleFr: 'Clarté mentale', descFr: 'Brouillard mental réduit. Meilleure concentration.'),
      ],
    ),
  ];

  static AbstinenceTemplate? findById(String id) =>
      templates.where((t) => t.id == id).firstOrNull;

  static List<AbstinenceTemplate> byCategory(String cat) =>
      templates.where((t) => t.category == cat).toList();
}
