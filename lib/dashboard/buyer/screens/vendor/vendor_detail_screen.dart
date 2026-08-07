import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../data/cart_provider.dart';
import '../../repositories/products_repository.dart';
import '../products/product_detail_screen.dart';

class VendorDetailScreen extends ConsumerStatefulWidget {
  final Vendor vendor;
  const VendorDetailScreen({super.key, required this.vendor});

  @override
  ConsumerState<VendorDetailScreen> createState() => _VendorDetailScreenState();
}

class _VendorDetailScreenState extends ConsumerState<VendorDetailScreen> {
  final _scrollCtrl = ScrollController();
  String? _activeCategoryTab;

  @override
  void initState() {
    super.initState();
    final cats = widget.vendor.categories;
    if (cats.isNotEmpty) _activeCategoryTab = cats.first;
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  List<String> get _tabs => widget.vendor.categories;

  List<Product> _productsForCategory(String? category) {
    if (category == null) return [];
    return widget.vendor.products
        .where((p) => p.category.toLowerCase() == category)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vendor;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollCtrl,
        slivers: [
          // ─── Unified Header: Banner + Overlapping Card ──────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 340,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Banner image
                  SizedBox(
                    height: 240,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: v.coverImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppColors.grey100,
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppColors.grey100,
                            child: const Icon(
                              Icons.store_outlined,
                              size: 60,
                              color: AppColors.grey400,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withValues(alpha: 0.5),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Floating back arrow
                  Positioned(
                    top: 40,
                    left: 16,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withValues(alpha: 0.92),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          size: 16,
                        ),
                      ),
                    ),
                  ),

                  // Overlapping vendor card
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 200,
                  child: Container(
                    padding: const EdgeInsets.only(top: 24, left: 18, right: 18, bottom: 18),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(24.0),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title Row: Store Name + Rating
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                v.sellerName,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.onSurface,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.star,
                                    size: 15,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    v.averageRating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Status Row
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: v.isAvailable
                                ? AppColors.primaryBg
                                : AppColors.redBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                v.isAvailable
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                size: 13,
                                color: v.isAvailable
                                    ? AppColors.primary
                                    : AppColors.red,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                v.isAvailable ? 'Open Now' : 'Closed',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: v.isAvailable
                                      ? AppColors.primary
                                      : AppColors.red,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Logistics Row
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.two_wheeler,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '₦1,200 delivery',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.access_time,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '20-30 min',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.receipt_long,
                                size: 16,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withValues(alpha: 0.5),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${v.products.length} items',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          ),

          // ─── In-Store Category Tabs (pinned) ─────────────────
          if (_tabs.length > 1)
            SliverPersistentHeader(
              pinned: true,
              delegate: _CategoryTabDelegate(
                tabs: _tabs,
                activeTab: _activeCategoryTab,
                onTabChanged: (tab) {
                  setState(() => _activeCategoryTab = tab);
                },
              ),
            ),

          if (_tabs.length > 1)
            const SliverToBoxAdapter(child: SizedBox(height: 16)),

          // ─── Product List ───────────────────────────────────
          if (_activeCategoryTab != null)
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final products = _productsForCategory(_activeCategoryTab);
                    if (index >= products.length) return null;
                    return _ProductListItem(product: products[index]);
                  },
                  childCount: _productsForCategory(_activeCategoryTab).length,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─── Sticky Category Tab Delegate ──────────────────────────
class _CategoryTabDelegate extends SliverPersistentHeaderDelegate {
  final List<String> tabs;
  final String? activeTab;
  final ValueChanged<String> onTabChanged;

  _CategoryTabDelegate({
    required this.tabs,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  double get minExtent => 48;
  @override
  double get maxExtent => 48;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            height: 44,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCard : AppColors.grey100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: tabs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 0),
              itemBuilder: (_, i) {
                final tab = tabs[i];
                final isActive = tab == activeTab;
                return GestureDetector(
                  onTap: () => onTabChanged(tab),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive
                          ? AppColors.primary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      tab[0].toUpperCase() + tab.substring(1),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isActive ? FontWeight.w600 : FontWeight.w500,
                        color: isActive
                            ? Colors.white
                            : (isDark
                                ? AppColors.darkText
                                : AppColors.text),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _CategoryTabDelegate old) =>
      activeTab != old.activeTab;
}

// ─── Product List Item ─────────────────────────────────────
class _ProductListItem extends StatelessWidget {
  final Product product;
  const _ProductListItem({required this.product});

  static String _formatPrice(num value) {
    final str = value.toStringAsFixed(0);
    final b = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) b.write(',');
      b.write(str[i]);
    }
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final inCart = cart.isInCart(product.id);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outOfStock = !product.inStock;

    return GestureDetector(
      onTap: outOfStock
          ? null
          : () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      ProductDetailScreen(product: product),
                ),
              ),
      child: ColorFiltered(
        colorFilter: outOfStock
            ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
            : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
        child: Opacity(
          opacity: outOfStock ? 0.55 : 1.0,
          child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: outOfStock
                ? AppColors.error.withValues(alpha: 0.4)
                : isDark
                    ? AppColors.darkBorder
                    : AppColors.border,
          ),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  ImageFiltered(
                    imageFilter: outOfStock
                        ? ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0)
                        : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppColors.grey100,
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.grey100,
                        child: const Icon(
                          Icons.image_outlined,
                          color: AppColors.grey400,
                        ),
                      ),
                    ),
                  ),
                  if (outOfStock)
                    Positioned.fill(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.45),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'SOLD OUT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: outOfStock
                              ? Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.45)
                              : null,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    product.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: outOfStock
                              ? Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color
                                  ?.withValues(alpha: 0.4)
                              : null,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '₦${_formatPrice(product.price)} / ${product.unit ?? 'item'}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: outOfStock
                              ? AppColors.grey500
                              : AppColors.primary,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (outOfStock)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Unavailable',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              )
            else
              _AddToCartButton(product: product, inCart: inCart),
          ],
        ),
      ),
        ),
      ),
    );
  }
}

class _AddToCartButton extends StatelessWidget {
  final Product product;
  final bool inCart;
  const _AddToCartButton({required this.product, required this.inCart});

  Future<void> _addToCart(BuildContext context) async {
    final cart = context.read<CartProvider>();

    // Fetch fresh stock data before adding — prevents adding OOS items
    try {
      final fresh = await ProductsRepository().getById(product.id);
      if (!fresh.inStock) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${fresh.name} is currently out of stock'),
            backgroundColor: const Color(0xFFC62828),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        return;
      }
    } catch (_) {
      // If the fresh check fails, allow the add (fail-open) —
      // the cart validation will catch it later.
    }

    if (!context.mounted) return;
    cart.addItem(product);
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (inCart) {
      return Container(
        decoration: BoxDecoration(
          color: AppColors.primaryBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _RoundBtn(
              icon: Icons.remove,
              onTap: () => cart.decrement(product.id),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${cart.quantityOf(product.id)}',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: AppColors.primary,
                ),
              ),
            ),
            _RoundBtn(
              icon: Icons.add,
              onTap: () => cart.increment(product.id),
            ),
          ],
        ),
      );
    }
    return GestureDetector(
      onTap: () => _addToCart(context),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Icon(
            Icons.add,
            color: Colors.white,
            size: 22,
          ),
        ),
      ),
    );
  }
}

class _RoundBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}
