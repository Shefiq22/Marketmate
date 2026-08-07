import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/core/network/api_endpoints.dart' show ApiEndpoints;
import '../models/rider_delivery_model.dart';

class RiderRepository {
  final ApiClient _client = ApiClient();

  Future<List<Map<String, dynamic>>> getMyOrders({String? status}) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;
    final res = await _client.get(ApiEndpoints.ridersMeOrders, query: query);
    if (!res.success) throw Exception(res.message);
    return res.dataList.cast<Map<String, dynamic>>();
  }

  Future<void> updateOnlineStatus(bool online) async {
    final res = await _client.patch(
      ApiEndpoints.ridersMeStatus,
      body: {'isOnline': online},
    );
    if (!res.success) throw Exception(res.message);
  }

  /// GET {{baseUrl}}/riders/orders/active — returns the rider's current
  /// delivery, or null when there is no active delivery.
  Future<RiderDeliveryModel?> getActiveOrder() async {
    final res = await _client.get(ApiEndpoints.ridersActiveOrder);
    if (!res.success) return null;
    final data = res.data;
    if (data is! Map) return null;
    final map = Map<String, dynamic>.from(data);
    // The payload may wrap the order under an 'order'/'data' key.
    final order = (map['order'] is Map)
        ? Map<String, dynamic>.from(map['order'] as Map)
        : map;
    return RiderDeliveryModel.fromJson(order);
  }

  /// GET {{baseUrl}}/riders/assignments/pending — deliveries waiting for the
  /// rider to accept or decline.
  Future<List<RiderDeliveryModel>> getPendingAssignments() async {
    final res = await _client.get(ApiEndpoints.ridersPendingAssignments);
    if (!res.success) return [];
    return res.dataList
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .map(RiderDeliveryModel.fromJson)
        .toList();
  }

  /// PATCH {{baseUrl}}/riders/location — sends the rider's live position.
  Future<void> updateLocation({
    required double latitude,
    required double longitude,
  }) async {
    final res = await _client.patch(
      ApiEndpoints.ridersLocation,
      body: {'longitude': longitude, 'latitude': latitude},
    );
    if (!res.success) throw Exception(res.message);
  }

  Future<void> confirmPickup(String orderId) async {
    final res = await _client.patch(ApiEndpoints.orderPickupConfirm(orderId));
    if (!res.success) throw Exception(res.message);
  }

  Future<void> markArrived(String orderId) async {
    final res = await _client.patch(ApiEndpoints.orderArrived(orderId));
    if (!res.success) throw Exception(res.message);
  }

  Future<void> completeOrder(String orderId) async {
    final res = await _client.patch(ApiEndpoints.orderComplete(orderId));
    if (!res.success) throw Exception(res.message);
  }

  Future<void> acceptOrder(String orderId) async {
    final res = await _client.patch(ApiEndpoints.orderAccept(orderId));
    if (!res.success) throw Exception(res.message);
  }

  Future<Map<String, dynamic>> getWallet() async {
    final res = await _client.get(ApiEndpoints.ridersMeWallet);
    if (!res.success) throw Exception(res.message);
    return (res.data ?? {}) as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> withdraw(Map<String, dynamic> body) async {
    final res = await _client.post(ApiEndpoints.ridersMeWalletWithdraw, body: body);
    if (!res.success) throw Exception(res.message);
    return (res.data ?? {}) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> getBankAccounts() async {
    final res = await _client.get(ApiEndpoints.ridersMeBank);
    if (!res.success) throw Exception(res.message);
    return res.dataList.cast<Map<String, dynamic>>();
  }

  Future<void> addBankAccount(Map<String, dynamic> body) async {
    final res = await _client.post(ApiEndpoints.ridersMeBank, body: body);
    if (!res.success) throw Exception(res.message);
  }
}
