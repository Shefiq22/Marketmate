import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/features/auth/data/auth_repository.dart';
import 'package:market_mate/features/auth/provider/auth_provider.dart';
import 'package:market_mate/features/auth/provider/otp_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/otp_field.dart';
import 'login_success_page.dart';

class ForgotPasswordEmailPage extends ConsumerStatefulWidget {
  final String? initialEmail;

  const ForgotPasswordEmailPage({super.key, this.initialEmail});

  @override
  ConsumerState<ForgotPasswordEmailPage> createState() =>
      _ForgotPasswordEmailPageState();
}

class _ForgotPasswordEmailPageState
    extends ConsumerState<ForgotPasswordEmailPage> {
  late final _emailCtrl = TextEditingController(text: widget.initialEmail);
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendResetCode() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Please enter your email address');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.requestPasswordReset(email);

      if (!mounted) return;

      // Save email for next step
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ForgotPasswordVerifyPage(email: email),
        ),
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Failed to send reset code. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.scaffoldDark
            : AppColors.scaffoldLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    'Reset Password',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 34 : 28,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    'Enter your email address and we\'ll send you a code to reset your password',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: size.height * 0.055),
                  Text(
                    'Email Address',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                  ),
                  SizedBox(height: size.height * 0.013),
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 15,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter your email',
                      hintStyle: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 16 : 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.gray2,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: isTablet
                            ? size.height * 0.026
                            : size.height * 0.022,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                          width: 1.4,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: EdgeInsets.only(top: size.height * 0.016),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isTablet ? 14 : 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.error,
                              size: isTablet ? 20 : 18,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: isTablet ? 13 : 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            height: isTablet
                ? size.height * 0.072
                : size.height * 0.064,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _sendResetCode,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: isDark ? AppColors.borderDark : AppColors.border,
                shape: const StadiumBorder(),
                elevation: 0,
                textStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 16 : 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white.withValues(alpha: 0.7),
                        ),
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('Send Reset Code'),
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordVerifyPage extends ConsumerStatefulWidget {
  final String email;

  const ForgotPasswordVerifyPage({super.key, required this.email});

  @override
  ConsumerState<ForgotPasswordVerifyPage> createState() =>
      _ForgotPasswordVerifyPageState();
}

class _ForgotPasswordVerifyPageState
    extends ConsumerState<ForgotPasswordVerifyPage> {
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
      await repo.verifyPasswordResetCode(email: widget.email, otp: otp);

      if (!mounted) return;
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) =>
              ForgotPasswordResetPage(email: widget.email, otp: otp),
        ),
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
      await repo.requestPasswordReset(widget.email);
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
    ref.watch(otpProvider);
    final otpNotifier = ref.read(otpProvider.notifier);
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.scaffoldDark
            : AppColors.scaffoldLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    'Step 2 of 3',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: size.height * 0.011),
                  Text(
                    'Verify Code',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 36 : 30,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  Center(
                    child: Text(
                      'Enter the 6 digits code sent to\nyour email',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 15 : 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Center(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final fieldWidth =
                            (constraints.maxWidth - (5 * 12)) / 6;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (i) {
                            return SizedBox(
                              width: fieldWidth,
                              height: fieldWidth * 1.3,
                              child: OtpField(
                                controller: _controllers[i],
                                focusNode: _focusNodes[i],
                                onChanged: (v) {
                                  ref.read(otpProvider.notifier).setDigit(i, v);
                                },
                                nextFocus: i < 5 ? _focusNodes[i + 1] : null,
                                prevFocus: i > 0 ? _focusNodes[i - 1] : null,
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                  SizedBox(height: size.height * 0.03),
                  if (_error != null)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(isTablet ? 14 : 12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.error.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: AppColors.error,
                            size: isTablet ? 20 : 18,
                          ),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet ? 13 : 12,
                                fontWeight: FontWeight.w500,
                                color: AppColors.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: size.height * 0.03),
                  Center(
                    child: GestureDetector(
                      onTap: _isResending ? null : _resend,
                      child: Text(
                        _isResending
                            ? 'Resending...'
                            : 'Didn\'t receive? Resend code',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: isTablet ? 14 : 13,
                          fontWeight: FontWeight.w600,
                          color: _isResending
                              ? AppColors.gray2
                              : AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            height: isTablet
                ? size.height * 0.072
                : size.height * 0.064,
            child: ElevatedButton(
              onPressed: _isLoading || !otpNotifier.isComplete
                  ? null
                  : _verify,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: isDark ? AppColors.borderDark : AppColors.border,
                shape: const StadiumBorder(),
                elevation: 0,
                textStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 16 : 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white.withValues(alpha: 0.7),
                        ),
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('Verify Code'),
            ),
          ),
        ),
      ),
    );
  }
}

class ForgotPasswordResetPage extends ConsumerStatefulWidget {
  final String email;
  final String otp;

  const ForgotPasswordResetPage({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  ConsumerState<ForgotPasswordResetPage> createState() =>
      _ForgotPasswordResetPageState();
}

class _ForgotPasswordResetPageState
    extends ConsumerState<ForgotPasswordResetPage> {
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmVisible = false;
  bool _isLoading = false;
  String? _error;
  String _passwordValue = '';

  bool _hasUpper(String v) => v.contains(RegExp(r'[A-Z]'));
  bool _hasLower(String v) => v.contains(RegExp(r'[a-z]'));
  bool _hasDigit(String v) => v.contains(RegExp(r'[0-9]'));
  bool _hasSymbol(String v) =>
      v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/]'));
  bool _hasLength(String v) => v.length >= 8;
  bool get _passwordValid =>
      _hasUpper(_passwordValue) &&
      _hasLower(_passwordValue) &&
      _hasDigit(_passwordValue) &&
      _hasSymbol(_passwordValue) &&
      _hasLength(_passwordValue);

  Widget _buildRequirement(String label, bool met, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: 7,
            height: 7,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: met ? AppColors.primary : AppColors.error,
            ),
          ),
          const SizedBox(width: 10),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 250),
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 13 : 12,
              fontWeight: met ? FontWeight.w600 : FontWeight.w400,
              color: met ? AppColors.primary : AppColors.error,
            ),
            child: Text(label),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    final password = _passwordCtrl.text.trim();
    final confirm = _confirmCtrl.text.trim();

    if (password.isEmpty) {
      setState(() => _error = 'Please enter a new password');
      return;
    }
    if (!_passwordValid) {
      setState(() => _error = 'Password does not meet all requirements');
      return;
    }
    if (confirm.isEmpty) {
      setState(() => _error = 'Please confirm your password');
      return;
    }
    if (password != confirm) {
      setState(() => _error = 'Passwords do not match');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.resetPassword(
        email: widget.email,
        otp: widget.otp,
        newPassword: password,
      );

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginSuccessPage()),
        (route) => false,
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = 'Failed to reset password. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppColors.scaffoldDark
            : AppColors.scaffoldLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      resizeToAvoidBottomInset: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  Text(
                    'Step 3 of 3',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: size.height * 0.011),
                  Text(
                    'Create New Password',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 34 : 28,
                      fontWeight: FontWeight.bold,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: size.height * 0.02),
                  Text(
                    'Enter your new password to complete the reset',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: size.height * 0.055),
                  Text(
                    'New Password',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                  ),
                  SizedBox(height: size.height * 0.013),
                  TextField(
                    controller: _passwordCtrl,
                    obscureText: !_passwordVisible,
                    onChanged: (v) => setState(() => _passwordValue = v),
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 15,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter password',
                      hintStyle: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 16 : 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.gray2,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(size.height * 0.018),
                          child: Icon(
                            _passwordVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.gray2,
                            size: isTablet ? 22 : 20,
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: isTablet
                            ? size.height * 0.026
                            : size.height * 0.022,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                          width: 1.4,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.013),
                  _buildRequirement(
                    'At least 8 characters',
                    _hasLength(_passwordValue),
                    isTablet,
                  ),
                  _buildRequirement(
                    'One uppercase letter',
                    _hasUpper(_passwordValue),
                    isTablet,
                  ),
                  _buildRequirement(
                    'One lowercase letter',
                    _hasLower(_passwordValue),
                    isTablet,
                  ),
                  _buildRequirement(
                    'One number',
                    _hasDigit(_passwordValue),
                    isTablet,
                  ),
                  _buildRequirement(
                    'One special character',
                    _hasSymbol(_passwordValue),
                    isTablet,
                  ),
                  SizedBox(height: size.height * 0.021),
                  Text(
                    'Confirm Password',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                  ),
                  SizedBox(height: size.height * 0.013),
                  TextField(
                    controller: _confirmCtrl,
                    obscureText: !_confirmVisible,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 15,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Confirm password',
                      hintStyle: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 16 : 15,
                        fontWeight: FontWeight.w400,
                        color: AppColors.gray2,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () =>
                            setState(() => _confirmVisible = !_confirmVisible),
                        child: Padding(
                          padding: EdgeInsets.all(size.height * 0.018),
                          child: Icon(
                            _confirmVisible
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: AppColors.gray2,
                            size: isTablet ? 22 : 20,
                          ),
                        ),
                      ),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.surfaceDark
                          : AppColors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: isTablet
                            ? size.height * 0.026
                            : size.height * 0.022,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: isDark ? AppColors.borderDark : AppColors.border,
                          width: 1.4,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: AppColors.primary,
                          width: 2.0,
                        ),
                      ),
                    ),
                  ),
                  if (_error != null)
                    Padding(
                      padding: EdgeInsets.only(top: size.height * 0.016),
                      child: Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isTablet ? 14 : 12),
                        decoration: BoxDecoration(
                          color: AppColors.error.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.error.withValues(alpha: 0.25),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: AppColors.error,
                              size: isTablet ? 20 : 18,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: isTablet ? 13 : 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: SizedBox(
            width: double.infinity,
            height: isTablet
                ? size.height * 0.072
                : size.height * 0.064,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _resetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: isDark ? AppColors.borderDark : AppColors.border,
                shape: const StadiumBorder(),
                elevation: 0,
                textStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 16 : 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: _isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.white.withValues(alpha: 0.7),
                        ),
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text('Reset Password'),
            ),
          ),
        ),
      ),
    );
  }
}
