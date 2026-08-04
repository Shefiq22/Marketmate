import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/product_model.dart';

class ProductListTile extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;
  final bool isPending;

  const ProductListTile({
    super.key,
    required this.product,
    required this.onTap,
    this.isPending = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final imgSize = isTablet ? 90.0 : 74.0;

    Widget tile = GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product.imageAsset,
                width: imgSize,
                height: imgSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: imgSize,
                  height: imgSize,
                  color: AppColors.gray1,
                  child: Icon(
                    Icons.image_outlined,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.gray2,
                    size: isTablet ? 36 : 28,
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
                    product.category,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 13 : 11,
                      fontWeight: FontWeight.w400,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.gray2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.name,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 17 : 15,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  RichText(
                    text: TextSpan(
                      text: 'Price: ',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 14 : 13,
                        fontWeight: FontWeight.w400,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      children: [
                        TextSpan(
                          text: product.formattedPrice,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(
              children: [
                GestureDetector(
                  onTap: () {},
                  child: SvgPicture.asset(
                    'assets/icons/more_icon.svg',
                    width: isTablet ? 22 : 18,
                    height: isTablet ? 22 : 18,
                    colorFilter: ColorFilter.mode(
                      isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
                SizedBox(height: isTablet ? 24 : 18),
                if (isPending)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.amber.withAlpha(38),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.product_pending_review,
                      style: TextStyle(
                        fontSize: isTablet ? 11 : 9,
                        fontWeight: FontWeight.w600,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  )
                else
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    size: isTablet ? 22 : 20,
                  ),
              ],
            ),
          ],
        ),
      ),
    );

    if (isPending) {
      tile = Opacity(opacity: 0.6, child: tile);
    }

    return tile;
  }
}
