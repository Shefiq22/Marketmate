import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/dashboard/seller/repositories/seller_repository.dart';

/// Legacy repository provider (backward compatible).
/// New code should use [sellerRepoProvider] from seller_state_providers.dart.
final sellerRepositoryProvider = Provider<SellerRepository>((ref) => SellerRepository());
