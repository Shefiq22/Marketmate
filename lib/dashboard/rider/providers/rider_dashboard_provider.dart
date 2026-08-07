import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/mock_rider_deliveries.dart';
import '../models/rider_delivery_model.dart';
import '../repositories/rider_repository.dart';

final riderRepositoryProvider = Provider<RiderRepository>((ref) => RiderRepository());

final riderSimulateProvider = StateProvider<bool>((ref) => false);

/// Drives the rider main screen's bottom-navigation tab. Lets any page inside
/// the IndexedStack (e.g. "Back to home" in the sign-out dialog) switch tabs.
final riderMainTabProvider = StateProvider<int>((ref) => 0);

final riderDeliveriesProvider = Provider<List<RiderDeliveryModel>>((ref) {
  return ref.watch(riderSimulateProvider) ? mockRiderDeliveries : [];
});

/// Holds the live API-backed active order + pending assignments.
class RiderLiveData {
  final List<RiderDeliveryModel> active;
  final List<RiderDeliveryModel> pending;
  final bool isLoading;
  final String? error;

  const RiderLiveData({
    this.active = const [],
    this.pending = const [],
    this.isLoading = false,
    this.error,
  });

  RiderLiveData copyWith({
    List<RiderDeliveryModel>? active,
    List<RiderDeliveryModel>? pending,
    bool? isLoading,
    String? error,
  }) {
    return RiderLiveData(
      active: active ?? this.active,
      pending: pending ?? this.pending,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class RiderLiveDataNotifier extends StateNotifier<RiderLiveData> {
  final RiderRepository _repo;
  RiderLiveDataNotifier(this._repo) : super(const RiderLiveData()) {
    refresh();
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final activeOrder = await _repo.getActiveOrder();
      final pending = await _repo.getPendingAssignments();
      state = RiderLiveData(
        active: activeOrder == null ? const [] : [activeOrder],
        pending: pending,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Refreshes just the active order — call after the rider accepts a new
  /// assignment so the "Current Delivery" card updates immediately.
  Future<void> refreshActive() async {
    try {
      final activeOrder = await _repo.getActiveOrder();
      state = state.copyWith(
        active: activeOrder == null ? const [] : [activeOrder],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }
}

final riderLiveDataProvider =
    StateNotifierProvider<RiderLiveDataNotifier, RiderLiveData>((ref) {
  return RiderLiveDataNotifier(ref.read(riderRepositoryProvider));
});

final riderActiveProvider = Provider<List<RiderDeliveryModel>>(
  (ref) => ref.watch(riderLiveDataProvider).active,
);

final riderPendingProvider = Provider<List<RiderDeliveryModel>>(
  (ref) => ref.watch(riderLiveDataProvider).pending,
);

final riderCompletedProvider = Provider<List<RiderDeliveryModel>>(
  (ref) => ref
      .watch(riderDeliveriesProvider)
      .where((d) => d.status == RiderDeliveryStatus.completed)
      .toList(),
);

final riderHistoryProvider = Provider<List<RiderDeliveryModel>>(
  (ref) => ref.watch(riderDeliveriesProvider),
);

final bankAccountsProvider = StateProvider<List<Map<String, String>>>(
  (ref) => mockBankAccounts.map((e) => Map<String, String>.from(e)).toList(),
);

final defaultBankIndexProvider = StateProvider<int>((ref) => 0);

final riderApiOrdersProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final repo = ref.read(riderRepositoryProvider);
  return repo.getMyOrders();
});

// ─────────────── Online status ───────────────

/// Persists rider flags across app launches so the UI restores the correct
/// state on relaunch, before the next server sync.
class RiderPersistence {
  static const _onlineKey = 'rider_online';

  Future<bool> loadOnline() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onlineKey) ?? false;
    } catch (_) {
      return false;
    }
  }

  Future<void> saveOnline(bool online) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onlineKey, online);
    } catch (_) {}
  }
}

final riderPersistenceProvider = Provider<RiderPersistence>((ref) => RiderPersistence());

/// Toggles the rider's availability end-to-end: updates the server status,
/// persists it locally, and starts/stops live location tracking.
class RiderOnlineToggleNotifier extends StateNotifier<bool> {
  final Ref _ref;
  bool _busy = false;

  RiderOnlineToggleNotifier(this._ref) : super(false);

  bool get isBusy => _busy;

  /// Restores the persisted status on relaunch without hitting the server or
  /// touching location tracking.
  void restore(bool online) {
    state = online;
  }

  Future<void> toggle(bool online) async {
    if (_busy) return;
    _busy = true;
    try {
      final repo = _ref.read(riderRepositoryProvider);
      await repo.updateOnlineStatus(online);
      await _ref.read(riderPersistenceProvider).saveOnline(online);
      state = online;
      final location = _ref.read(riderLocationProvider.notifier);
      if (online) {
        await location.startTracking();
      } else {
        location.stopTracking();
      }
    } finally {
      _busy = false;
    }
  }
}

final riderOnlineProvider =
    StateNotifierProvider<RiderOnlineToggleNotifier, bool>((ref) {
  return RiderOnlineToggleNotifier(ref);
});

// ─────────────── Live location tracking ───────────────

/// Live rider location state — drives both the map marker/camera and the
/// location endpoint.
class RiderLocationState {
  final LatLng? position;
  final bool isTracking;
  final bool permissionDenied;
  final bool serviceDisabled;
  final bool isLoading;

  const RiderLocationState({
    this.position,
    this.isTracking = false,
    this.permissionDenied = false,
    this.serviceDisabled = false,
    this.isLoading = false,
  });

  RiderLocationState copyWith({
    LatLng? position,
    bool? isTracking,
    bool? permissionDenied,
    bool? serviceDisabled,
    bool? isLoading,
  }) {
    return RiderLocationState(
      position: position ?? this.position,
      isTracking: isTracking ?? this.isTracking,
      permissionDenied: permissionDenied ?? this.permissionDenied,
      serviceDisabled: serviceDisabled ?? this.serviceDisabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Reads the rider's live position on a fixed cadence (10s) and publishes it
/// to both the map stream and PATCH /riders/location. A single failed ping is
/// non-critical — the next tick retries silently.
class RiderLocationService {
  final RiderRepository _repo;
  Timer? _timer;
  bool _tracking = false;
  bool _serviceDisabled = false;
  LatLng? _lastPosition;
  final _controller = StreamController<LatLng>.broadcast();

  /// Fired when the platform reports location services (GPS) are disabled.
  VoidCallback? onServiceDisabled;

  RiderLocationService(this._repo);

  Stream<LatLng> get positionStream => _controller.stream;
  LatLng? get lastPosition => _lastPosition;
  bool get isTracking => _tracking;
  bool get serviceDisabled => _serviceDisabled;

  Future<bool> start({Duration interval = const Duration(seconds: 10)}) async {
    if (_tracking) return true;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    _tracking = true;
    _serviceDisabled = false;
    await _ping();
    _timer = Timer.periodic(interval, (_) => _ping());
    return true;
  }

  void stop() {
    _tracking = false;
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _ping() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _serviceDisabled = false;
      _lastPosition = LatLng(position.latitude, position.longitude);
      if (!_controller.isClosed) {
        _controller.add(_lastPosition!);
      }
      await _repo.updateLocation(
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } on LocationServiceDisabledException {
      _serviceDisabled = true;
      onServiceDisabled?.call();
    } catch (e) {
      debugPrint('[RiderLocation] ping failed: $e');
    }
  }

  void dispose() {
    stop();
    _controller.close();
  }
}

class RiderLocationNotifier extends StateNotifier<RiderLocationState> {
  final RiderLocationService _service;
  StreamSubscription<LatLng>? _sub;
  bool _disposed = false;

  RiderLocationNotifier(this._service) : super(const RiderLocationState()) {
    _service.onServiceDisabled = () {
      if (_disposed) return;
      state = state.copyWith(serviceDisabled: true);
    };
    _sub = _service.positionStream.listen((pos) {
      if (_disposed) return;
      state = state.copyWith(
        position: pos,
        isTracking: true,
        permissionDenied: false,
        serviceDisabled: false,
      );
    });
  }

  Future<void> startTracking() async {
    state = state.copyWith(isLoading: true, permissionDenied: false);
    final started = await _service.start();
    if (_disposed) return;
    state = state.copyWith(
      isTracking: started,
      isLoading: false,
      permissionDenied: !started,
    );
  }

  void stopTracking() {
    _service.stop();
    if (_disposed) return;
    state = state.copyWith(isTracking: false);
  }

  Future<void> retry() => startTracking();

  @override
  void dispose() {
    _disposed = true;
    _sub?.cancel();
    _service.dispose();
    super.dispose();
  }
}

final riderLocationProvider =
    StateNotifierProvider<RiderLocationNotifier, RiderLocationState>((ref) {
  return RiderLocationNotifier(RiderLocationService(ref.read(riderRepositoryProvider)));
});
