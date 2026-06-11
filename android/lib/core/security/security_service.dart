import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// ════════════════════════════════════════════════════════
// SERVICE SÉCURITÉ — Chiffrement, Stockage sécurisé
// ════════════════════════════════════════════════════════

class SecurityService {
  SecurityService._();

  static late FlutterSecureStorage _storage;
  static bool _initialized = false;

  // ── Initialisation ────────────────────────────────────
  static Future<void> initialize() async {
    if (_initialized) return;

    const iOSOptions = IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false, // Jamais synchronisé iCloud
    );

    const androidOptions = AndroidOptions(
      encryptedSharedPreferences: true,   // AES-256 via Android Keystore
      storageCipherAlgorithm: StorageCipherAlgorithm.AES_GCM_NoPadding,
      keyCipherAlgorithm: KeyCipherAlgorithm.RSA_ECB_OAEPwithSHA_256andMGF1Padding,
    );

    _storage = const FlutterSecureStorage(
      iOptions: iOSOptions,
      aOptions: androidOptions,
    );

    _initialized = true;

    // Effacer les données si réinstallation (iOS garde le Keychain)
    await _handleReinstall();

    debugPrint('[Security] ✅ Initialisé');
  }

  // ── Stockage sécurisé ─────────────────────────────────
  static Future<void> write(String key, String value) async {
    _assertInitialized();
    await _storage.write(key: key, value: value);
  }

  static Future<String?> read(String key) async {
    _assertInitialized();
    return _storage.read(key: key);
  }

  static Future<void> delete(String key) async {
    _assertInitialized();
    await _storage.delete(key: key);
  }

  static Future<void> deleteAll() async {
    _assertInitialized();
    await _storage.deleteAll();
  }

  // ── Sérialisation sécurisée ───────────────────────────
  static Future<void> writeJson(String key, Map<String, dynamic> data) async {
    await write(key, jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> readJson(String key) async {
    final raw = await read(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ── Réinstallation iOS ────────────────────────────────
  // iOS conserve le Keychain après désinstallation
  // On stocke un flag en SharedPrefs pour détecter une réinstall
  static Future<void> _handleReinstall() async {
    const installKey = '_fitpro_installed';
    final existing = await _storage.read(key: installKey);
    if (existing == null) {
      // Première installation ou réinstallation → nettoyer
      await _storage.deleteAll();
      await _storage.write(key: installKey, value: '1');
    }
  }

  // ── Clés de stockage ──────────────────────────────────
  static const String keySessionToken      = 'session_token';
  static const String keyRefreshToken      = 'refresh_token';
  static const String keyBiometricEnabled  = 'biometric_enabled';
  static const String keyUserPreferences   = 'user_preferences';

  // ── Validation inputs ────────────────────────────────
  static bool isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email.trim());
  }

  static bool isValidPassword(String password) {
    // Min 8 caractères, 1 majuscule, 1 chiffre, 1 spécial
    return password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password) &&
        RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password);
  }

  static String sanitizeInput(String input) {
    return input
        .trim()
        .replaceAll(RegExp(r'[<>]'), '') // Anti XSS
        .substring(0, input.length.clamp(0, 500));
  }

  // ── Masquage données sensibles pour les logs ─────────
  static String maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***';
    final name = parts[0];
    final masked = name.length > 2
        ? '${name[0]}${'*' * (name.length - 2)}${name[name.length - 1]}'
        : '***';
    return '$masked@${parts[1]}';
  }

  static void _assertInitialized() {
    assert(_initialized, 'SecurityService non initialisé — appeler initialize() d\'abord');
  }
}
