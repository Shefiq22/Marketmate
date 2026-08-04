import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../data/cart_provider.dart';
import '../../providers/paystack_payment_provider.dart';
import '../../widgets/common_widgets.dart';
import 'payment_success_screen.dart';

class PaystackWebViewScreen extends ConsumerStatefulWidget {
  final String checkoutUrl;
  final String orderId;
  final double total;

  const PaystackWebViewScreen({
    super.key,
    required this.checkoutUrl,
    required this.orderId,
    required this.total,
  });

  @override
  ConsumerState<PaystackWebViewScreen> createState() =>
      _PaystackWebViewScreenState();
}

class _PaystackWebViewScreenState
    extends ConsumerState<PaystackWebViewScreen> {
  WebViewController? _controller;
  bool _isPageLoaded = false;
  bool _didStartPolling = false;
  bool _didComplete = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (progress >= 100 && !_isPageLoaded) {
              setState(() => _isPageLoaded = true);
            }
          },
          onPageFinished: (_) {
            if (!_isPageLoaded) {
              setState(() => _isPageLoaded = true);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  void _startPollingIfNeeded() {
    if (!_didStartPolling) {
      _didStartPolling = true;
      ref.read(paystackPaymentProvider.notifier).startPolling();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final psState = ref.watch(paystackPaymentProvider);
    final loc = AppLocalizations.of(context)!;

    if (psState.step == PaystackStep.paymentSuccess && !_didComplete) {
      _didComplete = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _navigateToSuccess(context);
      });
    }

    if (psState.step == PaystackStep.paymentFailed && !_didComplete) {
      _didComplete = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showFailureAndPop(context, psState.error);
      });
    }

    final hideContent = psState.webViewHidden;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        final currentState = ref.read(paystackPaymentProvider);
        if (currentState.step == PaystackStep.processingInWebView ||
            currentState.step == PaystackStep.verifyingStatus) {
          ref.read(paystackPaymentProvider.notifier).hideWebView();
          _startPollingIfNeeded();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: IconButton(
              icon: const Icon(Icons.close, size: 20.0),
              onPressed: () {
                final currentState = ref.read(paystackPaymentProvider);
                if (currentState.step == PaystackStep.processingInWebView ||
                    currentState.step == PaystackStep.verifyingStatus) {
                  ref.read(paystackPaymentProvider.notifier).hideWebView();
                  _startPollingIfNeeded();
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
          ),
          title: Text(
            loc.payment_processing,
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.darkText : AppColors.text,
            ),
          ),
          centerTitle: true,
        ),
        body: Stack(
          children: [
            if (!hideContent && _controller != null)
              WebViewWidget(controller: _controller!),
            if (!_isPageLoaded && !hideContent)
              _ShimmerOverlay(isDark: isDark),
            if (hideContent)
              _BackgroundVerificationCard(
                loc: loc,
                isDark: isDark,
                showManualCheck: psState.showManualCheck,
                onCheckNow: () {
                  ref.read(paystackPaymentProvider.notifier).checkManually();
                },
              ),
          ],
        ),
      ),
    );
  }

  void _navigateToSuccess(BuildContext context) {
    final cart = context.read<CartProvider>();
    final items = List.from(cart.selectedItems);
    cart.clearCart();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(
          items: items,
          total: widget.total,
          orderId: widget.orderId,
        ),
      ),
      (route) => route.isFirst,
    );
  }

  void _showFailureAndPop(BuildContext context, String? error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? AppLocalizations.of(context)!.payment_failed)),
    );
    Navigator.of(context).popUntil((r) => r.isFirst);
  }

  @override
  void dispose() {
    _startPollingIfNeeded();
    super.dispose();
  }
}

class _ShimmerOverlay extends StatelessWidget {
  final bool isDark;
  const _ShimmerOverlay({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: isDark ? AppColors.darkSurface : AppColors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _ShimmerBlock(width: 280, height: 40, isDark: isDark),
          const SizedBox(height: 24),
          _ShimmerBlock(width: 200, height: 20, isDark: isDark),
          const SizedBox(height: 48),
          _ShimmerBlock(width: 320, height: 180, isDark: isDark),
          const SizedBox(height: 24),
          _ShimmerBlock(width: 260, height: 50, isDark: isDark),
        ],
      ),
    );
  }
}

class _ShimmerBlock extends StatefulWidget {
  final double width;
  final double height;
  final bool isDark;
  const _ShimmerBlock({
    required this.width,
    required this.height,
    required this.isDark,
  });

  @override
  State<_ShimmerBlock> createState() => _ShimmerBlockState();
}

class _ShimmerBlockState extends State<_ShimmerBlock>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.3, end: 0.7).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, __) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: widget.isDark ? AppColors.darkElevated : AppColors.grey200,
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: _animation.value * 0.5),
                Colors.white.withValues(alpha: 0),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        );
      },
    );
  }
}

class _BackgroundVerificationCard extends StatelessWidget {
  final AppLocalizations loc;
  final bool isDark;
  final bool showManualCheck;
  final VoidCallback onCheckNow;

  const _BackgroundVerificationCard({
    required this.loc,
    required this.isDark,
    required this.showManualCheck,
    required this.onCheckNow,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.primary),
            const SizedBox(height: 24),
            Text(
              loc.payment_verifying_background,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.text,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (showManualCheck) ...[
              Text(
                loc.payment_check_manually,
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              GreenButton(
                label: loc.payment_check_now,
                onTap: onCheckNow,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
