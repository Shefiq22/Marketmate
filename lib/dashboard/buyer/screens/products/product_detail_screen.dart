import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../data/cart_provider.dart';
import '../../widgets/common_widgets.dart';
import '../cart/cart_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final cart = context.watch<CartProvider>();
    final inCart = cart.isInCart(p.id);
    final mq = MediaQuery.sizeOf(context);
    final isTablet = mq.shortestSide >= 600;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SizedBox(
            width: isTablet ? 600 : null,
            child: Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(32),
                      ),
                      child: SizedBox(
                        height: isTablet ? 360 : 280,
                        width: double.infinity,
                        child: CachedNetworkImage(
                          imageUrl: p.imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: isDark
                                ? AppColors.darkCard
                                : AppColors.grey100,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: isDark
                                ? AppColors.darkCard
                                : AppColors.grey100,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 12,
                      left: 12,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: EdgeInsets.all(isTablet ? 12 : 8),
                          decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkCard
                        : AppColors.white.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: isTablet ? 20 : 16,
                            color: isDark ? AppColors.darkText : AppColors.text,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                Container(
                  color: isDark ? AppColors.darkSurface : AppColors.white,
                  child: TabBar(
                    controller: _tabCtrl,
                    labelColor: AppColors.primary,
                    unselectedLabelColor: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.grey500,
                    indicatorColor: AppColors.primary,
                    indicatorWeight: 2.5,
                    labelStyle: TextStyle(
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                    ),
                    tabs: const [
                      Tab(text: 'About'),
                      Tab(text: 'Reviews'),
                    ],
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabCtrl,
                    children: [
                      SingleChildScrollView(child: _buildAbout(p, mq, isTablet)),
                      SingleChildScrollView(
                          child: _buildReviews(p, mq, isTablet)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomBar(p, cart, inCart, mq, isTablet),
    );
  }

  Widget _buildAbout(Product p, Size mq, bool isTablet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = mq.width * (isTablet ? 0.08 : 0.04);
    return Padding(
      padding: EdgeInsets.all(hPad),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: mq.width * 0.013,
              vertical: mq.height * 0.004,
            ),
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              p.category,
              style: TextStyle(
                fontSize: isTablet ? 13 : 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(height: mq.height * (isTablet ? 0.018 : 0.012)),
          Text(
            p.name,
            style: TextStyle(
              fontSize: isTablet ? 34 : 28,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.white : AppColors.text,
            ),
          ),
          SizedBox(height: mq.height * (isTablet ? 0.014 : 0.009)),
          Text(
            p.description,
            style: TextStyle(
              fontSize: isTablet ? 16 : 14,
              color: isDark
                  ? AppColors.darkTextSecondary
                  : AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          SizedBox(height: mq.height * (isTablet ? 0.024 : 0.016)),
          Row(
            children: [
              Text(
                'Price: ',
                style: TextStyle(
                  fontSize: isTablet ? 16 : 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
              Text(
                formatPrice(p.price),
                style: TextStyle(
                  fontSize: isTablet ? 26 : 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: mq.height * (isTablet ? 0.035 : 0.025)),
          Row(
            children: [
              Text(
                p.rating.toStringAsFixed(1),
                style: TextStyle(
                  fontSize: isTablet ? 26 : 20,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.darkText : AppColors.text,
                ),
              ),
              SizedBox(width: mq.width * (isTablet ? 0.03 : 0.02)),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  return Icon(
                    i < p.rating.floor()
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: isTablet ? 22 : 18,
                    color: AppColors.star,
                  );
                }),
              ),
              SizedBox(width: mq.width * (isTablet ? 0.02 : 0.015)),
              Text(
                '(${p.reviewCount})',
                style: TextStyle(
                  fontSize: isTablet ? 15 : 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          SizedBox(height: mq.height * (isTablet ? 0.035 : 0.025)),
          Text(
            'Ratings',
            style: TextStyle(
              fontSize: isTablet ? 18 : 16,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.white : AppColors.text,
            ),
          ),
          SizedBox(height: mq.height * (isTablet ? 0.024 : 0.017)),
          _RatingBreakdown(rating: p.rating, mq: mq, isTablet: isTablet),
        ],
      ),
    );
  }

  Widget _buildReviews(Product p, Size mq, bool isTablet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (p.reviews.isEmpty) {
      return EmptyState(
        emoji: '💬',
        title: AppLocalizations.of(context)!.product_no_reviews,
        subtitle: AppLocalizations.of(context)!.product_be_first_review,
      );
    }
    return ListView.separated(
      padding: EdgeInsets.all(mq.height * 0.022),
      itemCount: p.reviews.length,
      separatorBuilder: (_, __) =>
          Divider(color: isDark ? AppColors.darkDivider : AppColors.border),
      itemBuilder: (_, i) {
        final r = p.reviews[i];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: mq.height * 0.011),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      r.userName,
                      style: TextStyle(
                        fontSize: isTablet ? 16 : 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.white : AppColors.text,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    r.date,
                    style: TextStyle(
                      fontSize: isTablet ? 14 : 12,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.grey400,
                    ),
                  ),
                ],
              ),
              SizedBox(height: mq.height * 0.006),
              Text(
                r.comment,
                style: TextStyle(
                  fontSize: isTablet ? 15 : 13,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  height: 1.4,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomBar(
    Product p,
    CartProvider cart,
    bool inCart,
    Size mq,
    bool isTablet,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = mq.width * (isTablet ? 0.08 : 0.04);
    final qty = cart.quantityOf(p.id);
    final totalPrice = p.price * qty;
    final outOfStock = !p.inStock;

    return Container(
      color: isDark ? AppColors.darkSurface : AppColors.white,
      padding: EdgeInsets.fromLTRB(
        hPad,
        mq.height * (isTablet ? 0.02 : 0.014),
        hPad,
        mq.height * (isTablet ? 0.03 : 0.025),
      ),
      child: Opacity(
        opacity: outOfStock ? 0.5 : 1.0,
        child: Row(
          children: [
            Container(
              height: isTablet ? 56 : 48,
              padding: EdgeInsets.symmetric(horizontal: mq.width * 0.025),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.grey100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GestureDetector(
                    onTap: outOfStock ? null : () => cart.decrement(p.id),
                    child: Icon(
                      Icons.remove,
                      size: isTablet ? 22 : 18,
                      color: outOfStock
                          ? AppColors.grey400
                          : AppColors.primary,
                    ),
                  ),
                  SizedBox(width: mq.width * 0.02),
                  Text(
                    '${inCart ? qty : 1}',
                    style: TextStyle(
                      fontSize: isTablet ? 18 : 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkText : AppColors.text,
                    ),
                  ),
                  SizedBox(width: mq.width * 0.02),
                  GestureDetector(
                    onTap: outOfStock ? null : () => cart.increment(p.id),
                    child: Icon(
                      Icons.add,
                      size: isTablet ? 22 : 18,
                      color: outOfStock
                          ? AppColors.grey400
                          : AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: mq.width * (isTablet ? 0.03 : 0.02)),
            Expanded(
              child: GestureDetector(
                onTap: outOfStock
                    ? null
                    : () {
                        if (inCart) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const CartScreen()),
                          );
                        } else {
                          cart.addItem(p);
                        }
                      },
                child: Container(
                  height: isTablet ? 56 : 48,
                  decoration: BoxDecoration(
                    color: outOfStock
                        ? AppColors.grey400
                        : AppColors.primary,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        outOfStock
                            ? 'Out of Stock'
                            : (inCart ? 'Go to Cart' : 'Add to Cart'),
                        style: TextStyle(
                          fontSize: isTablet ? 16 : 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white,
                        ),
                      ),
                      if (!outOfStock) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: mq.width * 0.025,
                          ),
                          child: Container(
                            width: 1,
                            height: isTablet ? 28 : 22,
                            color: AppColors.white.withAlpha(0x4D),
                          ),
                        ),
                        Text(
                          formatPrice(inCart ? totalPrice : p.price),
                          style: TextStyle(
                            fontSize: isTablet ? 16 : 14,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingBreakdown extends StatelessWidget {
  final double rating;
  final Size mq;
  final bool isTablet;
  const _RatingBreakdown({
    required this.rating,
    required this.mq,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bars = [
      {'stars': 3, 'pct': 1.0},
      {'stars': 2, 'pct': 0.0},
      {'stars': 1, 'pct': 0.0},
    ];
    return Column(
      children: bars.map((b) {
        final pct = (b['pct'] as double);
        return Padding(
          padding: EdgeInsets.only(bottom: mq.height * 0.011),
          child: Row(
            children: [
              Row(
                children: List.generate(
                  b['stars'] as int,
                  (_) => Icon(
                    Icons.star,
                    size: isTablet ? 16 : 14,
                    color: AppColors.star,
                  ),
                ),
              ),
              SizedBox(width: mq.width * 0.013),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: pct,
                    backgroundColor:
                        isDark ? AppColors.darkBorder : AppColors.grey200,
                    color: AppColors.star,
                    minHeight: mq.height * (isTablet ? 0.012 : 0.008),
                  ),
                ),
              ),
              SizedBox(width: mq.width * 0.013),
              SizedBox(
                width: mq.width * 0.06,
                child: Text(
                  '${(pct * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: isTablet ? 14 : 12,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
