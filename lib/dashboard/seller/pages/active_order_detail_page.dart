import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_mate/dashboard/seller/models/order_model.dart';
import 'package:market_mate/features/chat/presentation/pages/order_chat_page.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';

class _TimelineEntry {
  final String title;
  final String subtitle;
  final String timestamp;

  const _TimelineEntry(this.title, this.subtitle, this.timestamp);
}

class ActiveOrderDetailPage extends StatelessWidget {
  final OrderModel order;

  const ActiveOrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final order = this.order;
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = isTablet ? size.width * 0.08 : 20.0;
    final stepIndex = order.currentStatus.index;
    final progress = (stepIndex + 1) / 4;

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
                    RichText(
                      text: TextSpan(
                        text: 'Order ${order.orderRef}   ',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: isTablet ? 17 : 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.black,
                        ),
                        children: [
                          TextSpan(
                            text: 'To: ${order.customerName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.secondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppLocalizations.of(context)!.seller_orders_placed_on(order.placedDate),
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 14 : 12,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Delivery Progress',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 15 : 13,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: isDark
                            ? AppColors.borderDark
                            : AppColors.border,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: order.timeline.map((step) {
                        return Column(
                          children: [
                            Container(
                              width: isTablet ? 36 : 30,
                              height: isTablet ? 36 : 30,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: step.completed
                                    ? AppColors.primary
                                    : (isDark
                                          ? AppColors.borderDark
                                          : AppColors.border),
                              ),
                              child: step.completed
                                  ? Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: SvgPicture.asset(
                                        'assets/icons/check.svg',
                                        width: isTablet ? 18 : 14,
                                        height: isTablet ? 18 : 14,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    )
                                  : const SizedBox.shrink(),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              step.label,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet ? 12 : 10,
                                fontWeight: FontWeight.w600,
                                color: step.completed
                                    ? (isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.black)
                                    : AppColors.gray2,
                              ),
                            ),
                            Text(
                              step.date,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet ? 11 : 10,
                                color: AppColors.gray2,
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 12),
                    ..._buildTimelineList(order, isTablet, isDark),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    _buildRiderSection(order, isTablet, isDark),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      'Order items',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 17 : 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.black,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...order.items.map(
                      (item) => _OrderItemRow(
                        item: item,
                        isTablet: isTablet,
                        isDark: isDark,
                      ),
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
        child: OutlinedButton.icon(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderChatPage(
                orderId: order.id,
                targetName: order.customerName,
                targetRole: 'customer',
              ),
            ),
          ),
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
          label: Text(AppLocalizations.of(context)!.order_detail_message_seller),
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
        ),
      ),
    );
  }

  List<Widget> _buildTimelineList(
    OrderModel order,
    bool isTablet,
    bool isDark,
  ) {
    final steps = <_TimelineEntry>[
      _TimelineEntry(
        'Order placed',
        'Your order has been received',
        order.timeline.isNotEmpty
            ? '${order.placedDate} - ${order.timeline[0].time}'
            : '',
      ),
      _TimelineEntry(
        'Order confirmed',
        "We've confirmed your order",
        order.timeline.length > 1
            ? '${order.placedDate} - ${order.timeline[1].time}'
            : '',
      ),
      _TimelineEntry(
        'Order processed',
        'Your order is being processed for delivery',
        order.timeline.length > 2 && order.timeline[2].completed
            ? 'January 21, 2026 - ${order.timeline[2].time}'
            : '',
      ),
      _TimelineEntry(
        'Order Shipped',
        'Your order is on the way',
        order.currentStatus.index >= OrderStatus.shipped.index
            ? 'January 22, 2026 - 02:54 PM'
            : '',
      ),
      _TimelineEntry(
        'Order Delivered',
        'Expected delivery',
        order.estimatedDelivery ?? '',
      ),
    ];

    return steps.asMap().entries.map((entry) {
      final i = entry.key;
      final step = entry.value;
      final done = i <= order.currentStatus.index;
      final isLast = i == steps.length - 1;
      return Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: isTablet ? 28 : 24,
                  height: isTablet ? 28 : 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.border),
                    border: Border.all(
                      color: done
                          ? AppColors.primary
                          : (isDark ? AppColors.borderDark : AppColors.border),
                      width: 2,
                    ),
                  ),
                  child: done
                      ? Padding(
                          padding: const EdgeInsets.all(5),
                          child: SvgPicture.asset(
                            'assets/icons/check.svg',
                            width: isTablet ? 14 : 12,
                            height: isTablet ? 14 : 12,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                        )
                      : const SizedBox.shrink(),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 36,
                    color: done && i < order.currentStatus.index
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.border),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 15 : 14,
                      fontWeight: FontWeight.w600,
                      color: done
                          ? (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.black)
                          : AppColors.gray2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    step.subtitle,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 13 : 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  if (step.timestamp.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.timestamp,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 12 : 11,
                        color: AppColors.gray2,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildRiderSection(OrderModel order, bool isTablet, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/riders_icon.svg',
                    width: isTablet ? 18 : 16,
                    height: isTablet ? 18 : 16,
                    colorFilter: ColorFilter.mode(
                      isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    order.riderName ?? '',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 15 : 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                order.riderCode ?? '',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 13 : 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Status',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 13 : 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.secondary),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  order.riderStatusLabel ?? '',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 13 : 12,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Estimated delivery',
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
                order.estimatedDelivery ?? '',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Last update',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 13 : 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.lastUpdate ?? '',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 13 : 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Last location',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 13 : 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                order.lastLocation ?? '',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 13 : 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _OrderItemRow extends StatelessWidget {
  final OrderItem item;
  final bool isTablet;
  final bool isDark;

  const _OrderItemRow({
    required this.item,
    required this.isTablet,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              item.imageAsset,
              width: isTablet ? 56 : 48,
              height: isTablet ? 56 : 48,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: isTablet ? 56 : 48,
                height: isTablet ? 56 : 48,
                color: AppColors.gray1,
                child: const Icon(
                  Icons.image_outlined,
                  color: AppColors.gray2,
                  size: 22,
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
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Quantity: ${item.quantity}',
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
