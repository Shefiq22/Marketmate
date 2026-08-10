import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/orders_repository.dart';

/// TODO(backend): confirm the exact status the order carries once the rider
/// marks delivery complete and BEFORE the customer confirms via
/// PATCH /orders/:id/customer-complete. Update this list — nothing else
/// needs to change once confirmed.
const List<String> kOrderAwaitingCustomerConfirmationStatuses = ['delivered'];

bool orderAwaitsCustomerConfirmation(String status) =>
    kOrderAwaitingCustomerConfirmationStatuses.contains(status);

final ordersRepositoryProvider = Provider<OrdersRepository>((ref) {
  return OrdersRepository();
});

final ordersProvider = FutureProvider<List<Order>>((ref) async {
  final repo = ref.watch(ordersRepositoryProvider);
  return repo.getAll();
});

final ordersByStatusProvider = FutureProvider.family<List<Order>, String>((
  ref,
  status,
) async {
  final repo = ref.watch(ordersRepositoryProvider);
  return repo.getAll(status: status);
});

final orderDetailProvider = FutureProvider.family<Order, String>((
  ref,
  id,
) async {
  final repo = ref.watch(ordersRepositoryProvider);
  return repo.getById(id);
});
