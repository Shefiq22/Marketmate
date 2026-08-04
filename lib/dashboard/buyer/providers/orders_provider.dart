import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/orders_repository.dart';

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
