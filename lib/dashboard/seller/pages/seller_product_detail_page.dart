import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_mate/dashboard/seller/models/product_model.dart';
import '../../../../core/theme/app_colors.dart';

class SellerProductDetailPage extends StatefulWidget {
  final ProductModel product;

  const SellerProductDetailPage({super.key, required this.product});

  @override
  State<SellerProductDetailPage> createState() =>
      _SellerProductDetailPageState();
}

class _SellerProductDetailPageState extends State<SellerProductDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final hPad = isTablet ? size.width * 0.08 : size.width * 0.053;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final p = widget.product;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: hPad,
                      vertical: size.height * 0.015,
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: SvgPicture.asset(
                            'assets/icons/back_icon.svg',
                            width: isTablet ? 28 : 24,
                            height: isTablet ? 28 : 24,
                            colorFilter: ColorFilter.mode(
                              isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.black,
                              BlendMode.srcIn,
                            ),
                          ),
                        ),
                        SizedBox(width: size.width * 0.021),
                        Text(
                          'Products',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 22 : 18,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    height: isTablet ? 280 : 220,
                    color: isDark ? AppColors.surfaceDark : AppColors.white,
                    padding: EdgeInsets.all(size.width * 0.043),
                    child: Image.network(
                      p.imageAsset,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_outlined,
                        size: 80,
                        color: AppColors.gray2,
                      ),
                    ),
                  ),
                  TabBar(
                    controller: _tabController,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2.5,
                    dividerColor: isDark ? AppColors.dividerDark : AppColors.divider,
                    labelStyle: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w400,
                    ),
                    tabs: const [
                      Tab(text: 'About'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                  SizedBox(
                    height: size.height * 0.6,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _AboutTab(product: p, hPad: hPad, isTablet: isTablet),
                        _ReviewsTab(product: p, hPad: hPad, isTablet: isTablet),
                      ],
                    ),
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

class _AboutTab extends StatelessWidget {
  final ProductModel product;
  final double hPad;
  final bool isTablet;

  const _AboutTab({
    required this.product,
    required this.hPad,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: hPad,
        vertical: size.height * 0.02,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Category: ${product.category}',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 14 : 12,
                  color: isDark
                      ? AppColors.textSecondaryDark
                      : AppColors.textSecondary,
                ),
              ),
              SvgPicture.asset(
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
            ],
          ),
          SizedBox(height: size.height * 0.015),
          Text(
            product.name,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 28 : 22,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : AppColors.black,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: size.height * 0.01),
          Text(
            product.description,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 15 : 13,
              fontWeight: FontWeight.w400,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
              height: 1.6,
            ),
          ),
          SizedBox(height: size.height * 0.0175),
          Text(
            'Price:',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 15 : 13,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: size.height * 0.005),
          Text(
            product.formattedPrice,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.w800,
              color: AppColors.primary,
            ),
          ),
          Divider(height: size.height * 0.04),
          Text(
            'Ratings',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textPrimaryDark : AppColors.black,
            ),
          ),
          SizedBox(height: size.height * 0.02),
          ...product.ratingBreakdown.entries.map((e) {
            return Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.015),
              child: Row(
                children: [
                  Row(
                    children: List.generate(
                      e.key,
                      (_) => Icon(
                        Icons.star,
                        color: AppColors.secondary,
                        size: isTablet ? 18 : 15,
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.027),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: LinearProgressIndicator(
                        value: e.value / 100,
                        backgroundColor: AppColors.gray1,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          e.value > 0 ? AppColors.primary : AppColors.gray1,
                        ),
                        minHeight: isTablet ? 8 : 6,
                      ),
                    ),
                  ),
                  SizedBox(width: size.width * 0.027),
                  Flexible(
                    child: SizedBox(
                      width: size.width * 0.107,
                      child: Text(
                        '${e.value.toInt()}%',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: isTablet ? 14 : 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _ReviewsTab extends StatelessWidget {
  final ProductModel product;
  final double hPad;
  final bool isTablet;

  const _ReviewsTab({
    required this.product,
    required this.hPad,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reviews = product.reviews;

    if (reviews.isEmpty) {
      return Center(
        child: Text(
          'No reviews yet.',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppColors.gray2),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(
        horizontal: hPad,
        vertical: size.height * 0.02,
      ),
      itemCount: reviews.length,
      separatorBuilder: (_, __) => Divider(height: size.height * 0.03),
      itemBuilder: (_, i) {
        final r = reviews[i];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              r.reviewerName,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 17 : 15,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.black,
              ),
            ),
            SizedBox(height: size.height * 0.005),
            Text(
              r.comment,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 14 : 13,
                fontWeight: FontWeight.w400,
                color: isDark
                    ? AppColors.textSecondaryDark
                    : AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            SizedBox(height: size.height * 0.0075),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                r.date,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 13 : 11,
                  color: AppColors.gray2,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
