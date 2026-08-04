import 'package:flutter_riverpod/legacy.dart';

final sellerBankAccountsProvider =
    StateProvider<List<Map<String, String>>>((ref) => [
      {'name': 'Seller Account', 'number': '0123456789', 'bank': 'Access Bank'},
    ]);

final sellerDefaultBankIndexProvider = StateProvider<int>((ref) => 0);

final sellerNigerianBanks = [
  'Access Bank',
  'First Bank',
  'GTBank',
  'Zenith Bank',
  'UBA',
  'Stanbic IBTC',
  'FCMB',
  'Fidelity Bank',
  'Union Bank',
  'Sterling Bank',
  'Polaris Bank',
  'Ecobank',
  'Keystone Bank',
  'Heritage Bank',
  'Wema Bank',
];
