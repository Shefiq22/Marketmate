import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_mate/dashboard/seller/models/order_model.dart';
import 'package:market_mate/dashboard/seller/models/rider_model.dart';
import 'package:market_mate/dashboard/seller/providers/seller_state_providers.dart';
import '../../../../core/theme/app_colors.dart';
import 'rider_detail_with_order_page.dart';

class SelectOrderForRiderPage extends ConsumerWidget {
  final RiderModel rider;

  const SelectOrderForRiderPage({super.key, required this.rider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final hPad = isTablet ? size.width * 0.08 : 20.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pendingAsync = ref.watch(pendingOrdersProvider);
    final allPending = pendingAsync.whenOrNull(data: (o) => o) ?? [];
    final unassigned = allPending.where((o) => o.riderName == null).toList();

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select Order',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 20 : 17,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.black,
                          ),
                        ),
                        Text(
                          'Assigning to ${rider.name}',
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
            ),
            const Divider(height: 1),
            Expanded(
              child: unassigned.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: isTablet ? 80 : 64,
                            height: isTablet ? 80 : 64,
                            decoration: const BoxDecoration(
                              color: AppColors.primarySurface,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.receipt_long_outlined,
                              color: AppColors.primary,
                              size: isTablet ? 40 : 32,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No unassigned orders',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: isTablet ? 17 : 15,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'All pending orders already have riders.',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: isTablet ? 14 : 12,
                              color: AppColors.gray2,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.fromLTRB(
                        hPad,
                        16,
                        hPad,
                        padding.bottom + 16,
                      ),
                      itemCount: unassigned.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) => _OrderCard(
                        order: unassigned[i],
                        isTablet: isTablet,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => RiderDetailWithOrderPage(
                              rider: rider,
                              order: unassigned[i],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isTablet;
  final VoidCallback onTap;

  const _OrderCard({
    required this.order,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.all(isTablet ? 16 : 14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order ${order.orderRef}',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: isTablet ? 14 : 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        order.customerName,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: isTablet ? 17 : 15,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Placed ${order.placedDate}',
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        order.formattedTotal,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: isTablet ? 17 : 15,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondarySurface,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          '${order.items.length} items',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 12 : 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 14,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: isTablet ? 15 : 13,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      order.deliveryAddress.replaceAll('\n', ', '),
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 12 : 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
