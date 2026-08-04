import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:market_mate/dashboard/seller/models/rider_model.dart';
import 'package:market_mate/dashboard/seller/data/mock_riders.dart';
import 'package:market_mate/dashboard/seller/providers/rider_assignment_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'select_order_for_rider_page.dart';
import 'rider_detail_with_order_page.dart';

import 'package:market_mate/dashboard/seller/models/order_model.dart';

class RidersNearYouPage extends ConsumerStatefulWidget {
  final String location;
  final OrderModel? order;
  const RidersNearYouPage({super.key, required this.location, this.order});

  @override
  ConsumerState<RidersNearYouPage> createState() => _RidersNearYouPageState();
}

class _RidersNearYouPageState extends ConsumerState<RidersNearYouPage> {
  final _mapController = MapController();

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  List<Marker> _buildMarkers(List<RiderModel> riders) {
    return riders
        .map(
          (r) => Marker(
            point: LatLng(r.lat, r.lng),
            width: 36,
            height: 36,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => widget.order != null
                      ? RiderDetailWithOrderPage(rider: r, order: widget.order!)
                      : SelectOrderForRiderPage(rider: r),
                ),
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.directions_bike_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = isTablet ? size.width * 0.08 : 16.0;
    final riders = ref.watch(availableRidersProvider);
    final sheetHeight = size.height * 0.6;

    return Scaffold(
      body: Stack(
        children: [
          SizedBox(
            width: double.infinity,
            height: size.height,
            child: FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: LatLng(lagosLat, lagosLng),
                initialZoom: 13.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://cartodb-basemaps-a.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.marketmateconnectltd.market_mate',
                ),
                MarkerLayer(markers: _buildMarkers(riders)),
              ],
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.surfaceDark : AppColors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: AppColors.shadowLight, blurRadius: 8),
                  ],
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: SvgPicture.asset(
                        'assets/icons/back_icon.svg',
                        width: isTablet ? 24 : 20,
                        height: isTablet ? 24 : 20,
                        colorFilter: ColorFilter.mode(
                          isDark ? AppColors.textPrimaryDark : AppColors.black,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        widget.location,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: isTablet ? 15 : 13,
                          fontWeight: FontWeight.w500,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.black,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: sheetHeight,
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : AppColors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 8),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: hPad),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Riders near you',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 18 : 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.black,
                          ),
                        ),
                        if (riders.isNotEmpty)
                          Text(
                            'See all',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: isTablet ? 14 : 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  Expanded(
                    child: riders.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.directions_bike_outlined,
                                  color: AppColors.gray2,
                                  size: isTablet ? 56 : 48,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No riders nearby',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Tap ⊞ to simulate nearby riders',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: isTablet ? 13 : 12,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.gray2,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            itemCount: riders.length,
                            itemBuilder: (_, i) => _RiderCard(
                              rider: riders[i],
                              isTablet: isTablet,
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => widget.order != null
                                      ? RiderDetailWithOrderPage(
                                          rider: riders[i],
                                          order: widget.order!,
                                        )
                                      : SelectOrderForRiderPage(
                                          rider: riders[i],
                                        ),
                                ),
                              ),
                              onAssign: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => widget.order != null
                                      ? RiderDetailWithOrderPage(
                                          rider: riders[i],
                                          order: widget.order!,
                                        )
                                      : SelectOrderForRiderPage(
                                          rider: riders[i],
                                        ),
                                ),
                              ),
                            ),
                          ),
                  ),
                  SizedBox(height: padding.bottom + 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RiderCard extends StatelessWidget {
  final RiderModel rider;
  final bool isTablet;
  final VoidCallback onTap;
  final VoidCallback onAssign;
  const _RiderCard({
    required this.rider,
    required this.isTablet,
    required this.onTap,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowLight,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: isTablet ? 30 : 26,
              backgroundColor: AppColors.gray1,
              child: Icon(
                Icons.person_rounded,
                color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
                size: isTablet ? 34 : 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rider.name,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        '${rider.completedDeliveries} completed deliveries',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: isTablet ? 13 : 11,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          '|',
                          style: TextStyle(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.border,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.star_rounded,
                        color: AppColors.secondary,
                        size: isTablet ? 15 : 13,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        rider.rating.toStringAsFixed(1),
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
                  const SizedBox(height: 2),
                  Text(
                    rider.formattedDistance,
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
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onAssign,
              child: Container(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 14 : 11,
                  vertical: isTablet ? 8 : 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  'Assign',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 13 : 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
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
