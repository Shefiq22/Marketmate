import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../data/mock_products.dart';
import '../models/product_model.dart';

// ── Sync mock providers (legacy, for development/testing) ──
final mockSellerProductsProvider = Provider<List<ProductModel>>((ref) {
  final hasData = ref.watch(mockSellerSimulateProvider);
  return hasData ? mockProducts : [];
});

final mockSellerSimulateProvider = StateProvider<bool>((ref) => false);

final mockProductsByCategoryProvider = Provider.family<List<ProductModel>, String>((
  ref,
  category,
) {
  final products = ref.watch(mockSellerProductsProvider);
  if (category == 'All') return products;
  return products.where((p) => p.category == category).toList();
});

final mockInStockProductsProvider = Provider.family<List<ProductModel>, String>((
  ref,
  category,
) {
  final products = ref.watch(mockProductsByCategoryProvider(category));
  return products.where((p) => p.inStock).toList();
});

final mockOutOfStockProductsProvider = Provider.family<List<ProductModel>, String>((
  ref,
  category,
) {
  final products = ref.watch(mockProductsByCategoryProvider(category));
  return products.where((p) => !p.inStock).toList();
});

final mockBestSellersProvider = Provider<List<ProductModel>>((ref) {
  final products = ref.watch(mockSellerProductsProvider);
  return products.take(2).toList();
});
