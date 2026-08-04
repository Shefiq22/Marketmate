import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/rider_model.dart';
import '../data/mock_riders.dart';

final riderSimulateProvider = StateProvider<bool>((ref) => false);

final availableRidersProvider = Provider<List<RiderModel>>((ref) {
  return ref.watch(riderSimulateProvider) ? mockRidersNearby : [];
});

final bestRiderProvider = Provider<RiderModel?>((ref) {
  final riders = ref.watch(availableRidersProvider);
  if (riders.isEmpty) return null;
  return riders.reduce(
    (a, b) =>
        (a.rating * 10 + a.completedDeliveries) >
            (b.rating * 10 + b.completedDeliveries)
        ? a
        : b,
  );
});

final selectedLocationProvider = StateProvider<String?>((ref) => null);
final assignedRiderProvider = StateProvider<RiderModel?>((ref) => null);
