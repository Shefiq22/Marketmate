import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../data/cart_provider.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/addresses_provider.dart';
import '../../providers/checkout_provider.dart';
import '../../providers/paystack_payment_provider.dart';
import '../../repositories/cart_repository.dart';
import '../profile/edit_profile_screen.dart';
import 'paystack_webview_screen.dart';
import 'payment_screen.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});
  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  String _paymentMethod = 'paystack';
  UserAddress? _selectedAddress;
  bool _initialized = false;
  bool _isProcessing = false;

  UserAddress? get _address => _selectedAddress;

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      _initSelectedAddress();
      _initialized = true;
    }
    final cart = context.watch<CartProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final availableSelected = cart.availableItems.where((i) => i.selected).toList();
    final availableSubtotal = availableSelected.fold<double>(0, (sum, i) => sum + i.total);
    final deliveryFee = availableSelected.isEmpty ? 0.0 : 2000.0;
    final commission = availableSubtotal * 0.0005;
    final totalWithCommission = availableSubtotal + deliveryFee + commission;
    final checkoutState = ref.watch(checkoutStateProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20.0),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Checkout',
          style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold, color: isDark ? AppColors.darkText : AppColors.text),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24.0),
                  Text(
                    AppLocalizations.of(context)!.order_detail_payment_method,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkText : AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 16.0),

                  _PaymentOption(
                    icon: Icons.account_balance_outlined,
                    title: AppLocalizations.of(context)!.checkout_bank_transfer,
                    subtitle: AppLocalizations.of(context)!.checkout_bank_transfer_desc,
                    value: 'bank',
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  const SizedBox(height: 12.0),
                  _PaymentOption(
                    icon: Icons.credit_card_outlined,
                    title: AppLocalizations.of(context)!.checkout_saved_card,
                    subtitle: '•••• •••• •••• 4875',
                    value: 'saved_card',
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  const SizedBox(height: 12.0),
                  _PaymentOption(
                    icon: Icons.payment_outlined,
                    title: AppLocalizations.of(context)!.checkout_paystack,
                    subtitle: null,
                    value: 'paystack',
                    groupValue: _paymentMethod,
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                    highlighted: true,
                  ),
                  const SizedBox(height: 12.0),

                  Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.add_circle_outline,
                          size: 20,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Add debit/credit card',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.text,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.chevron_right,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.grey400,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24.0),
                  Divider(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 20.0),

                  // Proceed with
                  Row(
                    children: [
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 18,
                        color: AppColors.grey500,
                      ),
                      Text(
                        ' Proceed with ${_paymentMethod == 'paystack'
                            ? AppLocalizations.of(context)!.checkout_paystack
                            : _paymentMethod == 'bank'
                            ? AppLocalizations.of(context)!.checkout_bank_transfer
                            : AppLocalizations.of(context)!.checkout_saved_card}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16.0),

                  // Address
                  GestureDetector(
                    onTap: _showAddressPicker,
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: AppColors.grey500,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Address: ',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.textSecondary,
                          ),
                        ),
                        Expanded(
                          child: Text(
                            _address?.address ?? 'Tap to select',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: _address != null
                                  ? (isDark ? AppColors.darkText : AppColors.text)
                                  : AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.chevron_right,
                          size: 16,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.grey500,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24.0),
                  Divider(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(height: 16.0),

                  // Order summary
                  _SummaryRow(
                    label: _paymentMethod == 'paystack'
                        ? AppLocalizations.of(context)!.checkout_paystack
                        : AppLocalizations.of(context)!.order_detail_payment_method,
                    value: formatPrice(availableSubtotal),
                    isBold: false,
                  ),
                  const SizedBox(height: 12.0),
                  _SummaryRow(
                    label: AppLocalizations.of(context)!.checkout_delivery_fee,
                    value: formatPrice(deliveryFee),
                    isBold: false,
                  ),
                  const SizedBox(height: 12.0),
                  _SummaryRow(
                    label: AppLocalizations.of(context)!.checkout_commission,
                    value: formatPrice(commission),
                    isBold: false,
                  ),
                  const SizedBox(height: 16.0),
                  _SummaryRow(
                    label: AppLocalizations.of(context)!.checkout_total_label,
                    value: formatPrice(totalWithCommission),
                    isBold: true,
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 32.0),
        color: Theme.of(context).cardColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (checkoutState.step == CheckoutStep.error && checkoutState.error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  checkoutState.error!,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            GreenButton(
              label: checkoutState.step == CheckoutStep.processing
                  ? 'Creating order…'
                  : checkoutState.step == CheckoutStep.error
                      ? AppLocalizations.of(context)!.retry
                      : 'Proceed to Payment',
              isLoading: _isProcessing || checkoutState.step == CheckoutStep.processing,
              onTap: (_isProcessing || checkoutState.step == CheckoutStep.processing)
                  ? null
                  : () => _handleProceed(cart, totalWithCommission),
            ),
          ],
        ),
      ),
    );
  }

  void _initSelectedAddress() {
    final addresses = ref.read(addressesProvider);
    if (_selectedAddress == null && addresses.isNotEmpty) {
      final defaultAddr = addresses.where((a) => a.isDefault).firstOrNull;
      _selectedAddress = defaultAddr ?? addresses.first;
    }
  }

  void _showAddressPicker() {
    final addresses = ref.read(addressesProvider);
    if (addresses.isEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AddNewAddressScreen()),
      ).then((_) {
        if (!mounted) return;
        ref.read(addressesProvider.notifier).refresh();
      });
      return;
    }
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select delivery address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText : AppColors.text,
                ),
              ),
              const SizedBox(height: 16),
              ...addresses.map((addr) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: addr.id == _selectedAddress?.id
                        ? AppColors.primary
                        : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                elevation: 0,
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.darkCard : AppColors.grey100,
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    addr.isDefault ? Icons.star : Icons.location_on_outlined,
                    color: addr.isDefault ? AppColors.primary : AppColors.grey500,
                  ),
                  title: Text(addr.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(addr.address, maxLines: 2, overflow: TextOverflow.ellipsis),
                  trailing: addr.id == _selectedAddress?.id
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                  onTap: () {
                    setState(() => _selectedAddress = addr);
                    Navigator.pop(ctx);
                  },
                ),
              )),
              const SizedBox(height: 8),
              TextButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddNewAddressScreen()),
                  ).then((_) {
                    if (!mounted) return;
                    ref.read(addressesProvider.notifier).refresh();
                  });
                },
                icon: const Icon(Icons.add, size: 18),
                label: Text(AppLocalizations.of(context)!.checkout_add_address),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isStockError(String? error) =>
      error != null && error.toLowerCase().contains('insufficient stock');

  void _showStockErrorSheet() {
    final loc = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      showDragHandle: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded, size: 32, color: AppColors.error),
              ),
              const SizedBox(height: 20),
              Text(
                loc.stock_error_title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkText : AppColors.text,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                loc.stock_error_message,
                style: TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.darkTextSecondary : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GreenButton(
                label: loc.stock_error_review_basket,
                onTap: () {
                  Navigator.pop(ctx);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  ({String street, String city, String state}) _parseAddress(String raw) {
    final parts = raw.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
    if (parts.length >= 3) {
      return (
        street: parts.sublist(0, parts.length - 2).join(', '),
        city: parts[parts.length - 2],
        state: parts.last,
      );
    }
    if (parts.length == 2) {
      return (street: parts[0], city: parts[0], state: parts.last);
    }
    return (street: raw, city: raw, state: raw);
  }

  List<double> _resolveCoords(UserAddress address) {
    final lng = address.longitude;
    final lat = address.latitude;
    if (lng != null && lat != null) return [lng, lat];
    return [3.3792, 6.5244];
  }

  void _handleProceed(CartProvider cart, double total) async {
    final loc = AppLocalizations.of(context)!;
    final address = _address;
    if (address == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.checkout_add_address_hint)),
      );
      return;
    }

    // Pre-checkout stock validation: re-fetch latest stock from API
    setState(() => _isProcessing = true);
    await cart.validateStock();

    // Check if all items became out of stock during validation
    if (!cart.hasAvailableItems) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      _showStockErrorSheet();
      return;
    }

    // Use the cart's available items (excludes OOS items)
    final checkoutItems = cart.availableItems.where((i) => i.selected).toList();
    if (checkoutItems.isEmpty) {
      if (!mounted) return;
      setState(() => _isProcessing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No available items to checkout')),
      );
      return;
    }

    // Token is now injected centrally by ApiClient._headers — no manual injection needed.

    final parsed = _parseAddress(address.address);
    final coords = _resolveCoords(address);

    debugPrint('[CheckoutDebug] Parsed address — street: "${parsed.street}", city: "${parsed.city}", state: "${parsed.state}"');
    debugPrint('[CheckoutDebug] Coordinates — $coords');
    debugPrint('[CheckoutDebug] Payment method UI: "${_paymentMethod}" → mapped to: "${_paymentMethod == 'paystack' ? 'card' : 'bank_transfer'}"');

    if (_paymentMethod == 'paystack') {
      final paystackNotifier = ref.read(paystackPaymentProvider.notifier);
      paystackNotifier.reset();
      final cartRepo = CartRepository();
      try {
        await cartRepo.clearCart();
        for (final item in checkoutItems) {
          await cartRepo.addItem(item.product.id, quantity: item.quantity);
        }
      } catch (_) {}
      await paystackNotifier.placeAndInitiateOrder(
        items: checkoutItems.map((item) => {
          'product': item.product.id,
          'quantity': item.quantity,
        }).toList(),
        street: parsed.street,
        city: parsed.city,
        stateName: parsed.state,
        coordinates: coords,
        paymentMethod: 'card',
      );
      if (!mounted) return;
      setState(() => _isProcessing = false);
      final psState = ref.read(paystackPaymentProvider);
      if (psState.step == PaystackStep.processingInWebView &&
          psState.accessCode != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaystackWebViewScreen(
              checkoutUrl: 'https://checkout.paystack.com/${psState.accessCode}',
              orderId: psState.orderId!,
              total: total,
            ),
          ),
        );
      } else if (psState.step == PaystackStep.paymentFailed) {
        if (_isStockError(psState.error)) {
          _showStockErrorSheet();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(psState.error ?? 'Checkout failed')),
          );
        }
      }
    } else {
      final notifier = ref.read(checkoutStateProvider.notifier);
      notifier.setProcessing();
      final cartRepo = CartRepository();
      try {
        await cartRepo.clearCart();
        for (final item in checkoutItems) {
          await cartRepo.addItem(item.product.id, quantity: item.quantity);
        }
      } catch (_) {}
      await notifier.placeOrder(
        items: checkoutItems.map((item) => {
          'product': item.product.id,
          'quantity': item.quantity,
        }).toList(),
        street: parsed.street,
        city: parsed.city,
        stateName: parsed.state,
        coordinates: coords,
        paymentMethod: 'bank_transfer',
      );
      if (!mounted) return;
      setState(() => _isProcessing = false);
      final state = ref.read(checkoutStateProvider);
      if (state.step == CheckoutStep.payment && state.orderData != null) {
        final orderId = state.orderData!['_id'] as String?;
        if (orderId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentScreen(
                orderId: orderId,
                total: total,
                paymentMethod: _paymentMethod,
              ),
            ),
          );
        }
      } else if (state.step == CheckoutStep.error) {
        if (_isStockError(state.error)) {
          _showStockErrorSheet();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error ?? 'Checkout failed')),
          );
        }
      }
    }
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String value;
  final String groupValue;
  final ValueChanged<String?> onChanged;
  final bool highlighted;

  const _PaymentOption({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.groupValue,
    required this.onChanged,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selected = value == groupValue;
    return GestureDetector(
      onTap: () => onChanged(value),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : (Theme.of(context).colorScheme.outline),
            width: selected ? 1.5 : 1,
          ),
          color: selected
              ? (isDark ? AppColors.darkElevated : AppColors.primaryBg)
              : (Theme.of(context).cardColor),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: highlighted
                    ? (isDark
                      ? AppColors.primaryLight
                      : AppColors.primary)
                    : AppColors.grey100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 18,
                color: highlighted
                    ? (isDark ? AppColors.darkText : AppColors.white)
                    : AppColors.grey600,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? (isDark
                                ? AppColors.white
                                : AppColors.text)
                          : (isDark ? AppColors.darkText : AppColors.text),
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 12,
                        color: selected
                            ? (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.text.withAlpha(0xBF))
                            : AppColors.grey500,
                      ),
                    ),
                ],
              ),
            ),
            Radio<String>(
              value: value,
              groupValue: groupValue,
              onChanged: onChanged,
              activeColor: AppColors.primary,
              fillColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return AppColors.primary;
                }
                return isDark ? AppColors.darkTextSecondary : AppColors.grey500;
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  const _SummaryRow({
    required this.label,
    required this.value,
    required this.isBold,
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
            fontSize: isBold ? 15 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w400,
            color: isBold
                ? (isDark ? AppColors.darkText : AppColors.text)
                : (isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isBold ? 16 : 14,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
            color: isBold
                ? AppColors.primary
                : (isDark ? AppColors.darkText : AppColors.text),
          ),
        ),
      ],
    );
  }
}
