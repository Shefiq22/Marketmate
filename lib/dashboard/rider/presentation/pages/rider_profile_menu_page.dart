import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/core/providers/theme_provider.dart';
import 'package:market_mate/features/auth/provider/auth_provider.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import 'package:market_mate/features/auth/presentation/pages/login_page.dart';
import 'package:market_mate/dashboard/rider/providers/rider_dashboard_provider.dart';
import 'rider_wallet_page.dart';
import 'rider_manage_bank_page.dart';
import 'rider_profile_page.dart';
import 'rider_settings_page.dart';
import 'package:market_mate/dashboard/seller/pages/sellers_messages_page.dart';
import 'package:market_mate/dashboard/seller/pages/seller_alert_preferences_page.dart';
import 'package:market_mate/dashboard/seller/pages/seller_help_support_page.dart';
import 'package:market_mate/dashboard/buyer/screens/profile/referral_screen.dart';

class RiderProfileMenuPage extends ConsumerWidget {
  const RiderProfileMenuPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final l10n = AppLocalizations.of(context)!;
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
            child: SingleChildScrollView(
              padding: EdgeInsets.all(size.width * 0.04),
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(size.width * 0.04),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.white,
                      borderRadius: BorderRadius.circular(size.width * 0.043),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: size.width * 0.147,
                          height: size.width * 0.147,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primarySurface,
                            border: Border.all(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              user?.initial ?? 'R',
                              style: TextStyle(
                                fontSize: size.width * 0.047,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * 0.035),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user?.name.isNotEmpty == true
                                    ? user!.name
                                    : 'Rider',
                                style: TextStyle(
                                  fontSize: size.width * 0.043,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: size.height * 0.004),
                              Text(
                                user?.email ?? 'rider@marketmate.app',
                                style: TextStyle(
                                  fontSize: size.width * 0.035,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.gray2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.021),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.white,
                      borderRadius: BorderRadius.circular(size.width * 0.043),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    child: Column(
                      children: [
                        _RMenuTile(
                          iconAsset: 'assets/icons/profile_icon.svg',
                          label: l10n.menu_profile_label,
                          isTablet: isTablet,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RiderProfilePage(),
                            ),
                          ),
                        ),
                        _RMenuTile(
                          iconAsset: 'assets/icons/earnings_icon.svg',
                          label: l10n.menu_wallet_label,
                          isTablet: isTablet,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RiderWalletPage(),
                            ),
                          ),
                        ),
                        _RMenuTile(
                          iconAsset: 'assets/icons/payment_icon.svg',
                          label: l10n.menu_bank_payouts,
                          isTablet: isTablet,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RiderManageBankPage(),
                            ),
                          ),
                        ),
                        _RMenuTile(
                          materialIcon: Icons.card_giftcard_outlined,
                          label: 'Referrals & Wallet',
                          isTablet: isTablet,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ReferralScreen(),
                            ),
                          ),
                        ),
                        _RMenuTile(
                          iconAsset: 'assets/icons/notification_icon.svg',
                          label: l10n.menu_alert_preferences,
                          isTablet: isTablet,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const SellerAlertPreferencesPage(),
                            ),
                          ),
                        ),
                        _RMenuTile(
                          iconAsset: 'assets/icons/messages.svg',
                          label: l10n.menu_messages,
                          isTablet: isTablet,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SellerMessagesPage(),
                            ),
                          ),
                        ),
                        _RMenuTile(
                          iconAsset: 'assets/icons/Question.svg',
                          label: l10n.menu_help_support,
                          isTablet: isTablet,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SellerHelpSupportPage(),
                            ),
                          ),
                        ),
                        _RMenuTile(
                          iconAsset: 'assets/icons/setting.svg',
                          label: l10n.menu_settings_label,
                          isTablet: isTablet,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const RiderSettingsPage(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.021),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.white,
                      borderRadius: BorderRadius.circular(size.width * 0.043),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    child: _RMenuTile(
                      iconAsset: 'assets/icons/sign_out_symbol.svg',
                      label: l10n.menu_sign_out,
                      isTablet: isTablet,
                      iconColor: AppColors.error,
                      textColor: AppColors.error,
                      onTap: () => _showSignOutDialog(context, isTablet, ref),
                    ),
                  ),
                  SizedBox(height: size.height * 0.021),
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardDark : AppColors.white,
                      borderRadius: BorderRadius.circular(size.width * 0.043),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    child: SwitchListTile(
                      secondary: Icon(
                        isDark ? Icons.dark_mode : Icons.light_mode,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                      title: Text(
                        l10n.menu_dark_mode_label,
                        style: TextStyle(
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
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
    );
  }

  void _showSignOutDialog(BuildContext context, bool isTablet, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

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
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.dialog_sign_out_title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 18 : 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
                    foregroundColor: AppColors.textOnPrimary,
                    minimumSize: Size(0, isTablet ? 56 : 50),
                    shape: const StadiumBorder(),
                    elevation: 0,
                  ),
                  child: Text(l10n.dialog_yes),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.read(riderMainTabProvider.notifier).state = 0;
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(
                      color: AppColors.primary,
                      width: 1.5,
                    ),
                    minimumSize: Size(0, isTablet ? 56 : 50),
                    shape: const StadiumBorder(),
                  ),
                  child: Text(l10n.dialog_back_to_home),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RMenuTile extends StatelessWidget {
  final String? iconAsset;
  final IconData? materialIcon;
  final String label;
  final bool isTablet;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const _RMenuTile({
    this.iconAsset,
    this.materialIcon,
    required this.label,
    required this.isTablet,
    required this.onTap,
    this.iconColor,
    this.textColor,
  }) : assert(iconAsset != null || materialIcon != null);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor =
        iconColor ??
        (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);
    final effectiveTextColor =
        textColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.textPrimary);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.022,
        ),
        child: Row(
          children: [
            if (materialIcon != null)
              Icon(
                materialIcon,
                size: isTablet ? 26 : size.width * 0.06,
                color: effectiveIconColor,
              )
            else
              SvgPicture.asset(
                iconAsset!,
                width: isTablet ? 26 : size.width * 0.06,
                height: isTablet ? 26 : size.width * 0.06,
                colorFilter: ColorFilter.mode(
                  effectiveIconColor,
                  BlendMode.srcIn,
                ),
              ),
            SizedBox(width: size.width * 0.04),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: size.width * 0.04,
                  fontWeight: FontWeight.w500,
                  color: effectiveTextColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: effectiveIconColor,
              size: isTablet ? 22 : 20,
            ),
          ],
        ),
      ),
    );
  }
}
