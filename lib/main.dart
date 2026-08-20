import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/network/api_client.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/shared_preferences_provider.dart';
import 'core/utils/prefs_cache.dart';
import 'core/utils/fallback_localization_delegate.dart';
import 'core/widgets/marketmate_splash_screen.dart';
import 'dashboard/buyer/data/cart_provider.dart';
import 'dashboard/buyer/theme/app_theme.dart' as buyer;
import 'dashboard/presentation/pages/dashboard_router.dart';
import 'features/auth/presentation/pages/login_page.dart';
import 'features/auth/presentation/pages/questionnaire_screen.dart';
import 'features/auth/provider/auth_provider.dart';
import 'features/auth/provider/auth_state.dart';
import 'features/onboarding/presentation/pages/onboarding_screen.dart';
import 'l10n/app_localizations.dart' as loc;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase (required for Firebase Auth and Cloud Messaging).
  await Firebase.initializeApp();

  // Transparent status bar so backgrounds bleed edge-to-edge
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
    ),
  );

  // Load SharedPreferences once and ensure caches are ready before mount
  final prefs = await SharedPreferences.getInstance();
  await PrefsCache().init();
  await ApiClient().init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const MarketMateApp(),
    ),
  );
}

class MarketMateApp extends ConsumerWidget {
  const MarketMateApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);

    final effectiveBrightness = themeMode == ThemeMode.system
        ? WidgetsBinding.instance.platformDispatcher.platformBrightness
        : themeMode == ThemeMode.dark
        ? Brightness.dark
        : Brightness.light;
    AppColors.setBrightness(effectiveBrightness);
    buyer.AppColors.setBrightness(effectiveBrightness);

    return ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MaterialApp(
        title: 'MarketMate',
        debugShowCheckedModeBanner: false,
        locale: locale,
        supportedLocales: const [
          Locale('en'),
          Locale('ha'),
          Locale('ig'),
          Locale('yo'),
          Locale('pcm'),
        ],
        localizationsDelegates: [
          loc.AppLocalizations.delegate,
          const FallbackMaterialLocalizationDelegate(),
          const FallbackCupertinoLocalizationDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeMode,
        builder: (context, child) => HeroMode(enabled: false, child: child!),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key}); 

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    return authState.when(
      data: (state) => switch (state) {
        AuthOnboarding() => const OnboardingScreen(),
        AuthUnauthenticated() => const LoginPage(),
        AuthPendingVerification() => const QuestionnaireScreen(),
        AuthBuyer() => const DashboardRouter(),
        AuthSeller() => const DashboardRouter(),
        AuthRider() => const DashboardRouter(),
      },
      loading: () => const MarketmateSplashScreen(),
      error: (_, __) => const LoginPage(),
    );
  }
}
