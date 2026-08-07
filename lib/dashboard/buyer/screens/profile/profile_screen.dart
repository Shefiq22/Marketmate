import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/features/auth/provider/auth_provider.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import 'package:market_mate/features/auth/presentation/pages/login_page.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/dashboard/seller/pages/sellers_messages_page.dart';
import 'package:market_mate/dashboard/seller/pages/seller_alert_preferences_page.dart';
import 'package:market_mate/dashboard/seller/pages/seller_help_support_page.dart';
import '../../theme/app_theme.dart';
import '../../../../core/providers/theme_provider.dart';
import 'address_book_screen.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});
  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Future<void> _refreshProfile() async {
    final token = ApiClient().accessToken;
    if (token != null) {
      final user = decodeUserFromJwt(token);
      if (user != null) {
        await ref.read(currentUserProvider.notifier).setUser(user);
      }
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.profile_refreshed),
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.watch(currentUserProvider);
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;
    final isDark = ref.watch(isDarkModeProvider);
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              onRefresh: _refreshProfile,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.all(w * 0.04),
                child: Column(
                  children: [
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(w * 0.04),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.white,
                        borderRadius: BorderRadius.circular(w * 0.043),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: w * 0.147,
                            height: w * 0.147,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primaryBg,
                              border: Border.all(
                                color: AppColors.primary,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                user?.initial ?? '?',
                                style: TextStyle(
                                  fontSize: w * 0.047,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: w * 0.035),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  user?.name.isNotEmpty == true
                                      ? user!.name
                                      : '',
                                  style: TextStyle(
                                    fontSize: w * 0.043,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.darkText
                                        : AppColors.text,
                                  ),
                                ),
                                SizedBox(height: h * 0.004),
                                Text(
                                  user?.email ?? '',
                                  style: TextStyle(
                                    fontSize: w * 0.035,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.grey500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: w * 0.027,
                              vertical: h * 0.005,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryBg,
                              borderRadius: BorderRadius.circular(w * 0.053),
                            ),
                            child: Text(
                              user?.role.replaceAll('_', ' ') ?? '',
                              style: TextStyle(
                                fontSize: w * 0.03,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: h * 0.021),

                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.white,
                        borderRadius: BorderRadius.circular(w * 0.043),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          _MenuItem(
                            icon: Image.asset(
                              'assets/icons/Profile.png',
                              width: w * 0.057,
                              height: w * 0.057,
                              fit: BoxFit.contain,
                              color: AppColors.grey600,
                            ),
                            label: l10n.menu_profile_label,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            ),
                          ),
                          _MenuItem(
                            icon: Icon(
                              Icons.location_on_outlined,
                              size: w * 0.057,
                              color: AppColors.grey600,
                            ),
                            label: l10n.menu_address_book,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddressBookScreen(),
                              ),
                            ),
                          ),
                          _MenuItem(
                            icon: SvgPicture.asset(
                              'assets/icons/messages.svg',
                              width: w * 0.057,
                              height: w * 0.057,
                              colorFilter: ColorFilter.mode(
                                AppColors.grey600,
                                BlendMode.srcIn,
                              ),
                            ),
                            label: l10n.menu_messages,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SellerMessagesPage(),
                              ),
                            ),
                          ),
                          _MenuItem(
                            icon: SvgPicture.asset(
                              'assets/icons/notification_icon.svg',
                              width: w * 0.057,
                              height: w * 0.057,
                              colorFilter: ColorFilter.mode(
                                AppColors.grey600,
                                BlendMode.srcIn,
                              ),
                            ),
                            label: l10n.menu_alert_preferences,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    const SellerAlertPreferencesPage(),
                              ),
                            ),
                          ),
                          _MenuItem(
                            icon: SvgPicture.asset(
                              'assets/icons/Question.svg',
                              width: w * 0.057,
                              height: w * 0.057,
                              colorFilter: ColorFilter.mode(
                                AppColors.grey600,
                                BlendMode.srcIn,
                              ),
                            ),
                            label: l10n.menu_help_support,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SellerHelpSupportPage(),
                              ),
                            ),
                          ),
                          _MenuItem(
                            icon: Icon(
                              Icons.settings_outlined,
                              size: w * 0.057,
                              color: AppColors.grey600,
                            ),
                            label: l10n.menu_settings_label,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const SettingsScreen(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: h * 0.021),

                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.white,
                        borderRadius: BorderRadius.circular(w * 0.043),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                      child: _MenuItem(
                        icon: Icon(
                          Icons.logout_rounded,
                          size: w * 0.057,
                          color: AppColors.error,
                        ),
                        label: l10n.menu_sign_out,
                        iconColor: AppColors.error,
                        textColor: AppColors.error,
                        onTap: () => _showSignOutDialog(context, ref, isDark),
                      ),
                    ),
                    SizedBox(height: h * 0.021),
                    Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkCard : AppColors.white,
                        borderRadius: BorderRadius.circular(w * 0.043),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                      child: SwitchListTile(
                        secondary: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          color: isDark ? AppColors.darkText : AppColors.text,
                        ),
                        title: Text(
                          l10n.menu_dark_mode_label,
                          style: TextStyle(
                            color: isDark ? AppColors.darkText : AppColors.text,
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

  void _showSignOutDialog(BuildContext context, WidgetRef ref, bool isDark) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;

    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (_) => Dialog(
        backgroundColor: isDark ? AppColors.darkElevated : AppColors.white,
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
                        color: isDark ? AppColors.darkBorder : AppColors.border,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: isDark ? AppColors.darkText : AppColors.black,
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
                  color: isDark ? AppColors.darkText : AppColors.black,
                ),
              ),
              SizedBox(height: size.height * 0.02),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
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
                    foregroundColor: AppColors.white,
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

class _MenuItem extends StatelessWidget {
  final Widget icon;
  final String label;
  final VoidCallback? onTap;
  final Color? iconColor;
  final Color? textColor;
  const _MenuItem({
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: w * 0.04,
          vertical: w * 0.039,
        ),
        child: Row(
          children: [
            SizedBox(width: w * 0.057, height: w * 0.057, child: icon),
            SizedBox(width: w * 0.035),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: w * 0.04,
                  fontWeight: FontWeight.w500,
                  color:
                      textColor ??
                      (isDark ? AppColors.darkText : AppColors.text),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: w * 0.052,
              color:
                  iconColor ??
                  (isDark ? AppColors.darkTextSecondary : AppColors.grey400),
            ),
          ],
        ),
      ),
    );
  }
}
