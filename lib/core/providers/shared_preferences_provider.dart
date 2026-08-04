import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Must be overridden in [ProviderScope] after calling
/// [SharedPreferences.getInstance()] in `main()`.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in ProviderScope. '
    'Call SharedPreferences.getInstance() in main() and pass via override.',
  );
});
