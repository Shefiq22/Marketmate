import 'package:flutter/foundation.dart';
import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart' show ApiEndpoints;
import '../models/models.dart';

class ProductsRepository {
  final ApiClient _client = ApiClient();

  Future<List<Product>> getAll({
    String? category,
    String? search,
    String? cursor,
    int limit = 20,
  }) async {
    final query = <String, String>{'limit': limit.toString()};
    if (category != null && category.isNotEmpty) query['category'] = category;
    if (search != null && search.isNotEmpty) query['search'] = search;
    if (cursor != null && cursor.isNotEmpty) query['cursor'] = cursor;

    final res = await _client.get(ApiEndpoints.products, query: query);
    if (!res.success) throw Exception(res.message);

    final firstItem = res.dataList.isNotEmpty ? res.dataList.first : null;
    debugPrint('[CatalogAudit] RAW BACKEND PAYLOAD (first product): $firstItem');

    return res.dataList
        .map((j) => Product.fromJson(j as Map<String, dynamic>))
        .toList();
  }

  Future<Product> getById(String id) async {
    final res = await _client.get(ApiEndpoints.productById(id));
    if (!res.success) throw Exception(res.message);
    debugPrint('[CatalogAudit] RAW BACKEND PAYLOAD (byId): ${res.data}');
    return Product.fromJson(res.data as Map<String, dynamic>);
  }
}
