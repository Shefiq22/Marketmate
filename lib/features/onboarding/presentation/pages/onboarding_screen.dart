import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/features/auth/presentation/pages/questionnaire_screen.dart';
import 'package:market_mate/features/onboarding/providers/onboarding_provider.dart';
import '../widgets/onboarding_intro_page.dart';
import '../widgets/onboarding_slide_page.dart';


class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_syncPage);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.transparent,
      ),
    );
  }

  void _syncPage() {
    final page = _pageController.page?.round() ?? 0;
    if (ref.read(onboardingPageProvider) != page) {
      ref.read(onboardingPageProvider.notifier).state = page;
    }
  }

  @override
  void dispose() {
    _pageController.removeListener(_syncPage);
    _pageController.dispose();
    super.dispose();
  }

  void _onComplete() {
    ref.read(onboardingSeenProvider.notifier).markSeen();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QuestionnaireScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: _pageController,
        children: [
          OnboardingIntroPage(
            onGetStarted: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            ),
          ),
          OnboardingSlidePage(
            backgroundImage: 'assets/images/onboarding_bg_2.png',
            title: 'Browse through\nour variety of fresh\nproducts',
            onSkip: _onComplete,
            onStart: () => _pageController.nextPage(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
            ),
            showSkip: true,
            slideIndex: 0,
            buttonLabel: 'Next',
          ),
          OnboardingSlidePage(
            backgroundImage: 'assets/images/onboarding_bg_3.png',
            title: 'Shop top quality\nat unbeatable\nprices',
            onSkip: _onComplete,
            onStart: _onComplete,
            showSkip: false,
            slideIndex: 1,
            buttonLabel: 'Start',
          ),
        ],
      ),
    );
  }
}