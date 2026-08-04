import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_mate/dashboard/seller/models/order_model.dart';
import 'package:market_mate/dashboard/seller/pages/assign_rider_map_page.dart';
import 'package:market_mate/features/chat/presentation/pages/order_chat_page.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class PendingOrderDetailPage extends StatelessWidget {
  final OrderModel order;

  const PendingOrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final hPad = isTablet ? size.width * 0.08 : 20.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: SvgPicture.asset(
                    'assets/icons/back_icon.svg',
                    width: isTablet ? 28 : 24,
                    height: isTablet ? 28 : 24,
                    colorFilter: ColorFilter.mode(
                      isDark ? AppColors.textPrimaryDark : AppColors.black,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  hPad,
                  0,
                  hPad,
                  padding.bottom + 100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              order.customerName,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet ? 22 : 18,
                                fontWeight: FontWeight.w800,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Placed on ${order.placedDate} - 10:33 AM',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet ? 13 : 12,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => AssignRiderMapPage(order: order),
                            ),
                          ),
                          child: Text(
                            '${AppLocalizations.of(context)!.seller_orders_assign_rider} →',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: isTablet ? 15 : 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Order items',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          ...order.items.map(
                            (item) =>
                                _PendingItemRow(item: item, isTablet: isTablet),
                          ),
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${order.items.length} items',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: isTablet ? 14 : 13,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                Text(
                                  'Total: ${order.formattedTotal}',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: isTablet ? 14 : 13,
                                    fontWeight: FontWeight.w700,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/location_icon.svg',
                                    width: 16,
                                    height: 16,
                                    colorFilter: ColorFilter.mode(
                                      isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppLocalizations.of(context)!.order_detail_delivery_address,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: isTablet ? 14 : 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                order.deliveryAddress,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: isTablet ? 13 : 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/payment_icon.svg',
                                    width: 16,
                                    height: 16,
                                    colorFilter: ColorFilter.mode(
                                      isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppLocalizations.of(context)!.order_detail_payment_method,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: isTablet ? 14 : 13,
                                      fontWeight: FontWeight.w600,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.black,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                order.paymentMethod,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: isTablet ? 13 : 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                order.maskedCard,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: isTablet ? 13 : 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Total: ${order.formattedTotal}',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: isTablet ? 13 : 12,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
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
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(hPad, 12, hPad, padding.bottom + 16),
        color: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => OrderChatPage(
                      orderId: order.id,
                      targetName: order.customerName,
                      targetRole: 'customer',
                    ),
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary, width: 1.5),
                  shape: const StadiumBorder(),
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 15),
                  minimumSize: const Size(0, 0),
                  textStyle: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.order_detail_message_seller),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => AssignRiderMapPage(order: order),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder(),
                  elevation: 0,
                  minimumSize: const Size(0, 0),
                  padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 15),
                  textStyle: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(AppLocalizations.of(context)!.seller_orders_assign_rider),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingItemRow extends StatelessWidget {
  final OrderItem item;
  final bool isTablet;

  const _PendingItemRow({required this.item, required this.isTablet});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.imageAsset,
              width: isTablet ? 52 : 44,
              height: isTablet ? 52 : 44,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: isTablet ? 52 : 44,
                height: isTablet ? 52 : 44,
                color: AppColors.gray1,
                child: const Icon(
                  Icons.image_outlined,
                  color: AppColors.gray2,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.name,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Quantity: ${item.quantity}',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 13 : 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.formattedUnit,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '${item.formattedTotal} total',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 12 : 11,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
