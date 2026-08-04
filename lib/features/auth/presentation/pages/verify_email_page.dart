import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/features/auth/data/auth_repository.dart';
import 'package:market_mate/features/auth/provider/auth_provider.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import 'package:market_mate/features/auth/provider/otp_provider.dart';
import 'package:market_mate/features/auth/provider/pending_verification_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'registration_success_page.dart';

import '../widgets/otp_field.dart';

class VerifyEmailPage extends ConsumerStatefulWidget {
  final String userId;
  final VoidCallback onBack;
  final VoidCallback? onVerified;

  const VerifyEmailPage({
    super.key,
    required this.userId,
    required this.onBack,
    this.onVerified,
  });

  @override
  ConsumerState<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends ConsumerState<VerifyEmailPage> {
  final _controllers = List.generate(6, (i) => TextEditingController());
  final _focusNodes = List.generate(6, (i) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  String? _error;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _clearFields() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Future<void> _verify() async {
    final otpNotifier = ref.read(otpProvider.notifier);
    if (!otpNotifier.isComplete) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      final otp = ref.read(otpProvider).digits.join();
      await repo.verifyEmail(userId: widget.userId, otp: otp);

      if (!mounted) return;
      await ref.read(pendingVerificationProvider.notifier).clear();

      final regForm = ref.read(registerFormProvider);
      final selectedRole = ref.read(selectedRoleProvider);
      final roleStr = userRoleToApi(selectedRole ?? UserRole.retailerOrConsumer);
      await ref.read(currentUserProvider.notifier).update(
        name: regForm.name,
        email: regForm.email,
        phone: regForm.phone,
        role: roleStr,
        userId: widget.userId,
      );
      ref.read(activeRoleProvider.notifier).state =
          selectedRole ?? UserRole.retailerOrConsumer;
      if (context.mounted) {
        ref.read(authProvider.notifier).authenticate(roleStr);
      }

      if (!mounted) return;

      if (widget.onVerified != null) {
        widget.onVerified!();
        return;
      }

      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const RegistrationSuccessPage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Verification failed. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _resend() async {
    setState(() {
      _isResending = true;
      _error = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resendOtp(widget.userId, type: 'email');
      if (mounted) {
        ref.read(otpProvider.notifier).resend();
        _clearFields();
      }
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (e) {
      if (mounted) setState(() => _error = 'Failed to resend code.');
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final otp = ref.watch(otpProvider);
    final otpNotifier = ref.read(otpProvider.notifier);
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = isTablet ? size.width * 0.1 : size.width * 0.055;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, size.height * 0.012, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lastly',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 20 : 17,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.black,
            ),
          ),
          SizedBox(height: size.height * 0.012),
          Text(
            'Verify email address',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 36 : 30,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.black,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: size.height * 0.03),
          Center(
            child: Text(
              'Enter the 6 digits code sent to your email',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 15 : 13,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                height: 1.7,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: size.height * 0.045),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(6, (i) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.012),
                child: OtpField(
                  controller: _controllers[i],
                  focusNode: _focusNodes[i],
                  nextFocus: i < 5 ? _focusNodes[i + 1] : null,
                  prevFocus: i > 0 ? _focusNodes[i - 1] : null,
                  onChanged: (v) => otpNotifier.setDigit(i, v),
                ),
              );
            }),
          ),
          SizedBox(height: size.height * 0.026),
          if (_error != null)
            Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.012),
              child: Center(
                child: Text(
                  _error!,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 13 : 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          Center(
            child: otp.expired
                ? GestureDetector(
                    onTap: _isResending ? null : _resend,
                    child: _isResending
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.primary,
                            ),
                          )
                        : Text(
                            'Send code again.',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: isTablet ? 15 : 13,
                              fontWeight: FontWeight.bold,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.black,
                            ),
                          ),
                  )
                : Column(
                    children: [
                      RichText(
                        text: TextSpan(
                          text: 'Code expires in ',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 14 : 13,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.black,
                          ),
                          children: [
                            TextSpan(
                              text: otp.formattedTime,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: size.height * 0.014),
                      GestureDetector(
                        onTap: _isResending ? null : _resend,
                        child: _isResending
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.primary,
                                ),
                              )
                            : Text(
                                "Didn't get code? Send code again.",
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: isTablet ? 14 : 13,
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.black,
                                ),
                              ),
                      ),
                    ],
                  ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: isTablet ? size.height * 0.081 : size.height * 0.073,
            child: ElevatedButton(
              onPressed: (otpNotifier.isComplete && !_isLoading)
                  ? _verify
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: const StadiumBorder(),
                elevation: 0,
                textStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 17 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white,
                      ),
                    )
                  : const Text('Next'),
            ),
          ),
          SizedBox(height: padding.bottom + size.height * 0.036),
        ],
      ),
    );
  }
}
