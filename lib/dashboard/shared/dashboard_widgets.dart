import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import 'dashboard_layout.dart';

/// Profile header card used on seller/rider profile menus.
class DashboardProfileHeader extends StatelessWidget {
  final String initial;
  final String name;
  final String email;
  final Color accentColor;
  final String? badge;

  const DashboardProfileHeader({
    super.key,
    required this.initial,
    required this.name,
    required this.email,
    this.accentColor = AppColors.primary,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(DashboardLayout.cardPadding),
      decoration: DashboardLayout.cardDecoration(context),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primarySurface,
              border: Border.all(color: accentColor, width: 2),
            ),
            child: Center(
              child: Text(
                initial,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: accentColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.2,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  email,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 13,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
                  ),
                ),
              ],
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                badge!,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Menu list tile for seller/rider profile screens.
class DashboardMenuTile extends StatelessWidget {
  final String? iconAsset;
  final IconData? materialIcon;
  final String label;
  final VoidCallback onTap;
  final Color? iconColor;
  final Color? textColor;

  const DashboardMenuTile({
    super.key,
    this.iconAsset,
    this.materialIcon,
    required this.label,
    required this.onTap,
    this.iconColor,
    this.textColor,
  }) : assert(iconAsset != null || materialIcon != null);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor =
        iconColor ?? (isDark ? AppColors.textSecondaryDark : AppColors.textSecondary);
    final effectiveTextColor =
        textColor ?? (isDark ? AppColors.textPrimaryDark : AppColors.black);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: DashboardLayout.cardPadding,
          vertical: 14,
        ),
        child: Row(
          children: [
            if (materialIcon != null)
              Icon(materialIcon, size: 22, color: effectiveIconColor)
            else
              SvgPicture.asset(
                iconAsset!,
                width: 22,
                height: 22,
                colorFilter: ColorFilter.mode(effectiveIconColor, BlendMode.srcIn),
              ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: effectiveTextColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: effectiveIconColor,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

/// Section header with optional trailing action.
class DashboardSectionHeader extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  const DashboardSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
            color: isDark ? AppColors.textPrimaryDark : AppColors.black,
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

/// Primary action button for dashboard screens.
class DashboardPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isLoading;
  final bool outlined;

  const DashboardPrimaryButton({
    super.key,
    required this.label,
    this.onTap,
    this.isLoading = false,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final disabled = onTap == null || isLoading;

    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: disabled
              ? (isDark ? AppColors.borderDark : AppColors.border)
              : outlined
                  ? (isDark ? AppColors.cardDark : AppColors.white)
                  : AppColors.primary,
          borderRadius: BorderRadius.circular(DashboardLayout.cardRadius),
          border: outlined && !disabled
              ? Border.all(color: AppColors.primary, width: 1.5)
              : null,
          boxShadow: disabled || outlined
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                    color: disabled
                        ? AppColors.gray2
                        : outlined
                            ? AppColors.primary
                            : AppColors.white,
                  ),
                ),
        ),
      ),
    );
  }
}
