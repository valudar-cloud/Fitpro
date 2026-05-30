# 💪 FitPro — Application Fitness Personnalisée

## Stack Technique
| Couche | Technologie | Rôle |
|--------|-------------|------|
| Mobile | Flutter 3.x (Dart) | iOS + Android |
| Backend | Supabase | Auth, BDD, Storage |
| Paiements | RevenueCat + Stripe | Abonnements in-app |
| Sécurité | flutter_secure_storage + RLS | Chiffrement + isolation données |
| État | Riverpod 2.x | Gestion d'état réactive |
| Navigation | GoRouter | Navigation déclarative |

## Structure du Projet
```
fitpro/
├── lib/
│   ├── main.dart                     # Point d'entrée + init sécurité
│   ├── app.dart                      # Router + Theme + Localisation
│   ├── core/
│   │   ├── constants/app_constants.dart
│   │   ├── security/security_service.dart   # Couche sécurité
│   │   ├── theme/app_theme.dart
│   │   ├── router/app_router.dart
│   │   └── localization/app_strings.dart   # FR + EN
│   └── features/
│       ├── auth/           # Login, Register, Auth provider
│       ├── onboarding/     # Objectif, lieu, douleurs
│       ├── exercises/      # Librairie + détail exercices
│       ├── home/           # Dashboard principal
│       ├── calendar/       # Programme personnel
│       ├── profile/        # Profil utilisateur
│       └── subscription/   # Paywall freemium
├── supabase/
│   ├── schema.sql          # BDD complète avec RLS
│   └── seed_exercises.sql  # ~60 exercices de base
└── docs/
    └── SECURITY.md         # Documentation sécurité
```

## Sécurité Implémentée
- ✅ Auth PKCE flow (Supabase)
- ✅ Row Level Security — chaque utilisateur ne voit QUE ses données
- ✅ flutter_secure_storage (AES-256 iOS Keychain / Android Keystore)
- ✅ Certificate pinning (MITM protection)
- ✅ Tokens JWT auto-refresh
- ✅ Aucune donnée sensible dans les logs
- ✅ Rate limiting côté Supabase
- ✅ Input sanitization sur tous les formulaires
- ✅ Obfuscation du code en production

## Installation

### 1. Prérequis
```bash
flutter --version  # >= 3.19.0
dart --version     # >= 3.3.0
```

### 2. Clone et dépendances
```bash
git clone <repo>
cd fitpro
flutter pub get
```

### 3. Variables d'environnement
```bash
cp .env.example .env
# Remplir avec vos clés Supabase, RevenueCat, Stripe
```

### 4. Supabase
- Créer un projet sur supabase.com
- Exécuter `supabase/schema.sql` dans l'éditeur SQL
- Exécuter `supabase/seed_exercises.sql`

### 5. RevenueCat
- Créer un projet sur app.revenuecat.com
- Configurer les produits iOS (App Store Connect) et Android (Google Play)
- Ajouter les identifiants dans `.env`

### 6. Build
```bash
# Debug
flutter run

# Release iOS
flutter build ipa --obfuscate --split-debug-info=build/debug-info

# Release Android
flutter build appbundle --obfuscate --split-debug-info=build/debug-info
```

## Modèle Freemium
| Fonctionnalité | Gratuit | Premium |
|----------------|---------|---------|
| Exercices de base | ✅ 20 exercices | ✅ 60+ exercices |
| Suivi objectif | ✅ 1 objectif | ✅ Tous les objectifs |
| Calendrier | ✅ 1 programme | ✅ Programmes illimités |
| GIF animés | ❌ | ✅ |
| Gestion douleurs | ✅ Basique | ✅ Avancée |
| Stats & progression | ❌ | ✅ |
| Prix | Gratuit | 9,99€/mois ou 59,99€/an |
