import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RoleOptionCard extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const RoleOptionCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isTablet = size.shortestSide >= 600;
    final cardHeight = size.height * 0.11;
    final iconSize = isTablet ? 32.0 : 28.0;
    final fontSize = isTablet ? 22.0 : 19.0;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        height: cardHeight,
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 28 : 20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (isDark ? AppColors.borderDark : AppColors.border),
            width: selected ? 2.0 : 1.2,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: iconSize,
              height: iconSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? AppColors.primary : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : (isDark ? AppColors.borderDark : AppColors.border),
                  width: 1.8,
                ),
              ),
              child: selected
                  ? Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: isTablet ? 20 : 18,
                    )
                  : null,
            ),
            SizedBox(width: isTablet ? 20 : 16),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.textPrimaryDark : AppColors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
