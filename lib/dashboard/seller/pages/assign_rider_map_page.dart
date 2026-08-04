import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:market_mate/dashboard/seller/models/rider_model.dart';
import 'package:market_mate/dashboard/seller/data/mock_riders.dart';
import 'package:market_mate/dashboard/seller/providers/rider_assignment_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'location_search_page.dart';
import 'select_order_for_rider_page.dart';
import 'rider_detail_with_order_page.dart';

import 'package:market_mate/dashboard/seller/models/order_model.dart';

class AssignRiderMapPage extends ConsumerStatefulWidget {
  final OrderModel? order;
  const AssignRiderMapPage({super.key, this.order});

  @override
  ConsumerState<AssignRiderMapPage> createState() => _AssignRiderMapPageState();
}

class _AssignRiderMapPageState extends ConsumerState<AssignRiderMapPage> {
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
    final hPad = isTablet ? size.width * 0.08 : 20.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final riders = ref.watch(availableRidersProvider);
    final bestRider = ref.watch(bestRiderProvider);
    final sheetHeight = size.height * 0.54;

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
                initialZoom: 12.5,
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
              padding: EdgeInsets.all(hPad),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 28,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.black,
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
                  if (bestRider != null)
                    Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 0),
                      child: _AutoAssignCard(
                        rider: bestRider,
                        isTablet: isTablet,
                        onAssign: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => widget.order != null
                                ? RiderDetailWithOrderPage(
                                    rider: bestRider,
                                    order: widget.order!,
                                  )
                                : SelectOrderForRiderPage(rider: bestRider),
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 12),
                    child: Text(
                      'Riders around you',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 18 : 16,
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
                        builder: (_) => LocationSearchPage(order: widget.order),
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: Container(
                        height: isTablet ? 52 : 46,
                        decoration: BoxDecoration(
                          color: AppColors.gray1,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            const SizedBox(width: 16),
                            Icon(
                              Icons.search_rounded,
                              color: AppColors.gray2,
                              size: isTablet ? 22 : 18,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Enter location',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet ? 15 : 13,
                                color: AppColors.gray2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: riders.isEmpty
                        ? Center(
                            child: Text(
                              'No riders nearby.\nTap ⊞ to simulate.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet ? 14 : 13,
                                color: AppColors.gray2,
                              ),
                            ),
                          )
                        : ListView.separated(
                            padding: EdgeInsets.symmetric(horizontal: hPad),
                            itemCount: riders.take(3).length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, i) => _RiderListTile(
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

class _AutoAssignCard extends StatelessWidget {
  final RiderModel rider;
  final bool isTablet;
  final VoidCallback onAssign;
  const _AutoAssignCard({
    required this.rider,
    required this.isTablet,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: isTablet ? 24 : 20,
            backgroundColor: AppColors.gray1,
            child: Icon(
              Icons.person_rounded,
              color: AppColors.gray2,
              size: isTablet ? 28 : 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-assign best available rider',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 12 : 11,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  rider.name,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 17 : 15,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      '${rider.completedDeliveries} completed deliveries',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 12 : 11,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '|',
                      style: TextStyle(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.star_rounded,
                      color: AppColors.secondary,
                      size: isTablet ? 14 : 12,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      rider.rating.toStringAsFixed(1),
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
          ),
          ElevatedButton(
            onPressed: onAssign,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: Size(isTablet ? 90 : 78, isTablet ? 44 : 38),
              shape: const StadiumBorder(),
              elevation: 0,
              textStyle: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            child: const Text('Assign'),
          ),
        ],
      ),
    );
  }
}

class _RiderListTile extends StatelessWidget {
  final RiderModel rider;
  final bool isTablet;
  final VoidCallback onTap;
  final VoidCallback onAssign;
  const _RiderListTile({
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            CircleAvatar(
              radius: isTablet ? 26 : 22,
              backgroundColor: AppColors.gray1,
              child: Icon(
                Icons.person_rounded,
                color: AppColors.gray2,
                size: isTablet ? 30 : 26,
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
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
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
                        padding: EdgeInsets.symmetric(horizontal: 6),
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
                        size: isTablet ? 14 : 12,
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
