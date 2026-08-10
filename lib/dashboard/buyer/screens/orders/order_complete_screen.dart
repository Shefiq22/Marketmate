import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/models.dart';
import '../../providers/orders_provider.dart';
import '../../theme/app_theme.dart';

class OrderCompleteScreen extends ConsumerStatefulWidget {
  final Order order;
  const OrderCompleteScreen({super.key, required this.order});

  @override
  ConsumerState<OrderCompleteScreen> createState() => _OrderCompleteScreenState();
}

enum _Stage { confirm, loading, success, error }

class _OrderCompleteScreenState extends ConsumerState<OrderCompleteScreen> {
  _Stage _stage = _Stage.confirm;
  String? _errorMessage;

  Future<void> _confirmComplete() async {
    setState(() => _stage = _Stage.loading);
    HapticFeedback.mediumImpact();
    try {
      final repo = ref.read(ordersRepositoryProvider);
      await repo.completeOrder(widget.order.id);
      ref.invalidate(ordersProvider);
      if (!mounted) return;
      HapticFeedback.heavyImpact();
      setState(() => _stage = _Stage.success);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _stage = _Stage.error;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return PopScope(
      canPop: _stage != _Stage.loading,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: switch (_stage) {
                    _Stage.confirm => _ConfirmView(
                        key: const ValueKey('confirm'),
                        order: widget.order,
                        isDark: isDark,
                        onConfirm: _confirmComplete,
                      ),
                    _Stage.loading => const _LoadingView(key: ValueKey('loading')),
                    _Stage.success => _SuccessView(
                        key: const ValueKey('success'),
                        order: widget.order,
                      ),
                    _Stage.error => _ErrorView(
                        key: const ValueKey('error'),
                        message: _errorMessage ?? 'Something went wrong.',
                        onRetry: () => setState(() => _stage = _Stage.confirm),
                      ),
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ConfirmView extends StatelessWidget {
  final Order order;
  final bool isDark;
  final VoidCallback onConfirm;
  const _ConfirmView({
    super.key,
    required this.order,
    required this.isDark,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.local_shipping_rounded, size: 44, color: AppColors.primary),
        ),
        const SizedBox(height: 24),
        Text(
          'Your order has arrived',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'Order #${order.displayId} has been delivered by your rider. '
          'Please confirm you\'ve received everything before we close this order.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            height: 1.5,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: const StadiumBorder(),
              elevation: 0,
            ),
            child: const Text(
              'Confirm Order Received',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Only confirm once you\'ve checked your items.',
          style: TextStyle(
            fontSize: 12,
            color: isDark ? AppColors.darkTextSecondary : AppColors.grey500,
          ),
        ),
      ],
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: const [
        SizedBox(
          width: 48,
          height: 48,
          child: CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
        ),
        SizedBox(height: 20),
        Text('Confirming your order...', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _SuccessView extends StatefulWidget {
  final Order order;
  const _SuccessView({super.key, required this.order});

  @override
  State<_SuccessView> createState() => _SuccessViewState();
}

class _SuccessViewState extends State<_SuccessView> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _checkProgress;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.15), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.15, end: 1.0), weight: 40),
    ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _checkProgress = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) => Transform.scale(scale: _scale.value, child: child),
          child: Container(
            width: 110,
            height: 110,
            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
            child: AnimatedBuilder(
              animation: _checkProgress,
              builder: (context, _) => CustomPaint(painter: _CheckPainter(progress: _checkProgress.value)),
            ),
          ),
        ),
        const SizedBox(height: 28),
        Text(
          'Order Completed!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.darkText : AppColors.text,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Thanks for shopping with us — order #${widget.order.displayId} is all done.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          height: 54,
          child: OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary, width: 1.5),
              shape: const StadiumBorder(),
            ),
            child: const Text('Back to Orders', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }
}

class _CheckPainter extends CustomPainter {
  final double progress;
  _CheckPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.white
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final p1 = Offset(size.width * 0.28, size.height * 0.52);
    final p2 = Offset(size.width * 0.44, size.height * 0.68);
    final p3 = Offset(size.width * 0.74, size.height * 0.34);

    final path = Path()..moveTo(p1.dx, p1.dy);

    if (progress <= 0.5) {
      final t = (progress / 0.5).clamp(0.0, 1.0);
      path.lineTo(p1.dx + (p2.dx - p1.dx) * t, p1.dy + (p2.dy - p1.dy) * t);
    } else {
      path.lineTo(p2.dx, p2.dy);
      final t = ((progress - 0.5) / 0.5).clamp(0.0, 1.0);
      path.lineTo(p2.dx + (p3.dx - p2.dx) * t, p2.dy + (p3.dy - p2.dy) * t);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _CheckPainter oldDelegate) => oldDelegate.progress != progress;
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  const _ErrorView({super.key, required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.error_outline_rounded, size: 40, color: AppColors.error),
        ),
        const SizedBox(height: 20),
        const Text('Couldn\'t confirm your order', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 13, color: AppColors.grey500)),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onRetry,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.white,
              shape: const StadiumBorder(),
            ),
            child: const Text('Try Again'),
          ),
        ),
      ],
    );
  }
}
