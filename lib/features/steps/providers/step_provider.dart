import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// ════════════════════════════════════════════════════════
// STEP COUNTER PROVIDER — Capteur natif + Calories
// ════════════════════════════════════════════════════════

class StepData {
  final int stepsToday;
  final int stepsTotal;
  final double caloriesBurned;
  final double distanceKm;
  final bool isAvailable;
  final String status; // 'walking', 'stopped', 'unknown'
  final DateTime lastUpdated;

  const StepData({
    this.stepsToday = 0,
    this.stepsTotal = 0,
    this.caloriesBurned = 0.0,
    this.distanceKm = 0.0,
    this.isAvailable = false,
    this.status = 'unknown',
    required this.lastUpdated,
  });

  // Objectif quotidien par défaut
  static const int dailyGoal = 10000;
  double get progressToGoal => (stepsToday / dailyGoal).clamp(0.0, 1.0);
  bool get goalReached => stepsToday >= dailyGoal;

  StepData copyWith({
    int? stepsToday, int? stepsTotal, double? caloriesBurned,
    double? distanceKm, bool? isAvailable, String? status,
    DateTime? lastUpdated,
  }) => StepData(
    stepsToday: stepsToday ?? this.stepsToday,
    stepsTotal: stepsTotal ?? this.stepsTotal,
    caloriesBurned: caloriesBurned ?? this.caloriesBurned,
    distanceKm: distanceKm ?? this.distanceKm,
    isAvailable: isAvailable ?? this.isAvailable,
    status: status ?? this.status,
    lastUpdated: lastUpdated ?? this.lastUpdated,
  );
}

class StepNotifier extends StateNotifier<StepData> {
  StepNotifier() : super(StepData(lastUpdated: DateTime.now())) {
    _init();
  }

  StreamSubscription<StepCount>? _stepSub;
  StreamSubscription<PedestrianStatus>? _statusSub;

  // Poids utilisateur (en kg) pour le calcul des calories
  double _userWeightKg = 70.0;
  // Nombre de pas au début de la journée (pour isoler les pas du jour)
  int _stepsAtDayStart = 0;
  String _today = '';

  // ── Formule calories ────────────────────────────────
  // MET marche = 3.5, formule : Cal = MET × poids(kg) × 0.0175 × temps(min)
  // Simplifiée par pas : Cal ≈ 0.04 × poids(kg)/70 × pas
  double _calcCalories(int steps) {
    return steps * 0.04 * (_userWeightKg / 70.0);
  }

  // Distance en km (pas moyen = 0.75m)
  double _calcDistance(int steps) {
    return (steps * 0.75) / 1000.0;
  }

  Future<void> _init() async {
    await _loadSavedData();
    await _loadUserWeight();
    await _requestPermission();
  }

  Future<void> _loadSavedData() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();
    final savedDay = prefs.getString('steps_date') ?? '';

    if (savedDay == today) {
      _stepsAtDayStart = prefs.getInt('steps_day_start') ?? 0;
      final stepsToday = prefs.getInt('steps_today') ?? 0;
      state = state.copyWith(
        stepsToday: stepsToday,
        caloriesBurned: _calcCalories(stepsToday),
        distanceKm: _calcDistance(stepsToday),
        lastUpdated: DateTime.now(),
      );
    } else {
      // Nouveau jour — reset
      await prefs.setString('steps_date', today);
      await prefs.setInt('steps_today', 0);
      _today = today;
    }
  }

  Future<void> _loadUserWeight() async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;
      final data = await Supabase.instance.client
          .from('profiles')
          .select('weight_kg')
          .eq('id', uid)
          .single();
      if (data['weight_kg'] != null) {
        _userWeightKg = (data['weight_kg'] as num).toDouble();
      }
    } catch (_) {
      // Utilise le poids par défaut
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      _startListening();
    } else {
      state = state.copyWith(isAvailable: false, status: 'permission_denied');
    }
  }

  void _startListening() {
    // Écoute les pas
    _stepSub = Pedometer.stepCountStream.listen(
      _onStepCount,
      onError: (e) {
        state = state.copyWith(isAvailable: false, status: 'unavailable');
      },
    );

    // Écoute le statut (marche / arrêt)
    _statusSub = Pedometer.pedestrianStatusStream.listen(
      (event) => state = state.copyWith(status: event.status),
      onError: (_) => state = state.copyWith(status: 'unknown'),
    );

    state = state.copyWith(isAvailable: true);
  }

  Future<void> _onStepCount(StepCount event) async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayString();

    // Nouveau jour
    if (today != _today) {
      _today = today;
      _stepsAtDayStart = event.steps;
      await prefs.setString('steps_date', today);
      await prefs.setInt('steps_day_start', _stepsAtDayStart);
    }

    // Initialise le début de journée si premier lancement
    if (_stepsAtDayStart == 0 && event.steps > 0) {
      final savedStart = prefs.getInt('steps_day_start') ?? 0;
      if (savedStart == 0) {
        _stepsAtDayStart = event.steps;
        await prefs.setInt('steps_day_start', _stepsAtDayStart);
      } else {
        _stepsAtDayStart = savedStart;
      }
    }

    final stepsToday = (event.steps - _stepsAtDayStart).clamp(0, 999999);
    await prefs.setInt('steps_today', stepsToday);

    // Sauvegarder en BDD quotidiennement (pour stats)
    _saveToDatabase(stepsToday);

    state = state.copyWith(
      stepsToday: stepsToday,
      stepsTotal: event.steps,
      caloriesBurned: _calcCalories(stepsToday),
      distanceKm: _calcDistance(stepsToday),
      isAvailable: true,
      lastUpdated: DateTime.now(),
    );
  }

  Future<void> _saveToDatabase(int steps) async {
    try {
      final uid = Supabase.instance.client.auth.currentUser?.id;
      if (uid == null) return;
      await Supabase.instance.client.from('daily_steps').upsert({
        'user_id': uid,
        'date': _todayString(),
        'steps': steps,
        'calories': _calcCalories(steps),
        'distance_km': _calcDistance(steps),
        'updated_at': DateTime.now().toIso8601String(),
      }, onConflict: 'user_id, date');
    } catch (_) {
      // Silencieux — pas critique
    }
  }

  String _todayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2,'0')}-${now.day.toString().padLeft(2,'0')}';
  }

  @override
  void dispose() {
    _stepSub?.cancel();
    _statusSub?.cancel();
    super.dispose();
  }
}

final stepProvider = StateNotifierProvider<StepNotifier, StepData>(
  (ref) => StepNotifier(),
);

// Provider historique 7 jours
final stepsHistoryProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final uid = Supabase.instance.client.auth.currentUser?.id;
  if (uid == null) return [];
  final data = await Supabase.instance.client
      .from('daily_steps')
      .select()
      .eq('user_id', uid)
      .order('date', ascending: false)
      .limit(7);
  return List<Map<String, dynamic>>.from(data);
});
