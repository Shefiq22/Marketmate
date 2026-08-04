import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/core/network/api_endpoints.dart' show ApiEndpoints;

class CheckoutRepository {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> createOrder({
    required List<Map<String, dynamic>> items,
    required String street,
    required String city,
    required String state,
    required List<double> coordinates,
    required String paymentMethod,
    String? notes,
    String? selectedVehicleType,
    String? token,
  }) async {
    if (token != null) {
      _client.setAccessToken(token);
    }

    // Defensive payload sanitization: ensure quantities are int, product IDs are strings.
    // Some backends reject string-typed quantities or non-string product references.
    final sanitizedItems = items.map((item) {
      final rawQty = item['quantity'];
      final sanitizedQty = rawQty is int
          ? rawQty
          : rawQty is double
              ? rawQty.toInt()
              : rawQty is String
                  ? (int.tryParse(rawQty) ?? 1)
                  : 1;
      final productId = item['product']?.toString() ?? item['productId']?.toString() ?? '';
      return <String, dynamic>{
        'product': productId,
        'quantity': sanitizedQty,
      };
    }).toList();

    final body = <String, dynamic>{
      'items': sanitizedItems,
      'deliveryAddress': {
        'street': street,
        'city': city,
        'state': state,
        'coordinates': {
          'type': 'Point',
          'coordinates': coordinates,
        },
      },
      'paymentMethod': paymentMethod,
      if (notes != null) 'notes': notes,
      if (selectedVehicleType != null) 'selectedVehicleType': selectedVehicleType,
    };

    debugPrint('[CheckoutDebug] Sanitized Order Payload: ${jsonEncode(body)}');
    debugPrint('[CheckoutDebug] Item count: ${sanitizedItems.length}');
    for (final item in sanitizedItems) {
      debugPrint('[CheckoutDebug]   → product=${item['product']}, quantity=${item['quantity']} (${item['quantity'].runtimeType})');
    }
    debugPrint('[CheckoutDebug] Authorization header present: ${_client.accessToken != null}');

    final res = await _client.post(
      ApiEndpoints.orders,
      body: body,
    );

    if (!res.success) {
      debugPrint('[CheckoutDebug] Order creation failed — status: ${res.statusCode}, message: ${res.message}, errors: ${res.errors}');
      throw Exception(res.message);
    }

    debugPrint('[CheckoutDebug] Order created successfully: ${jsonEncode(res.data)}');
    return (res.data ?? {}) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> initiateCardPayment(String orderId) async {
    final res = await _client.post(
      ApiEndpoints.paymentsInitiate,
      body: {'orderId': orderId},
    );
    if (!res.success) throw Exception(res.message);
    return (res.data ?? {}) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> assignVirtualAccount(String orderId) async {
    final res = await _client.post(
      ApiEndpoints.paymentsVirtualAccount,
      body: {'orderId': orderId},
    );
    if (!res.success) throw Exception(res.message);
    return (res.data ?? {}) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPaymentStatus(String orderId) async {
    final res = await _client.get(ApiEndpoints.paymentStatus(orderId));
    if (!res.success) throw Exception(res.message);
    return (res.data ?? {}) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPaymentReceipt(String orderId) async {
    final res = await _client.get(ApiEndpoints.paymentReceipt(orderId));
    if (!res.success) throw Exception(res.message);
    return (res.data ?? {}) as Map<String, dynamic>;
  }
}
