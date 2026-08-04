import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:market_mate/core/widgets/sandy_loader.dart';
import '../../features/onboarding/presentation/pages/onboarding_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/questionnaire_screen.dart';
import '../../dashboard/presentation/pages/dashboard_router.dart';
import '../providers/auth_state_provider.dart';

class RootNavigator extends StatefulWidget {
  const RootNavigator({super.key});

  @override
  State<RootNavigator> createState() => _RootNavigatorState();
}

class _RootNavigatorState extends State<RootNavigator> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthStateProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStateProvider>();
    switch (auth.status) {
      case AuthStatus.loading:
        return const SandyFullScreenLoader();
      case AuthStatus.onboarding:
        return const OnboardingScreen();
      case AuthStatus.unauthenticated:
        return const LoginPage();
      case AuthStatus.authenticated:
        return const DashboardRouter();
      case AuthStatus.pendingVerification:
        return const QuestionnaireScreen();
    }
  }
}
