import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart' show ApiEndpoints;
import '../models/models.dart';

class OrdersRepository {
  final ApiClient _client = ApiClient();

  Future<List<Order>> getAll({String? status}) async {
    final query = <String, String>{};
    if (status != null) query['status'] = status;

    final res = await _client.get(ApiEndpoints.orders, query: query);
    if (!res.success) throw Exception(res.message);

    return res.dataList
        .map((j) => _parseOrder(j as Map<String, dynamic>))
        .toList();
  }

  Future<Order> getById(String id) async {
    final res = await _client.get(ApiEndpoints.orderById(id));
    if (!res.success) throw Exception(res.message);
    return _parseOrder(res.data as Map<String, dynamic>);
  }

  Future<Order> completeOrder(String orderId) async {
    final res = await _client.patch(ApiEndpoints.orderCustomerComplete(orderId));
    if (!res.success) throw Exception(res.message);
    return _parseOrder(res.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> create({
    required String street,
    required String city,
    required List<double> coordinates,
    required String paymentMethod,
    String? notes,
  }) async {
    final res = await _client.post(
      ApiEndpoints.orders,
      body: {
        'deliveryAddress': {
          'street': street,
          'city': city,
          'coordinates': coordinates,
        },
        'paymentMethod': paymentMethod,
        'notes': ?notes,
      },
    );
    if (!res.success) throw Exception(res.message);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> initiatePayment(String orderId) async {
    final res = await _client.post(
      ApiEndpoints.paymentsInitiate,
      body: {'orderId': orderId},
    );
    if (!res.success) throw Exception(res.message);
    return res.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getPaymentStatus(String orderId) async {
    final res = await _client.get(ApiEndpoints.paymentStatus(orderId));
    if (!res.success) throw Exception(res.message);
    return res.data as Map<String, dynamic>;
  }

  Order _parseOrder(Map<String, dynamic> json) {
    final items =
        (json['items'] as List<dynamic>?)
            ?.map(
              (i) => CartItem(
                product: Product(
                  id: i['productId'] ?? '',
                  name: i['name'] ?? '',
                  category: '',
                  price: ((i['price'] as num?)?.toDouble() ?? 0.0) / 100,
                  imageUrl: '',
                  description: '',
                ),
                quantity: i['quantity'] ?? 1,
              ),
            )
            .toList() ??
        [];
    final pricing = json['pricing'] as Map<String, dynamic>?;
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      displayId: json['orderNumber'] ?? json['orderId'] ?? '',
      items: items,
      total: ((pricing?['total'] as num?)?.toDouble() ?? 0.0) / 100,
      deliveryFee: ((pricing?['deliveryFee'] as num?)?.toDouble() ?? 0.0) / 100,
      status: json['status'] ?? 'pending',
      placedDate: json['createdAt'] ?? '',
      deliveryAddress: _formatAddress(json['deliveryAddress']),
      paymentMethod: json['payment']?['method'] ?? 'card',
      receiptNumber: json['receiptUrl'],
      checkoutSessionId: json['_id'],
      paymentStatus: json['payment']?['status'],
      statusHistory: (json['statusHistory'] as List<dynamic>?)
              ?.map((e) => OrderStatusEvent.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String _formatAddress(dynamic addr) {
    if (addr is Map) {
      return '${addr['street'] ?? ''}, ${addr['city'] ?? ''}';
    }
    return addr?.toString() ?? '';
  }
}
