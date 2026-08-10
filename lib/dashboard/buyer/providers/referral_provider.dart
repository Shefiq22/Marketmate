import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/referral_models.dart';
import '../repositories/referral_repository.dart';

final referralRepositoryProvider = Provider<ReferralRepository>(
  (ref) => ReferralRepository(),
);

final referralStatsProvider = FutureProvider<ReferralStats>((ref) async {
  final repo = ref.watch(referralRepositoryProvider);
  return repo.getReferralStats();
});

final walletBalanceProvider = FutureProvider<WalletBalance>((ref) async {
  final repo = ref.watch(referralRepositoryProvider);
  return repo.getWalletBalance();
});
