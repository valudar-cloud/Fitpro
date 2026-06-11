import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Conditions générales'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _Section('1. Présentation', '''
FitPro est une application mobile de fitness personnalisée éditée par FitPro SAS. Elle permet à ses utilisateurs de suivre leurs entraînements, de gérer leur programme sportif et d'accéder à une bibliothèque d'exercices.

En utilisant FitPro, vous acceptez sans réserve les présentes conditions générales d'utilisation (CGU).'''),

          _Section('2. Inscription et compte', '''
Pour utiliser FitPro, vous devez créer un compte en fournissant une adresse email valide et un mot de passe sécurisé. Vous êtes responsable de la confidentialité de vos identifiants et de toute activité effectuée depuis votre compte.

Vous devez avoir au moins 16 ans pour créer un compte. En vous inscrivant, vous garantissez avoir l'âge requis.'''),

          _Section('3. Abonnement Premium', '''
FitPro propose une offre gratuite limitée et un abonnement Premium payant disponible en formule mensuelle ou annuelle.

L'abonnement Premium est renouvelé automatiquement à chaque période sauf résiliation. Vous pouvez résilier à tout moment via votre compte App Store ou Google Play. Aucun remboursement ne sera accordé pour la période en cours.

Les prix sont affichés TTC et peuvent être modifiés à tout moment. Toute modification tarifaire vous sera notifiée avec un préavis de 30 jours.'''),

          _Section('4. Utilisation de l\'application', '''
FitPro est destiné à un usage personnel et non commercial. Vous vous engagez à :
• Ne pas partager votre compte avec d'autres personnes
• Ne pas tenter de contourner les mesures de sécurité
• Ne pas utiliser l'application à des fins illégales
• Consulter un médecin avant de commencer tout programme sportif

FitPro décline toute responsabilité en cas de blessure résultant de l'utilisation des programmes d'entraînement.'''),

          _Section('5. Données personnelles', '''
FitPro collecte et traite vos données personnelles conformément au Règlement Général sur la Protection des Données (RGPD).

Données collectées : email, nom, données de santé (objectifs, blessures), historique d'entraînement.

Ces données sont utilisées exclusivement pour le fonctionnement de l'application et ne sont jamais vendues à des tiers.

Conformément au RGPD, vous disposez d'un droit d'accès, de rectification, de suppression et de portabilité de vos données. Pour exercer ces droits, contactez-nous à : privacy@fitpro.app

Vos données sont supprimées dans un délai de 30 jours suivant la fermeture de votre compte.'''),

          _Section('6. Propriété intellectuelle', '''
Tous les contenus de FitPro (textes, images, GIFs, code, marques) sont la propriété exclusive de FitPro SAS et sont protégés par le droit de la propriété intellectuelle.

Toute reproduction, modification ou utilisation non autorisée est strictement interdite.'''),

          _Section('7. Disponibilité du service', '''
FitPro s'efforce d'assurer une disponibilité maximale de ses services. Toutefois, des interruptions pour maintenance ou en cas de force majeure peuvent survenir.

FitPro ne saurait être tenu responsable des dommages résultant d'une indisponibilité temporaire du service.'''),

          _Section('8. Modification des CGU', '''
FitPro se réserve le droit de modifier les présentes CGU à tout moment. Les modifications prennent effet dès leur publication dans l'application. L'utilisation continue de FitPro après modification vaut acceptation des nouvelles CGU.'''),

          _Section('9. Droit applicable', '''
Les présentes CGU sont soumises au droit français. Tout litige sera soumis à la compétence exclusive des tribunaux français.

Pour toute question : support@fitpro.app'''),

          SizedBox(height: 20),
          Text(
            'Dernière mise à jour : Juin 2025',
            style: TextStyle(color: Colors.white38, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        title: const Text('Politique de confidentialité'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          _Section('Données collectées', '''
Nous collectons les informations suivantes :
• Informations de compte : email, nom complet
• Données de santé : objectif fitness, blessures/douleurs, niveau de forme
• Données d'utilisation : séances effectuées, exercices réalisés, progression
• Données techniques : type d'appareil, version de l'OS (anonymisées)'''),

          _Section('Utilisation des données', '''
Vos données sont utilisées pour :
• Personnaliser votre expérience et vos recommandations d'exercices
• Calculer votre progression et vos statistiques
• Améliorer l'application (données anonymisées uniquement)
• Envoyer des notifications de rappel (avec votre accord)'''),

          _Section('Stockage et sécurité', '''
Vos données sont stockées sur des serveurs sécurisés (Supabase) situés dans l'Union Européenne.

Nous appliquons les mesures de sécurité suivantes :
• Chiffrement AES-256 des données sensibles
• Authentification sécurisée (PKCE)
• Isolation des données par utilisateur (Row Level Security)
• Aucun mot de passe stocké en clair'''),

          _Section('Partage des données', '''
Vos données ne sont jamais vendues. Elles peuvent être partagées avec :
• Supabase (hébergement BDD) — politique RGPD compliant
• RevenueCat (gestion abonnements) — identifiant anonyme uniquement
• Stripe (paiements) — données de paiement uniquement

Aucun partage avec des annonceurs publicitaires.'''),

          _Section('Vos droits', '''
Conformément au RGPD, vous pouvez à tout moment :
• Accéder à vos données : Profil → Paramètres → Mes données
• Rectifier vos données : directement dans l'application
• Supprimer votre compte : Profil → Paramètres → Supprimer mon compte
• Exporter vos données : contactez privacy@fitpro.app
• Retirer votre consentement aux notifications : Paramètres du téléphone'''),

          SizedBox(height: 20),
          Text(
            'Contact DPO : privacy@fitpro.app\nDernière mise à jour : Juin 2025',
            style: TextStyle(color: Colors.white38, fontSize: 12),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String content;
  const _Section(this.title, this.content);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.primary,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
