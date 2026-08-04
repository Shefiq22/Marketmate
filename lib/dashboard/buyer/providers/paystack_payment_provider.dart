import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/core/utils/prefs_cache.dart';
import '../repositories/checkout_repository.dart';

enum PaystackStep {
  idle,
  placingOrder,
  processingInWebView,
  verifyingStatus,
  paymentSuccess,
  paymentFailed,
}

class PaystackPaymentState {
  final PaystackStep step;
  final String? orderId;
  final String? orderNumber;
  final String? accessCode;
  final String? error;
  final bool showManualCheck;
  final bool webViewHidden;

  const PaystackPaymentState({
    this.step = PaystackStep.idle,
    this.orderId,
    this.orderNumber,
    this.accessCode,
    this.error,
    this.showManualCheck = false,
    this.webViewHidden = false,
  });

  PaystackPaymentState copyWith({
    PaystackStep? step,
    String? orderId,
    String? orderNumber,
    String? accessCode,
    String? error,
    bool? showManualCheck,
    bool? webViewHidden,
  }) {
    return PaystackPaymentState(
      step: step ?? this.step,
      orderId: orderId ?? this.orderId,
      orderNumber: orderNumber ?? this.orderNumber,
      accessCode: accessCode ?? this.accessCode,
      error: error ?? this.error,
      showManualCheck: showManualCheck ?? this.showManualCheck,
      webViewHidden: webViewHidden ?? this.webViewHidden,
    );
  }
}

final paystackPaymentProvider =
    NotifierProvider<PaystackPaymentNotifier, PaystackPaymentState>(
  PaystackPaymentNotifier.new,
);

class PaystackPaymentNotifier extends Notifier<PaystackPaymentState> {
  Timer? _pollTimer;
  final CheckoutRepository _repo = CheckoutRepository();

  @override
  PaystackPaymentState build() {
    ref.onDispose(() => _pollTimer?.cancel());
    return const PaystackPaymentState();
  }

  Future<void> placeAndInitiateOrder({
    required List<Map<String, dynamic>> items,
    required String street,
    required String city,
    required String stateName,
    required List<double> coordinates,
    required String paymentMethod,
    String? notes,
  }) async {
    state = state.copyWith(step: PaystackStep.placingOrder, error: null);
    try {
      // Read from the singleton directly (no Riverpod cache staleness)
      var activeToken = ApiClient().accessToken;
      if (activeToken == null || activeToken.isEmpty) {
        activeToken = PrefsCache().getString('auth_token') ?? PrefsCache().getString('access_token');
        if (activeToken != null && activeToken.isNotEmpty) {
          ApiClient().setAccessToken(activeToken);
        }
      }
      debugPrint('[ApiClientDebug] Real-time Token check: ${activeToken != null && activeToken.isNotEmpty ? 'Token found (starts with: ${activeToken.substring(0, 8)})' : 'CRITICAL: TOKEN IS NULL'}');
      debugPrint('[PaystackPayment] Creating order with paymentMethod: $paymentMethod');
      final order = await _repo.createOrder(
        items: items,
        street: street,
        city: city,
        state: stateName,
        coordinates: coordinates,
        paymentMethod: paymentMethod,
        notes: notes,
        token: activeToken,
      );
      final orderId = order['_id'] as String?;
      final orderNumber = order['orderNumber'] as String?;
      if (orderId == null) {
        throw Exception('No order ID returned from server');
      }
      debugPrint('[PaystackPayment] Order created — _id: $orderId, orderNumber: $orderNumber');

      // Backend now returns accessCode directly in the order response
      final accessCode = order['accessCode'] as String? ??
          order['access_code'] as String? ??
          (order['data'] is Map ? (order['data'] as Map)['access_code'] as String? : null);

      if (accessCode == null || accessCode.isEmpty) {
        debugPrint('[PaystackPayment] No accessCode in order response: ${order.toString()}');
        throw Exception('No payment access code returned from server');
      }
      debugPrint('[PaystackPayment] Access code obtained: $accessCode');

      final checkoutUrl = 'https://checkout.paystack.com/$accessCode';
      debugPrint('[PaystackDebug] Launching Checkout WebView with URL: $checkoutUrl');

      state = state.copyWith(
        step: PaystackStep.processingInWebView,
        accessCode: accessCode,
      );
    } catch (e) {
      debugPrint('[PaystackPayment] Error: $e');
      state = state.copyWith(
        step: PaystackStep.paymentFailed,
        error: e.toString(),
      );
    }
  }

  void startPolling() {
    _pollTimer?.cancel();
    state = state.copyWith(step: PaystackStep.verifyingStatus);
    _runPollingLoop();
  }

  Future<void> _runPollingLoop() async {
    const tierADelay = Duration(seconds: 3);
    const tierBDelay = Duration(seconds: 6);
    const tierATimeout = Duration(seconds: 30);
    const maxDuration = Duration(seconds: 90);

    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed < maxDuration) {
      final elapsed = stopwatch.elapsed;
      final delay = elapsed < tierATimeout ? tierADelay : tierBDelay;

      await Future.delayed(delay);

      final orderId = state.orderId;
      if (orderId == null) break;

      try {
        final status = await _repo.getPaymentStatus(orderId);
        final paymentStatus =
            status['data']?['payment']?['status'] as String?;

        if (paymentStatus == 'paid') {
          state = state.copyWith(step: PaystackStep.paymentSuccess);
          return;
        } else if (paymentStatus == 'failed') {
          state = state.copyWith(
            step: PaystackStep.paymentFailed,
            error: 'Payment was declined',
          );
          return;
        }
      } catch (_) {
        // Continue polling on transient errors
      }
    }

    state = state.copyWith(showManualCheck: true);
  }

  Future<void> checkManually() async {
    state = state.copyWith(showManualCheck: false);
    _runPollingLoop();
  }

  void hideWebView() {
    state = state.copyWith(webViewHidden: true);
    if (_pollTimer == null && state.accessCode != null) {
      startPolling();
    }
  }

  void reset() {
    _pollTimer?.cancel();
    _pollTimer = null;
    state = const PaystackPaymentState();
  }
}
