import 'package:flutter/material.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/l10n/app_localizations.dart';

class SellerHelpSupportPage extends StatelessWidget {
  const SellerHelpSupportPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final hPad = isTablet ? size.width * 0.08 : 20.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      body: SafeArea(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, size.height * 0.018, hPad, 0),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 28,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.black,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, size.height * 0.02, hPad, 0),
                child: Text(
                  AppLocalizations.of(context)!.menu_help_support,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 26 : 22,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.black,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.018),
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: hPad),
                  child: Column(
                    children: [
                      const Divider(height: 1),
                      _InfoRow(
                        label: AppLocalizations.of(context)!.support_phone,
                        value: '+234 8172606560',
                        isTablet: isTablet,
                      ),
                      const Divider(height: 1),
                      _InfoRow(
                        label: AppLocalizations.of(context)!.support_email,
                        value: 'info@marketmate.app',
                        isTablet: isTablet,
                      ),
                      const Divider(height: 1),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTablet;
  const _InfoRow({
    required this.label,
    required this.value,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: MediaQuery.sizeOf(context).height * 0.0225,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 16 : 14,
                color: isDark ? AppColors.textPrimaryDark : AppColors.black,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 16 : 14,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
