import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart' show ApiEndpoints;
import '../models/models.dart';

class CartRepository {
  final ApiClient _client = ApiClient();

  Future<List<CartItem>> getCart() async {
    final res = await _client.get(ApiEndpoints.cart);
    if (!res.success) throw Exception(res.message);

    final data = res.data;
    final items = (data is Map ? data['items'] : data);
    if (items is List) {
      return items.map((j) => _parseItem(j as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<void> addItem(String productId, {int quantity = 1}) async {
    final res = await _client.post(
      ApiEndpoints.cartItems,
      body: {'productId': productId, 'quantity': quantity},
    );
    if (!res.success) throw Exception(res.message);
  }

  Future<void> updateItem(String productId, {int? quantity}) async {
    final body = <String, dynamic>{};
    if (quantity != null) body['quantity'] = quantity;
    final res = await _client.patch(
      ApiEndpoints.cartItem(productId),
      body: body,
    );
    if (!res.success) throw Exception(res.message);
  }

  Future<void> removeItem(String productId) async {
    final res = await _client.delete(ApiEndpoints.cartItem(productId));
    if (!res.success) throw Exception(res.message);
  }

  Future<void> clearCart() async {
    final res = await _client.delete(ApiEndpoints.cart);
    if (!res.success) throw Exception(res.message);
  }

  CartItem _parseItem(Map<String, dynamic> json) {
    return CartItem(
      product: Product(
        id: json['productId'] ?? '',
        name: json['name'] ?? '',
        category: json['category'] ?? '',
        price: ((json['price'] as num?)?.toDouble() ?? 0.0) / 100,
        imageUrl: json['imageUrl'] ?? '',
        description: '',
        sellerId: json['sellerId'],
      ),
      quantity: json['quantity'] ?? 1,
      selected: true,
    );
  }
}
