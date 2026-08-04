import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:market_mate/core/widgets/sandy_loader.dart';
import 'package:market_mate/dashboard/buyer/screens/products/products_screen.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import 'package:market_mate/l10n/app_localizations.dart';

import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../data/cart_provider.dart';
import '../../widgets/common_widgets.dart';
import '../cart/cart_screen.dart';
import '../notifications/notifications_screen.dart';
import '../vendor/vendor_detail_screen.dart';
import '../../providers/products_provider.dart';

const _categoryAssets = <String, String>{
  'all': 'assets/icons/All.png',
  'vegetables': 'assets/icons/vegetable.png',
  'foodstuff': 'assets/icons/Foodstuff.png',
  'fruits': 'assets/icons/fruits.png',
  'meat': 'assets/icons/meat.png',
  'fish': 'assets/icons/fish.png',
};

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _searchCtrl = TextEditingController();
  String _search = '';
  String _activeCategory = 'all';

  late final PageController _carouselCtrl;
  int _carouselPage = 0;
  Timer? _carouselTimer;

  List<Vendor> get _vendors =>
      ref.watch(vendorsProvider);

  List<Vendor> get _featuredVendors => _vendors.take(4).toList();

  List<String> get _categories {
    final cats = _vendors
        .expand((v) => v.categories)
        .toSet()
        .toList();
    cats.sort();
    return ['all', ...cats];
  }

  List<Vendor> get _filteredVendors {
    return _vendors.where((v) {
      if (_activeCategory != 'all' &&
          !v.categories.contains(_activeCategory)) {
        return false;
      }
      if (_search.isNotEmpty &&
          !v.sellerName.toLowerCase().contains(_search.toLowerCase())) {
        return false;
      }
      return true;
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _carouselCtrl = PageController(viewportFraction: 0.88);
    _startAutoPlay();
  }

  void _startAutoPlay() {
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _featuredVendors.isEmpty || !_carouselCtrl.hasClients) return;
      final next = (_carouselPage + 1) % _featuredVendors.length;
      _carouselCtrl.animateToPage(
        next,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _carouselTimer?.cancel();
    _carouselCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final user = ref.watch(currentUserProvider);
    final productsAsync = ref.watch(productsProvider);
    final cardBg = Theme.of(context).cardColor;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          Container(
            color: cardBg,
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
                        _buildHeader(cart, user),
                        _buildSearch(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: _buildBody(productsAsync),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _refresh() async {
    ref.invalidate(productsProvider);
    ref.invalidate(productsByCategoryProvider);
    await Future.delayed(Duration.zero);
    await ref.read(productsProvider.future);
  }

  Widget _buildBody(AsyncValue<List<Product>> async) {
    final l10n = AppLocalizations.of(context)!;
    return async.when(
      loading: () => const SandyLoader(),
      error: (e, _) => RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off_rounded,
                      size: 48,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.home_error_loading,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton.icon(
                      onPressed: _refresh,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: Text(l10n.retry),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      data: (_) => RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildFeaturedCarousel(),
              const SizedBox(height: 8),
              _buildCategories(),
              _buildVendorsSection(),
            ],
          ),
        ),
      ),
    );
  }

  // ─── HEADER ──────────────────────────────────────────────
  Widget _buildHeader(CartProvider cart, UserModel? user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final initial = user?.initial ?? '';
    final displayName = user?.firstName.isNotEmpty == true
        ? user!.firstName
        : (user?.name.isNotEmpty == true
              ? user!.name
              : (user?.email.isNotEmpty == true
                    ? user!.email.split('@').first
                    : 'User'));
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(
                initial,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Row(
              children: [
                Text(
                  AppLocalizations.of(context)!.home_greeting(displayName),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 4),
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/notification_icon.svg',
                  width: 17,
                  height: 17,
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            ),
            child: Stack(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Image.asset(
                      'assets/icons/orders.png',
                      color: AppColors.white,
                    ),
                  ),
                ),
                if (cart.totalCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${cart.totalCount}',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
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
    );
  }

  // ─── SEARCH ──────────────────────────────────────────────
  Widget _buildSearch() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      color: Theme.of(context).cardColor,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              onChanged: (v) => setState(() => _search = v),
              style: TextStyle(
                fontSize: 14,
                color: isDark
                    ? Theme.of(context).colorScheme.onSurface
                    : AppColors.black,
              ),
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.home_search_hint,
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
                      : AppColors.grey500,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: isDark
                      ? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5)
                      : AppColors.grey500,
                  size: 20,
                ),
                filled: true,
                fillColor: isDark
                    ? Theme.of(context).cardColor
                    : AppColors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(100),
                  borderSide: BorderSide(
                    color: isDark
                        ? Theme.of(context).dividerColor
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
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.tune_rounded,
              size: 20,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }

  // ─── FEATURED VENDOR CAROUSEL ────────────────────────────
  Widget _buildFeaturedCarousel() {
    final items = _featuredVendors;
    if (items.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SectionHeader(
            title: AppLocalizations.of(context)!.home_featured_stores,
            onSeeAll: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductsScreen()),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: PageView.builder(
            controller: _carouselCtrl,
            itemCount: items.length,
            onPageChanged: (i) => setState(() => _carouselPage = i),
            itemBuilder: (_, i) => _buildCarouselSlide(items[i]),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(items.length, (i) {
            final active = i == _carouselPage;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.grey400,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildCarouselSlide(Vendor vendor) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VendorDetailScreen(vendor: vendor),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              fit: StackFit.expand,
              children: [
                CachedNetworkImage(
                  imageUrl: vendor.coverImageUrl,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    color: AppColors.grey100,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.grey100,
                    child: const Icon(
                      Icons.store_outlined,
                      color: AppColors.grey400,
                      size: 40,
                    ),
                  ),
                ),
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerRight,
                      end: Alignment.centerLeft,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: 0.60),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      vendor.isAvailable ? AppLocalizations.of(context)!.home_open_now : AppLocalizations.of(context)!.home_closed,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.white,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 16,
                  bottom: 16,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vendor.sellerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 14,
                            color: AppColors.star,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vendor.averageRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Icon(
                            Icons.delivery_dining_outlined,
                            size: 14,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vendor.deliveryFee ?? AppLocalizations.of(context)!.home_free,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── CATEGORIES ──────────────────────────────────────────
  Widget _buildCategories() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final categoryLabels = <String, String>{
      'all': l10n.category_all,
      'vegetables': l10n.category_vegetables,
      'foodstuff': l10n.category_foodstuff,
      'fruits': l10n.category_fruits,
      'meat': l10n.category_meat,
      'fish': l10n.category_fish,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SectionHeader(
            title: l10n.home_categories,
            onSeeAll: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductsScreen()),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 84,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) {
              final id = _categories[i];
              final label = categoryLabels[id] ?? id;
              final isActive = _activeCategory == id;
              final assetPath = _categoryAssets[id] ?? 'assets/icons/All.png';

              return GestureDetector(
                onTap: () => setState(() => _activeCategory = id),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : (isDark ? AppColors.darkCard : AppColors.white),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isActive
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkBorder
                                    : AppColors.border),
                        ),
                      ),
                      padding: const EdgeInsets.all(10),
                      child: id == 'all'
                          ? Icon(
                              Icons.all_inclusive_rounded,
                              size: 28,
                              color: isActive ? AppColors.white : AppColors.primary,
                            )
                          : Image.asset(
                              assetPath,
                              fit: BoxFit.contain,
                              color: isActive ? AppColors.white : null,
                            ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? AppColors.primary
                            : (isDark ? AppColors.white : AppColors.grey600),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── AVAILABLE SELLERS ───────────────────────────────────
  Widget _buildVendorsSection() {
    final vendors = _filteredVendors;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.home_available_sellers,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              height: 1.0,
              color: isDark ? AppColors.white : AppColors.text,
            ),
          ),
          if (vendors.isEmpty)
            EmptyState(
              emoji: '🔍',
              title: AppLocalizations.of(context)!.home_no_sellers_found,
              subtitle: AppLocalizations.of(context)!.home_search_empty_hint,
            )
          else
            Transform.translate(
              offset: const Offset(0, -8),
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: vendors.length,
                itemBuilder: (_, i) => _buildVendorCard(vendors[i]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(Vendor vendor) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VendorDetailScreen(vendor: vendor),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 21 / 9,
              child: CachedNetworkImage(
                imageUrl: vendor.coverImageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                placeholder: (_, __) => Container(
                  color: AppColors.grey100,
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.grey100,
                  child: const Icon(
                    Icons.store_outlined,
                    color: AppColors.grey400,
                    size: 36,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.sellerName,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.motorcycle_outlined,
                              size: 14,
                              color: isDark ? AppColors.darkTextTertiary : AppColors.grey500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              vendor.deliveryFee ?? AppLocalizations.of(context)!.home_free_delivery,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkText.withValues(alpha: 0.75) : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '•',
                              style: TextStyle(
                                color: isDark ? AppColors.darkText.withValues(alpha: 0.4) : AppColors.grey400,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '20-30 min',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkText.withValues(alpha: 0.75) : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
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
                          size: 13,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          vendor.averageRating.toStringAsFixed(1),
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
