import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/features/auth/provider/auth_provider.dart' show tokenProvider;
import '../repositories/checkout_repository.dart';

enum CheckoutStep { form, processing, payment, success, error }

class CheckoutState {
  final CheckoutStep step;
  final Map<String, dynamic>? orderData;
  final Map<String, dynamic>? paymentData;
  final String? error;

  const CheckoutState({
    this.step = CheckoutStep.form,
    this.orderData,
    this.paymentData,
    this.error,
  });

  CheckoutState copyWith({
    CheckoutStep? step,
    Map<String, dynamic>? orderData,
    Map<String, dynamic>? paymentData,
    String? error,
  }) {
    return CheckoutState(
      step: step ?? this.step,
      orderData: orderData ?? this.orderData,
      paymentData: paymentData ?? this.paymentData,
      error: error ?? this.error,
    );
  }
}

final checkoutRepositoryProvider = Provider<CheckoutRepository>((ref) => CheckoutRepository());

final checkoutStateProvider = NotifierProvider<CheckoutNotifier, CheckoutState>(
  CheckoutNotifier.new,
);

class CheckoutNotifier extends Notifier<CheckoutState> {
  @override
  CheckoutState build() => const CheckoutState();

  void setProcessing() {
    state = state.copyWith(step: CheckoutStep.processing, error: null);
  }

  Future<void> placeOrder({
    required List<Map<String, dynamic>> items,
    required String street,
    required String city,
    required String stateName,
    required List<double> coordinates,
    required String paymentMethod,
    String? notes,
    String? selectedVehicleType,
  }) async {
    state = state.copyWith(step: CheckoutStep.processing, error: null);
    try {
      final activeToken = ref.read(tokenProvider);
      debugPrint('[ApiClientDebug] Real-time Token check: ${activeToken != null ? 'Token found (starts with: ${activeToken.substring(0, 8)})' : 'CRITICAL: TOKEN IS NULL'}');
      final repo = ref.read(checkoutRepositoryProvider);
      final order = await repo.createOrder(
        items: items,
        street: street,
        city: city,
        state: stateName,
        coordinates: coordinates,
        paymentMethod: paymentMethod,
        notes: notes,
        selectedVehicleType: selectedVehicleType,
        token: activeToken,
      );
      state = state.copyWith(step: CheckoutStep.payment, orderData: order);
    } catch (e) {
      state = state.copyWith(step: CheckoutStep.error, error: e.toString());
    }
  }

  Future<void> initiateCardPayment() async {
    final orderId = state.orderData?['_id'] as String?;
    if (orderId == null) return;
    try {
      final repo = ref.read(checkoutRepositoryProvider);
      final payment = await repo.initiateCardPayment(orderId);
      state = state.copyWith(paymentData: payment);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> assignVirtualAccount() async {
    final orderId = state.orderData?['_id'] as String?;
    if (orderId == null) return;
    try {
      final repo = ref.read(checkoutRepositoryProvider);
      final dva = await repo.assignVirtualAccount(orderId);
      state = state.copyWith(paymentData: dva);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void markSuccess() {
    state = state.copyWith(step: CheckoutStep.success);
  }

  void reset() {
    state = const CheckoutState();
  }
}
