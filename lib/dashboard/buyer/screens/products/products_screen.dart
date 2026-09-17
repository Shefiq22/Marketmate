import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../theme/buyer_layout.dart';
import '../../data/cart_provider.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/products_provider.dart';
import 'product_detail_screen.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});
  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen> {
  String _activeCategory = 'all';
  final bool _showGrid = false;
  final _searchCtrl = TextEditingController();
  String _search = '';

  static const _categoryAssets = <String, String>{
    'all': 'assets/icons/All.png',
    'vegetables': 'assets/icons/vegetable.png',
    'foodstuff': 'assets/icons/Foodstuff.png',
    'fruits': 'assets/icons/fruits.png',
    'meat': 'assets/icons/meat.png',
    'fish': 'assets/icons/fish.png',
  };

  List<Product> get _filtered {
    final products = ref.watch(productsProvider).asData?.value ?? [];
    return products.where((p) {
      final matchSearch =
          p.name.toLowerCase().contains(_search.toLowerCase()) ||
          p.category.toLowerCase().contains(_search.toLowerCase());
      final matchCat =
          _activeCategory == 'all' ||
          p.category.toLowerCase() == _activeCategory;
      return matchSearch && matchCat;
    }).toList();
  }

  List<Map<String, dynamic>> _categories(AppLocalizations l10n) {
    final products = ref.watch(productsProvider).asData?.value ?? [];
    final uniqueCats = products.map((p) => p.category).toSet().toList()..sort();
    return [
      {'id': 'all', 'icon': Icons.all_inclusive_rounded, 'label': l10n.category_all},
      ...uniqueCats.map(
        (cat) => <String, dynamic>{
          'id': cat.toLowerCase(),
          'assetPath': _categoryAssets[cat.toLowerCase()] ?? 'assets/icons/All.png',
          'label': cat,
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    const catIcon = 52.0;
    const hChips = catIcon + 24.0;
    const iconBtn = 44.0;
    const pad = BuyerLayout.screenPadding;
    const gapSm = 8.0;
    const gapMd = 12.0;
    const gapXs = 4.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            color: isDark ? AppColors.darkSurface : AppColors.white,
            child: SafeArea(
              top: true,
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            BuyerLayout.screenPadding,
                            0,
                            BuyerLayout.screenPadding,
                            12,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _searchCtrl,
                                  onChanged: (v) => setState(() => _search = v),
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: 14,
                                    color: isDark
                                        ? AppColors.darkText
                                        : AppColors.black,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: l10n.products_search_hint,
                                    hintStyle: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 14,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.grey500,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search_rounded,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.grey500,
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor: isDark
                                        ? AppColors.darkCard
                                        : AppColors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: BorderSide(
                                        color: isDark
                                            ? AppColors.darkBorder
                                            : AppColors.border,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(100),
                                      borderSide: const BorderSide(
                                        color: AppColors.primary,
                                        width: 1.5,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: gapSm),
                              Container(
                                width: iconBtn,
                                height: iconBtn,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.tune_rounded,
                                  size: 20,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(pad, gapXs, pad, gapSm),
                              child: Text(
                                l10n.products_categories,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: -0.2,
                                  color: isDark ? AppColors.white : AppColors.text,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: hChips,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.fromLTRB(pad, 0, pad, 0),
                                itemCount: _categories(l10n).length,
                                separatorBuilder: (_, __) => const SizedBox(width: gapMd),
                                itemBuilder: (_, i) {
                                  final cat = _categories(l10n)[i];
                                  final isActive = _activeCategory == cat['id'];
                                  return GestureDetector(
                                    onTap: () => setState(
                                      () => _activeCategory = cat['id']!,
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          width: catIcon,
                                          height: catIcon,
                                          decoration: BoxDecoration(
                                            color: isActive
                                                ? AppColors.primary
                                                : (isDark
                                                      ? AppColors.darkCard
                                                      : AppColors.grey100),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: cat['icon'] != null
                                              ? Icon(
                                                  cat['icon'] as IconData,
                                                  size: 24,
                                                  color: isActive
                                                      ? AppColors.white
                                                      : AppColors.primary,
                                                )
                                              : Padding(
                                                  padding: const EdgeInsets.all(10),
                                                  child: Image.asset(
                                                    cat['assetPath'] as String? ?? 'assets/icons/All.png',
                                                    fit: BoxFit.contain,
                                                    color: isActive ? AppColors.white : null,
                                                  ),
                                                ),
                                        ),
                                        const SizedBox(height: gapXs),
                                        Text(
                                          cat['label']!,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: isActive
                                                ? AppColors.primary
                                                : (isDark
                                                      ? AppColors.white
                                                      : AppColors.grey600),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Container(
              color: AppColors.background,
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            BuyerLayout.screenPadding,
                            0,
                            BuyerLayout.screenPadding,
                            8,
                          ),
                          child: SectionHeader(title: l10n.products_browse),
                        ),
                        SizedBox(
                          height: 420,
                          child: _filtered.isEmpty
                              ? EmptyState(
                                  emoji: '📦',
                                  title: l10n.products_no_products,
                                  subtitle: l10n.products_no_products_category,
                                )
                              : _showGrid
                              ? _buildGrid()
                              : _buildList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        BuyerLayout.screenPadding,
        0,
        BuyerLayout.screenPadding,
        BuyerLayout.sectionGap,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: BuyerLayout.itemGap,
        mainAxisSpacing: BuyerLayout.itemGap,
      ),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => ProductCard(
        product: _filtered[i],
        onTap: () => _openDetail(_filtered[i]),
      ),
    );
  }

  Widget _buildList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        BuyerLayout.screenPadding,
        0,
        BuyerLayout.screenPadding,
        BuyerLayout.sectionGap,
      ),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => const SizedBox(height: BuyerLayout.itemGap),
      itemBuilder: (_, i) => _ListProductCard(
        product: _filtered[i],
        onTap: () => _openDetail(_filtered[i]),
      ),
    );
  }

  void _openDetail(Product p) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ProductDetailScreen(product: p)),
    );
  }
}

class _ListProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback onTap;
  const _ListProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const listImg = 88.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final outOfStock = !product.inStock;
    return GestureDetector(
      onTap: outOfStock ? null : onTap,
      child: Opacity(
        opacity: outOfStock ? 0.5 : 1.0,
        child: Container(
        decoration: BuyerLayout.cardDecoration(context),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(BuyerLayout.cardRadius),
              ),
              child: Stack(
                children: [
                  ImageFiltered(
                    imageFilter: outOfStock
                        ? ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5)
                        : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                    child: ColorFiltered(
                      colorFilter: outOfStock
                          ? const ColorFilter.mode(
                              Colors.grey, BlendMode.saturation)
                          : const ColorFilter.mode(
                              Colors.transparent, BlendMode.dst),
                      child: AppNetworkImage(
                        imageUrl: product.imageUrl,
                        width: listImg,
                        height: listImg,
                      ),
                    ),
                  ),
                  if (outOfStock)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withValues(alpha: 0.18),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: BuyerLayout.itemGap),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.grey500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      product.name,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.text,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      formatPrice(product.price),
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    StarRow(rating: product.rating, count: product.reviewCount),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(right: BuyerLayout.itemGap),
                child: product.inStock
                    ? GestureDetector(
                        onTap: () =>
                            context.read<CartProvider>().addItem(product),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.products_add,
                            style: const TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkCard
                              : AppColors.grey200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.products_sold_out_badge,
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.grey500,
                          ),
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
