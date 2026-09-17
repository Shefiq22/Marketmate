import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/core/providers/theme_provider.dart';
import 'package:market_mate/features/auth/presentation/pages/login_page.dart';
import 'package:market_mate/features/auth/provider/auth_provider.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import 'package:market_mate/dashboard/buyer/theme/buyer_layout.dart';
import 'package:market_mate/dashboard/buyer/theme/app_theme.dart' as buyer;
import 'seller_profile_page.dart';
import 'seller_earnings_page.dart';
import 'seller_help_support_page.dart';
import 'seller_settings_page.dart';
import 'sellers_messages_page.dart';
import 'seller_alert_preferences_page.dart';
import 'package:market_mate/dashboard/buyer/screens/profile/referral_screen.dart';

class SellerProfileMenuPage extends ConsumerWidget {
  const SellerProfileMenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = ref.watch(isDarkModeProvider);
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              onRefresh: () => _refreshProfile(context, ref),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: BuyerLayout.screenInsets(
                  bottom: BuyerLayout.bottomNavClearance,
                ),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(BuyerLayout.cardPadding),
                      decoration: BuyerLayout.cardDecoration(context),
                      child: Row(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: buyer.AppColors.primaryBg,
                              border: Border.all(
                                color: AppColors.sellerAccent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                user?.initial ?? 'S',
                                style: const TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.sellerAccent,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name.isNotEmpty == true
                                      ? user!.name
                                      : 'Seller',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                    color: isDark
                                        ? buyer.AppColors.darkText
                                        : buyer.AppColors.text,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  user?.email ?? 'seller@marketmate.app',
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 13,
                                    color: isDark
                                        ? buyer.AppColors.darkTextSecondary
                                        : buyer.AppColors.grey500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: buyer.AppColors.primaryBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              user?.role.replaceAll('_', ' ') ?? '',
                              style: const TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.sellerAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: BuyerLayout.sectionGap),

                    Container(
                      decoration: BuyerLayout.cardDecoration(context),
                      child: Column(
                        children: [
                          _SMenuTile(
                            iconAsset: 'assets/icons/profile_icon.svg',
                            label:
                                AppLocalizations.of(context)!.menu_profile_label,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SellerProfilePage(),
                              ),
                            ),
                          ),
                          _SMenuTile(
                            iconAsset: 'assets/icons/earnings_icon.svg',
                            label: AppLocalizations.of(context)!.menu_earnings,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SellerEarningsPage(),
                              ),
                            ),
                          ),
                          _SMenuTile(
                            materialIcon: Icons.card_giftcard_outlined,
                            label: 'Referrals & Wallet',
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const ReferralScreen(),
                              ),
                            ),
                          ),
                          _SMenuTile(
                            iconAsset: 'assets/icons/messages.svg',
                            label: AppLocalizations.of(context)!.menu_messages,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SellerMessagesPage(),
                              ),
                            ),
                          ),
                          _SMenuTile(
                            iconAsset: 'assets/icons/notification_icon.svg',
                            label: AppLocalizations.of(
                              context,
                            )!.menu_alert_preferences,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) =>
                                    const SellerAlertPreferencesPage(),
                              ),
                            ),
                          ),
                          _SMenuTile(
                            iconAsset: 'assets/icons/Question.svg',
                            label:
                                AppLocalizations.of(context)!.menu_help_support,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SellerHelpSupportPage(),
                              ),
                            ),
                          ),
                          _SMenuTile(
                            iconAsset: 'assets/icons/setting.svg',
                            label:
                                AppLocalizations.of(context)!.menu_settings_label,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const SellerSettingsPage(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: BuyerLayout.sectionGap),

                    Container(
                      decoration: BuyerLayout.cardDecoration(context),
                      child: _SMenuTile(
                        iconAsset: 'assets/icons/sign_out_symbol.svg',
                        label: AppLocalizations.of(context)!.menu_sign_out,
                        iconColor: buyer.AppColors.error,
                        textColor: buyer.AppColors.error,
                        onTap: () =>
                            _showSignOutDialog(context, isTablet, ref),
                      ),
                    ),
                    const SizedBox(height: BuyerLayout.sectionGap),
                    Container(
                      decoration: BuyerLayout.cardDecoration(context),
                      child: SwitchListTile(
                        secondary: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: isDark
                              ? buyer.AppColors.darkText
                              : buyer.AppColors.text,
                        ),
                        title: Text(
                          AppLocalizations.of(context)!.menu_dark_mode_label,
                          style: TextStyle(
                            color: isDark
                                ? buyer.AppColors.darkText
                                : buyer.AppColors.text,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        value: isDark,
                        onChanged: (_) =>
                            ref.read(themeModeProvider.notifier).toggle(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshProfile(BuildContext context, WidgetRef ref) async {
    final token = ApiClient().accessToken;
    if (token != null) {
      final user = decodeUserFromJwt(token);
      if (user != null) {
        await ref.read(currentUserProvider.notifier).setUser(user);
      }
    }
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.profile_refreshed),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  void _showSignOutDialog(BuildContext context, bool isTablet, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => Dialog(
        backgroundColor: isDark ? AppColors.elevatedDark : AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: EdgeInsets.all(size.height * 0.03),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                AppLocalizations.of(context)!.dialog_sign_out_title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.read(currentUserProvider.notifier).clear();
                    ref.read(authProvider.notifier).logout().then((_) {
                      if (context.mounted) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (_) => const LoginPage(),
                          ),
                          (_) => false,
                        );
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.error,
                    foregroundColor: Colors.white,
                    minimumSize: Size(0, isTablet ? 56 : 50),
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: Text(AppLocalizations.of(context)!.dialog_yes),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    minimumSize: Size(0, isTablet ? 56 : 50),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(AppLocalizations.of(context)!.dialog_back_to_home),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SMenuTile extends StatelessWidget {
  final String? iconAsset;
  final IconData? materialIcon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _SMenuTile({
    this.iconAsset,
    this.materialIcon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
  }) : assert(iconAsset != null || materialIcon != null);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor =
        iconColor ??
        (isDark
            ? buyer.AppColors.darkTextSecondary
            : buyer.AppColors.grey600);
    final effectiveTextColor =
        textColor ?? (isDark ? buyer.AppColors.darkText : buyer.AppColors.text);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: BuyerLayout.cardPadding,
          vertical: 14,
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: materialIcon != null
                  ? Icon(materialIcon, size: 22, color: effectiveIconColor)
                  : SvgPicture.asset(
                      iconAsset!,
                      width: 22,
                      height: 22,
                      colorFilter: ColorFilter.mode(
                        effectiveIconColor,
                        BlendMode.srcIn,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: effectiveTextColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color:
                  iconColor ??
                  (isDark
                      ? buyer.AppColors.darkTextSecondary
                      : buyer.AppColors.grey400),
            ),
          ],
        ),
      ),
    );
  }
}
