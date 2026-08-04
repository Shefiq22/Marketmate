import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/theme/app_colors.dart';

class OnboardingSlidePage extends StatefulWidget {
  final String backgroundImage;
  final String title;
  final VoidCallback onSkip;
  final VoidCallback onStart;
  final bool showSkip;
  final int slideIndex;
  final String buttonLabel;

  const OnboardingSlidePage({
    super.key,
    required this.backgroundImage,
    required this.title,
    required this.onSkip,
    required this.onStart,
    required this.showSkip,
    required this.slideIndex,
    this.buttonLabel = 'Start',
  });

  @override
  State<OnboardingSlidePage> createState() => _OnboardingSlidePageState();
}

class _OnboardingSlidePageState extends State<OnboardingSlidePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _bgFade;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _titleSlide;
  late final Animation<Offset> _bottomSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _bgFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    );

    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.2, 0.9, curve: Curves.easeOut),
    );

    _titleSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _bottomSlide = Tween<Offset>(begin: const Offset(0, 1.0), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _controller,
            curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
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
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;

    final logoSize = isTablet ? 62.0 : 46.0;
    final titleSize = isTablet ? 60.0 : 52.0;
    final horizontalPad = isTablet ? size.width * 0.08 : 24.0;
    final topPad = padding.top + 16.0;
    final bottomSafe = padding.bottom == 0 ? 24.0 : padding.bottom;
    final bottomBarHeight = isTablet ? 60.0 : 48.0;
    final textBottomOffset = bottomSafe + bottomBarHeight + 60.0;

    return Stack(
      fit: StackFit.expand,
      children: [
        FadeTransition(
          opacity: _bgFade,
          child: Image.asset(widget.backgroundImage, fit: BoxFit.cover),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withAlpha((0.1 * 255).round()),
                Colors.black.withAlpha((0.8 * 255).round()),
              ],
              stops: const [0.25, 1.0],
            ),
          ),
        ),
        Positioned(
          top: topPad,
          left: horizontalPad,
          child: FadeTransition(
            opacity: _contentFade,
            child: Image.asset(
              'assets/images/mm_mmicon.png',
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          left: horizontalPad,
          right: horizontalPad,
          bottom: textBottomOffset,
          child: FadeTransition(
            opacity: _contentFade,
            child: SlideTransition(
              position: _titleSlide,
              child: Text(
                widget.title,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: titleSize,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  height: 1.25,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: horizontalPad,
          right: horizontalPad,
          bottom: bottomSafe + 12.0,
          child: SlideTransition(
            position: _bottomSlide,
            child: FadeTransition(
              opacity: _contentFade,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (widget.showSkip)
                    GestureDetector(
                      onTap: widget.onSkip,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 12,
                        ),
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 23.0 : 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 48),
                  AnimatedSmoothIndicator(
                    activeIndex: widget.slideIndex,
                    count: 2,
                    effect: WormEffect(
                      activeDotColor: AppColors.primary,
                      dotColor: Colors.white.withAlpha((0.4 * 255).round()),
                      dotHeight: isTablet ? 35.0 : 23.0,
                      dotWidth: isTablet ? 35.0 : 23.0,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: widget.onStart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: Size(
                        isTablet ? 130.0 : 110.0,
                        bottomBarHeight,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: isTablet ? 40.0 : 32.0,
                      ),
                      shape: const StadiumBorder(),
                      elevation: 0,
                      textStyle: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 17.0 : 15.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    child: Text(
                      widget.buttonLabel,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
