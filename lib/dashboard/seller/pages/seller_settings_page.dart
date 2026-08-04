import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/core/widgets/settings_tile.dart';
import 'package:market_mate/core/widgets/language_page.dart';
import 'package:market_mate/core/providers/theme_provider.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'seller_security_page.dart';

class SellerSettingsPage extends ConsumerWidget {
  const SellerSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(isDarkModeProvider);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final hPad = isTablet ? size.width * 0.08 : 20.0;

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.appbar_settings,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SettingsSectionHeader(label: AppLocalizations.of(context)!.section_preferences, isDark: isDark),
              const SizedBox(height: 10),
              SettingsGroup(
                isDark: isDark,
                children: [
                  SettingsTile(
                    label: AppLocalizations.of(context)!.menu_dark_mode,
                    icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    isDark: isDark,
                    trailing: Switch(
                      value: isDark,
                      activeColor: AppColors.primary,
                      onChanged: (_) => ref.read(themeModeProvider.notifier).toggle(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SettingsSectionHeader(label: AppLocalizations.of(context)!.section_general, isDark: isDark),
              const SizedBox(height: 10),
              SettingsGroup(
                isDark: isDark,
                children: [
                  SettingsTile(
                    label: AppLocalizations.of(context)!.menu_security,
                    icon: Icons.lock_outline_rounded,
                    isDark: isDark,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SellerSecurityPage()),
                    ),
                  ),
                  _settingsDivider(isDark),
                  SettingsTile(
                    label: AppLocalizations.of(context)!.menu_language,
                    icon: Icons.language_rounded,
                    isDark: isDark,
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LanguagePage())),
                  ),
                  _settingsDivider(isDark),
                  SettingsTile(
                    label: AppLocalizations.of(context)!.menu_notifications,
                    icon: Icons.notifications_outlined,
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 28),
              SettingsSectionHeader(label: AppLocalizations.of(context)!.section_support, isDark: isDark),
              const SizedBox(height: 10),
              SettingsGroup(
                isDark: isDark,
                children: [
                  SettingsTile(
                    label: AppLocalizations.of(context)!.menu_privacy_policy,
                    icon: Icons.privacy_tip_outlined,
                    isDark: isDark,
                    onTap: () {},
                  ),
                  _settingsDivider(isDark),
                  SettingsTile(
                    label: AppLocalizations.of(context)!.menu_terms_of_service,
                    icon: Icons.article_outlined,
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _settingsDivider(bool isDark) {
  return Divider(
    height: 1,
    indent: 16,
    endIndent: 16,
    color: isDark ? AppColors.dividerDark : AppColors.divider,
  );
}
