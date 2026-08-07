import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../data/cart_provider.dart';
import '../../widgets/common_widgets.dart';
import '../cart/checkout_screen.dart';

class CartScreen extends StatefulWidget {
  final VoidCallback? onBack;
  const CartScreen({super.key, this.onBack});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final cart = context.read<CartProvider>();
      if (cart.items.isNotEmpty) {
        cart.validateStock();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cart = context.watch<CartProvider>();
    final cartList = cart.items;

    final available = cartList.where((i) => !i.outOfStock && i.product.inStock).toList();
    final outOfStock = cartList.where((i) => i.outOfStock || !i.product.inStock).toList();

    debugPrint('[CartDebug] Total: ${cartList.length}, Available: ${available.length}, OOS: ${outOfStock.length}');

    final selectedAvailable = available.where((i) => i.selected).toList();
    final deliveryFee = selectedAvailable.isEmpty ? 0.0 : 2000.0;
    final subtotal = selectedAvailable.fold<double>(0, (sum, i) => sum + i.total);
    final grandTotal = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              size: 20.0,
              color: isDark ? AppColors.darkText : AppColors.text,
            ),
            onPressed: () {
              // Switch back to the Home tab if callback is provided (inside MainShell).
              // Fallback: pop if possible, otherwise push home route to avoid blank screen.
              if (widget.onBack != null) {
                widget.onBack!();
              } else if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (_) => false,
                );
              }
            },
          ),
        ),
        title: Text(
          l10n.cart_title,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
        centerTitle: true,
        actions: [
          if (cartList.isNotEmpty)
            IconButton(
              icon: Icon(
                Icons.delete_outline_rounded,
                size: 20,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) {
                    final dk = Theme.of(ctx).brightness == Brightness.dark;
                    return AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Text(
                        AppLocalizations.of(ctx)!.dialog_clear_cart_title,
                        style: TextStyle(
                          color: dk ? AppColors.darkText : AppColors.text,
                        ),
                      ),
                      content: Text(
                        AppLocalizations.of(ctx)!.dialog_clear_cart_body,
                        style: TextStyle(
                          color: dk ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(
                            AppLocalizations.of(ctx)!.dialog_cancel,
                            style: TextStyle(
                              color: dk ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(
                            AppLocalizations.of(ctx)!.dialog_clear,
                            style: const TextStyle(color: AppColors.error),
                          ),
                        ),
                      ],
                    );
                  },
                );
                if (confirmed == true) cart.clearCart();
              },
            )
          else
            const SizedBox(width: 48),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: cartList.isEmpty
                  ? _buildEmptyState(l10n, isDark)
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      children: [
                        if (cart.isValidating)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'Checking stock availability...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (outOfStock.isNotEmpty)
                          _buildOutOfStockSection(context, outOfStock, cart),
                        if (available.isNotEmpty)
                          ...available.asMap().entries.map((entry) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _CartItemCard(item: entry.value),
                            );
                          }),
                      ],
                    ),
            ),
            if (cartList.isNotEmpty)
              _CheckoutSummaryFooter(
                subtotal: subtotal,
                deliveryFee: deliveryFee,
                grandTotal: grandTotal,
                canCheckout: selectedAvailable.isNotEmpty,
                disabledLabel: outOfStock.isNotEmpty && available.isEmpty
                    ? 'All items are sold out'
                    : 'No items available',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutOfStockSection(BuildContext context, List outOfStockItems, CartProvider cart) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 16,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              'Out of Stock (${outOfStockItems.length})',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.text,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                for (final item in List.from(outOfStockItems)) {
                  cart.removeItem(item.product.id);
                }
              },
              child: Text(
                'Remove all',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...outOfStockItems.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _CartItemCard(item: item),
            )),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n, bool isDark) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('\u{1F6D2}', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            Text(
              l10n.cart_empty,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cart_empty_desc,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CheckoutSummaryFooter extends StatelessWidget {
  final double subtotal;
  final double deliveryFee;
  final double grandTotal;
  final bool canCheckout;
  final String disabledLabel;

  const _CheckoutSummaryFooter({
    required this.subtotal,
    required this.deliveryFee,
    required this.grandTotal,
    required this.canCheckout,
    this.disabledLabel = 'No items available',
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : AppColors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.border,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(
            label: l10n.cart_total,
            value: formatPrice(subtotal),
            valueColor: isDark ? AppColors.darkText : AppColors.text,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: l10n.checkout_delivery_fee,
            value: formatPrice(deliveryFee),
            valueColor: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Divider(
              height: 1,
              color: isDark ? AppColors.darkDivider : AppColors.border,
            ),
          ),
          _SummaryRow(
            label: l10n.checkout_total_label,
            value: formatPrice(grandTotal),
            valueColor: AppColors.primary,
            boldValue: true,
            boldLabel: true,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: GreenButton(
              label: canCheckout ? l10n.cart_checkout : disabledLabel,
              onTap: canCheckout
                  ? () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CheckoutScreen(),
                        ),
                      )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color valueColor;
  final bool boldValue;
  final bool boldLabel;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.valueColor,
    this.boldValue = false,
    this.boldLabel = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: boldLabel ? FontWeight.w700 : FontWeight.w400,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: boldValue ? FontWeight.w700 : FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }
}

class _CartItemCard extends StatelessWidget {
  final dynamic item;
  const _CartItemCard({required this.item});

  bool get _isSoldOut => item.outOfStock == true || !item.product.inStock;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return _buildCard(context, cart);
  }

  Widget _buildCard(BuildContext context, CartProvider cart) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool hasStockWarning = item.stockWarning != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkElevated : AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSoldOut
              ? (isDark ? AppColors.darkBorder : AppColors.border)
              : hasStockWarning
                  ? AppColors.warning
                  : (isDark ? AppColors.darkBorder : AppColors.border),
          width: hasStockWarning || _isSoldOut ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImage(context),
              const SizedBox(width: 12),
              // Name/description/price dim together when sold out; the image
              // itself is blurred separately below so it reads as "greyed
              // out" rather than merely faded.
              Expanded(
                child: Opacity(
                  opacity: _isSoldOut ? 0.5 : 1.0,
                  child: _buildInfo(context),
                ),
              ),
              const SizedBox(width: 8),
              _buildActions(context, cart),
            ],
          ),
          if (hasStockWarning && !_isSoldOut) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      item.stockWarning!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Blurred + greyscaled image for sold-out items, matching the treatment
  /// used on the product browse and vendor store pages, instead of just a
  /// flat opacity fade.
  Widget _buildImage(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final image = AppNetworkImage(
      imageUrl: item.product.imageUrl,
      width: 80,
      height: 80,
      borderRadius: BorderRadius.circular(12),
      fallbackColor: isDark ? AppColors.darkSurface : AppColors.grey100,
    );

    if (!_isSoldOut) return image;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Stack(
        children: [
          ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 2.5, sigmaY: 2.5),
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(
                Colors.grey,
                BlendMode.saturation,
              ),
              child: image,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withValues(alpha: 0.18)),
          ),
        ],
      ),
    );
  }

  Widget _buildInfo(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.product.name,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 4),
        Text(
          item.product.description.length > 50
              ? '${item.product.description.substring(0, 50)}...'
              : item.product.description,
          style: TextStyle(
            fontSize: 13,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              formatPrice(item.product.price),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            if (item.product.estimatedWeightKg > 0) ...[
              const SizedBox(width: 6),
              Text(
                '/ ${item.product.estimatedWeightKg}kg',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context, CartProvider cart) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isSoldOut) {
      // Tiny "Sold out" pill sits in the side actions column — no quantity
      // controls are shown, so the item cannot be incremented, decremented,
      // or otherwise pushed toward checkout from here. Only removal remains.
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          SoldOutPill(
            color: isDark ? AppColors.darkTextSecondary : AppColors.grey600,
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => cart.removeItem(item.product.id),
            child: Icon(
              Icons.delete_outline_rounded,
              size: 18,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => cart.removeItem(item.product.id),
          child: Icon(
            Icons.close,
            size: 18,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => cart.increment(item.product.id),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Icon(
                    Icons.add,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${item.quantity}',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 1,
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
              GestureDetector(
                onTap: () => cart.decrement(item.product.id),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
