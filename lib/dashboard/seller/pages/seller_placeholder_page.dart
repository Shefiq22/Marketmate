import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class SellerPlaceholderPage extends StatelessWidget {
  final String title;

  const SellerPlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      body: Center(
        child: Text(
          title,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
