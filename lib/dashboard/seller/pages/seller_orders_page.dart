import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/dashboard/seller/models/order_model.dart';
import 'package:market_mate/dashboard/seller/pages/Order history page.dart';
import 'package:market_mate/dashboard/seller/pages/Pending_order_detail_page.dart';
import 'package:market_mate/dashboard/seller/pages/active_order_detail_page.dart';
import 'package:market_mate/dashboard/seller/presentation/widgets/orders_empty_state.dart';
import 'package:market_mate/dashboard/seller/providers/seller_state_providers.dart';
import '../../../../core/theme/app_colors.dart';

class SellerOrdersPage extends ConsumerStatefulWidget {
  const SellerOrdersPage({super.key});

  @override
  ConsumerState<SellerOrdersPage> createState() => _SellerOrdersPageState();
}

class _SellerOrdersPageState extends ConsumerState<SellerOrdersPage> {
  @override
  Widget build(BuildContext context) {
    final activeAsync = ref.watch(activeOrdersProvider);
    final pendingAsync = ref.watch(pendingOrdersProvider);
    final completedAsync = ref.watch(completedOrdersProvider);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = isTablet ? size.width * 0.08 : size.width * 0.058;

    final active = activeAsync.whenOrNull(data: (o) => o) ?? [];
    final pending = pendingAsync.whenOrNull(data: (o) => o) ?? [];
    final completed = completedAsync.whenOrNull(data: (o) => o) ?? [];

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(sellerOrdersProvider);
                await ref.read(sellerOrdersProvider.future);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          hPad,
                          size.height * 0.016,
                          hPad,
                          0,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                AppLocalizations.of(context)!.seller_orders_title,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: isTablet ? 22 : 18,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.black,
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const OrderHistoryPage(),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    AppLocalizations.of(context)!.seller_orders_history,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: isTablet ? 14 : 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    size: 16,
                                    color: AppColors.primary,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.016),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: hPad),
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          dividerColor: Colors.transparent,
                          indicatorColor: Colors.transparent,
                          labelPadding: EdgeInsets.only(
                            right: size.width * 0.027,
                          ),
                          tabs: [
                            _TabChip(
                              label: AppLocalizations.of(context)!.seller_orders_active,
                              count: active.length,
                              size: size,
                            ),
                            _TabChip(
                              label: AppLocalizations.of(context)!.seller_orders_pending,
                              count: pending.length,
                              size: size,
                            ),
                            _TabChip(
                              label: AppLocalizations.of(context)!.seller_orders_completed,
                              count: completed.length,
                              size: size,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      SizedBox(
                        height: size.height * 0.72,
                        child: TabBarView(
                          children: [
                            _ActiveTab(
                              orders: active,
                              hPad: hPad,
                              isTablet: isTablet,
                              size: size,
                            ),
                            _PendingTab(
                              orders: pending,
                              hPad: hPad,
                              isTablet: isTablet,
                              size: size,
                            ),
                            _CompletedTab(
                              orders: completed,
                              hPad: hPad,
                              isTablet: isTablet,
                              size: size,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  final String label;
  final int count;
  final Size size;

  const _TabChip({
    required this.label,
    required this.count,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final controller = DefaultTabController.of(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final tabs = [AppLocalizations.of(context)!.seller_orders_active, AppLocalizations.of(context)!.seller_orders_pending, AppLocalizations.of(context)!.seller_orders_completed];
        final idx = tabs.indexOf(label);
        final selected = controller.index == idx;
        return Tab(
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? size.width * 0.04 : size.width * 0.032,
              vertical: isTablet ? size.height * 0.012 : size.height * 0.009,
            ),
            decoration: BoxDecoration(
              color: selected ? Colors.transparent : Colors.transparent,
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: selected
                    ? AppColors.primary
                    : (isDark ? AppColors.borderDark : AppColors.border),
                width: selected ? 1.8 : 1.2,
              ),
            ),
            child: Text(
              '$label ($count)',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w600,
                color: selected
                    ? AppColors.primary
                    : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ActiveTab extends StatelessWidget {
  final List<OrderModel> orders;
  final double hPad;
  final bool isTablet;
  final Size size;

  const _ActiveTab({
    required this.orders,
    required this.hPad,
    required this.isTablet,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    if (orders.isEmpty) {
      return OrdersEmptyState(
        title: AppLocalizations.of(context)!.seller_orders_no_active,
        subtitle: AppLocalizations.of(context)!.seller_orders_no_active_desc,
      );
    }
    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: hPad,
        vertical: size.height * 0.01,
      ),
      itemCount: orders.length,
      itemBuilder: (_, i) => _ActiveOrderCard(
        order: orders[i],
        isTablet: isTablet,
        size: size,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) {
                return ActiveOrderDetailPage(order: orders[i]);
              },
            ),
          );
        },
      ),
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  final OrderModel order;
  final bool isTablet;
  final Size size;
  final VoidCallback onTap;

  const _ActiveOrderCard({
    required this.order,
    required this.isTablet,
    required this.size,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [AppLocalizations.of(context)!.seller_orders_confirmed, AppLocalizations.of(context)!.seller_orders_processed, AppLocalizations.of(context)!.seller_orders_shipped, AppLocalizations.of(context)!.seller_orders_delivered];
    final currentIdx = order.currentStatus.index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: size.height * 0.018),
        padding: EdgeInsets.all(isTablet ? 18 : 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.seller_orders_to(order.customerName),
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 13 : 11,
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: size.height * 0.005),
            Text(
              order.items.map((e) => e.name).join(', '),
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 16 : 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.black,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: size.height * 0.005),
            Text(
              AppLocalizations.of(context)!.seller_orders_rider(order.riderName ?? 'Unassigned'),
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 13 : 12,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: size.height * 0.005),
            RichText(
              text: TextSpan(
                text: AppLocalizations.of(context)!.seller_orders_price,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 13 : 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
                children: [
                  TextSpan(
                    text: order.formattedTotal,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: size.height * 0.015),
            Row(
              children: steps.asMap().entries.map((entry) {
                final idx = entry.key;
                final label = entry.value;
                final active = idx <= currentIdx;
                final isLast = idx == steps.length - 1;
                return Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            vertical: isTablet ? 9 : 7,
                          ),
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : AppColors.gray1,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              label,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet ? 11 : 10,
                                fontWeight: FontWeight.w600,
                                color: active ? Colors.white : AppColors.gray2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (!isLast)
                        Container(
                          width: size.width * 0.021,
                          height: size.height * 0.003,
                          color: active && idx < currentIdx
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.border),
                        ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PendingTab extends StatelessWidget {
  final List<OrderModel> orders;
  final double hPad;
  final bool isTablet;
  final Size size;

  const _PendingTab({
    required this.orders,
    required this.hPad,
    required this.isTablet,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (orders.isEmpty) {
      return OrdersEmptyState(
        title: AppLocalizations.of(context)!.seller_orders_no_pending,
        subtitle: AppLocalizations.of(context)!.seller_orders_no_pending_desc,
      );
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: hPad,
        vertical: size.height * 0.01,
      ),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final o = orders[i];
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => PendingOrderDetailPage(order: o)),
          ),
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
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
                      SizedBox(height: size.height * 0.005),
                      Text(
                        AppLocalizations.of(context)!.seller_orders_placed_on(o.placedDate),
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
                Row(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.seller_orders_assign_rider,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.secondary,
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.secondary,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _CompletedTab extends StatelessWidget {
  final List<OrderModel> orders;
  final double hPad;
  final bool isTablet;
  final Size size;

  const _CompletedTab({
    required this.orders,
    required this.hPad,
    required this.isTablet,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (orders.isEmpty) {
      return OrdersEmptyState(
        title: AppLocalizations.of(context)!.seller_orders_no_completed,
        subtitle: AppLocalizations.of(context)!.seller_orders_no_completed_desc,
      );
    }
    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: hPad,
        vertical: size.height * 0.01,
      ),
      itemCount: orders.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final o = orders[i];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: size.height * 0.018),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
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
                    SizedBox(height: size.height * 0.005),
                    Text(
                      o.dateRange,
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
              Text(
                AppLocalizations.of(context)!.seller_orders_status_completed,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 14 : 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
