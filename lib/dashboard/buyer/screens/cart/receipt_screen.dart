import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/addresses_provider.dart';
import '../orders/review_screen.dart';

Widget _buildResponsiveWrapper(Widget child) {
  return SingleChildScrollView(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 600),
      child: Center(child: child),
    ),
  );
}

class SuccessScreen extends StatelessWidget {
  final VoidCallback onViewReceipt;
  const SuccessScreen({super.key, required this.onViewReceipt});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _buildResponsiveWrapper(
          Padding(
            padding: EdgeInsets.all(MediaQuery.sizeOf(context).height * 0.035),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(child: Container()),
                Image.network(
                  'https://cdn-icons-png.flaticon.com/512/845/845646.png',
                  width: MediaQuery.sizeOf(context).height * 0.14,
                  height: MediaQuery.sizeOf(context).height * 0.14,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.check_circle_outline,
                    size: MediaQuery.sizeOf(context).height * 0.12,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                Text(
                  'Payment successful!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.015),
                Text(
                  'Your payment has been made, wait a while\nfor your order confirmation.',
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                Expanded(child: Container()),
                GreenButton(
                  label: AppLocalizations.of(context)!.review_back_homepage,
                  onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.015),
                GreenButton(
                  label: AppLocalizations.of(context)!.receipt_view,
                  outlined: true,
                  onTap: onViewReceipt,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ReceiptScreen extends ConsumerWidget {
  final List items;
  final double total;
  final String paymentMethod;
  const ReceiptScreen({
    super.key,
    required this.items,
    required this.total,
    required this.paymentMethod,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final addresses = ref.watch(addressesProvider);
    final defaultAddr = addresses.where((a) => a.isDefault).firstOrNull;
    final address = defaultAddr ?? (addresses.isNotEmpty ? addresses.first : null);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: _buildResponsiveWrapper(
          SingleChildScrollView(
            padding: EdgeInsets.all(MediaQuery.sizeOf(context).height * 0.02),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(
                    MediaQuery.sizeOf(context).height * 0.028,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width:
                                    MediaQuery.sizeOf(context).height * 0.032,
                                height:
                                    MediaQuery.sizeOf(context).height * 0.032,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(
                                  Icons.storefront_outlined,
                                  size: 16,
                                  color: AppColors.white,
                                ),
                              ),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.02,
                              ),
                              Text(
                                'MarketMate',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.text,
                                ),
                              ),
                            ],
                          ),
                          Flexible(
                            child: Text(
                              'Invoice number: JS390HRW4',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.grey500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.005,
                      ),
                      Text(
                        'Support:  info@marketmate.app  +234 8172606560',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.grey400,
                        ),
                      ),

                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.028,
                      ),
                      Divider(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.015,
                      ),

                      Text(
                        'Payment Summary',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkText : AppColors.text,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.015,
                      ),

                      _ReceiptRow(label: AppLocalizations.of(context)!.receipt_date, value: 'Jan. 25th, 2026'),
                      _ReceiptRow(label: AppLocalizations.of(context)!.receipt_time, value: '12:40 PM'),
                      _ReceiptRow(label: AppLocalizations.of(context)!.receipt_to, value: 'MarketMate'),
                      _ReceiptRow(
                        label: AppLocalizations.of(context)!.receipt_for,
                        value: ref.watch(currentUserProvider)?.name ?? 'Guest',
                      ),

                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.015,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Paystack',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            formatPrice(total),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.text,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.005,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.cart_total,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.darkText
                                  : AppColors.text,
                            ),
                          ),
                          Text(
                            formatPrice(total),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),

                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.028,
                      ),
                      Divider(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.015,
                      ),

                      Text(
                        'Order Items',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.darkText : AppColors.text,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.013,
                      ),

                      ...items.map(
                        (item) => Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.sizeOf(context).height * 0.009,
                          ),
                          child: Row(
                            children: [
                              AppNetworkImage(
                                imageUrl: item.product.imageUrl,
                                width: 48,
                                height: 48,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              SizedBox(
                                width: MediaQuery.sizeOf(context).width * 0.028,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.product.name,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Quantity ${item.quantity}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: isDark ? AppColors.darkTextSecondary : AppColors.grey500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                formatPrice(item.total),
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.darkText
                                      : AppColors.text,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      Divider(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.009,
                      ),
                      _ReceiptRow(
                        label: '${items.length} items',
                        value: formatPrice(total - 2000),
                      ),
                      _ReceiptRow(label: AppLocalizations.of(context)!.receipt_delivery, value: formatPrice(2000)),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.005,
                      ),
                      _ReceiptRow(
                        label: AppLocalizations.of(context)!.receipt_subtotal,
                        value: formatPrice(total),
                        bold: true,
                      ),

                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.028,
                      ),
                      Divider(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.015,
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.order_detail_delivery_address,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.005,
                                ),
                                Text(
                                  address?.name ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  address?.address ?? '',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.035,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.order_detail_payment_method,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                SizedBox(
                                  height:
                                      MediaQuery.sizeOf(context).height * 0.005,
                                ),
                                Text(
                                  'Paystack',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '••••••••••••5634',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: MediaQuery.sizeOf(context).height * 0.03),
                GreenButton(
                  label: AppLocalizations.of(context)!.receipt_rate_items,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReviewScreen(items: items.cast()),
                    ),
                  ),
                ),
                SizedBox(height: MediaQuery.sizeOf(context).height * 0.015),
                GreenButton(
                  label: AppLocalizations.of(context)!.review_back_homepage,
                  outlined: true,
                  onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _ReceiptRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.sizeOf(context).height * 0.005,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: bold
                  ? (isDark ? AppColors.darkText : AppColors.text)
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
                color: bold
                    ? AppColors.primary
                    : (isDark ? AppColors.darkText : AppColors.text),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
