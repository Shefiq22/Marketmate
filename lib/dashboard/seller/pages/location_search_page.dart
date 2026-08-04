import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_mate/dashboard/seller/data/mock_riders.dart';
import 'package:market_mate/dashboard/seller/providers/rider_assignment_provider.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import 'riders_near_you_page.dart';

import 'package:market_mate/dashboard/seller/models/order_model.dart';

class LocationSearchPage extends ConsumerStatefulWidget {
  final OrderModel? order;
  const LocationSearchPage({super.key, this.order});

  @override
  ConsumerState<LocationSearchPage> createState() => _LocationSearchPageState();
}

class _LocationSearchPageState extends ConsumerState<LocationSearchPage> {
  final _pickupController = TextEditingController();
  final _dropoffController = TextEditingController();
  final _pickupFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _pickupFocus.requestFocus(),
    );
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _dropoffController.dispose();
    _pickupFocus.dispose();
    super.dispose();
  }

  void _selectLocation(String label) {
    ref.read(selectedLocationProvider.notifier).state = label;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RidersNearYouPage(location: label, order: widget.order),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final hPad = isTablet ? size.width * 0.08 : 20.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.surfaceDark : AppColors.white,
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
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Column(
                children: [
                  TextField(
                    controller: _pickupController,
                    focusNode: _pickupFocus,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 15 : 14,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.location_pickup,
                      hintStyle: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 15 : 14,
                        color: AppColors.gray2,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(13),
                        child: SvgPicture.asset(
                          'assets/icons/location_icon.svg',
                          width: isTablet ? 22 : 18,
                          height: isTablet ? 22 : 18,
                          colorFilter: const ColorFilter.mode(
                            AppColors.primary,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.8,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) _selectLocation(v.trim());
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _dropoffController,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 15 : 14,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.location_dropoff,
                      hintStyle: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 15 : 14,
                        color: AppColors.gray2,
                      ),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(13),
                        child: Icon(
                          Icons.search_rounded,
                          color: AppColors.gray2,
                          size: isTablet ? 22 : 18,
                        ),
                      ),
                      filled: true,
                      fillColor: AppColors.gray1,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.border,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 1.8,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty) _selectLocation(v.trim());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                itemCount: mockRecentLocations.length,
                separatorBuilder: (_, __) => Divider(
                  height: 1,
                  color: isDark ? AppColors.borderDark : AppColors.border,
                ),
                itemBuilder: (_, i) {
                  final loc = mockRecentLocations[i];
                  return GestureDetector(
                    onTap: () => _selectLocation(loc.$1),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.access_time_rounded,
                            color: AppColors.gray2,
                            size: isTablet ? 22 : 18,
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.$1,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: isTablet ? 16 : 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.textPrimaryDark
                                        : AppColors.black,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  loc.$2,
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
                            loc.$3,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: isTablet ? 13 : 12,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
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
