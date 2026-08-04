import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/dashboard/seller/data/mock_products.dart';
import 'package:market_mate/dashboard/seller/presentation/widgets/multi_image_picker.dart';
import 'package:market_mate/dashboard/seller/providers/product_image_notifier.dart';
import 'package:market_mate/dashboard/seller/providers/seller_state_providers.dart';
import 'package:market_mate/dashboard/seller/repositories/seller_products_repository.dart';
import 'package:market_mate/features/chat/providers/cloudinary_providers.dart';

class SellerAddProductPage extends ConsumerStatefulWidget {
  const SellerAddProductPage({super.key});

  @override
  ConsumerState<SellerAddProductPage> createState() => _SellerAddProductPageState();
}

class _SellerAddProductPageState extends ConsumerState<SellerAddProductPage> {
  String? _selectedCategory;
  bool _isUploading = false;
  bool _showCategoryList = false;
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _estimatedWeightController = TextEditingController();
  String _deliveryClass = 'standard';

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _estimatedWeightController.dispose();
    super.dispose();
  }

  Future<void> _submitProduct() async {
    final images = ref.read(productImagesProvider);
    if (_selectedCategory == null || images.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(AppLocalizations.of(context)!.snackbar_select_category_image)),
      );
      return;
    }
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();
    if (name.isEmpty || priceText.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.snackbar_enter_name_price)),
      );
      return;
    }

    setState(() => _isUploading = true);

    final notifier = ref.read(productImagesProvider.notifier);
    final service = ref.read(cloudinaryUploadServiceProvider);
    int failedCount = 0;

    for (int i = 0; i < images.length; i++) {
      final slot = images[i];
      if (slot.status == ImageSlotStatus.done) continue;

      notifier.markUploading(i);
      setState(() {});

      debugPrint('[SellerAddProduct] Uploading image $i — path: ${slot.file.path}, size: ${slot.file.lengthSync()}');
      try {
        final url = await service.uploadImage(slot.file, folder: 'products');
        debugPrint('[SellerAddProduct] Image $i uploaded — url: $url');
        notifier.markDone(i, url);
      } catch (e) {
        debugPrint('[SellerAddProduct] Image $i FAILED — $e');
        notifier.markFailed(i, e.toString());
        failedCount++;
      }
    }

    if (failedCount > 0) {
      if (mounted) {
        final errors = images
            .where((s) => s.status == ImageSlotStatus.failed)
            .map((s) => s.error)
            .where((e) => e != null)
            .join('; ');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '$failedCount image(s) failed. ${images.length - failedCount} uploaded.'),
          ),
        );
        debugPrint('[SellerAddProduct] Upload failures: $errors');
        setState(() => _isUploading = false);
      }
      return;
    }

    final imageUrls = notifier.uploadedUrls;
    final priceInKobo = (double.tryParse(priceText) ?? 0) * 100;
    final categoryLower = _selectedCategory!.toLowerCase();
    final estimatedWeightKg =
        double.tryParse(_estimatedWeightController.text.trim()) ?? 0.0;
    final deliveryClass = _deliveryClass;
    debugPrint('--- Product payload ---');
    debugPrint('name: $name');
    debugPrint('description: ${_descController.text.trim()}');
    debugPrint('price (kobo): ${priceInKobo.round()}');
    debugPrint('category: $categoryLower');
    debugPrint('estimatedWeightKg: $estimatedWeightKg');
    debugPrint('deliveryClass: $deliveryClass');
    debugPrint('stock: 10');
    debugPrint('isPerishable: false');
    debugPrint('images: $imageUrls');
    debugPrint('------------------------');
    try {
      final repo = SellerProductsRepository();
      await repo.createProduct({
        'name_en': name,
        'name': name,
        'description_en': _descController.text.trim(),
        'description': _descController.text.trim(),
        'price': priceInKobo.round(),
        'category': categoryLower,
        'estimatedWeightKg': estimatedWeightKg,
        'deliveryClass': deliveryClass,
        'stock': 10,
        'isPerishable': false,
        'images': imageUrls,
      });
      if (mounted) {
        notifier.clear();
        ref.invalidate(sellerProductsProvider);
        ref.invalidate(sellerProductsByCategoryProvider(categoryLower));
        ref.invalidate(sellerDashboardStatsProvider);
        debugPrint('[SellerAddProduct] Product created — invalidated providers for category: $categoryLower');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.snackbar_product_added)),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      debugPrint('[SellerAddProduct] createProduct FAILED — $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.seller_add_product_failed(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = isTablet ? size.width * 0.08 : 20.0;
    final vPadExtra = isTablet ? size.height * 0.02 : 12.0;
    final inputFontSize = isTablet ? 15.0 : 14.0;
    final sectionAfterGap = isTablet ? size.height * 0.025 : 20.0;
    final inputRadius = BorderRadius.circular(12);

    InputDecoration fieldDec({String? hint}) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: inputFontSize,
        color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
      ),
      filled: true,
      fillColor: isDark ? AppColors.cardDark : AppColors.white,
      contentPadding: const EdgeInsets.all(16),
      enabledBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(
          color: isDark ? AppColors.borderDark : AppColors.border,
          width: 1.2,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
      ),
    );

    Widget sectionLabel(String text) => Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.012),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: isTablet ? 16 : 14,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textPrimaryDark : AppColors.black,
        ),
      ),
    );

    final categories = allCategories.where((c) => c != 'All').toList();
    final images = ref.watch(productImagesProvider);
    final productName = _nameController.text.trim();
    final priceText = _priceController.text.trim();
    final weightText = _estimatedWeightController.text.trim();
    final canSubmit = _selectedCategory != null &&
        images.isNotEmpty &&
        productName.isNotEmpty &&
        priceText.isNotEmpty &&
        weightText.isNotEmpty &&
        double.tryParse(weightText) != null &&
        double.parse(weightText) > 0 &&
        _deliveryClass.isNotEmpty &&
        !_isUploading;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                hPad,
                vPadExtra,
                hPad,
                padding.bottom + size.height * 0.03,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
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
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)!.seller_add_product_title,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 22 : 18,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const MultiImagePicker(),
                  SizedBox(height: sectionAfterGap),
                  sectionLabel('Product Name'),
                  TextField(
                    controller: _nameController,
                    onChanged: (_) => setState(() {}),
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: inputFontSize,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                    decoration: fieldDec(hint: 'Enter product name'),
                  ),
                  SizedBox(height: sectionAfterGap),
                  sectionLabel('Select Category'),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showCategoryList = !_showCategoryList),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _showCategoryList
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.borderDark
                                    : AppColors.border),
                          width: _showCategoryList ? 1.8 : 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              _selectedCategory ?? 'Choose',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: inputFontSize,
                                color: _selectedCategory != null
                                    ? (isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.black)
                                    : AppColors.gray2,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          AnimatedRotation(
                            turns: _showCategoryList ? 0.5 : 0,
                            duration: const Duration(milliseconds: 200),
                            child: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: AppColors.gray2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (_showCategoryList)
                    Container(
                      margin: EdgeInsets.only(top: size.height * 0.004),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardDark : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.borderDark
                              : AppColors.border,
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowLight,
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: categories.map((c) {
                          final selected = _selectedCategory == c;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _selectedCategory = c;
                              _showCategoryList = false;
                            }),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primarySurface
                                    : Colors.transparent,
                              ),
                              child: Text(
                                c,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: inputFontSize,
                                  fontWeight: selected
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: selected
                                      ? AppColors.primary
                                      : (isDark
                                            ? AppColors.textPrimaryDark
                                            : AppColors.black),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  SizedBox(height: sectionAfterGap),
                  sectionLabel('Description'),
                  TextField(
                    controller: _descController,
                    maxLines: 5,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: inputFontSize,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                    decoration: fieldDec(hint: 'Type here'),
                  ),
                  SizedBox(height: sectionAfterGap),
                  sectionLabel('Price'),
                  TextField(
                    controller: _priceController,
                    onChanged: (_) => setState(() {}),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: inputFontSize,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                    decoration: fieldDec(hint: 'Enter here'),
                  ),
                  SizedBox(height: sectionAfterGap),
                  sectionLabel('Estimated Weight (Kg)'),
                  TextField(
                    controller: _estimatedWeightController,
                    onChanged: (_) => setState(() {}),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: inputFontSize,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                    decoration: fieldDec(hint: 'e.g. 2.5'),
                  ),
                  SizedBox(height: sectionAfterGap),
                  sectionLabel('Delivery Class'),
                  Row(
                    children: [
                      _DeliveryClassChip(
                        label: AppLocalizations.of(context)!.product_type_standard,
                        value: 'standard',
                        selected: _deliveryClass == 'standard',
                        inputFontSize: inputFontSize,
                        isDark: isDark,
                        onTap: () => setState(() => _deliveryClass = 'standard'),
                      ),
                      const SizedBox(width: 8),
                      _DeliveryClassChip(
                        label: AppLocalizations.of(context)!.product_type_fragile,
                        value: 'fragile',
                        selected: _deliveryClass == 'fragile',
                        inputFontSize: inputFontSize,
                        isDark: isDark,
                        onTap: () => setState(() => _deliveryClass = 'fragile'),
                      ),
                      const SizedBox(width: 8),
                      _DeliveryClassChip(
                        label: AppLocalizations.of(context)!.product_type_bulky,
                        value: 'bulky',
                        selected: _deliveryClass == 'bulky',
                        inputFontSize: inputFontSize,
                        isDark: isDark,
                        onTap: () => setState(() => _deliveryClass = 'bulky'),
                      ),
                      const SizedBox(width: 8),
                      _DeliveryClassChip(
                        label: AppLocalizations.of(context)!.product_type_heavy,
                        value: 'heavy',
                        selected: _deliveryClass == 'heavy',
                        inputFontSize: inputFontSize,
                        isDark: isDark,
                        onTap: () => setState(() => _deliveryClass = 'heavy'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          child: SizedBox(
            width: double.infinity,
            height: isTablet ? 64 : 56,
            child: ElevatedButton(
              onPressed: canSubmit ? _submitProduct : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: isDark ? AppColors.borderDark : AppColors.textDisabled,
                shape: const StadiumBorder(),
                elevation: 0,
                textStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 18 : 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: _isUploading
                  ? const SizedBox(
                      width: 22, height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(AppLocalizations.of(context)!.seller_add_product_title),
            ),
          ),
        ),
      ),
    );
  }
}

class _DeliveryClassChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final double inputFontSize;
  final bool isDark;
  final VoidCallback onTap;

  const _DeliveryClassChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.inputFontSize,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withAlpha((0.12 * 255).round())
                : (isDark ? AppColors.cardDark : AppColors.white),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? AppColors.primary
                  : (isDark ? AppColors.borderDark : AppColors.border),
              width: selected ? 1.8 : 1.2,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: inputFontSize - 1,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? AppColors.primary
                  : (isDark ? AppColors.textPrimaryDark : AppColors.black),
            ),
          ),
        ),
      ),
    );
  }
}
