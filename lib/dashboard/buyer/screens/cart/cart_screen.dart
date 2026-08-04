import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:market_mate/l10n/app_localizations.dart';
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
    final cart = context.watch<CartProvider>();
    final cartList = cart.items;

    final available = cartList.where((i) => !i.outOfStock).toList();
    final outOfStock = cartList.where((i) => i.outOfStock).toList();

    debugPrint('[CartDebug] Total: ${cartList.length}, Available: ${available.length}, OOS: ${outOfStock.length}');

    final selectedAvailable = available.where((i) => i.selected).toList();
    final deliveryFee = selectedAvailable.isEmpty ? 0.0 : 2000.0;
    final subtotal = selectedAvailable.fold<double>(0, (sum, i) => sum + i.total);
    final grandTotal = subtotal + deliveryFee;

    return Scaffold(
      backgroundColor: const Color(0xFF13161C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF13161C),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20.0),
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
          style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          if (cartList.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFF6B7685)),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (ctx) {
                    return AlertDialog(
                      backgroundColor: const Color(0xFF2B3643),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      title: Text(AppLocalizations.of(ctx)!.dialog_clear_cart_title,
                        style: TextStyle(color: Color(0xFFE9EDEF))),
                      content: Text(AppLocalizations.of(ctx)!.dialog_clear_cart_body,
                        style: TextStyle(color: Color(0xFF6B7685))),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(AppLocalizations.of(ctx)!.dialog_cancel,
                            style: TextStyle(color: Color(0xFF6B7685))),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(ctx, true),
                          child: Text(AppLocalizations.of(ctx)!.dialog_clear,
                            style: TextStyle(color: Color(0xFFC62828))),
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
                  ? _buildEmptyState(l10n)
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                      children: [
                        if (cart.isValidating)
                          const Padding(
                            padding: EdgeInsets.only(bottom: 16.0),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 14,
                                  height: 14,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Color(0xFF6B7685),
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'Checking stock availability...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF6B7685),
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
            if (selectedAvailable.isNotEmpty)
              _CheckoutSummaryFooter(
                subtotal: subtotal,
                deliveryFee: deliveryFee,
                grandTotal: grandTotal,
                canCheckout: cart.canProceedToCheckout,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildOutOfStockSection(BuildContext context, List outOfStockItems, CartProvider cart) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFC62828)),
            const SizedBox(width: 6),
            Text(
              'Out of Stock (${outOfStockItems.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFFC62828),
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {
                for (final item in List.from(outOfStockItems)) {
                  cart.removeItem(item.product.id);
                }
              },
              child: const Text(
                'Remove all',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7685),
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

  Widget _buildEmptyState(AppLocalizations l10n) {
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
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFE9EDEF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.cart_empty_desc,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6B7685),
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

  const _CheckoutSummaryFooter({
    required this.subtotal,
    required this.deliveryFee,
    required this.grandTotal,
    required this.canCheckout,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: const BoxDecoration(
        color: Color(0xFF1E222D),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 16,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(
            label: l10n.cart_total,
            value: formatPrice(subtotal),
            valueColor: const Color(0xFFE9EDEF),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: l10n.checkout_delivery_fee,
            value: formatPrice(deliveryFee),
            valueColor: const Color(0xFF6B7685),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFF333D47)),
          ),
          _SummaryRow(
            label: l10n.checkout_total_label,
            value: formatPrice(grandTotal),
            valueColor: const Color(0xFF2E7D32),
            boldValue: true,
            boldLabel: true,
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: GreenButton(
              label: canCheckout ? l10n.cart_checkout : 'No items available',
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: boldLabel ? FontWeight.w700 : FontWeight.w400,
            color: const Color(0xFF6B7685),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      child: _isSoldOut
          ? Opacity(
              opacity: 0.6,
              child: _buildCard(context, cart),
            )
          : _buildCard(context, cart),
    );
  }

  Widget _buildCard(BuildContext context, CartProvider cart) {
    final bool hasStockWarning = item.stockWarning != null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E222D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _isSoldOut
              ? const Color(0xFFC62828)
              : hasStockWarning
                  ? const Color(0xFFF57F17)
                  : const Color(0xFF333D47),
          width: hasStockWarning ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildImageWithBadge(context),
              const SizedBox(width: 12),
              Expanded(child: _buildInfo()),
              const SizedBox(width: 8),
              _buildActions(cart),
            ],
          ),
          if (hasStockWarning) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF57F17).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 14,
                    color: Color(0xFFF57F17),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      item.stockWarning!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFF57F17),
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

  Widget _buildImageWithBadge(BuildContext context) {
    return Stack(
      children: [
        AppNetworkImage(
          imageUrl: item.product.imageUrl,
          width: 80,
          height: 80,
          borderRadius: BorderRadius.circular(12),
          fallbackColor: const Color(0xFF1A2128),
        ),
        if (_isSoldOut)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFC62828),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                AppLocalizations.of(context)!.products_sold_out_badge,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.product.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFFE9EDEF),
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 4),
        Text(
          item.product.description.length > 50
              ? '${item.product.description.substring(0, 50)}...'
              : item.product.description,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7685),
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
                color: Color(0xFF2E7D32),
              ),
            ),
            if (item.product.estimatedWeightKg > 0) ...[
              const SizedBox(width: 6),
              Text(
                '/ ${item.product.estimatedWeightKg}kg',
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7685),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildActions(CartProvider cart) {
    if (_isSoldOut) {
      return GestureDetector(
        onTap: () => cart.removeItem(item.product.id),
        child: const Icon(
          Icons.delete_outline_rounded,
          size: 18,
          color: Color(0xFF6B7685),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () => cart.removeItem(item.product.id),
          child: const Icon(
            Icons.close,
            size: 18,
            color: Color(0xFF6B7685),
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF333D47)),
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
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 1,
                color: const Color(0xFF333D47),
              ),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  '${item.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFFE9EDEF),
                  ),
                ),
              ),
              Container(
                width: 28,
                height: 1,
                color: const Color(0xFF333D47),
              ),
              GestureDetector(
                onTap: () => cart.decrement(item.product.id),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  child: Icon(
                    Icons.remove,
                    size: 16,
                    color: Color(0xFF2E7D32),
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
