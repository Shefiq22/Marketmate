import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../repositories/products_repository.dart';

final productsRepositoryProvider = Provider<ProductsRepository>((ref) {
  return ProductsRepository();
});

final productsProvider = FutureProvider<List<Product>>((ref) async {
  final repo = ref.watch(productsRepositoryProvider);
  return repo.getAll();
});

final productDetailProvider = FutureProvider.family<Product, String>((
  ref,
  id,
) async {
  final repo = ref.watch(productsRepositoryProvider);
  return repo.getById(id);
});

final productsByCategoryProvider = FutureProvider.family<List<Product>, String>(
  (ref, category) async {
    final repo = ref.watch(productsRepositoryProvider);
    return repo.getAll(category: category);
  },
);

List<Vendor> _groupProductsByVendor(List<Product> products) {
  final map = <String, List<Product>>{};
  for (final p in products) {
    if (p.sellerId == null || p.sellerId!.isEmpty) continue;
    map.putIfAbsent(p.sellerId!, () => []).add(p);
  }
  return map.entries.map((e) {
    final prods = e.value;
    final first = prods.first;
    final cats = prods.map((p) => p.category.toLowerCase()).toSet().toList()
      ..sort();
    final avgRating = prods.fold<double>(
          0,
          (sum, p) => sum + p.rating,
        ) /
        prods.length;
    return Vendor(
      sellerId: e.key,
      sellerName: first.sellerName ?? 'Store',
      products: prods,
      averageRating: avgRating,
      deliveryFee: first.deliveryClass,
      imageUrl: first.images.isNotEmpty ? first.images.first : null,
      categories: cats,
    );
  }).toList()
    ..sort((a, b) => b.products.length.compareTo(a.products.length));
}

final vendorsProvider = Provider<List<Vendor>>((ref) {
  final products = ref.watch(productsProvider).asData?.value ?? [];
  return _groupProductsByVendor(products);
});

final filteredVendorsProvider =
    Provider.family<List<Vendor>, String>((ref, category) {
  final vendors = ref.watch(vendorsProvider);
  if (category == 'all') return vendors;
  return vendors
      .where((v) => v.categories.contains(category.toLowerCase()))
      .toList();
});
