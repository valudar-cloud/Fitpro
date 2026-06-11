import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/constants/app_constants.dart';

class PaywallScreen extends ConsumerStatefulWidget {
  const PaywallScreen({super.key});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  List<Package> _packages = [];
  Package? _selectedPackage;
  bool _isLoading = true;
  bool _isPurchasing = false;
  String? _errorMsg;

  @override
  void initState() {
    super.initState();
    _loadOfferings();
  }

  Future<void> _loadOfferings() async {
    try {
      final offerings = await Purchases.getOfferings();
      final current = offerings.current;
      if (current != null) {
        setState(() {
          _packages = current.availablePackages;
          // Sélectionne l'annuel par défaut (meilleure valeur)
          _selectedPackage = _packages.firstWhere(
            (p) => p.packageType == PackageType.annual,
            orElse: () => _packages.first,
          );
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMsg = 'Impossible de charger les offres';
      });
    }
  }

  Future<void> _purchase() async {
    if (_selectedPackage == null) return;
    setState(() => _isPurchasing = true);

    try {
      final result = await Purchases.purchasePackage(_selectedPackage!);
      final isPremium = result.entitlements.active
          .containsKey(AppConstants.premiumEntitlement);

      if (isPremium && mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('🎉 Premium activé ! Profite de tout FitPro'),
            backgroundColor: const Color(0xFFFFD700),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } on PurchasesErrorCode catch (e) {
      if (e != PurchasesErrorCode.purchaseCancelledError) {
        setState(() => _errorMsg = 'Erreur lors de l\'achat');
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  Future<void> _restore() async {
    setState(() => _isPurchasing = true);
    try {
      final result = await Purchases.restorePurchases();
      final isPremium = result.entitlements.active
          .containsKey(AppConstants.premiumEntitlement);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(isPremium
              ? '✅ Achats restaurés !'
              : 'Aucun achat trouvé'),
          backgroundColor:
              isPremium ? AppTheme.secondary : AppTheme.surface,
          behavior: SnackBarBehavior.floating,
        ));
        if (isPremium) context.pop();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _errorMsg = 'Erreur lors de la restauration');
      }
    } finally {
      if (mounted) setState(() => _isPurchasing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(sProvider);

    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [

              // ─ Header ─────────────────────────
              Stack(
                children: [
                  Container(
                    height: 280,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFFFD700), Color(0xFF0D0D0D)],
                        stops: [0.0, 1.0],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white70),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  Positioned.fill(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('👑',
                            style: TextStyle(fontSize: 64))
                            .animate(onPlay: (c) => c.repeat(reverse: true))
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1.05, 1.05),
                              duration: 1.seconds,
                            ),
                        const SizedBox(height: 12),
                        Text(s.paywallTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            )),
                        Text(s.paywallSubtitle,
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [

                    const SizedBox(height: 20),

                    // ─ Features ─────────────────
                    ..._features.map((f) => _FeatureRow(f))
                        .toList()
                        .animate(interval: 60.ms)
                        .slideX(begin: -0.2)
                        .fadeIn(),

                    const SizedBox(height: 28),

                    // ─ Plans ──────────────────
                    if (_isLoading)
                      const CircularProgressIndicator(
                          color: Color(0xFFFFD700))
                    else if (_packages.isEmpty)
                      Text(
                        _errorMsg ?? 'Aucune offre disponible',
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 14),
                      )
                    else
                      ..._packages.map((pkg) => _PlanCard(
                            package: pkg,
                            isSelected: _selectedPackage == pkg,
                            onSelect: () =>
                                setState(() => _selectedPackage = pkg),
                          )).toList(),

                    const SizedBox(height: 20),

                    // ─ Bouton achat ───────────
                    ElevatedButton(
                      onPressed:
                          _isPurchasing || _selectedPackage == null
                              ? null
                              : _purchase,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFFD700),
                        foregroundColor: Colors.black,
                        minimumSize: const Size(double.infinity, 58),
                      ),
                      child: _isPurchasing
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(
                                  color: Colors.black, strokeWidth: 2.5),
                            )
                          : Text(s.subscribeBtn,
                              style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700)),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                    const SizedBox(height: 12),

                    TextButton(
                      onPressed: _isPurchasing ? null : _restore,
                      child: Text(s.restoreBtn,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 13)),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      '${s.cancelAnytime} • Conforme RGPD',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                    ),

                    if (_errorMsg != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(_errorMsg!,
                            style: const TextStyle(
                                color: AppTheme.danger, fontSize: 12)),
                      ),

                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Features premium ──────────────────────────────────
const _features = [
  ('💪', '60+ exercices avec GIF animés', 'vs 20 en gratuit'),
  ('🎯', 'Tous les objectifs simultanément', 'Renforcement, perte gras, masse'),
  ('📅', 'Programmes illimités', 'vs 1 en gratuit'),
  ('📊', 'Stats & graphiques de progression', 'Suivi complet'),
  ('⚔️', 'Quêtes exclusives Premium', 'XP boostée'),
  ('🩹', 'Gestion avancée des blessures', 'Filtres intelligents'),
  ('☁️', 'Synchronisation multi-appareils', 'Partout avec toi'),
];

class _FeatureRow extends StatelessWidget {
  final (String, String, String) feature;
  const _FeatureRow(this.feature);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Text(feature.$1, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(feature.$2,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(feature.$3,
                    style: const TextStyle(
                        color: Colors.white38, fontSize: 12)),
              ],
            ),
          ),
          const Icon(Icons.check_circle,
              color: Color(0xFFFFD700), size: 20),
        ],
      ),
    );
  }
}

// ── Carte de plan ─────────────────────────────────────
class _PlanCard extends StatelessWidget {
  final Package package;
  final bool isSelected;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.package,
    required this.isSelected,
    required this.onSelect,
  });

  bool get isAnnual => package.packageType == PackageType.annual;

  @override
  Widget build(BuildContext context) {
    final price = package.storeProduct.priceString;
    final period = isAnnual ? 'an' : 'mois';

    return GestureDetector(
      onTap: onSelect,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFFFD700).withOpacity(0.1)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFFFFD700) : AppTheme.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            // Radio
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFFFFD700)
                      : Colors.white38,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFD700),
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        isAnnual ? 'Annuel' : 'Mensuel',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                      if (isAnnual) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTheme.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Économise 17%',
                            style: TextStyle(
                                color: AppTheme.secondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ],
                  ),
                  Text(
                    '$price / $period',
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFFFFD700)
                          : Colors.white54,
                      fontSize: 14,
                    ),
                  ),
                  if (isAnnual)
                    Text(
                      '= ${(package.storeProduct.price > 0 ? package.storeProduct.price / 12 : 49.99 / 12).toStringAsFixed(2)}€ / mois',
                      style: const TextStyle(
                          color: Colors.white38, fontSize: 11),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
