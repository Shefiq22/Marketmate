import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/dashboard/rider/models/rider_delivery_model.dart';
import 'package:market_mate/dashboard/rider/providers/rider_dashboard_provider.dart';
import 'rider_delivery_detail_page.dart';

class RiderDeliveryHistoryPage extends ConsumerWidget {
  const RiderDeliveryHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final hPad = isTablet ? size.width * 0.08 : 20.0;
    final history = ref.watch(riderHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 28,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 16),
              child: Text(
                'Delivery history',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 26 : 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: history.isEmpty
                  ? Center(
                      child: Text(
                        'No history yet',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: isTablet ? 14 : 13,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.gray2,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        hPad,
                        0,
                        hPad,
                        padding.bottom + 16,
                      ),
                      itemCount: history.length,
                      itemBuilder: (_, i) {
                        final d = history[i];
                        final isPending =
                            d.status == RiderDeliveryStatus.pending;
                        final isActive = d.status == RiderDeliveryStatus.active;
                        return GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  RiderDeliveryDetailPage(delivery: d),
                            ),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(isTablet ? 16 : 14),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.surfaceDark
                                  : AppColors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.borderDark
                                    : AppColors.border,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order ${d.orderRef}',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: isTablet ? 15 : 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      d.dateRange,
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isPending || isActive
                                        ? AppColors.secondarySurface
                                        : AppColors.primarySurface,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    isPending || isActive
                                        ? 'Pending'
                                        : 'Completed',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: isTablet ? 13 : 12,
                                      fontWeight: FontWeight.w600,
                                      color: isPending || isActive
                                          ? AppColors.secondary
                                          : AppColors.primary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
