import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_mate/dashboard/seller/models/order_model.dart';
import 'package:market_mate/dashboard/seller/models/rider_model.dart';
import 'package:market_mate/dashboard/seller/providers/rider_assignment_provider.dart';
import '../../../../core/theme/app_colors.dart';

class RiderDetailWithOrderPage extends ConsumerStatefulWidget {
  final RiderModel rider;
  final OrderModel order;

  const RiderDetailWithOrderPage({
    super.key,
    required this.rider,
    required this.order,
  });

  @override
  ConsumerState<RiderDetailWithOrderPage> createState() =>
      _RiderDetailWithOrderPageState();
}

class _RiderDetailWithOrderPageState
    extends ConsumerState<RiderDetailWithOrderPage>
    with SingleTickerProviderStateMixin {
  bool _assigned = false;
  bool _orderExpanded = false;
  late final AnimationController _blurCtrl;
  late final Animation<double> _blurAnim;

  @override
  void initState() {
    super.initState();
    _blurCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _blurAnim = CurvedAnimation(parent: _blurCtrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _blurCtrl.dispose();
    super.dispose();
  }

  void _assign() {
    ref.read(assignedRiderProvider.notifier).state = widget.rider;
    setState(() => _assigned = true);
    _blurCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final hPad = isTablet ? size.width * 0.08 : 20.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rider = widget.rider;
    final order = widget.order;
    final showDropdown = order.items.length > 5;
    final visibleItems = showDropdown && !_orderExpanded
        ? order.items.take(5).toList()
        : order.items;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      body: Stack(
        children: [
          SafeArea(
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
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      0,
                      hPad,
                      padding.bottom + 90,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Driver Information',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 22 : 20,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Container(
                          padding: EdgeInsets.all(isTablet ? 18 : 14),
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.surfaceDark
                                : AppColors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.primary,
                              width: 1.5,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: isTablet ? 36 : 30,
                                backgroundColor: AppColors.gray1,
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppColors.gray2,
                                  size: isTablet ? 40 : 34,
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
                                        fontSize: isTablet ? 18 : 16,
                                        fontWeight: FontWeight.w700,
                                        color: isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        ...List.generate(
                                          3,
                                          (_) => Icon(
                                            Icons.star_rounded,
                                            color: AppColors.secondary,
                                            size: isTablet ? 16 : 14,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          rider.formattedRating,
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
                                    const SizedBox(height: 4),
                                    if (rider.isVerified)
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.verified_rounded,
                                            color: AppColors.primary,
                                            size: isTablet ? 16 : 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            'Verified',
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: isTablet ? 13 : 12,
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SvgPicture.asset(
                                    'assets/images/car.svg',
                                    width: isTablet ? 90 : 72,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${rider.vehicleInfo} - ${rider.plateNumber}',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: isTablet ? 12 : 10,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: Colors.white,
                                  minimumSize: Size(0, isTablet ? 52 : 46),
                                  shape: const StadiumBorder(),
                                  elevation: 0,
                                  textStyle: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: isTablet ? 15 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text('Message'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {},
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.primary,
                                  side: const BorderSide(
                                    color: AppColors.primary,
                                    width: 1.5,
                                  ),
                                  minimumSize: Size(0, isTablet ? 52 : 46),
                                  shape: const StadiumBorder(),
                                  textStyle: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: isTablet ? 15 : 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text('Call'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _buildRatingBars(rider, isTablet),
                        const SizedBox(height: 24),
                        _buildOrderCard(
                          order,
                          visibleItems,
                          showDropdown,
                          isTablet,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          AnimatedBuilder(
            animation: _blurAnim,
            builder: (_, __) {
              if (!_assigned) return const SizedBox.shrink();
              return Stack(
                children: [
                  Container(
                    color: Colors.black.withAlpha(
                      ((0.45 * _blurAnim.value) * 255).round(),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 0),
                      child: _SuccessBanner(
                        isTablet: isTablet,
                        onClose: () {
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: _assigned
          ? null
          : Container(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, padding.bottom + 16),
              color: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
              child: ElevatedButton(
                onPressed: _assign,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  minimumSize: Size(double.infinity, isTablet ? 60 : 52),
                  shape: const StadiumBorder(),
                  elevation: 0,
                  textStyle: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 17 : 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: const Text('Assign delivery'),
              ),
            ),
    );
  }

  Widget _buildRatingBars(RiderModel rider, bool isTablet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ratings',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: isTablet ? 18 : 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.black,
          ),
        ),
        const SizedBox(height: 14),
        ...rider.ratingBreakdown.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Row(
                  children: List.generate(
                    e.key,
                    (_) => Icon(
                      Icons.star_rounded,
                      color: AppColors.secondary,
                      size: isTablet ? 16 : 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: LinearProgressIndicator(
                      value: e.value / 100,
                      minHeight: isTablet ? 8 : 6,
                      backgroundColor: isDark
                          ? AppColors.borderDark
                          : AppColors.border,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 40,
                  child: Text(
                    '${e.value.toInt()}%',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 13 : 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(
    OrderModel order,
    List<OrderItem> visibleItems,
    bool showDropdown,
    bool isTablet,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.circular(16),
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
                        fontSize: isTablet ? 13 : 12,
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
                  ],
                ),
                Text(
                  order.formattedTotal,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 18 : 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 16 : 14,
              vertical: 12,
            ),
            child: Text(
              'Order items',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.black,
              ),
            ),
          ),
          ...visibleItems.map(
            (item) => Padding(
              padding: EdgeInsets.fromLTRB(
                isTablet ? 16 : 14,
                0,
                isTablet ? 16 : 14,
                12,
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      item.imageAsset,
                      width: isTablet ? 44 : 38,
                      height: isTablet ? 44 : 38,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        width: isTablet ? 44 : 38,
                        height: isTablet ? 44 : 38,
                        color: AppColors.gray1,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.gray2,
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.name,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.black,
                      ),
                    ),
                  ),
                  Text(
                    'x${item.quantity}',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 13 : 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    item.formattedTotal,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 13 : 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (showDropdown)
            GestureDetector(
              onTap: () => setState(() => _orderExpanded = !_orderExpanded),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isTablet ? 16 : 14,
                  0,
                  isTablet ? 16 : 14,
                  12,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _orderExpanded
                          ? 'Show less'
                          : '+ ${order.items.length - 5} more items',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    AnimatedRotation(
                      turns: _orderExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.primary,
                        size: isTablet ? 18 : 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.all(isTablet ? 16 : 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 13 : 12,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                Text(
                  'Total: ${order.formattedTotal}',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 14 : 13,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessBanner extends StatelessWidget {
  final bool isTablet;
  final VoidCallback onClose;

  const _SuccessBanner({required this.isTablet, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 20 : 16,
        vertical: isTablet ? 16 : 14,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha((0.3 * 255).round()),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: isTablet ? 32 : 28,
            height: isTablet ? 32 : 28,
            decoration: BoxDecoration(
              color: Colors.white.withAlpha((0.2 * 255).round()),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_box_rounded,
              color: Colors.white,
              size: isTablet ? 18 : 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Success',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 16 : 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'You have successfully assigned the rider.',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 13 : 12,
                    color: Colors.white.withAlpha((0.9 * 255).round()),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Icon(
              Icons.close_rounded,
              color: Colors.white.withAlpha((0.8 * 255).round()),
              size: isTablet ? 20 : 18,
            ),
          ),
        ],
      ),
    );
  }
}
