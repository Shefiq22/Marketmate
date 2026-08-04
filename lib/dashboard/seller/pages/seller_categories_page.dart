import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/dashboard/seller/data/mock_products.dart';
import 'package:market_mate/dashboard/seller/presentation/widgets/category_card.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'seller_product_list_page.dart';

class SellerCategoriesPage extends ConsumerWidget {
  const SellerCategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = isTablet ? size.width * 0.08 : size.width * 0.053;
    final sellerId = ref.watch(currentUserProvider)?.userId ?? '';

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: size.height * 0.008,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: SvgPicture.asset(
                            'assets/icons/back_icon.svg',
                            width: isTablet
                                ? size.width * 0.047
                                : size.width * 0.064,
                            height: isTablet
                                ? size.width * 0.047
                                : size.width * 0.064,
                            colorFilter: ColorFilter.mode(
                              isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * 0.02),
                        Expanded(
                          child: Text(
                            AppLocalizations.of(context)!.seller_products_title,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: isTablet ? 22 : 18,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      size.height * 0.01,
                      hPad,
                      size.height * 0.03,
                    ),
                    child: Text(
                      AppLocalizations.of(context)!.seller_categories_title,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 18 : 16,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.black,
                      ),
                    ),
                  ),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      0,
                      hPad,
                      size.height * 0.06,
                    ),
                    gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: size.height * 0.04,
                          crossAxisSpacing: size.height * 0.04,
                          childAspectRatio: 0.92,
                        ),
                    itemCount: allCategories.length,
                    itemBuilder: (_, i) {
                      final cat = allCategories[i];
                      return CategoryCard(
                        category: cat,
                        onTap: () {
                          debugPrint('[CategoryNavDebug] Selected Category Card: $cat');
                          debugPrint('[CategoryNavDebug] Outgoing Query: /api/v1/products?sellerId=$sellerId&category=${cat.toLowerCase()}');
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => SellerProductListPage(
                                category: cat,
                              ),
                            ),
                          );
                        },
                      );
                    },
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
