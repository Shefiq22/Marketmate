import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';
import '../data/cart_provider.dart';
import 'package:provider/provider.dart';

// ─────────────── Safe Network Image ───────────────
class AppNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadiusGeometry? borderRadius;
  final Color? fallbackColor;
  final Widget? fallbackIcon;
  final Color? color;
  final BlendMode? colorBlendMode;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.fallbackColor,
    this.fallbackIcon,
    this.color,
    this.colorBlendMode,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) return _fallback(context);

    Widget image = CachedNetworkImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      fit: fit,
      color: color,
      colorBlendMode: colorBlendMode,
      placeholder: (_, __) => _fallback(context),
      errorWidget: (_, __, ___) => _fallback(context),
    );

    if (borderRadius != null) {
      image = ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }

  Widget _fallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: width,
      height: height,
      color:
          fallbackColor ?? (isDark ? AppColors.darkSurface : AppColors.grey100),
      child:
          fallbackIcon ??
          Icon(
            Icons.image_outlined,
            color: isDark ? AppColors.darkTextSecondary : AppColors.grey400,
          ),
    );
  }
}

// ─────────────── Product Card ───────────────
class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  const ProductCard({super.key, required this.product, this.onTap});

  Widget _imageFallback(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      height: 120,
      width: double.infinity,
      color: AppColors.darkSurface,
      child: Center(
        child: Icon(
          Icons.image_outlined,
          color: isDark ? AppColors.darkTextSecondary : AppColors.grey400,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final inCart = cart.isInCart(product.id);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final outOfStock = !product.inStock;

    return GestureDetector(
      onTap: outOfStock ? null : onTap,
      child: Opacity(
        opacity: outOfStock ? 0.5 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkElevated : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: CachedNetworkImage(
                      imageUrl: product.imageUrl,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _imageFallback(context),
                      errorWidget: (_, __, ___) => _imageFallback(context),
                    ),
                  ),
                  if (outOfStock)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          'Out of Stock',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 10,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.grey500,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.text,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₦${product.price.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (outOfStock)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            'Out of Stock',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.error,
                            ),
                          ),
                        ),
                      )
                    else if (inCart)
                      _QtyControls(productId: product.id)
                    else
                      GestureDetector(
                        onTap: () =>
                            context.read<CartProvider>().addItem(product),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Text(
                              'Add to cart',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QtyControls extends StatelessWidget {
  final String productId;
  const _QtyControls({required this.productId});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final qty = cart.quantityOf(productId);
    return Row(
      children: [
        _QtyBtn(icon: Icons.remove, onTap: () => cart.decrement(productId)),
        const SizedBox(width: 8),
        Text(
          '$qty',
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(width: 8),
        _QtyBtn(icon: Icons.add, onTap: () => cart.increment(productId)),
        const Spacer(),
        GestureDetector(
          onTap: () => cart.addItem(
            cart.items.firstWhere((i) => i.product.id == productId).product,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Add to cart',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primary),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 14, color: AppColors.primary),
      ),
    );
  }
}

// ─────────────── Section Header ───────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const SectionHeader({super.key, required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.white : AppColors.text,
          ),
        ),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See All',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
              ),
            ),
          ),
      ],
    );
  }
}

// ─────────────── Price Formatter ───────────────
String formatPrice(double price) {
  final s = price.toStringAsFixed(0);
  final result = s.replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return '₦$result';
}

// ─────────────── Star Row ───────────────
class StarRow extends StatelessWidget {
  final double rating;
  final int? count;
  const StarRow({super.key, required this.rating, this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ...List.generate(5, (i) {
          if (i < rating.floor()) {
            return const Icon(Icons.star, size: 14, color: AppColors.star);
          } else if (i < rating) {
            return const Icon(Icons.star_half, size: 14, color: AppColors.star);
          }
          return const Icon(
            Icons.star_border,
            size: 14,
            color: AppColors.grey300,
          );
        }),
        if (count != null) ...[
          const SizedBox(width: 4),
          Text(
            '($count)',
            style: const TextStyle(fontSize: 12, color: AppColors.grey500),
          ),
        ],
      ],
    );
  }
}

// ─────────────── Custom Back Button AppBar ───────────────
PreferredSizeWidget customAppBar(
  BuildContext context,
  String title, {
  List<Widget>? actions,
  bool showBack = true,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return AppBar(
    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    leading: showBack
        ? GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkCard : AppColors.grey100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: isDark ? AppColors.darkText : AppColors.text,
              ),
            ),
          )
        : null,
    title: Text(
      title,
      style: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkText : AppColors.text,
      ),
    ),
    actions: actions,
  );
}

// ─────────────── Green Button ───────────────
class GreenButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool outlined;
  final bool isLoading;
  const GreenButton({
    super.key,
    required this.label,
    this.onTap,
    this.outlined = false,
    this.isLoading = false,
  });

  bool get _disabled => onTap == null || isLoading;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: _disabled ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: _disabled
              ? (isDark ? AppColors.darkBorder : AppColors.grey300)
              : outlined
                  ? (isDark ? AppColors.darkSurface : AppColors.white)
                  : AppColors.primary,
          borderRadius: BorderRadius.circular(12),
          border: _disabled
              ? null
              : outlined
                  ? Border.all(color: AppColors.primary)
                  : null,
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _disabled
                  ? AppColors.textSecondary
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

// ─────────────── Empty State ───────────────
class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  const EmptyState({
    super.key,
    required this.emoji,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
