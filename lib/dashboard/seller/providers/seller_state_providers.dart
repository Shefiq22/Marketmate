import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/dashboard/seller/models/seller_profile_model.dart';
import 'package:market_mate/dashboard/seller/models/seller_earnings_model.dart';
import 'package:market_mate/dashboard/seller/models/seller_dashboard_stats.dart';
import 'package:market_mate/dashboard/seller/models/seller_analytics_model.dart';
import 'package:market_mate/dashboard/seller/models/product_model.dart';
import 'package:market_mate/dashboard/seller/models/order_model.dart';
import 'package:market_mate/dashboard/seller/repositories/seller_repository.dart';
import 'package:market_mate/dashboard/seller/repositories/seller_products_repository.dart';
import 'package:market_mate/dashboard/seller/repositories/seller_orders_repository.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';

/// Maps a UI category name (e.g. "Vegetables") to the lowercase API schema value.
String mapCategoryToApi(String uiName) =>
    uiName.toLowerCase().replaceAll(' ', '');
// ── Repository providers ──
final sellerRepoProvider = Provider<SellerRepository>((ref) => SellerRepository());
final sellerProductsRepoProvider = Provider<SellerProductsRepository>((ref) => SellerProductsRepository());
final sellerOrdersRepoProvider = Provider<SellerOrdersRepository>((ref) => SellerOrdersRepository());

// ── Seller Profile ──
final sellerProfileProvider = FutureProvider.autoDispose<SellerProfileModel>((ref) async {
  final repo = ref.watch(sellerRepoProvider);
  return repo.getProfile();
});

// ── Seller Earnings ──
final sellerEarningsProvider = FutureProvider.autoDispose<SellerEarningsModel>((ref) async {
  final repo = ref.watch(sellerRepoProvider);
  return repo.getEarnings();
});

// ── Seller Dashboard Stats ──
final sellerDashboardStatsProvider = FutureProvider.autoDispose<SellerDashboardStats>((ref) async {
  final repo = ref.watch(sellerRepoProvider);
  return repo.getDashboardStats();
});

// ── Seller Analytics ──
final sellerAnalyticsProvider =
    FutureProvider.autoDispose.family<SellerAnalyticsModel, String>((ref, period) async {
  final repo = ref.watch(sellerRepoProvider);
  return repo.getAnalytics(period: period);
});

// ── Seller Products ──
final sellerProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final repo = ref.watch(sellerProductsRepoProvider);
  final user = ref.watch(currentUserProvider);
  final sellerId = (user?.userId ?? '').isNotEmpty ? user!.userId : null;
  debugPrint('[SellerProductsDebug] Fetching all products for seller: $sellerId');
  final products = await repo.getProducts(sellerId: sellerId);
  debugPrint('[SellerProductsDebug] Successfully loaded ${products.length} products from backend.');
  return products;
});

final sellerProductsByCategoryProvider =
    FutureProvider.autoDispose.family<List<ProductModel>, String>((ref, category) async {
  final repo = ref.watch(sellerProductsRepoProvider);
  final user = ref.watch(currentUserProvider);
  final sellerId = (user?.userId ?? '').isNotEmpty ? user!.userId : null;
  final apiCategory = category == 'All' ? null : mapCategoryToApi(category);
  debugPrint('[SellerProductsDebug] Fetching products — sellerId: $sellerId, category: $apiCategory');
  final all = await repo.getProducts(category: apiCategory, sellerId: sellerId);
  debugPrint('[SellerProductsDebug] Loaded ${all.length} products for category "$category"');
  return all;
});

final bestSellersProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.watch(sellerProductsRepoProvider);
  return repo.getBestSellersRaw();
});

// ── Seller Orders ──
final sellerOrdersProvider =
    FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final repo = ref.watch(sellerOrdersRepoProvider);
  return repo.getOrders();
});

final sellerOrdersByStatusProvider =
    FutureProvider.autoDispose.family<List<OrderModel>, String?>((ref, status) async {
  final repo = ref.watch(sellerOrdersRepoProvider);
  return repo.getOrders(status: status);
});

// ── Extracted computed providers ──
final activeOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final orders = await ref.watch(sellerOrdersProvider.future);
  return orders.where((o) => o.tabStatus == OrderTabStatus.active).toList();
});

final pendingOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final orders = await ref.watch(sellerOrdersProvider.future);
  return orders.where((o) => o.tabStatus == OrderTabStatus.pending).toList();
});

final completedOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final orders = await ref.watch(sellerOrdersProvider.future);
  return orders.where((o) => o.tabStatus == OrderTabStatus.completed).toList();
});

final cancelledOrdersProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final orders = await ref.watch(sellerOrdersProvider.future);
  return orders.where((o) => o.tabStatus == OrderTabStatus.cancelled).toList();
});

final orderHistoryProvider = FutureProvider.autoDispose<List<OrderModel>>((ref) async {
  final orders = await ref.watch(sellerOrdersProvider.future);
  return orders
      .where(
        (o) =>
            o.tabStatus == OrderTabStatus.completed ||
            o.tabStatus == OrderTabStatus.cancelled,
      )
      .toList();
});

// ── In-stock / out-of-stock filtered ──
final inStockProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final products = await ref.watch(sellerProductsProvider.future);
  return products.where((p) => p.inStock).toList();
});

final outOfStockProductsProvider = FutureProvider.autoDispose<List<ProductModel>>((ref) async {
  final products = await ref.watch(sellerProductsProvider.future);
  return products.where((p) => !p.inStock).toList();
});

final inStockProductsByCategoryProvider =
    FutureProvider.autoDispose.family<List<ProductModel>, String>((ref, category) async {
  final products = await ref.watch(sellerProductsByCategoryProvider(category).future);
  return products.where((p) => p.inStock).toList();
});

final outOfStockProductsByCategoryProvider =
    FutureProvider.autoDispose.family<List<ProductModel>, String>((ref, category) async {
  final products = await ref.watch(sellerProductsByCategoryProvider(category).future);
  return products.where((p) => !p.inStock).toList();
});
