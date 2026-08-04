import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'rider_dashboard_provider.dart';

class RiderOnlineState {
  final bool isOnline;
  final bool isLoading;
  final String? error;

  const RiderOnlineState({
    this.isOnline = false,
    this.isLoading = false,
    this.error,
  });

  RiderOnlineState copyWith({bool? isOnline, bool? isLoading, String? error}) {
    return RiderOnlineState(
      isOnline: isOnline ?? this.isOnline,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

final riderOnlineStatusProvider = NotifierProvider<RiderOnlineNotifier, RiderOnlineState>(
  RiderOnlineNotifier.new,
);

class RiderOnlineNotifier extends Notifier<RiderOnlineState> {
  @override
  RiderOnlineState build() => const RiderOnlineState();

  Future<void> toggle(bool online) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = ref.read(riderRepositoryProvider);
      await repo.updateOnlineStatus(online);
      state = state.copyWith(isOnline: online, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}
