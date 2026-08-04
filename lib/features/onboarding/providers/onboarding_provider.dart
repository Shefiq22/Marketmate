import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:market_mate/core/utils/prefs_cache.dart';

final onboardingPageProvider = StateProvider<int>((ref) => 0);

class OnboardingSeenNotifier extends AsyncNotifier<bool> {
  static const _key = 'onboarding_seen';

  @override
  Future<bool> build() async {
    return PrefsCache().getBool(_key) ?? false;
  }

  Future<void> markSeen() async {
    await PrefsCache().setBool(_key, true);
    state = const AsyncData(true);
  }
}

final onboardingSeenProvider =
    AsyncNotifierProvider<OnboardingSeenNotifier, bool>(
  OnboardingSeenNotifier.new,
);
