import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../data/cart_provider.dart';
import '../../widgets/common_widgets.dart';
import 'receipt_screen.dart';

class PaymentSuccessScreen extends ConsumerStatefulWidget {
  final List items;
  final double total;
  final String orderId;

  const PaymentSuccessScreen({
    super.key,
    required this.items,
    required this.total,
    required this.orderId,
  });

  @override
  ConsumerState<PaymentSuccessScreen> createState() =>
      _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends ConsumerState<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;
  bool _showActions = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 1.0)),
    );
    _controller.forward();
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _showActions = true);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Spacer(),
                  ScaleTransition(
                    scale: _scaleAnim,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.primary.withValues(alpha: 0.1),
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        size: 64,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Text(
                      loc.payment_success,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.darkText : AppColors.text,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FadeTransition(
                    opacity: _fadeAnim,
                    child: Text(
                      '${loc.payment_order_placed}. ${loc.receipt_for.toLowerCase()} ₦${widget.total.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Spacer(),
                  if (_showActions) ...[
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: GreenButton(
                        label: loc.receipt_view,
                        onTap: () {
                          final cart = context.read<CartProvider>();
                          cart.clearCart();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReceiptScreen(
                                items: widget.items,
                                total: widget.total,
                                paymentMethod: 'paystack',
                              ),
                            ),
                            (route) => route.isFirst,
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeTransition(
                      opacity: _fadeAnim,
                      child: GreenButton(
                        label: loc.payment_go_home,
                        outlined: true,
                        onTap: () {
                          final cart = context.read<CartProvider>();
                          cart.clearCart();
                          Navigator.of(context).popUntil((r) => r.isFirst);
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
