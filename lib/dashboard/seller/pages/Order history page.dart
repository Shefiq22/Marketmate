import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/dashboard/seller/models/order_model.dart';
import 'package:market_mate/dashboard/seller/presentation/widgets/orders_empty_state.dart';
import 'package:market_mate/dashboard/seller/providers/seller_state_providers.dart';
import '../../../../core/theme/app_colors.dart';

class OrderHistoryPage extends ConsumerWidget {
  const OrderHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(orderHistoryProvider);
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final hPad = isTablet ? size.width * 0.08 : 20.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final orders = ordersAsync.whenOrNull(data: (o) => o) ?? [];

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
                    child: Icon(
                      Icons.chevron_left_rounded,
                      size: 28,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppLocalizations.of(context)!.seller_orders_history,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 22 : 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: orders.isEmpty
                  ? OrdersEmptyState(
                      title: AppLocalizations.of(context)!.seller_orders_no_history,
                      subtitle: AppLocalizations.of(context)!.seller_orders_no_history_desc,
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        ref.invalidate(sellerOrdersProvider);
                        await ref.read(sellerOrdersProvider.future);
                      },
                      child: ListView.separated(
                        padding: EdgeInsets.fromLTRB(
                          hPad,
                          8,
                          hPad,
                          padding.bottom + 16,
                        ),
                        itemCount: orders.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final o = orders[i];
                          final isCompleted =
                              o.tabStatus == OrderTabStatus.completed;
                          final isCancelled =
                              o.tabStatus == OrderTabStatus.cancelled;
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      o.customerName,
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: isTablet ? 16 : 15,
                                        fontWeight: FontWeight.w600,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      o.dateRange,
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: isTablet ? 14 : 12,
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
                                    color: isCompleted
                                        ? AppColors.primarySurface
                                        : isCancelled
                                        ? AppColors.errorSurface
                                        : AppColors.secondarySurface,
                                    borderRadius: BorderRadius.circular(100),
                                  ),
                                  child: Text(
                                    isCompleted
                                        ? AppLocalizations.of(context)!.seller_orders_status_completed
                                        : isCancelled
                                        ? 'Canceled'
                                        : AppLocalizations.of(context)!.seller_orders_pending,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: isTablet ? 13 : 12,
                                      fontWeight: FontWeight.w600,
                                      color: isCompleted
                                          ? AppColors.primary
                                          : isCancelled
                                          ? AppColors.error
                                          : AppColors.secondary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
