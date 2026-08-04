import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/core/network/api_endpoints.dart';
import 'package:market_mate/dashboard/seller/models/order_model.dart';

class SellerOrdersRepository {
  final ApiClient _client = ApiClient();

  Future<List<Map<String, dynamic>>> getOrdersRaw({
    String? status,
    String? cursor,
    int limit = 20,
  }) async {
    final query = <String, String>{
      if (status != null) 'status': status,
      if (cursor != null) 'cursor': cursor,
      'limit': limit.toString(),
    };
    final res = await _client.get(ApiEndpoints.sellersOrders, query: query);
    if (!res.success) throw Exception(res.message);
    return res.dataList.cast<Map<String, dynamic>>();
  }

  Future<List<OrderModel>> getOrders({
    String? status,
    String? cursor,
    int limit = 20,
  }) async {
    final raw = await getOrdersRaw(status: status, cursor: cursor, limit: limit);
    return raw.map((j) => OrderModel.fromJson(j)).toList();
  }

  Future<Map<String, dynamic>> getOrderRaw(String id) async {
    final res = await _client.get(ApiEndpoints.orderById(id));
    if (!res.success) throw Exception(res.message);
    return res.data as Map<String, dynamic>;
  }

  Future<OrderModel> getOrder(String id) async {
    final raw = await getOrderRaw(id);
    return OrderModel.fromJson(raw);
  }

  Future<void> acceptOrder(String id) async {
    final res = await _client.patch(ApiEndpoints.orderAccept(id));
    if (!res.success) throw Exception(res.message);
  }

  Future<void> markPreparing(String id) async {
    final res = await _client.patch(ApiEndpoints.orderPreparing(id));
    if (!res.success) throw Exception(res.message);
  }

  Future<void> markReady(String id) async {
    final res = await _client.patch(ApiEndpoints.orderReady(id));
    if (!res.success) throw Exception(res.message);
  }

  Future<List<Map<String, dynamic>>> suggestRiders(String orderId) async {
    final res = await _client.get(ApiEndpoints.orderRiderSuggest(orderId));
    if (!res.success) throw Exception(res.message);
    return res.dataList.cast<Map<String, dynamic>>();
  }

  Future<void> assignRider(String orderId, String riderId) async {
    final res = await _client.post(
      ApiEndpoints.orderAssignRider(orderId),
      body: {'riderId': riderId},
    );
    if (!res.success) throw Exception(res.message);
  }

  Future<String> getPickupCode(String id) async {
    final res = await _client.get(ApiEndpoints.sellerOrderPickupCode(id));
    if (!res.success) throw Exception(res.message);
    return (res.data as Map<String, dynamic>)['pickupCode'] as String;
  }

  Future<void> cancelOrder(String id, {String? reason}) async {
    final res = await _client.patch(
      ApiEndpoints.orderCancel(id),
      body: {'reason': reason ?? 'Cancelled by seller'},
    );
    if (!res.success) throw Exception(res.message);
  }
}
