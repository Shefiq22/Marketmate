import 'package:flutter/foundation.dart';
import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/core/network/api_endpoints.dart';
import 'package:market_mate/dashboard/seller/models/product_model.dart';

class SellerProductsRepository {
  final ApiClient _client = ApiClient();

  Future<List<Map<String, dynamic>>> getProductsRaw({
    String? search,
    String? category,
    String? sellerId,
    String? cursor,
    int limit = 20,
  }) async {
    final query = <String, String>{
      if (search != null) 'search': search,
      if (category != null) 'category': category,
      if (sellerId != null) 'sellerId': sellerId,
      if (cursor != null) 'cursor': cursor,
      'limit': limit.toString(),
    };
    final res = await _client.get(ApiEndpoints.products, query: query);
    if (!res.success) throw Exception(res.message);
    final list = res.dataList;
    if (list.isEmpty) {
      debugPrint('[SellerProductsRepository] GET ${ApiEndpoints.products} returned 0 items (query: $query)');
    }
    return list.cast<Map<String, dynamic>>();
  }

  Future<List<ProductModel>> getProducts({
    String? search,
    String? category,
    String? sellerId,
    String? cursor,
    int limit = 20,
  }) async {
    final raw = await getProductsRaw(
      search: search,
      category: category,
      sellerId: sellerId,
      cursor: cursor,
      limit: limit,
    );
    final models = <ProductModel>[];
    for (final (i, j) in raw.indexed) {
      try {
        models.add(ProductModel.fromJson(j));
      } catch (e) {
        debugPrint('[SellerProductsRepository] Failed to parse product at index $i: $e');
        debugPrint('  raw: $j');
      }
    }
    return models;
  }

  Future<List<ProductModel>> getMyProducts() async {
    final res = await _client.get(ApiEndpoints.sellersMeProducts);
    if (!res.success) throw Exception(res.message);
    final list = res.dataList.cast<Map<String, dynamic>>();
    final models = <ProductModel>[];
    for (final (i, j) in list.indexed) {
      try {
        models.add(ProductModel.fromJson(j));
      } catch (e) {
        debugPrint('[SellerProductsRepository] Failed to parse product at index $i: $e');
        debugPrint('  raw: $j');
      }
    }
    return models;
  }

  Future<Map<String, dynamic>> getProductRaw(String id) async {
    final res = await _client.get(ApiEndpoints.productById(id));
    if (!res.success) throw Exception(res.message);
    return res.data as Map<String, dynamic>;
  }

  Future<ProductModel> getProduct(String id) async {
    final raw = await getProductRaw(id);
    return ProductModel.fromJson(raw);
  }

  Future<Map<String, dynamic>> createProduct(Map<String, dynamic> body) async {
    final res = await _client.post(ApiEndpoints.products, body: body);
    if (!res.success) {
      final detail = StringBuffer(res.message);
      if (res.errors != null) {
        detail.write(' | errors: ${res.errors}');
      }
      detail.write(' | statusCode: ${res.statusCode}');
      throw Exception(detail.toString());
    }
    return (res.data ?? {}) as Map<String, dynamic>;
  }

  Future<void> updateProduct(String id, Map<String, dynamic> body) async {
    final res = await _client.patch(ApiEndpoints.productById(id), body: body);
    if (!res.success) throw Exception(res.message);
  }

  Future<void> deleteProduct(String id) async {
    final res = await _client.delete(ApiEndpoints.productById(id));
    if (!res.success) throw Exception(res.message);
  }

  Future<List<Map<String, dynamic>>> getBestSellersRaw({String period = '30d'}) async {
    final res = await _client.get(
      ApiEndpoints.sellersMeBestSelling,
      query: {'period': period},
    );
    if (!res.success) throw Exception(res.message);
    return res.dataList.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> getUploadSignature() async {
    final res = await _client.get(ApiEndpoints.uploadSignature);
    if (!res.success) throw Exception(res.message);
    return res.data as Map<String, dynamic>;
  }
}
