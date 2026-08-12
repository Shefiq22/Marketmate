import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:latlong2/latlong.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/core/widgets/sandy_loader.dart';
import 'package:market_mate/dashboard/rider/providers/rider_dashboard_provider.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import 'rider_notifications_page.dart';

class RiderHomePage extends ConsumerStatefulWidget {
  const RiderHomePage({super.key});

  @override
  ConsumerState<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends ConsumerState<RiderHomePage>
    with SingleTickerProviderStateMixin {
  bool _earningsVisible = true;
  bool _togglingOnline = false;
  final _mapController = MapController();
  AnimationController? _cameraController;
  Animation<LatLng>? _cameraAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      // Restore the last known online status so the UI reflects it on
      // relaunch; the next server sync happens on the next toggle.
      final wasOnline = await ref.read(riderPersistenceProvider).loadOnline();
      if (!mounted) return;
      if (wasOnline) {
        ref.read(riderOnlineProvider.notifier).restore(true);
      }
    });
  }

  @override
  void dispose() {
    _cameraController?.dispose();
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
    final locationState = ref.watch(riderLocationProvider);
    final activeDelivery = active.isNotEmpty ? active.first : null;

    // Follow the rider on the map: jump to the first fix, then glide smoothly
    // on subsequent updates.
    ref.listen<RiderLocationState>(riderLocationProvider, (previous, next) {
      final pos = next.position;
      if (pos == null) return;
      if (previous?.position == null) {
        _mapController.move(pos, 15.5);
      } else if (pos != previous!.position) {
        _animateCameraTo(pos);
      }
    });

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
                      _togglingOnline
                          ? SizedBox(
                              width: size.width * 0.052,
                              height: size.width * 0.052,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.primary,
                              ),
                            )
                          : Switch(
                              value: isOnline,
                              onChanged: (v) async {
                                setState(() => _togglingOnline = true);
                                try {
                                  await ref
                                      .read(riderOnlineProvider.notifier)
                                      .toggle(v);
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _onlineErrorMessage(e),
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted) {
                                    setState(() => _togglingOnline = false);
                                  }
                                }
                              },
                              activeThumbColor: AppColors.primary,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
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
                    crossAxisAlignment: CrossAxisAlignment.start,
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
                      child: Column(
                        children: [
                          Icon(
                            Icons.delivery_dining_outlined,
                            size: size.width * 0.08,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.gray2,
                          ),
                          SizedBox(height: size.height * 0.01),
                          Text(
                            l10n.rider_no_active_deliveries,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: size.width * 0.036,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.gray2,
                            ),
                          ),
                        ],
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
                    child: SizedBox(
                      height: size.height * 0.28,
                      child: Stack(
                        children: [
                          Positioned.fill(
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
                                if (locationState.position != null)
                                  MarkerLayer(
                                    markers: [
                                      Marker(
                                        point: locationState.position!,
                                        width: 46,
                                        height: 46,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white,
                                              width: 3,
                                            ),
                                            boxShadow: const [
                                              BoxShadow(
                                                color: Colors.black26,
                                                blurRadius: 8,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.directions_bike,
                                            color: AppColors.textOnPrimary,
                                            size: 22,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          if (locationState.permissionDenied)
                            Positioned(
                              top: 10,
                              left: 10,
                              right: 10,
                              child: _MapStatusChip(
                                icon: Icons.location_off_rounded,
                                message:
                                    'Enable location access to share your live position.',
                                actionLabel: 'Retry',
                                onAction: () => ref
                                    .read(riderLocationProvider.notifier)
                                    .retry(),
                              ),
                            )
                          else if (locationState.serviceDisabled)
                            const Positioned(
                              top: 10,
                              left: 10,
                              right: 10,
                              child: _MapStatusChip(
                                icon: Icons.gps_off_rounded,
                                message: 'Location services are turned off.',
                              ),
                            )
                          else if (locationState.isTracking &&
                              locationState.position == null)
                            const Positioned(
                              top: 10,
                              left: 10,
                              right: 10,
                              child: _MapStatusChip(
                                icon: Icons.my_location_rounded,
                                message: 'Getting your location…',
                              ),
                            ),
                          if (locationState.position != null)
                            Positioned(
                              bottom: 10,
                              left: 10,
                              child: _MapStatusChip(
                                icon: locationState.isTracking
                                    ? Icons.circle
                                    : Icons.pause_circle_outline_rounded,
                                message: locationState.isTracking
                                    ? 'Live tracking on'
                                    : 'Tracking paused',
                              ),
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

  String _onlineErrorMessage(Object error) {
    final text = error.toString().replaceFirst('Exception: ', '').toLowerCase();

    if (text.contains('approved')) {
      return 'Your rider account is awaiting admin approval. '
          'You can go online once your account is approved.';
    }
    if (error is TimeoutException ||
        error is SocketException ||
        error is HttpException ||
        text.contains('timed out') ||
        text.contains('connection') ||
        text.contains('internet') ||
        text.contains('socket')) {
      return 'No internet connection. Check your network and try again.';
    }
    if (text.contains('authentication required') ||
        text.contains('log in') ||
        text.contains('unauthor')) {
      return 'Your session has expired. Please log in again.';
    }
    return 'Could not update your online status. Please try again.';
  }

  void _animateCameraTo(LatLng target) {
    final current = _mapController.camera.center;
    _cameraAnimation = _LatLngTween(begin: current, end: target)
        .animate(CurvedAnimation(
      parent: _cameraController ??
          (_cameraController = AnimationController(
            vsync: this,
            duration: const Duration(milliseconds: 900),
          )),
      curve: Curves.easeInOut,
    ));
    _cameraAnimation!.addListener(() {
      if (!mounted) return;
      _mapController.move(_cameraAnimation!.value, 15.5);
    });
    _cameraController!.forward(from: 0);
  }
}

class _LatLngTween extends Tween<LatLng> {
  _LatLngTween({super.begin, super.end});

  @override
  LatLng lerp(double t) {
    final b = begin!;
    final e = end!;
    return LatLng(
      b.latitude + (e.latitude - b.latitude) * t,
      b.longitude + (e.longitude - b.longitude) * t,
    );
  }
}

class _MapStatusChip extends StatelessWidget {
  final IconData icon;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  const _MapStatusChip({
    required this.icon,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final background = isDark
        ? Colors.black.withValues(alpha: 0.65)
        : Colors.white.withValues(alpha: 0.92);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              message,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimary,
              ),
            ),
          ),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(width: 8),
            InkWell(
              onTap: onAction,
              child: Text(
                actionLabel!,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ],
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
