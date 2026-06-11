# 🔐 FitPro — Documentation Sécurité

## Architecture de sécurité

### 1. Authentification
| Mécanisme | Détail |
|-----------|--------|
| Flow PKCE | Protection CSRF — aucun token en URL |
| JWT auto-refresh | Tokens renouvelés automatiquement |
| Stockage tokens | flutter_secure_storage (jamais SharedPrefs) |
| Biométrie | Face ID / Empreinte (local_auth) |
| Google OAuth | Délègue à Google — pas de mot de passe stocké |

### 2. Stockage local
- **iOS** : Keychain (AES-256), `first_unlock_this_device`
- **Android** : EncryptedSharedPreferences via Android Keystore
- **Clé de chiffrement** : Générée dans le Secure Enclave — jamais exportable
- **Réinstallation** : Détection et nettoyage automatique du Keychain iOS

### 3. Base de données (Supabase RLS)
Chaque table a une politique **Row Level Security** :
```sql
-- Exemple : un utilisateur ne peut lire QUE ses propres séances
CREATE POLICY "sessions_own" ON workout_sessions
  FOR ALL USING (auth.uid() = user_id);
```
→ Même si la clé `anon` est compromise, **aucune donnée d'autres utilisateurs n'est accessible**.

### 4. Réseau
- **TLS 1.3** obligatoire sur toutes les requêtes Supabase
- **Certificate pinning** recommandé pour la production (package `http_certificate_pinning`)
- **Aucune donnée sensible** dans les URLs (query params)

### 5. Validation des inputs
```dart
// Email
RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')

// Mot de passe : 8+ chars, majuscule, chiffre, spécial
SecurityService.isValidPassword(password)

// Sanitisation anti-XSS
SecurityService.sanitizeInput(input) // Retire < > " '
```

### 6. Build de production
```bash
# Obfuscation du code (obligatoire)
flutter build ipa --obfuscate --split-debug-info=build/debug-info
flutter build appbundle --obfuscate --split-debug-info=build/debug-info
```

### 7. Variables d'environnement
- `.env` **jamais commité** (dans `.gitignore`)
- Clés Supabase anon : **publiques par conception** (protégées par RLS)
- Clés privées (Stripe, RevenueCat secret) : **uniquement côté serveur** (Edge Functions)

### 8. Conformité
- **RGPD** : Suppression de compte → cascade DELETE sur toutes les tables
- **App Store / Google Play** : Pas de stockage de données de paiement (RevenueCat gère)
- **Logs** : Aucune donnée sensible (emails masqués, pas de tokens)

## Checklist avant publication

- [ ] `debug: false` dans `Supabase.initialize()`
- [ ] Clés de production dans `.env` (pas les clés de test)
- [ ] Obfuscation activée dans le build
- [ ] Rate limiting activé sur Supabase (Dashboard → Auth Settings)
- [ ] Email confirmation activée pour les nouveaux comptes
- [ ] Webhook Stripe/RevenueCat configuré sur Edge Function (pas Flutter)
- [ ] Politique de confidentialité publiée (obligatoire App Store)
