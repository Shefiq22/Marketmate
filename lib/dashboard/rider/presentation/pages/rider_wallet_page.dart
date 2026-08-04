import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/dashboard/rider/providers/rider_dashboard_provider.dart';
import 'rider_manage_bank_page.dart';
import 'rider_withdraw_page.dart';

class RiderWalletPage extends ConsumerWidget {
  const RiderWalletPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final hPad = isTablet ? size.width * 0.08 : size.width * 0.05;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    final accounts = ref.watch(bankAccountsProvider);
    final defaultIdx = ref.watch(defaultBankIndexProvider);
    final defaultAccount = accounts.isNotEmpty ? accounts[defaultIdx] : null;

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                hPad,
                size.height * 0.018,
                hPad,
                padding.bottom + size.height * 0.12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: size.height * 0.013,
                    ),
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Icon(
                        Icons.chevron_left_rounded,
                        size: 28,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                  Text(
                    l10n.wallet_title,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet
                          ? size.height * 0.038
                          : size.height * 0.032,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: size.height * 0.008),
                  RichText(
                    text: TextSpan(
                      text: l10n.wallet_earned_prefix,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet
                            ? size.height * 0.021
                            : size.height * 0.019,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: '₦45,000',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        TextSpan(
                          text: l10n.wallet_earned_suffix,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.032),

                  if (defaultAccount != null) ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                defaultAccount['name'] ?? '',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: isTablet
                                      ? size.height * 0.026
                                      : size.height * 0.023,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: size.height * 0.003),
                              Row(
                                children: [
                                  Text(
                                    defaultAccount['bank'] ?? '',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: isTablet
                                          ? size.height * 0.021
                                          : size.height * 0.018,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              l10n.wallet_set_default,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet
                                    ? size.height * 0.021
                                    : size.height * 0.018,
                                color: AppColors.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: size.width * 0.01),
                            Container(
                              width: isTablet
                                  ? size.width * 0.06
                                  : size.width * 0.055,
                              height: isTablet
                                  ? size.width * 0.06
                                  : size.width * 0.055,
                              decoration: BoxDecoration(
                                border: Border.all(color: AppColors.secondary),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: size.height * 0.022),
                  ],

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(
                      isTablet ? size.height * 0.030 : size.height * 0.023,
                    ),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.border,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Text(
                                    l10n.rider_total_earnings,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: isTablet
                                          ? size.height * 0.021
                                          : size.height * 0.019,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.01),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.textSecondary,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    l10n.wallet_history,
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: isTablet
                                          ? size.height * 0.019
                                          : size.height * 0.017,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const Icon(
                                    Icons.chevron_right_rounded,
                                    color: AppColors.primary,
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.024),
                        Text(
                          '₦45,000',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet
                                ? size.height * 0.052
                                : size.height * 0.045,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: size.height * 0.006),
                        Text(
                          l10n.wallet_breakdown('20', '₦223,500.05'),
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet
                                ? size.height * 0.019
                                : size.height * 0.017,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: size.height * 0.032),

                  Text(
                    l10n.wallet_actions,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet
                          ? size.height * 0.026
                          : size.height * 0.023,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: size.height * 0.016),

                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RiderManageBankPage(),
                      ),
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.018,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: isTablet
                                ? size.width * 0.065
                                : size.width * 0.06,
                            height: isTablet
                                ? size.width * 0.065
                                : size.width * 0.06,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.textSecondaryDark.withValues(
                                      alpha: 0.15,
                                    )
                                  : AppColors.border.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add_rounded,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              size: 22,
                            ),
                          ),
                          SizedBox(width: size.width * 0.035),
                          Expanded(
                            child: Text(
                              l10n.wallet_manage_bank,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet
                                    ? size.height * 0.022
                                    : size.height * 0.020,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
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
                  SizedBox(height: size.height * 0.012),

                  GestureDetector(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const RiderWithdrawPage(),
                      ),
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        horizontal: size.width * 0.04,
                        vertical: size.height * 0.018,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: isTablet
                                ? size.width * 0.065
                                : size.width * 0.06,
                            height: isTablet
                                ? size.width * 0.065
                                : size.width * 0.06,
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.textSecondaryDark.withValues(
                                      alpha: 0.15,
                                    )
                                  : AppColors.border.withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.remove_circle_outline_rounded,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              size: 22,
                            ),
                          ),
                          SizedBox(width: size.width * 0.035),
                          Expanded(
                            child: Text(
                              l10n.wallet_withdraw,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet
                                    ? size.height * 0.022
                                    : size.height * 0.020,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.textPrimary,
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
