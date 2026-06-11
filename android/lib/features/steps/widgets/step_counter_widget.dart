import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/step_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/constants/app_constants.dart';

class StepCounterWidget extends ConsumerWidget {
  const StepCounterWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(stepProvider);

    return GestureDetector(
      onTap: () => context.push(AppConstants.routeSteps),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            const Color(0xFF4ECDC4).withOpacity(0.15),
            const Color(0xFF2ED573).withOpacity(0.08),
          ]),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF4ECDC4).withOpacity(0.3)),
        ),
        child: Row(children: [
          Stack(alignment: Alignment.center, children: [
            SizedBox(width: 52, height: 52,
              child: CircularProgressIndicator(
                value: data.progressToGoal, strokeWidth: 4,
                backgroundColor: AppTheme.border,
                valueColor: AlwaysStoppedAnimation(
                    data.goalReached ? AppTheme.secondary : const Color(0xFF4ECDC4)))),
            Text(data.status == 'walking' ? '🚶' : '👟',
                style: const TextStyle(fontSize: 22)),
          ]),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(
                data.isAvailable ? '${data.stepsToday} pas' : 'Pas disponible',
                style: const TextStyle(color: Colors.white,
                    fontWeight: FontWeight.w700, fontSize: 16)),
              if (data.goalReached) ...[
                const SizedBox(width: 6),
                const Text('⭐', style: TextStyle(fontSize: 14))],
            ]),
            if (data.isAvailable)
              Text('🔥 ${data.caloriesBurned.toStringAsFixed(0)} kcal  '
                  '📍 ${data.distanceKm.toStringAsFixed(2)} km',
                  style: const TextStyle(color: Colors.white54, fontSize: 12)),
            if (!data.isAvailable)
              const Text('Autoriser l\'accès aux données d\'activité',
                  style: TextStyle(color: Colors.white38, fontSize: 12)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('${(data.progressToGoal * 100).toInt()}%',
                style: TextStyle(
                    color: data.goalReached ? AppTheme.secondary : const Color(0xFF4ECDC4),
                    fontWeight: FontWeight.w700, fontSize: 14)),
            const Text('objectif',
                style: TextStyle(color: Colors.white38, fontSize: 10)),
            const SizedBox(height: 4),
            const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12),
          ]),
        ]),
      ),
    );
  }
}
