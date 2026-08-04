import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/mock_rider_deliveries.dart';
import '../models/rider_delivery_model.dart';
import '../repositories/rider_repository.dart';

final riderRepositoryProvider = Provider<RiderRepository>((ref) => RiderRepository());

final riderOnlineProvider = StateProvider<bool>((ref) => false);
final riderSimulateProvider = StateProvider<bool>((ref) => false);

final riderDeliveriesProvider = Provider<List<RiderDeliveryModel>>((ref) {
  return ref.watch(riderSimulateProvider) ? mockRiderDeliveries : [];
});

final riderActiveProvider = Provider<List<RiderDeliveryModel>>(
  (ref) => ref
      .watch(riderDeliveriesProvider)
      .where((d) => d.status == RiderDeliveryStatus.active)
      .toList(),
);

final riderPendingProvider = Provider<List<RiderDeliveryModel>>(
  (ref) => ref
      .watch(riderDeliveriesProvider)
      .where((d) => d.status == RiderDeliveryStatus.pending)
      .toList(),
);

final riderCompletedProvider = Provider<List<RiderDeliveryModel>>(
  (ref) => ref
      .watch(riderDeliveriesProvider)
      .where((d) => d.status == RiderDeliveryStatus.completed)
      .toList(),
);

final riderHistoryProvider = Provider<List<RiderDeliveryModel>>(
  (ref) => ref.watch(riderDeliveriesProvider),
);

final bankAccountsProvider = StateProvider<List<Map<String, String>>>(
  (ref) => mockBankAccounts.map((e) => Map<String, String>.from(e)).toList(),
);

final defaultBankIndexProvider = StateProvider<int>((ref) => 0);

final riderApiOrdersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(riderRepositoryProvider);
  return repo.getMyOrders();
});

final riderToggleOnlineProvider = FutureProvider.family<void, bool>((ref, online) async {
  final repo = ref.read(riderRepositoryProvider);
  await repo.updateOnlineStatus(online);
});
