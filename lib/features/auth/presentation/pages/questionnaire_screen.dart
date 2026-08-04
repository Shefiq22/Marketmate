import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/features/auth/provider/auth_provider.dart';
import 'package:market_mate/features/auth/provider/rider_documents_provider.dart';
import 'package:market_mate/features/auth/provider/seller_onboarding_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/auth_progress_bar.dart';
import 'register_page.dart';
import 'registration_success_page.dart';
import 'rider_documents_page.dart';
import 'role_selection_page.dart';
import 'seller_onboarding_page.dart';
import 'verify_email_page.dart';

class QuestionnaireScreen extends ConsumerStatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  ConsumerState<QuestionnaireScreen> createState() =>
      _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends ConsumerState<QuestionnaireScreen> {
  final _pageController = PageController();
  int _currentStep = 1;

  double _dragStartX = 0;

  bool get _isRider =>
      ref.read(selectedRoleProvider) == UserRole.rider;

  bool get _isSeller =>
      ref.read(selectedRoleProvider) == UserRole.farmerOrWholesaler;

  int get _totalSteps {
    if (_isRider) return 4;
    if (_isSeller) return 4;
    return 3;
  }

  int get _totalDisplaySteps {
    if (_isSeller) return 6;
    return _totalSteps;
  }

  int get _currentDisplayStep {
    if (_isSeller && _currentStep == 4) {
      final subStep = ref.read(sellerOnboardingFormProvider).internalStep;
      return 4 + subStep;
    }
    return _currentStep;
  }

  String _sectionLabel(int step) {
    if (_isSeller && step == 4) {
      final subStep = ref.read(sellerOnboardingFormProvider).internalStep;
      return ['Store Info', 'Categories', 'Verification'][subStep];
    }
    if (_isRider) {
      return ['Choose role', 'Personal info', 'Verify email', 'Upload documents']
          [step - 1];
    }
    return ['Choose role', 'Personal info', 'Verify email'][step - 1];
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        SystemChrome.setSystemUIOverlayStyle(
          SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goTo(int step) {
    if (step == 4 && _isSeller) {
      ref.read(sellerOnboardingFormProvider.notifier).reset();
    }
    if (step == 4 && _isRider) {
      ref.read(riderDocumentsProvider.notifier).reset();
    }
    setState(() => _currentStep = step);
    _pageController.animateToPage(
      step - 1,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  bool _canAdvance() {
    switch (_currentStep) {
      case 1:
        return ref.read(selectedRoleProvider) != null;
      case 2:
        final form = ref.read(registerFormProvider);
        return form.name.trim().isNotEmpty &&
            form.phone.trim().isNotEmpty &&
            form.email.trim().isNotEmpty &&
            form.password.trim().isNotEmpty;
      case 3:
        return true;
      case 4:
        if (_isRider) {
          return ref.read(riderDocumentsProvider.notifier).allUploaded;
        }
        if (_isSeller) {
          final form = ref.read(sellerOnboardingFormProvider);
          return form.isComplete;
        }
        return true;
      default:
        return true;
    }
  }

  void _next() {
    if (_currentStep < _totalSteps && _canAdvance()) _goTo(_currentStep + 1);
  }

  void _back() {
    if (_currentStep > 1) {
      _goTo(_currentStep - 1);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  void _onHorizontalDragStart(DragStartDetails d) {
    _dragStartX = d.globalPosition.dx;
  }

  void _onHorizontalDragEnd(DragEndDetails d) {
    final dx = d.globalPosition.dx - _dragStartX;
    const threshold = 60.0;
    if (dx < -threshold) {
      if (_canAdvance()) _next();
    } else if (dx > threshold) {
      _back();
    }
  }

  List<Widget> get _pages {
    final userId = ref.read(registerFormProvider).userId;
    final verifyPage = userId != null
        ? VerifyEmailPage(
            userId: userId,
            onBack: _back,
          )
        : const SizedBox();

    if (_isRider) {
      return [
        RoleSelectionPage(onNext: _next, onBack: _back),
        RegisterPage(onNext: _next, onBack: _back),
        VerifyEmailPage(
          userId: userId ?? '',
          onBack: _back,
          onVerified: _next,
        ),
        RiderDocumentsPage(
          onNext: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const RegistrationSuccessPage(),
            ),
            (route) => false,
          ),
          onBack: _back,
        ),
      ];
    }

    if (_isSeller) {
      return [
        RoleSelectionPage(onNext: _next, onBack: _back),
        RegisterPage(onNext: _next, onBack: _back),
        VerifyEmailPage(
          userId: userId ?? '',
          onBack: _back,
          onVerified: _next,
        ),
        SellerOnboardingPage(
          onNext: () => Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (_) => const RegistrationSuccessPage(),
            ),
            (route) => false,
          ),
          onBack: _back,
        ),
      ];
    }

    return [
      RoleSelectionPage(onNext: _next, onBack: _back),
      RegisterPage(onNext: _next, onBack: _back),
      verifyPage,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = isTablet ? size.width * 0.1 : size.width * 0.055;

    ref.watch(selectedRoleProvider);
    ref.watch(sellerOnboardingFormProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      body: GestureDetector(
        onHorizontalDragStart: _onHorizontalDragStart,
        onHorizontalDragEnd: _onHorizontalDragEnd,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(hPad, padding.top + size.height * 0.015, hPad, size.height * 0.015),
                    child: AuthProgressBar(
                      currentStep: _currentDisplayStep,
                      totalSteps: _totalDisplaySteps,
                      sectionLabel: _sectionLabel(_currentStep),
                      onBack: _back,
                    ),
                  ),
                  Expanded(
                    child: PageView(
                      controller: _pageController,
                      physics: const NeverScrollableScrollPhysics(),
                      children: _pages,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}