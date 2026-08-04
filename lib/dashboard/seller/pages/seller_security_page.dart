import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/core/providers/theme_provider.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/dashboard/seller/pages/seller_reset_passowrd_page.dart';

class SellerSecurityPage extends ConsumerStatefulWidget {
  const SellerSecurityPage({super.key});

  @override
  ConsumerState<SellerSecurityPage> createState() => _SellerSecurityPageState();
}

class _SellerSecurityPageState extends ConsumerState<SellerSecurityPage> {
  bool _fingerprint = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = ref.watch(isDarkModeProvider);

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20.0),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          l10n.menu_security,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Divider(
                    height: 1,
                    color: isDark ? AppColors.dividerDark : null,
                  ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const SellerResetPasswordPage(),
                      ),
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n.menu_reset_password,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.black,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? AppColors.dividerDark : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          l10n.menu_fingerprint,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 14,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.black,
                          ),
                        ),
                        Switch(
                          value: _fingerprint,
                          onChanged: (v) => setState(() => _fingerprint = v),
                          activeThumbColor: AppColors.primary,
                          activeTrackColor: isDark
                              ? AppColors.primary.withValues(alpha: 0.4)
                              : null,
                        ),
                      ],
                    ),
                  ),
                  Divider(
                    height: 1,
                    color: isDark ? AppColors.dividerDark : null,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
