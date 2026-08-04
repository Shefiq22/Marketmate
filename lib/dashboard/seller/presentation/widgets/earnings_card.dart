import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/theme/app_colors.dart';
import '../../providers/seller_state_providers.dart';

class EarningsCard extends ConsumerStatefulWidget {
  const EarningsCard({super.key});

  @override
  ConsumerState<EarningsCard> createState() => _EarningsCardState();
}

class _EarningsCardState extends ConsumerState<EarningsCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _pulse;
  bool _balanceVisible = true;

  @override
  void initState() {
    super.initState();
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _pulse = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final earningsAsync = ref.watch(sellerEarningsProvider);
    final dashAsync = ref.watch(sellerDashboardStatsProvider);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final totalEarnings = earningsAsync.whenOrNull(
          data: (e) => e.formattedTotal,
        ) ??
        '\u20A60.00';

    return AnimatedBuilder(
      animation: _pulse,
      builder: (_, child) {
        final t = _pulse.value;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(isTablet ? 28 : 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [AppColors.primaryDark, AppColors.secondaryDark]
                  : const [Color(0xFF3D9A50), Color(0xFFC5763A)],
            ),
            boxShadow: [
              BoxShadow(
                color: (isDark ? AppColors.primaryDark : AppColors.primary)
                    .withAlpha(((0.15 + t * 0.18) * 255).round()),
                blurRadius: 12 + t * 10,
                spreadRadius: t * 3,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: child,
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Total Earnings',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withAlpha((0.9 * 255).round()),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _balanceVisible = !_balanceVisible),
                    child: SvgPicture.asset(
                      'assets/icons/eye_icon.svg',
                      width: isTablet ? 22 : 18,
                      height: isTablet ? 22 : 18,
                      colorFilter: ColorFilter.mode(
                        Colors.white.withAlpha((0.85 * 255).round()),
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Text(
                      'Payment history',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 14 : 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withAlpha((0.9 * 255).round()),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.white.withAlpha((0.9 * 255).round()),
                      size: isTablet ? 18 : 16,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isTablet ? 14 : 10),
          Text(
            _balanceVisible ? totalEarnings : '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 34 : 28,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: isTablet ? 8 : 6),
          dashAsync.when(
            data: (dash) => Text(
              '${dash.totalProducts} products \u2022 ${dash.pendingOrders} pending orders',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 12 : 11,
                color: Colors.white.withAlpha((0.75 * 255).round()),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
