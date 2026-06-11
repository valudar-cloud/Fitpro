import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/abstinence_model.dart';

final _db = Supabase.instance.client;

// ── Liste des trackers actifs ─────────────────────────
final abstinenceListProvider =
    StreamProvider.autoDispose<List<AbstinenceTracker>>((ref) {
  final uid = _db.auth.currentUser?.id;
  if (uid == null) return Stream.value([]);
  return _db
      .from('abstinence_trackers')
      .stream(primaryKey: ['id'])
      .eq('user_id', uid)
      .map((data) => data
          .where((d) => d['is_active'] == true)
          .map((d) => AbstinenceTracker.fromJson(d))
          .toList()
        ..sort((a, b) => b.startDate.compareTo(a.startDate)));
});

// ── Notifier CRUD ─────────────────────────────────────
class AbstinenceNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  // Créer un tracker
  Future<void> create({
    required String name,
    required String icon,
    required String category,
    DateTime? startDate,
    String? note,
  }) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return;
    await _db.from('abstinence_trackers').insert({
      'user_id': uid,
      'name': name,
      'icon': icon,
      'category': category,
      'start_date': (startDate ?? DateTime.now()).toIso8601String(),
      'is_active': true,
      'custom_note': note,
    });
  }

  // Réinitialiser (rechute)
  Future<void> reset(String id) async {
    await _db.from('abstinence_trackers').update({
      'start_date': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // Renommer
  Future<void> rename(String id, String newName) async {
    await _db.from('abstinence_trackers')
        .update({'name': newName}).eq('id', id);
  }

  // Supprimer
  Future<void> delete(String id) async {
    await _db.from('abstinence_trackers')
        .update({'is_active': false}).eq('id', id);
  }

  // Modifier la date de début
  Future<void> updateStartDate(String id, DateTime date) async {
    await _db.from('abstinence_trackers')
        .update({'start_date': date.toIso8601String()}).eq('id', id);
  }
}

final abstinenceNotifierProvider =
    AsyncNotifierProvider<AbstinenceNotifier, void>(AbstinenceNotifier.new);
