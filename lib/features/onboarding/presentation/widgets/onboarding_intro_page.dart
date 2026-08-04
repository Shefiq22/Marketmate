import 'package:flutter/material.dart';

class OnboardingIntroPage extends StatefulWidget {
  final VoidCallback onGetStarted;

  const OnboardingIntroPage({super.key, required this.onGetStarted});

  @override
  State<OnboardingIntroPage> createState() => _OnboardingIntroPageState();
}

class _OnboardingIntroPageState extends State<OnboardingIntroPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slideContent;
  late final Animation<Offset> _slideButton;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    _slideContent = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _slideButton = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.4, 1.0, curve: Curves.easeOutCubic),
          ),
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
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final logoSize = isTablet ? 204.0 : 176.0;
    final titleSize = isTablet ? 40.0 : 32.0;
    final subtitleSize = isTablet ? 34.0 : 28.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.asset('assets/images/onboarding_bg_1.png', fit: BoxFit.cover),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withAlpha((0.45 * 255).round()),
                Colors.black.withAlpha((0.75 * 255).round()),
              ],
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? size.width * 0.15 : 32.0,
            ),
            child: FadeTransition(
              opacity: _fade,
              child: SlideTransition(
                position: _slideContent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      'assets/images/mm_mmicon.png',
                      width: logoSize,
                      height: logoSize,
                      fit: BoxFit.contain,
                    ),
                    Text(
                      'Market for all your',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Text(
                      'Fresh products',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: subtitleSize,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        letterSpacing: -2.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: MediaQuery.paddingOf(context).bottom + 24.0,
          right: isTablet ? size.width * 0.08 : 28.0,
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slideButton,
              child: GestureDetector(
                onTap: widget.onGetStarted,
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Get started',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: isTablet ? 27.0 : 25.0,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
