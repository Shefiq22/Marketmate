import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthProgressBar extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final String? sectionLabel;
  final VoidCallback? onBack;

  const AuthProgressBar({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.sectionLabel,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: onBack,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: EdgeInsets.only(right: size.width * 0.028),
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: isTablet ? 30 : 26,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                ),
              ),
            ),
            Text(
              '$currentStep of $totalSteps',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 15 : 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.black,
              ),
            ),
            SizedBox(width: size.width * 0.028),
            Expanded(
              child: Row(
                children: List.generate(totalSteps, (i) {
                  final filled = i < currentStep;
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: i < totalSteps - 1 ? size.width * 0.015 : 0,
                      ),
                      height: 4,
                      decoration: BoxDecoration(
                        color: filled ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
        if (sectionLabel != null) ...[
          SizedBox(height: size.height * 0.016),
          Text(
            sectionLabel!,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 13 : 11,
              fontWeight: FontWeight.w600,
              color: AppColors.gray2,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }
}
