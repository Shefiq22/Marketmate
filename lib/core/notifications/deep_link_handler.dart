import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/navigation/global_navigator.dart';
import 'package:market_mate/dashboard/buyer/models/models.dart';
import 'package:market_mate/dashboard/buyer/providers/products_provider.dart';
import 'package:market_mate/dashboard/buyer/repositories/orders_repository.dart';
import 'package:market_mate/dashboard/buyer/repositories/products_repository.dart';
import 'package:market_mate/dashboard/buyer/screens/notifications/notifications_screen.dart';
import 'package:market_mate/dashboard/buyer/screens/orders/order_detail_screen.dart';
import 'package:market_mate/dashboard/buyer/screens/products/product_detail_screen.dart';
import 'package:market_mate/dashboard/buyer/screens/vendor/vendor_detail_screen.dart';

/// Resolves a notification payload into the matching screen and pushes it.
///
/// `type` selects the route and `link` carries the target id:
///  - `order_update`   -> OrderDetailScreen (order id)
///  - `market_promo`   -> VendorDetailScreen (vendor/seller id)
///  - `product_detail` -> ProductDetailScreen (product id)
///  - anything else    -> NotificationsScreen
///
/// Resolution happens against the API, so values that fail to load (or a
/// missing `link`) degrade gracefully to the notifications inbox.
Future<void> handleNotificationDeepLink(
  Map<String, dynamic> data, {
  Ref? ref,
}) async {
  final type = (data['type'] ?? 'general').toString();
  final link = (data['link'] ?? '').toString();

  Widget screen = const NotificationsScreen();

  switch (type) {
    case 'order_update':
      if (link.isNotEmpty) {
        screen = await _buildOrderScreen(link);
      }
      break;
    case 'market_promo':
      if (link.isNotEmpty) {
        screen = await _buildVendorScreen(link, ref);
      }
      break;
    case 'product_detail':
      if (link.isNotEmpty) {
        screen = await _buildProductScreen(link);
      }
      break;
    case 'general':
    default:
      break;
  }

  await _push(screen);
}

Future<Widget> _buildOrderScreen(String orderId) async {
  try {
    final order = await OrdersRepository().getById(orderId);
    return OrderDetailScreen(order: order);
  } catch (e) {
    debugPrint('[DeepLink] Order resolve failed: $e');
    return const NotificationsScreen();
  }
}

Future<Widget> _buildProductScreen(String productId) async {
  try {
    final product = await ProductsRepository().getById(productId);
    return ProductDetailScreen(product: product);
  } catch (e) {
    debugPrint('[DeepLink] Product resolve failed: $e');
    return const NotificationsScreen();
  }
}

Future<Widget> _buildVendorScreen(String sellerId, Ref? ref) async {
  if (ref == null) return const NotificationsScreen();
  try {
    final products = await ref.read(productsProvider.future);
    final filtered = products
        .where((p) =>
            (p.sellerId ?? '').isNotEmpty &&
            (p.sellerId == sellerId || p.sellerName == sellerId))
        .toList();
    if (filtered.isEmpty) return const NotificationsScreen();

    final first = filtered.first;
    return VendorDetailScreen(
      vendor: Vendor(
        sellerId: sellerId,
        sellerName: first.sellerName ?? 'Store',
        products: filtered,
        averageRating: filtered.fold<double>(
              0,
              (sum, p) => sum + p.rating,
            ) /
            filtered.length,
        deliveryFee: first.deliveryClass,
        imageUrl: first.images.isNotEmpty ? first.images.first : null,
        categories: filtered
            .map((p) => p.category.toLowerCase())
            .toSet()
            .toList(),
      ),
    );
  } catch (e) {
    debugPrint('[DeepLink] Vendor resolve failed: $e');
    return const NotificationsScreen();
  }
}

Future<void> _push(Widget screen) async {
  final navigator = appNavigatorKey.currentState;

  if (navigator != null) {
    navigator.push(MaterialPageRoute(builder: (_) => screen));
    return;
  }

  // App still starting (terminated-state launch) — retry once the navigator
  // is attached. Back off for up to 2 seconds.
  for (var i = 0; i < 10; i++) {
    await Future.delayed(const Duration(milliseconds: 200));
    final state = appNavigatorKey.currentState;
    if (state != null) {
      state.push(MaterialPageRoute(builder: (_) => screen));
      return;
    }
  }
}