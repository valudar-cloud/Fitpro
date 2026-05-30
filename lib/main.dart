import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'app.dart';
import 'core/security/security_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Charger les variables d'env ───────────────
  await dotenv.load(fileName: '.env');

  // ── 2. Forcer le mode portrait ───────────────────
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ── 3. Style de la barre système ─────────────────
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0D0D0D),
    ),
  );

  // ── 4. Supabase (PKCE Flow = sécurité renforcée) ──
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce, // Protection CSRF
      autoRefreshToken: true,
    ),
    debug: false, // JAMAIS true en production
  );

  // ── 5. RevenueCat (abonnements) ───────────────────
  await _initRevenueCat();

  // ── 6. Initialiser la couche sécurité ────────────
  await SecurityService.initialize();

  // ── 7. Lancer l'app ───────────────────────────────
  runApp(
    const ProviderScope(
      child: FitProApp(),
    ),
  );
}

Future<void> _initRevenueCat() async {
  await Purchases.setLogLevel(LogLevel.error); // Pas de logs sensibles

  PurchasesConfiguration config;
  if (defaultTargetPlatform == TargetPlatform.iOS) {
    config = PurchasesConfiguration(dotenv.env['REVENUECAT_IOS_KEY']!);
  } else {
    config = PurchasesConfiguration(dotenv.env['REVENUECAT_ANDROID_KEY']!);
  }

  await Purchases.configure(config);
}
