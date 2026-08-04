import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import '../../theme/app_theme.dart';
import '../../data/cart_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../providers/checkout_provider.dart';
import 'receipt_screen.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String orderId;
  final double total;
  final String paymentMethod;
  const PaymentScreen({
    super.key,
    required this.orderId,
    required this.total,
    required this.paymentMethod,
  });
  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  final _cardCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();
  bool _paying = false;

  InputDecoration _inputDecoration(String hint) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.grey500,
        fontSize: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.outline,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: 1.5,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
          'Payment Details',
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
                        Container(
                          width: 40,
                          height: 28,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.primaryLight : AppColors.primary,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Center(
                            child: Text(
                              'PS',
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Paystack',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  color: isDark ? AppColors.darkText : AppColors.text,
                                ),
                              ),
                              Text(
                                ref.watch(currentUserProvider)?.email ?? 'tolahazy35@gmail.com',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.darkTextSecondary : AppColors.grey500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Pay ${formatPrice(widget.total)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24.0),
                  Text(
                    'Enter your card details to pay',
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 20.0),

                  _buildLabel('CARD NUMBER'),
                  const SizedBox(height: 8.0),
                  TextField(
                    controller: _cardCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration('0000 0000 0000 0000'),
                  ),
                  const SizedBox(height: 18.0),

                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('CARD EXPIRY'),
                            const SizedBox(height: 8.0),
                            TextField(
                              controller: _expiryCtrl,
                              keyboardType: TextInputType.datetime,
                              decoration: _inputDecoration('MM/YY'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildLabel('CVV'),
                            const SizedBox(height: 8.0),
                            TextField(
                              controller: _cvvCtrl,
                              keyboardType: TextInputType.number,
                              obscureText: true,
                              decoration: _inputDecoration('123'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24.0),
                ],
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 32.0),
        child: GreenButton(
          label: _paying ? 'Processing...' : 'Pay ${formatPrice(widget.total)}',
          onTap: _paying ? null : _initiatePay,
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: isDark
            ? AppColors.darkTextSecondary
            : AppColors.grey500,
        letterSpacing: 0.5,
      ),
    );
  }

  void _initiatePay() async {
    setState(() => _paying = true);
    try {
      final checkoutNotifier = ref.read(checkoutStateProvider.notifier);
      if (widget.paymentMethod == 'paystack') {
        await checkoutNotifier.initiateCardPayment();
      } else {
        await checkoutNotifier.assignVirtualAccount();
      }
      if (!mounted) return;
      final state = ref.read(checkoutStateProvider);
      if (state.error != null) {
        throw Exception(state.error);
      }
      if (state.paymentData == null) {
        throw Exception('No payment data returned');
      }
      checkoutNotifier.markSuccess();
      if (!mounted) return;
      final cart = context.read<CartProvider>();
      final items = List.from(cart.selectedItems);
      cart.clearCart();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => ReceiptScreen(
            items: items,
            total: widget.total,
            paymentMethod: widget.paymentMethod,
          ),
        ),
        (route) => route.isFirst,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }
}
