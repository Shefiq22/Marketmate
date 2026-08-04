import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OtpState {
  final List<String> digits;
  final int secondsRemaining;
  final bool expired;

  const OtpState({
    this.digits = const ['', '', '', '', '', ''],
    this.secondsRemaining = 89,
    this.expired = false,
  });

  OtpState copyWith({
    List<String>? digits,
    int? secondsRemaining,
    bool? expired,
  }) =>
      OtpState(
        digits: digits ?? this.digits,
        secondsRemaining: secondsRemaining ?? this.secondsRemaining,
        expired: expired ?? this.expired,
      );

  String get formattedTime {
    final m = secondsRemaining ~/ 60;
    final s = secondsRemaining % 60;
    return '$m:${s.toString().padLeft(2, '0')}s';
  }
}

class OtpNotifier extends Notifier<OtpState> {
  Timer? _timer;

  @override
  OtpState build() {
    ref.onDispose(() => _timer?.cancel());
    _startTimer();
    return const OtpState();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (state.secondsRemaining <= 0) {
        t.cancel();
        state = state.copyWith(expired: true);
      } else {
        state = state.copyWith(
          secondsRemaining: state.secondsRemaining - 1,
        );
      }
    });
  }

  void setDigit(int index, String value) {
    final updated = List<String>.from(state.digits);
    updated[index] = value;
    state = state.copyWith(digits: updated);
  }

  void resend() {
    state = const OtpState();
    _startTimer();
  }

  bool get isComplete => state.digits.every((d) => d.isNotEmpty);
}

final otpProvider = NotifierProvider<OtpNotifier, OtpState>(OtpNotifier.new);