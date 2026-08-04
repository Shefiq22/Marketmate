import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/providers/locale_provider.dart';
import 'package:market_mate/dashboard/buyer/models/models.dart' as buyer;
import 'package:market_mate/dashboard/seller/models/product_model.dart' as seller;

/// Extensions on [WidgetRef] to retrieve locale-aware product text.
///
/// Usage:
/// ```dart
/// final name = ref.localizedProductName(product);
/// final description = ref.localizedProductDescription(product);
/// ```
extension ProductLocalizationRef on WidgetRef {
  String localizedProductName(buyer.Product product) {
    final locale = watch(localeProvider).languageCode;
    return product.localizedName(locale);
  }

  String localizedProductDescription(buyer.Product product) {
    final locale = watch(localeProvider).languageCode;
    return product.localizedDescription(locale);
  }

  String localizedSellerProductName(seller.ProductModel product) {
    final locale = watch(localeProvider).languageCode;
    return product.localizedName(locale);
  }

  String localizedSellerProductDescription(seller.ProductModel product) {
    final locale = watch(localeProvider).languageCode;
    return product.localizedDescription(locale);
  }
}

/// Extension on [BuildContext] for non-Riverpod widgets.
///
/// Falls back to [LocaleNotifier] via ref if run inside a Riverpod widget,
/// otherwise reads [Locale] from [WidgetsBinding] for legacy provider widgets.
extension ProductLocalizationContext on BuildContext {
  String localizedProductName(buyer.Product product) {
    final locale = Localizations.localeOf(this).languageCode;
    return product.localizedName(locale);
  }

  String localizedProductDescription(buyer.Product product) {
    final locale = Localizations.localeOf(this).languageCode;
    return product.localizedDescription(locale);
  }

  String localizedSellerProductName(seller.ProductModel product) {
    final locale = Localizations.localeOf(this).languageCode;
    return product.localizedName(locale);
  }

  String localizedSellerProductDescription(seller.ProductModel product) {
    final locale = Localizations.localeOf(this).languageCode;
    return product.localizedDescription(locale);
  }
}
