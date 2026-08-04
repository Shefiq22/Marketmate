import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class DocumentPickerSheet extends StatelessWidget {
  final String documentLabel;
  final Future<String?> Function() onCamera;
  final Future<String?> Function() onFilePicker;

  const DocumentPickerSheet({
    super.key,
    required this.documentLabel,
    required this.onCamera,
    required this.onFilePicker,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 8, 24, padding.bottom + 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.borderDark : AppColors.border,
              borderRadius: BorderRadius.circular(100),
            ),
          ),
          Text(
            'Attach $documentLabel',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 20 : 17,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.black,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Choose how you want to attach this document',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 14 : 12,
              fontWeight: FontWeight.w400,
              color: AppColors.gray2,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 28),
          _PickerOption(
            icon: Icons.camera_alt_outlined,
            title: 'Take a photo',
            subtitle: 'Use your camera to snap the document',
            isTablet: isTablet,
            onTap: () async {
              final result = await onCamera();
              if (context.mounted) Navigator.of(context).pop(result);
            },
          ),
          const SizedBox(height: 14),
          _PickerOption(
            icon: Icons.upload_file_outlined,
            title: 'Upload from files',
            subtitle: 'PDF, DOCX, JPG, PNG and more',
            isTablet: isTablet,
            onTap: () async {
              final result = await onFilePicker();
              if (context.mounted) Navigator.of(context).pop(result);
            },
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 15 : 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isTablet;
  final VoidCallback onTap;

  const _PickerOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 22 : 18,
          vertical: isTablet ? 20 : 16,
        ),
        decoration: BoxDecoration(
          color: AppColors.gray1,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border, width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: isTablet ? 52 : 44,
              height: isTablet ? 52 : 44,
              decoration: BoxDecoration(
                color: AppColors.primarySurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: isTablet ? 26 : 22,
              ),
            ),
            SizedBox(width: isTablet ? 18 : 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 13 : 11,
                      fontWeight: FontWeight.w400,
                      color: AppColors.gray2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.gray2,
              size: isTablet ? 22 : 20,
            ),
          ],
        ),
      ),
    );
  }
}
