import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/localization/app_strings.dart';

// ════════════════════════════════════════════════════════
// APP ROOT
// ════════════════════════════════════════════════════════

class FitProApp extends ConsumerWidget {
  const FitProApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'FitPro',
      debugShowCheckedModeBanner: false,

      // ── Thème ──────────────────────────────────────
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,

      // ── Localisation ───────────────────────────────
      locale: locale,
      supportedLocales: const [Locale('fr'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Router ─────────────────────────────────────
      routerConfig: router,
    );
  }
}
