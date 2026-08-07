import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
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
    final mq = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final s16 = mq.width * 0.04;
    final s12 = mq.width * 0.03;
    final s10 = mq.width * 0.025;
    final h4 = mq.height * 0.005;
    final h8 = mq.height * 0.01;
    final h12 = mq.height * 0.015;
    final catIcon = mq.width * 0.14;
    final hChips = catIcon + 24.0;
    final iconBtn = mq.width * 0.115;

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
                          padding: EdgeInsets.fromLTRB(s16, 0, s16, h12),
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
                              SizedBox(width: s10),
                              Container(
                                width: iconBtn,
                                height: iconBtn,
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBg,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.tune_rounded,
                                  size: mq.width * 0.05,
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
                              padding: EdgeInsets.fromLTRB(s16, h4, s16, h8),
                              child:                               Text(
                                l10n.products_categories,
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? AppColors.white : AppColors.text,
                                ),
                              ),
                            ),
                            SizedBox(
                                height: hChips,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.fromLTRB(s16, 0, s16, 0),
                                itemCount: _categories(l10n).length,
                                separatorBuilder: (_, __) => SizedBox(width: s12),
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
                                                  size: mq.width * 0.06,
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
                                        SizedBox(height: h4),
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
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          child: SectionHeader(title: l10n.products_browse),
                        ),
                        SizedBox(
                          height: mq.height * 0.55,
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
    final mq = MediaQuery.sizeOf(context);
    final s16 = mq.width * 0.04;
    final s12 = mq.width * 0.03;
    final h12 = mq.height * 0.015;
    final h24 = mq.height * 0.03;
    return GridView.builder(
      padding: EdgeInsets.fromLTRB(s16, 0, s16, h24),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: s12,
        mainAxisSpacing: h12,
      ),
      itemCount: _filtered.length,
      itemBuilder: (_, i) => ProductCard(
        product: _filtered[i],
        onTap: () => _openDetail(_filtered[i]),
      ),
    );
  }

  Widget _buildList() {
    final mq = MediaQuery.sizeOf(context);
    final s16 = mq.width * 0.04;
    final h12 = mq.height * 0.015;
    final h24 = mq.height * 0.03;
    return ListView.separated(
      padding: EdgeInsets.fromLTRB(s16, 0, s16, h24),
      itemCount: _filtered.length,
      separatorBuilder: (_, __) => SizedBox(height: h12),
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
    final mq = MediaQuery.sizeOf(context);
    final s12 = mq.width * 0.03;
    final s4 = mq.width * 0.01;
    final s14 = mq.width * 0.035;
    final s10 = mq.width * 0.025;
    final h4 = mq.height * 0.005;
    final h8 = mq.height * 0.01;
    final h12 = mq.height * 0.015;
    final listImg = mq.width * 0.25;

    final isDark = Theme.of(context).brightness == Brightness.dark;
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
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
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
            SizedBox(width: s12),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: h12, horizontal: s4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.category,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.grey500,
                      ),
                    ),
                    SizedBox(height: h4),
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkText : AppColors.text,
                      ),
                    ),
                    SizedBox(height: h8),
                    Text(
                      formatPrice(product.price),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: h4),
                    StarRow(rating: product.rating, count: product.reviewCount),
                  ],
                ),
              ),
            ),
            Flexible(
              child: Padding(
                padding: EdgeInsets.only(right: s12),
                child: product.inStock
                    ? GestureDetector(
                        onTap: () =>
                            context.read<CartProvider>().addItem(product),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: s14,
                            vertical: h8,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            AppLocalizations.of(context)!.products_add,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: s10,
                          vertical: h8,
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
