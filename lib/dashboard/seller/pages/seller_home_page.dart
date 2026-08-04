import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_mate/dashboard/seller/presentation/widgets/earnings_card.dart';
import 'package:market_mate/dashboard/seller/presentation/widgets/empty_state_widget.dart';
import 'package:market_mate/dashboard/seller/presentation/widgets/product_list_tile.dart';
import 'package:market_mate/dashboard/seller/models/product_model.dart';
import 'package:market_mate/dashboard/seller/providers/seller_state_providers.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import 'package:market_mate/core/widgets/sandy_loader.dart';
import '../../../../core/theme/app_colors.dart';
import 'seller_add_product_page.dart';
import 'seller_categories_page.dart';
import 'seller_product_detail_page.dart';
import 'package:market_mate/dashboard/seller/pages/seller_notifications_page.dart';

class SellerHomePage extends ConsumerStatefulWidget {
  const SellerHomePage({super.key});

  @override
  ConsumerState<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends ConsumerState<SellerHomePage> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  bool _isRetrying = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    ref.invalidate(sellerDashboardStatsProvider);
    ref.invalidate(sellerEarningsProvider);
    ref.invalidate(sellerProductsProvider);
    ref.invalidate(bestSellersProvider);
    try {
      await Future.wait([
        ref.read(sellerDashboardStatsProvider.future),
        ref.read(sellerEarningsProvider.future),
        ref.read(sellerProductsProvider.future),
      ]);
    } catch (_) {}
  }

  Future<void> _retry() async {
    setState(() => _isRetrying = true);
    await _refresh();
    if (mounted) setState(() => _isRetrying = false);
  }

  @override
  Widget build(BuildContext context) {
    final dashAsync = ref.watch(sellerDashboardStatsProvider);
    final productsAsync = ref.watch(sellerProductsProvider);
    final bestSellersAsync = ref.watch(bestSellersProvider);

    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = isTablet ? size.width * 0.08 : 20.0;
    final vPad = size.height * 0.018;
    final vGap = isTablet ? size.height * 0.018 : 14.0;
    final hGap = isTablet ? size.width * 0.038 : 16.0;

    debugPrint('[SellerHomeDebug] Building — products: ${productsAsync.runtimeType}, dash: ${dashAsync.runtimeType}, best: ${bestSellersAsync.runtimeType}');

    // ── Error state (if ALL failed) ──
    final allError = productsAsync.hasError && dashAsync.hasError && bestSellersAsync.hasError;
    if (allError && !_isRetrying) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.gray2),
                const SizedBox(height: 12),
                Text(
                  'Failed to load data',
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
      );
    }

    // ── Retrying state — show SandyLoader ──
    if (_isRetrying) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
        body: const SafeArea(child: SandyLoader()),
      );
    }

    // ── Loading skeleton state ──
    final allLoading = dashAsync.isLoading && productsAsync.isLoading && bestSellersAsync.isLoading;
    if (allLoading) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: _buildLoadingSkeleton(size, isDark, hPad),
            ),
          ),
        ),
      );
    }

    // Extract stats — approved count from live product list, orders from dashboard endpoint
    final approvedCount = productsAsync.whenOrNull(
          data: (list) => list.where((p) => p.isApproved).length,
        ) ??
        0;
    final apiOrders = dashAsync.whenOrNull(
          data: (d) => d.pendingOrders,
        ) ??
        0;

    // Filter products by search
    final q = _search.toLowerCase();
    final allProducts = productsAsync.whenOrNull(data: (p) => p) ?? [];
    final pendingProducts = allProducts.where((p) => !p.isApproved).toList();
    final approvedInStock = allProducts.where((p) => p.isApproved && p.inStock).toList();
    final bestList = bestSellersAsync.whenOrNull(data: (b) => b) ?? [];
    final filteredBest = bestList
        .where((b) {
          final name = (b['product'] as Map<String, dynamic>?)?['name'] as String?;
          return name?.toLowerCase().contains(q) ?? false;
        })
        .toList();
    final filteredPending = pendingProducts
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
    final filteredApproved = approvedInStock
        .where((p) => p.name.toLowerCase().contains(q))
        .toList();
    final filteredAll = [...filteredPending, ...filteredApproved];

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(hPad, size.height * 0.016, hPad, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: isTablet ? 52 : 40,
                              height: isTablet ? 52 : 40,
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface,
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Center(
                                child: Text(
                                  ref.watch(currentUserProvider)?.initial ?? 'S',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                    fontSize: isTablet ? 18 : 14,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              AppLocalizations.of(context)!.seller_home_greeting(ref.watch(currentUserProvider)?.firstName ?? 'Seller'),
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet ? 20 : 17,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.textPrimaryDark
                                    : AppColors.black,
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SellerNotificationsPage(),
                            ),
                          ),
                          child: Container(
                            width: isTablet ? 44 : 38,
                            height: isTablet ? 44 : 38,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/icons/notification_icon.svg',
                                width: isTablet ? 22 : 18,
                                height: isTablet ? 22 : 18,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white,
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: vPad),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _search = v),
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: isTablet ? 15 : 14,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.black,
                            ),
                            decoration: InputDecoration(
                              hintText: AppLocalizations.of(context)!.seller_home_search_hint,
                              hintStyle: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet ? 15 : 14,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.gray2,
                              ),
                              prefixIcon: Icon(
                                Icons.search_rounded,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.gray2,
                                size: 20,
                              ),
                              filled: true,
                              fillColor: isDark
                                  ? AppColors.cardDark
                                  : AppColors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(100),
                                borderSide: BorderSide(
                                  color: isDark
                                      ? AppColors.borderDark
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
                        const SizedBox(width: 10),
                        Container(
                          width: isTablet ? 44 : 38,
                          height: isTablet ? 44 : 38,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: SvgPicture.asset(
                              'assets/icons/filter_icon.svg',
                              width: isTablet ? 20 : 17,
                              height: isTablet ? 20 : 17,
                              colorFilter: const ColorFilter.mode(
                                Colors.white,
                                BlendMode.srcIn,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: vPad),
                    const EarningsCard(),
                    SizedBox(height: vPad),
                    _buildStatRow(approvedCount, apiOrders, size, hGap, isTablet),
                    SizedBox(height: vPad + vGap * 0.25),
                    _SectionHeader(
                      title: AppLocalizations.of(context)!.seller_home_best_sellers,
                      onSeeAll: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SellerCategoriesPage(),
                        ),
                      ),
                      isTablet: isTablet,
                    ),
                    const SizedBox(height: 12),
                    filteredBest.isEmpty
                        ? EmptyStateWidget(
                            title: AppLocalizations.of(context)!.seller_home_no_best_sellers,
                            subtitle: AppLocalizations.of(context)!.seller_home_no_best_sellers_desc,
                          )
                        : Column(
                            children: filteredBest
                                .map(
                                  (b) {
                                    final productData = b['product'] as Map<String, dynamic>? ?? {};
                                    final product = ProductModel.fromJson(productData);
                                    return ProductListTile(
                                      product: product,
                                      onTap: () => Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              SellerProductDetailPage(product: product),
                                        ),
                                      ),
                                    );
                                  },
                                )
                                .toList(),
                          ),
                    SizedBox(height: vPad + vGap * 0.25),
                    _SectionHeader(
                      title: AppLocalizations.of(context)!.seller_home_available_products,
                      onSeeAll: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SellerCategoriesPage(),
                        ),
                      ),
                      isTablet: isTablet,
                    ),
                    const SizedBox(height: 12),
                    filteredAll.isEmpty
                        ? EmptyStateWidget(
                            title: allProducts.isEmpty || _search.isNotEmpty
                                ? AppLocalizations.of(context)!.seller_home_no_products
                                : AppLocalizations.of(context)!.seller_home_pending_approval,
                            subtitle: allProducts.isEmpty
                                ? AppLocalizations.of(context)!.seller_home_add_first_product
                                : AppLocalizations.of(context)!.seller_home_pending_approval_desc,
                          )
                        : Column(
                            children: filteredAll
                                .map(
                                  (p) => ProductListTile(
                                    product: p,
                                    isPending: !p.isApproved,
                                    onTap: !p.isApproved
                                        ? () => ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  AppLocalizations.of(context)!.product_pending_review_message,
                                                ),
                                              ),
                                            )
                                        : () => Navigator.of(context).push(
                                              MaterialPageRoute(
                                                builder: (_) =>
                                                    SellerProductDetailPage(product: p),
                                              ),
                                            ),
                                  ),
                                )
                                .toList(),
                          ),
                    SizedBox(height: vPad + vGap),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatRow(
    int approvedCount,
    int apiOrders,
    Size size,
    double hGap,
    bool isTablet,
  ) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: AppLocalizations.of(context)!.seller_home_products_in_stock, value: '$approvedCount', isTablet: isTablet)),
        SizedBox(width: hGap * 0.75),
        Expanded(child: _StatCard(label: AppLocalizations.of(context)!.seller_home_pending_orders, value: '$apiOrders', isTablet: isTablet)),
        SizedBox(width: hGap * 0.75),
        Expanded(child: _AddProductCard(isTablet: isTablet, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SellerAddProductPage())))),
      ],
    );
  }

  Widget _buildLoadingSkeleton(Size size, bool isDark, double hPad) {
    final vPad = size.height * 0.018;
    final baseColor = isDark ? AppColors.cardDark : AppColors.border;

    Widget shimmerBox({required double w, required double h, double radius = 10}) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(hPad, size.height * 0.016, hPad, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row skeleton
          Row(
            children: [
              shimmerBox(w: 40, h: 40, radius: 100),
              const SizedBox(width: 12),
              shimmerBox(w: 160, h: 18),
            ],
          ),
          SizedBox(height: vPad),
          // Search bar skeleton
          shimmerBox(w: double.infinity, h: 46, radius: 100),
          SizedBox(height: vPad),
          // Earnings card skeleton
          shimmerBox(w: double.infinity, h: 100, radius: 14),
          SizedBox(height: vPad),
          // Stat row skeleton
          Row(
            children: [
              Expanded(child: shimmerBox(w: 0, h: 60, radius: 14)),
              const SizedBox(width: 12),
              Expanded(child: shimmerBox(w: 0, h: 60, radius: 14)),
              const SizedBox(width: 12),
              Expanded(child: shimmerBox(w: 0, h: 60, radius: 14)),
            ],
          ),
          SizedBox(height: vPad),
          // Section header skeleton
          shimmerBox(w: 140, h: 18),
          const SizedBox(height: 12),
          // List tile skeletons
          ...List.generate(3, (_) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: shimmerBox(w: double.infinity, h: 72, radius: 14),
          )),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onSeeAll;
  final bool isTablet;

  const _SectionHeader({
    required this.title,
    required this.onSeeAll,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: isTablet ? 20 : 17,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.black,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: Text(
            AppLocalizations.of(context)!.see_all,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 15 : 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final bool isTablet;

  const _StatCard({
    required this.label,
    required this.value,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: EdgeInsets.all(isTablet ? 16 : 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 13 : 11,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 26 : 22,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddProductCard extends StatelessWidget {
  final bool isTablet;
  final VoidCallback onTap;

  const _AddProductCard({required this.isTablet, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isTablet ? 16 : 12),
        decoration: BoxDecoration(
          color: AppColors.secondary,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppLocalizations.of(context)!.seller_home_add_new_product,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 13 : 11,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Icon(Icons.add, color: Colors.white, size: isTablet ? 26 : 20),
          ],
        ),
      ),
    );
  }
}
