import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:market_mate/core/providers/locale_provider.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/dashboard/buyer/screens/cart/cart_screen.dart';
import 'package:market_mate/dashboard/buyer/screens/home/home_screen.dart';
import 'package:market_mate/dashboard/buyer/screens/orders/orders_screen.dart';
import 'package:market_mate/dashboard/buyer/screens/products/products_screen.dart';
import 'package:market_mate/dashboard/buyer/screens/profile/profile_screen.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../data/cart_provider.dart';

class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _index = 0;

  void _switchToTab(int index) {
    if (mounted) setState(() => _index = index);
  }

  late final List<Widget> _screens = [
    const HomeScreen(),
    const ProductsScreen(),
    CartScreen(onBack: () => _switchToTab(0)),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CartProvider>().loadFromApi();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final cartCount = context.watch<CartProvider>().totalCount;
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBody: true,
      body: HeroMode(
        enabled: false,
        child: IndexedStack(index: _index, children: _screens),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.fromLTRB(
          isTablet ? 40 : 20,
          0,
          isTablet ? 40 : 20,
          padding.bottom + (isTablet ? 16 : 12),
        ),
        child: Container(
          height: isTablet ? 72 : 64,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.white,
            borderRadius: BorderRadius.circular(isTablet ? 28 : 24),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.10),
                      blurRadius: 24,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: Row(
            children: [
              _NavItem(
                assetPath: 'assets/icons/Home.png',
                label: l10n.nav_home,
                index: 0,
                current: _index,
                onTap: () => setState(() => _index = 0),
              ),
              _NavItem(
                assetPath: 'assets/icons/products.png',
                label: l10n.nav_products,
                index: 1,
                current: _index,
                onTap: () => setState(() => _index = 1),
              ),
              _CartNavItem(
                count: cartCount,
                current: _index,
                onTap: () => setState(() => _index = 2),
                label: l10n.nav_cart,
              ),
              _NavItem(
                assetPath: 'assets/icons/orders_icon.svg',
                label: l10n.nav_orders,
                index: 3,
                current: _index,
                onTap: () => setState(() => _index = 3),
                isSvg: true,
              ),
              _NavItem(
                assetPath: 'assets/icons/Profile.png',
                label: l10n.nav_profile,
                index: 4,
                current: _index,
                onTap: () => setState(() => _index = 4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.assetPath,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
    this.isSvg = false,
  });

  final String assetPath;
  final String label;
  final int index;
  final int current;
  final VoidCallback onTap;
  final bool isSvg;

  @override
  Widget build(BuildContext context) {
    final active = index == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final inactiveColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.gray2;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isSvg)
              SvgPicture.asset(
                assetPath,
                width: 24,
                height: 24,
                colorFilter: ColorFilter.mode(
                  active ? AppColors.primary : inactiveColor,
                  BlendMode.srcIn,
                ),
              )
            else
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  active ? AppColors.primary : inactiveColor,
                  BlendMode.srcIn,
                ),
                child: Image.asset(
                  assetPath,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                ),
              ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 12 : 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? AppColors.primary : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartNavItem extends StatelessWidget {
  const _CartNavItem({
    required this.count,
    required this.current,
    required this.onTap,
    required this.label,
  });

  final int count;
  final int current;
  final VoidCallback onTap;
  final String label;

  @override
  Widget build(BuildContext context) {
    final active = current == 2;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final inactiveColor = isDark
        ? AppColors.textSecondaryDark
        : AppColors.gray2;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    active ? AppColors.primary : inactiveColor,
                    BlendMode.srcIn,
                  ),
                  child: Image.asset(
                    'assets/icons/orders.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                  ),
                ),
                if (count > 0)
                  Positioned(
                    top: -5,
                    right: -6,
                    child: Container(
                      width: 15,
                      height: 15,
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 12 : 10,
                fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                color: active ? AppColors.primary : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
