import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/core/network/api_endpoints.dart';
import 'package:market_mate/dashboard/seller/models/seller_profile_model.dart';
import 'package:market_mate/dashboard/seller/models/seller_earnings_model.dart';
import 'package:market_mate/dashboard/seller/models/seller_dashboard_stats.dart';
import 'package:market_mate/dashboard/seller/models/seller_analytics_model.dart';

class SellerRepository {
  final ApiClient _client = ApiClient();

  Future<Map<String, dynamic>> getProfileRaw() async {
    final res = await _client.get(ApiEndpoints.sellersMe);
    if (!res.success) throw Exception(res.message);
    return res.data as Map<String, dynamic>;
  }

  Future<SellerProfileModel> getProfile() async {
    final raw = await getProfileRaw();
    return SellerProfileModel.fromJson(raw);
  }

  Future<void> updateProfile(Map<String, dynamic> body) async {
    final res = await _client.patch(ApiEndpoints.sellersMe, body: body);
    if (!res.success) throw Exception(res.message);
  }

  Future<void> updateStoreProfile(Map<String, dynamic> body) async {
    final res = await _client.patch(ApiEndpoints.sellersProfile, body: body);
    if (!res.success) throw Exception(res.message);
  }

  Future<void> submitOnboarding(Map<String, dynamic> body) async {
    final res = await _client.post(ApiEndpoints.sellersOnboarding, body: body);
    if (!res.success) throw Exception(res.message);
  }

  Future<Map<String, dynamic>> getEarningsRaw() async {
    final res = await _client.get(ApiEndpoints.sellersMeEarnings);
    if (!res.success) throw Exception(res.message);
    return res.data as Map<String, dynamic>;
  }

  Future<SellerEarningsModel> getEarnings() async {
    final raw = await getEarningsRaw();
    return SellerEarningsModel.fromJson(raw);
  }

  Future<Map<String, dynamic>> getDashboardStatsRaw() async {
    final res = await _client.get(ApiEndpoints.sellersDashboard);
    if (!res.success) throw Exception(res.message);
    return (res.data ?? {}) as Map<String, dynamic>;
  }

  Future<SellerDashboardStats> getDashboardStats() async {
    final raw = await getDashboardStatsRaw();
    return SellerDashboardStats.fromJson(raw);
  }

  Future<Map<String, dynamic>> getAnalyticsRaw({String period = '30d'}) async {
    final res = await _client.get(
      ApiEndpoints.sellersMeAnalytics,
      query: {'period': period},
    );
    if (!res.success) throw Exception(res.message);
    return res.data as Map<String, dynamic>;
  }

  Future<SellerAnalyticsModel> getAnalytics({String period = '30d'}) async {
    final raw = await getAnalyticsRaw(period: period);
    return SellerAnalyticsModel.fromJson(raw);
  }
}
