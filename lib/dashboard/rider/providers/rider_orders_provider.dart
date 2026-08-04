import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'rider_dashboard_provider.dart';

class RiderOrdersState {
  final List<Map<String, dynamic>> orders;
  final bool isLoading;
  final String? error;

  const RiderOrdersState({
    this.orders = const [],
    this.isLoading = false,
    this.error,
  });

  RiderOrdersState copyWith({
    List<Map<String, dynamic>>? orders,
    bool? isLoading,
    String? error,
  }) {
    return RiderOrdersState(
      orders: orders ?? this.orders,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

final riderOrdersProvider = NotifierProvider<RiderOrdersNotifier, RiderOrdersState>(
  RiderOrdersNotifier.new,
);

class RiderOrdersNotifier extends Notifier<RiderOrdersState> {
  @override
  RiderOrdersState build() => const RiderOrdersState(isLoading: true);

  Future<void> loadOrders({String? status}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(riderRepositoryProvider);
      final orders = await repo.getMyOrders(status: status);
      state = RiderOrdersState(orders: orders, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> confirmPickup(String orderId) async {
    try {
      final repo = ref.read(riderRepositoryProvider);
      await repo.confirmPickup(orderId);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> markArrived(String orderId) async {
    try {
      final repo = ref.read(riderRepositoryProvider);
      await repo.markArrived(orderId);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> completeDelivery(String orderId) async {
    try {
      final repo = ref.read(riderRepositoryProvider);
      await repo.completeOrder(orderId);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> acceptOrder(String orderId) async {
    try {
      final repo = ref.read(riderRepositoryProvider);
      await repo.acceptOrder(orderId);
      await loadOrders();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}
