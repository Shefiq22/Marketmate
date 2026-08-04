import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/dashboard/seller/presentation/widgets/empty_state_widget.dart';
import 'package:market_mate/dashboard/seller/presentation/widgets/product_list_tile.dart';
import 'package:market_mate/dashboard/seller/providers/seller_state_providers.dart';
import 'package:market_mate/core/widgets/sandy_loader.dart';
import '../../../../core/theme/app_colors.dart';
import 'seller_product_detail_page.dart';
import 'seller_add_product_page.dart';

class SellerProductListPage extends ConsumerStatefulWidget {
  final String category;

  const SellerProductListPage({super.key, required this.category});

  @override
  ConsumerState<SellerProductListPage> createState() => _SellerProductListPageState();
}

class _SellerProductListPageState extends ConsumerState<SellerProductListPage> {
  bool _isRetrying = false;

  @override
  void initState() {
    super.initState();
    debugPrint('[SellerProductListDebug] Opening category: ${widget.category}');
  }

  Future<void> _refresh() async {
    debugPrint('[SellerProductListDebug] Pull-to-refresh triggered for: ${widget.category}');
    ref.invalidate(sellerProductsByCategoryProvider(widget.category));
    try {
      await ref.read(sellerProductsByCategoryProvider(widget.category).future);
    } catch (_) {}
  }

  Future<void> _retry() async {
    setState(() => _isRetrying = true);
    await _refresh();
    if (mounted) setState(() => _isRetrying = false);
  }

  @override
  Widget build(BuildContext context) {
    final inStockAsync = ref.watch(inStockProductsByCategoryProvider(widget.category));
    final outOfStockAsync = ref.watch(outOfStockProductsByCategoryProvider(widget.category));
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = isTablet ? size.width * 0.08 : 20.0;

    final inStock = inStockAsync.whenOrNull(data: (p) => p) ?? [];
    final outOfStock = outOfStockAsync.whenOrNull(data: (p) => p) ?? [];

    debugPrint('[SellerProductListDebug] Category: ${widget.category}, inStock: ${inStock.length}, outOfStock: ${outOfStock.length}');

    // ── Combined error state ──
    if (inStockAsync.hasError && outOfStockAsync.hasError && !_isRetrying) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldLight,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, size, isDark, hPad, isTablet),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.gray2),
                      const SizedBox(height: 12),
                      Text(
                        'Failed to load products',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Check your connection and try again.',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _retry,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ── Retrying state — show SandyLoader ──
    if (_isRetrying) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldLight,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, size, isDark, hPad, isTablet),
              const Expanded(child: SandyLoader()),
            ],
          ),
        ),
      );
    }

    // ── Loading state ──
    if (inStockAsync.isLoading && outOfStockAsync.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.scaffoldLight,
        body: SafeArea(
          child: Column(
            children: [
              _buildAppBar(context, size, isDark, hPad, isTablet),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Loading ${widget.category} products...',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          children: [
            _buildAppBar(context, size, isDark, hPad, isTablet),
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: TabBar(
                          isScrollable: true,
                          tabAlignment: TabAlignment.start,
                          dividerColor: Colors.transparent,
                          indicatorColor: Colors.transparent,
                          labelPadding: EdgeInsets.only(
                            right: size.width * 0.03,
                          ),
                          tabs: [
                            _StockTab(
                              label: AppLocalizations.of(context)!.seller_product_list_available,
                              count: inStock.length,
                            ),
                            _StockTab(
                              label: AppLocalizations.of(context)!.seller_product_list_out_of_stock,
                              count: outOfStock.length,
                              isActive: false,
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.01),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _refresh,
                        child: TabBarView(
                          children: [
                            _ProductListView(
                              products: inStock,
                              hPad: hPad,
                              emptyTitle: AppLocalizations.of(context)!.seller_product_list_no_available,
                              emptySubtitle: AppLocalizations.of(context)!.seller_product_list_no_available_desc,
                              category: widget.category,
                            ),
                            _ProductListView(
                              products: outOfStock,
                              hPad: hPad,
                              emptyTitle: AppLocalizations.of(context)!.seller_product_list_no_out_of_stock,
                              emptySubtitle: AppLocalizations.of(context)!.seller_product_list_all_in_stock,
                              category: widget.category,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, Size size, bool isDark, double hPad, bool isTablet) {
    return Padding(
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
          SizedBox(width: size.width * 0.02),
          Expanded(
            child: Text(
              widget.category,
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
    );
  }
}

class _StockTab extends StatelessWidget {
  final String label;
  final int count;
  final bool isActive;

  const _StockTab({
    required this.label,
    required this.count,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;

    return Tab(
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isTablet ? 18 : 14,
          vertical: isTablet ? 10 : 8,
        ),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primarySurface : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: 1.5,
          ),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: isTablet ? 14 : 13,
            fontWeight: FontWeight.w600,
            color: isActive ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _ProductListView extends ConsumerWidget {
  final List products;
  final double hPad;
  final String emptyTitle;
  final String emptySubtitle;
  final String category;

  const _ProductListView({
    required this.products,
    required this.hPad,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.category,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final size = MediaQuery.sizeOf(context);

    if (products.isEmpty) {
      return Center(
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              EmptyStateWidget(title: emptyTitle, subtitle: emptySubtitle),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const SellerAddProductPage(),
                  ),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Add your first product',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(
        horizontal: hPad,
        vertical: size.height * 0.01,
      ),
      itemCount: products.length,
      itemBuilder: (_, i) => ProductListTile(
        product: products[i],
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => SellerProductDetailPage(product: products[i]),
          ),
        ),
      ),
    );
  }
}
