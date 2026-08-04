import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/dashboard/rider/models/rider_delivery_model.dart';
import 'package:market_mate/dashboard/rider/providers/rider_dashboard_provider.dart';
import 'rider_delivery_detail_page.dart';
import 'rider_delivery_history_page.dart';

class RiderDeliveriesPage extends ConsumerWidget {
  const RiderDeliveriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final active = ref.watch(riderActiveProvider);
    final pending = ref.watch(riderPendingProvider);
    final completed = ref.watch(riderCompletedProvider);
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tabs = [l10n.rider_deliveries_active, l10n.rider_deliveries_pending, l10n.rider_deliveries_completed];
    final counts = [active.length, pending.length, completed.length];

    return DefaultTabController(
      length: 3,
      child: Builder(
        builder: (tabCtx) => Scaffold(
        backgroundColor:
            isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _buildHeader(context, isDark),
              _buildSegmentedBar(tabCtx, isDark, tabs, counts),
              Expanded(
                child: TabBarView(
                  physics: const ClampingScrollPhysics(),
                  children: [
                    _DeliveryList(deliveries: active),
                    _DeliveryList(deliveries: pending),
                    _CompletedList(deliveries: completed),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      ),
    );
  }
  
  

  Widget _buildHeader(BuildContext context, bool isDark) {
    final l10n = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_new, size: 20),
          ),
          const SizedBox(width: 12),
          Text(
            l10n.rider_deliveries_title,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color:
                  isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const RiderDeliveryHistoryPage(),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.rider_delivery_history,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 2),
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
    );
  }

  Widget _buildSegmentedBar(
      BuildContext context, bool isDark, List<String> tabs, List<int> counts) {
    final controller = DefaultTabController.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: List.generate(tabs.length, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                right: i < tabs.length - 1 ? 12 : 0,
              ),
              child: GestureDetector(
                onTap: () => controller.animateTo(i),
                child: AnimatedBuilder(
                  animation: controller,
                  builder: (_, __) {
                    final selected = controller.index == i;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: selected
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.border),
                          width: selected ? 1.8 : 1.2,
                        ),
                      ),
                      child: Text(
                        '${tabs[i]} (${counts[i]})',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final String title;
  final String subtitle;

  const _EmptyState({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: (isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary)
                  .withValues(alpha: 0.25),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w400,
                height: 1.4,
                color:
                    isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryList extends StatelessWidget {
  final List<RiderDeliveryModel> deliveries;
  const _DeliveryList({required this.deliveries});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (deliveries.isEmpty) {
      return _EmptyState(
        title: l10n.rider_no_deliveries,
        subtitle: l10n.rider_no_deliveries_desc,
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: deliveries.length,
      itemBuilder: (_, i) => GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => RiderDeliveryDetailPage(delivery: deliveries[i]),
          ),
        ),
        child: _DeliveryCard(delivery: deliveries[i]),
      ),
    );
  }
}

class _DeliveryCard extends StatelessWidget {
  final RiderDeliveryModel delivery;
  const _DeliveryCard({required this.delivery});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = [
      l10n.rider_accept_delivery,
      l10n.rider_heading_to_pick,
      l10n.rider_picked_up,
      l10n.rider_delivered_label,
    ];
    final stepDates = ['Jan 21', 'Jan 18', 'Jan 19', l10n.rider_delivery_soon];
    final currentIdx = delivery.currentStep.index;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: '${l10n.rider_order_ref(delivery.orderRef)}  ',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              children: [
                TextSpan(
                  text: l10n.rider_to_customer(delivery.customerName),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _AddrRow(
            icon: Icons.circle,
            address: delivery.pickupAddress,
            showNav: true,
          ),
          const SizedBox(height: 8),
          _AddrRow(
            icon: Icons.stop_rounded,
            address: delivery.dropoffAddress,
            showNav: false,
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: (currentIdx + 1) / 4,
              minHeight: 4,
              backgroundColor:
                  isDark ? AppColors.borderDark : AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (i) {
              final done = i <= currentIdx;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.border),
                      ),
                      child: Icon(
                        done
                            ? Icons.check_rounded
                            : Icons.circle_outlined,
                        color: AppColors.textOnPrimary,
                        size: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 60,
                      child: Text(
                        steps[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: done
                              ? (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary)
                              : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.gray2),
                        ),
                      ),
                    ),
                    Text(
                      stepDates[i],
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 10,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.gray2,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AddrRow extends StatelessWidget {
  final IconData icon;
  final String address;
  final bool showNav;

  const _AddrRow({
    required this.icon,
    required this.address,
    required this.showNav,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 10,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              address,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 11,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
          ),
          if (showNav)
            Icon(
              Icons.navigation_outlined,
              size: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
        ],
      ),
    );
  }
}

class _CompletedList extends StatelessWidget {
  final List<RiderDeliveryModel> deliveries;
  const _CompletedList({required this.deliveries});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (deliveries.isEmpty) {
      return _EmptyState(
        title: l10n.rider_no_completed_deliveries,
        subtitle: l10n.rider_no_completed_deliveries_desc,
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      itemCount: deliveries.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: isDark ? AppColors.dividerDark : AppColors.divider,
      ),
      itemBuilder: (_, i) {
        final d = deliveries[i];
        return GestureDetector(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RiderDeliveryDetailPage(delivery: d),
            ),
          ),
          behavior: HitTestBehavior.opaque,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.rider_order_ref(d.orderRef),
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        d.dateRange,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
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
                      l10n.rider_status_completed,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_rounded,
                      color: AppColors.primary,
                      size: 14,
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
