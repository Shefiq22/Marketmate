import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/widgets/sandy_loader.dart';
import 'package:market_mate/dashboard/presentation/pages/dashboard_router.dart';
import 'package:market_mate/features/auth/provider/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';

class RegistrationSuccessPage extends ConsumerStatefulWidget {
  const RegistrationSuccessPage({super.key});

  @override
  ConsumerState<RegistrationSuccessPage> createState() =>
      _RegistrationSuccessPageState();
}

class _RegistrationSuccessPageState
    extends ConsumerState<RegistrationSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  late final Animation<double> _confettiFade;
  late final Animation<double> _confettiScale;
  late final Animation<double> _checkFade;
  late final Animation<double> _checkScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _confettiFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
    );
    _confettiScale = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutBack),
      ),
    );
    _checkFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.25, 0.6, curve: Curves.easeOut),
    );
    _checkScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.25, 0.75, curve: Curves.easeOutBack),
      ),
    );
    _contentFade = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
    );
    _contentSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _proceed() async {
    setState(() => _loading = true);
    _ctrl.stop();
    await Future.delayed(const Duration(milliseconds: 50));
    if (!mounted) return;

    final selected = ref.read(selectedRoleProvider);
    ref.read(activeRoleProvider.notifier).state =
        selected ?? UserRole.retailerOrConsumer;

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardRouter()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final confettiSize = isTablet ? size.width * 0.55 : size.width * 0.72;

    return Stack(
      children: [
        Scaffold(
          backgroundColor: isDark
              ? AppColors.scaffoldDark
              : AppColors.scaffoldLight,
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? size.width * 0.12 : 32.0,
              ),
              child: Column(
                children: [
                  SizedBox(height: size.height * 0.1),
                  FadeTransition(
                    opacity: _confettiFade,
                    child: ScaleTransition(
                      scale: _confettiScale,
                      child: Image.asset(
                        'assets/images/congrats.png',
                        width: confettiSize,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) =>
                            SizedBox(height: confettiSize * 0.55),
                      ),
                    ),
                  ),
                  FadeTransition(
                    opacity: _checkFade,
                    child: ScaleTransition(
                      scale: _checkScale,
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                        size: isTablet ? 120.0 : 102.0,
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),
                  FadeTransition(
                    opacity: _contentFade,
                    child: SlideTransition(
                      position: _contentSlide,
                      child: Column(
                        children: [
                          Text(
                            'Account created\nsuccessfully!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: isTablet ? 30.0 : 24.0,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.black,
                              letterSpacing: -0.4,
                              height: 1.3,
                            ),
                          ),
                          SizedBox(height: size.height * 0.018),
                          Text(
                            'Your account has been created, you can\nnow proceed to the home page.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: isTablet ? 20.0 : 17.0,
                              fontWeight: FontWeight.w400,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.textSecondary,
                              height: 1.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  FadeTransition(
                    opacity: _contentFade,
                    child: SizedBox(
                      width: double.infinity,
                      height: isTablet ? 64 : 56,
                      child: ElevatedButton(
                        onPressed: _proceed,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: const StadiumBorder(),
                          elevation: 0,
                          textStyle: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 18 : 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Proceed to Home'),
                      ),
                    ),
                  ),
                  SizedBox(height: padding.bottom + 28),
                ],
              ),
            ),
          ),
        ),
        if (_loading) const SandyFullScreenLoader(),
      ],
    );
  }
}
