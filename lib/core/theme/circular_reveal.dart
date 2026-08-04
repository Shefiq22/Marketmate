import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/providers/theme_provider.dart';
import 'package:market_mate/core/theme/app_colors.dart';

class _RevealClipper extends CustomClipper<Path> {
  _RevealClipper({required this.origin, required this.progress});
  final Offset origin;
  final double progress;

  @override
  Path getClip(Size size) {
    final radius = _diagonalRadius(size, origin) * progress;
    return Path()..addOval(Rect.fromCircle(center: origin, radius: radius));
  }

  @override
  bool shouldReclip(_RevealClipper old) =>
      old.progress != progress || old.origin != origin;
}

double _diagonalRadius(Size size, Offset origin) {
  final dx = math.max(origin.dx, size.width - origin.dx);
  final dy = math.max(origin.dy, size.height - origin.dy);
  return math.sqrt(dx * dx + dy * dy);
}

class _RevealOverlay extends ConsumerStatefulWidget {
  const _RevealOverlay({required this.wasDark, required this.origin});

  final bool wasDark;
  final Offset origin;

  @override
  ConsumerState<_RevealOverlay> createState() => _RevealOverlayState();
}

class _RevealOverlayState extends ConsumerState<_RevealOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    duration: const Duration(milliseconds: 700),
    vsync: this,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) ref.read(themeModeProvider.notifier).toggle();
    });
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        Navigator.of(context).pop();
      }
    });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, animation) {
        return ClipPath(
          clipper: _RevealClipper(
            origin: widget.origin,
            progress: _ctrl.value,
          ),
          child: Container(
            width: size.width,
            height: size.height,
            color: widget.wasDark
                ? AppColors.scaffoldLight
                : AppColors.scaffoldDark,
          ),
        );
      },
    );
  }
}

class CircularRevealRoute extends PageRouteBuilder<void> {
  CircularRevealRoute({
    required bool wasDark,
    required Offset origin,
  }) : super(
          transitionDuration: const Duration(milliseconds: 700),
          reverseTransitionDuration: const Duration(milliseconds: 500),
          opaque: false,
          pageBuilder: (context, _, _) =>
              _RevealOverlay(wasDark: wasDark, origin: origin),
        );
}
