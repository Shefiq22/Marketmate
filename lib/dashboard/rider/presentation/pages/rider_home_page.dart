import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/core/widgets/sandy_loader.dart';
import 'package:market_mate/dashboard/rider/providers/rider_dashboard_provider.dart';
import 'package:market_mate/dashboard/rider/repositories/rider_repository.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import 'rider_delivery_detail_page.dart';
import 'rider_notifications_page.dart';

class RiderHomePage extends ConsumerStatefulWidget {
  const RiderHomePage({super.key});

  @override
  ConsumerState<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends ConsumerState<RiderHomePage> {
  bool _earningsVisible = true;
  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final hPad = isTablet ? size.width * 0.08 : size.width * 0.05;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final l10n = AppLocalizations.of(context)!;
    final isOnline = ref.watch(riderOnlineProvider);
    final hasData = ref.watch(riderSimulateProvider);
    final active = ref.watch(riderActiveProvider);
    final completed = ref.watch(riderCompletedProvider);
    final pending = ref.watch(riderPendingProvider);
    final apiOrdersAsync = ref.watch(riderApiOrdersProvider);
    final activeDelivery = active.isNotEmpty ? active.first : null;

    if (apiOrdersAsync.isLoading && !hasData) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
        body: const SafeArea(child: SandyLoader()),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                hPad,
                size.height * 0.015,
                hPad,
                padding.bottom + size.height * 0.15,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: size.width * 0.11,
                        height: size.width * 0.11,
                        decoration: BoxDecoration(
                          color: AppColors.primarySurface,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Center(
                          child: Text(
                            ref.watch(currentUserProvider)?.initial ?? 'R',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                              fontSize: size.width * 0.04,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.022),
                      Expanded(
                        child: Text(
                          l10n.rider_home_greeting(ref.watch(currentUserProvider)?.firstName ?? 'Rider'),
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: size.width * 0.042,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const RiderNotificationsPage(),
                          ),
                        ),
                        child: Container(
                          width: size.width * 0.095,
                          height: size.width * 0.095,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(
                              size.width * 0.027,
                            ),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/notification_icon.svg',
                              width: size.width * 0.047,
                              height: size.width * 0.047,
                              colorFilter: ColorFilter.mode(
                                AppColors.textOnPrimary,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.008),
                  Row(
                    children: [
                      Switch(
                        value: isOnline,
                        onChanged: (v) async {
                          ref.read(riderOnlineProvider.notifier).state = v;
                          try {
                            final repo = RiderRepository();
                            await repo.updateOnlineStatus(v);
                          } catch (_) {}
                        },
                        activeThumbColor: AppColors.primary,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      SizedBox(width: size.width * 0.022),
                      Expanded(
                        child: Text(
                          isOnline
                              ? l10n.rider_online
                              : l10n.rider_go_online,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: size.width * 0.032,
                            color: isOnline
                                ? AppColors.primary
                                : isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.022),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(size.width * 0.05),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(size.width * 0.04),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF3D9A50), Color(0xFFC5763A)],
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.rider_total_earnings,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: size.width * 0.035,
                                    color: Colors.white.withAlpha(
                                      (0.9 * 255).round(),
                                    ),
                                  ),
                                ),
                                SizedBox(width: size.width * 0.022),
                                GestureDetector(
                                  onTap: () => setState(
                                    () => _earningsVisible = !_earningsVisible,
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/icons/eye_icon.svg',
                                    width: size.width * 0.047,
                                    height: size.width * 0.047,
                                    colorFilter: ColorFilter.mode(
                                      Colors.white.withAlpha(
                                        (0.85 * 255).round(),
                                      ),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Flexible(
                              child: GestureDetector(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      l10n.rider_payment_history,
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: size.width * 0.036,
                                        color: Colors.white.withAlpha(
                                          (0.9 * 255).round(),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: size.width * 0.01),
                                    Icon(
                                      Icons.chevron_right_rounded,
                                      color: Colors.white.withAlpha(
                                        (0.9 * 255).round(),
                                      ),
                                      size: size.width * 0.04,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.01),
                        Text(
                          _earningsVisible ? '₦223,500.05' : '••••••••',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: size.width * 0.072,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textOnPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.022),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(size.width * 0.04),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(
                              size.width * 0.035,
                            ),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.rider_completed_today,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: size.width * 0.032,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: size.height * 0.008),
                              Text(
                                '${completed.length}',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: size.width * 0.065,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: size.width * 0.032),
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.all(size.width * 0.04),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(
                              size.width * 0.035,
                            ),
                            border: Border.all(
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.rider_pending_deliveries,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: size.width * 0.032,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondary,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              SizedBox(height: size.height * 0.008),
                              Text(
                                '${pending.length}',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: size.width * 0.065,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.secondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          l10n.rider_active_delivery,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: size.width * 0.045,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (active.length > 1)
                        Flexible(
                          child:                           Text(
                            l10n.see_all,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: size.width * 0.036,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.end,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: size.height * 0.015),
                  if (activeDelivery == null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(size.width * 0.055),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.white,
                        borderRadius: BorderRadius.circular(size.width * 0.035),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.border,
                        ),
                      ),
                      child: Text(
                        hasData
                            ? l10n.rider_no_active_deliveries
                            : 'Tap ⊞ to simulate data',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: size.width * 0.036,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.gray2,
                        ),
                      ),
                    )
                  else
                    _ActiveDeliveryCard(delivery: activeDelivery, size: size),
                  SizedBox(height: size.height * 0.05),
                  Text(
                    l10n.rider_live_location,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: size.width * 0.045,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(size.width * 0.04),
                    child: Container(
                      height: size.height * 0.28,
                      color: const Color(0xFF1A1A2E),
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: const LatLng(6.5244, 3.3792),
                          initialZoom: 12.5,
                          backgroundColor: const Color(0xFF1A1A2E),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName:
                                'com.marketmateconnectltd.market_mate',
                          ),
                          if (activeDelivery != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: const LatLng(6.5244, 3.3792),
                                  width: size.width * 0.085,
                                  height: size.width * 0.085,
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.directions_bike_rounded,
                                      color: AppColors.textOnPrimary,
                                      size: size.width * 0.035,
                                    ),
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
          ),
        ),
      ),
    );
  }
}

class _ActiveDeliveryCard extends StatelessWidget {
  final dynamic delivery;
  final Size size;
  const _ActiveDeliveryCard({required this.delivery, required this.size});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = [
      l10n.rider_accept_delivery,
      l10n.rider_heading_to_pick,
      l10n.rider_picked_up,
      l10n.rider_delivered_label,
    ];
    final stepDates = ['Jan 21', 'Jan 19', 'Jan 19', l10n.rider_delivery_soon];
    final currentIdx = delivery.currentStep.index;
    final w = size.width;
    final h = size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(w * 0.045),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(w * 0.035),
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
                fontSize: w * 0.037,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
          SizedBox(height: h * 0.015),
          _AddressRow(
            icon: Icons.circle,
            address: delivery.pickupAddress,
            showNav: true,
            size: size,
          ),
          SizedBox(height: h * 0.008),
          _AddressRow(
            icon: Icons.stop_rounded,
            address: delivery.dropoffAddress,
            showNav: false,
            size: size,
          ),
          SizedBox(height: h * 0.022),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: (currentIdx + 1) / 4,
              minHeight: h * 0.007,
              backgroundColor: isDark ? AppColors.borderDark : AppColors.border,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
          SizedBox(height: h * 0.015),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(steps.length, (i) {
              final done = i <= currentIdx;
              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: w * 0.09,
                      height: w * 0.09,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: done
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.borderDark
                                  : AppColors.border),
                      ),
                      child: Icon(
                        done ? Icons.check_rounded : Icons.circle_outlined,
                        color: AppColors.textOnPrimary,
                        size: w * 0.035,
                      ),
                    ),
                    SizedBox(height: h * 0.005),
                    SizedBox(
                      width: double.infinity,
                      child: Text(
                        steps[i],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: w * 0.03,
                          fontWeight: FontWeight.w600,
                          color: done
                              ? (isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary)
                              : (isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.gray2),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      stepDates[i],
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: w * 0.028,
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

class _AddressRow extends StatelessWidget {
  final IconData icon;
  final String address;
  final bool showNav;
  final Size size;
  const _AddressRow({
    required this.icon,
    required this.address,
    required this.showNav,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    final w = size.width;
    final h = size.height;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: w * 0.035, vertical: h * 0.015),
      decoration: BoxDecoration(
        color: AppColors.gray1,
        borderRadius: BorderRadius.circular(w * 0.027),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: w * 0.032,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          SizedBox(width: w * 0.027),
          Expanded(
            child: Text(
              address,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: w * 0.035,
                color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (showNav)
            Icon(
              Icons.navigation_outlined,
              size: w * 0.045,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
        ],
      ),
    );
  }
}
