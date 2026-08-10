import '../../../core/network/api_client.dart';
import '../../../core/network/api_endpoints.dart';
import '../models/referral_models.dart';

class ReferralRepository {
  final ApiClient _client = ApiClient();

  Future<ReferralStats> getReferralStats() async {
    final res = await _client.get(ApiEndpoints.referralsMe);
    if (!res.success) throw Exception(res.message);
    return ReferralStats.fromJson(res.data as Map<String, dynamic>);
  }

  Future<WalletBalance> getWalletBalance() async {
    final res = await _client.get(ApiEndpoints.walletMe);
    if (!res.success) throw Exception(res.message);
    return WalletBalance.fromJson(res.data as Map<String, dynamic>);
  }
}
