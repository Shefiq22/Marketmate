import 'package:flutter/material.dart';
import 'package:market_mate/core/theme/app_colors.dart';

class SellerAlertPreferencesPage extends StatefulWidget {
  const SellerAlertPreferencesPage({super.key});

  @override
  State<SellerAlertPreferencesPage> createState() =>
      _SellerAlertPreferencesPageState();
}

class _SellerAlertPreferencesPageState
    extends State<SellerAlertPreferencesPage> {
  bool _newsletters = false;
  bool _orderUpdates = true;
  bool _promotions = false;
  bool _newMessages = true;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final hPad = isTablet ? size.width * 0.08 : 20.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = [
      ('Newsletters', _newsletters, (v) => setState(() => _newsletters = v)),
      (
        'Order updates',
        _orderUpdates,
        (v) => setState(() => _orderUpdates = v),
      ),
      ('Promotions', _promotions, (v) => setState(() => _promotions = v)),
      ('New messages', _newMessages, (v) => setState(() => _newMessages = v)),
    ];

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 28,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 16),
              child: Text(
                'Alert Preference',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 26 : 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                ),
              ),
            ),
            ...items.map(
              (item) => Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          item.$1,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 16 : 14,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.black,
                          ),
                        ),
                        Switch(
                          value: item.$2,
                          onChanged: item.$3,
                          activeThumbColor: AppColors.primary,
                        ),
                      ],
                    ),
                    const Divider(height: 1),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
