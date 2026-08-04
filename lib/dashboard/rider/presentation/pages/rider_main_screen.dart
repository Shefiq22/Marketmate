import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_mate/core/providers/locale_provider.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'rider_home_page.dart';
import 'rider_deliveries_page.dart';
import 'rider_wallet_page.dart';
import 'rider_profile_menu_page.dart';

class RiderMainScreen extends ConsumerStatefulWidget {
  const RiderMainScreen({super.key});

  @override
  ConsumerState<RiderMainScreen> createState() => _RiderMainScreenState();
}

class _RiderMainScreenState extends ConsumerState<RiderMainScreen> {
  int _currentIndex = 0;

  final _screens = const [
    RiderHomePage(),
    RiderDeliveriesPage(),
    RiderWalletPage(),
    RiderProfileMenuPage(),
  ];

  static const _navIcons = [
    'assets/icons/home_icon.svg',
    'assets/icons/riders_icon.svg',
    'assets/icons/payment_icon.svg',
    'assets/icons/profile_icon.svg',
  ];

  @override
  Widget build(BuildContext context) {
    ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context)!;
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final navLabels = [l10n.nav_home, l10n.nav_deliveries, l10n.nav_wallet, l10n.nav_profile];

    return PopScope(
      canPop: _currentIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _currentIndex != 0) {
          setState(() => _currentIndex = 0);
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
        extendBody: true,
        body: HeroMode(
          enabled: false,
          child: IndexedStack(index: _currentIndex, children: _screens),
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
                _RiderNavItem(
                  iconPath: _navIcons[0],
                  label: navLabels[0],
                  index: 0,
                  current: _currentIndex,
                  onTap: () => setState(() => _currentIndex = 0),
                  isTablet: isTablet,
                ),
                _RiderNavItem(
                  iconPath: _navIcons[1],
                  label: navLabels[1],
                  index: 1,
                  current: _currentIndex,
                  onTap: () => setState(() => _currentIndex = 1),
                  isTablet: isTablet,
                ),
                _RiderNavItem(
                  iconPath: _navIcons[2],
                  label: navLabels[2],
                  index: 2,
                  current: _currentIndex,
                  onTap: () => setState(() => _currentIndex = 2),
                  isTablet: isTablet,
                ),
                _RiderNavItem(
                  iconPath: _navIcons[3],
                  label: navLabels[3],
                  index: 3,
                  current: _currentIndex,
                  onTap: () => setState(() => _currentIndex = 3),
                  isTablet: isTablet,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RiderNavItem extends StatelessWidget {
  const _RiderNavItem({
    required this.iconPath,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
    required this.isTablet,
  });

  final String iconPath;
  final String label;
  final int index;
  final int current;
  final VoidCallback onTap;
  final bool isTablet;

  @override
  Widget build(BuildContext context) {
    final selected = index == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            SvgPicture.asset(
              iconPath,
              width: isTablet ? 26 : 22,
              height: isTablet ? 26 : 22,
              colorFilter: ColorFilter.mode(
                selected ? AppColors.primary : inactiveColor,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 12 : 10,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected ? AppColors.primary : inactiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
