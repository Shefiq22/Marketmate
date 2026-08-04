import 'package:flutter/material.dart';
import 'package:market_mate/core/theme/app_colors.dart';

class SettingsTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isDark;
  final VoidCallback? onTap;
  final Widget? trailing;

  const SettingsTile({
    super.key,
    required this.label,
    required this.icon,
    required this.isDark,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isDark ? AppColors.elevatedDark : const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 20, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                ),
              ),
            ),
            trailing ??
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }
}

class SettingsGroup extends StatelessWidget {
  final bool isDark;
  final List<Widget> children;

  const SettingsGroup({super.key, required this.isDark, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(children: children),
    );
  }
}

class SettingsSectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;

  const SettingsSectionHeader({super.key, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
        ),
      ),
    );
  }
}
