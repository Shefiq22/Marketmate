import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:market_mate/dashboard/seller/data/mock_order.dart';
import '../models/order_model.dart';

// ── Sync mock providers (legacy, for development/testing) ──
final mockOrdersSimulateProvider = StateProvider<bool>((ref) => false);

final mockAllOrdersProvider = Provider<List<OrderModel>>((ref) {
  final hasData = ref.watch(mockOrdersSimulateProvider);
  return hasData ? mockOrders : [];
});

final mockActiveOrdersProvider = Provider<List<OrderModel>>(
  (ref) => ref
      .watch(mockAllOrdersProvider)
      .where((o) => o.tabStatus == OrderTabStatus.active)
      .toList(),
);

final mockPendingOrdersProvider = Provider<List<OrderModel>>(
  (ref) => ref
      .watch(mockAllOrdersProvider)
      .where((o) => o.tabStatus == OrderTabStatus.pending)
      .toList(),
);

final mockCompletedOrdersProvider = Provider<List<OrderModel>>(
  (ref) => ref
      .watch(mockAllOrdersProvider)
      .where((o) => o.tabStatus == OrderTabStatus.completed)
      .toList(),
);

final mockOrderHistoryProvider = Provider<List<OrderModel>>(
  (ref) => ref
      .watch(mockAllOrdersProvider)
      .where(
        (o) =>
            o.tabStatus == OrderTabStatus.completed ||
            o.tabStatus == OrderTabStatus.cancelled,
      )
      .toList(),
);
