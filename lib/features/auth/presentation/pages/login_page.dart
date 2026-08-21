import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/features/auth/data/auth_repository.dart';
import 'package:market_mate/features/auth/data/social_auth_service.dart';
import 'package:market_mate/features/auth/provider/auth_provider.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import 'package:market_mate/features/auth/provider/pending_verification_provider.dart';
import '../../../../core/theme/app_colors.dart';
import 'login_success_page.dart';
import 'questionnaire_screen.dart';
import 'verify_email_page.dart';
import 'forgot_password_email_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _isVerifying = false;
  String? _loadingProvider;
  final _socialAuthService = SocialAuthService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(loginFormProvider.notifier).reset();
    });
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _goVerify() async {
    if (_isVerifying) return;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    setState(() => _isVerifying = true);
    final email = ref.read(loginFormProvider).email;
    final userId = await ref
        .read(pendingVerificationProvider.notifier)
        .resolveUserId(email);

    if (!mounted) return;
    if (userId == null || userId.isEmpty) {
      setState(() => _isVerifying = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not find your account ID. Please sign up again to verify.',
          ),
        ),
      );
      return;
    }

    try {
      await ref.read(authRepositoryProvider).resendOtp(userId, type: 'email');
    } catch (_) {}

    if (!mounted) return;
    setState(() => _isVerifying = false);

    final navigator = Navigator.of(context);
    navigator.push(
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
          appBar: AppBar(
            backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => navigator.pop(),
            ),
          ),
          body: VerifyEmailPage(
            userId: userId,
            onBack: () => navigator.pop(),
            onVerified: () {
              navigator.pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginSuccessPage()),
                (route) => false,
              );
            },
          ),
        ),
      ),
    );
  }

  // ─────────────── Social Login ───────────────

  /// Handles the post-login flow shared by both email/password and social login.
  /// Decodes the JWT, updates the current user, sets the auth state and
  /// navigates to the success screen.
  Future<void> _handleLoginSuccess(
    Map<String, dynamic> data, {
    String? socialEmail,
  }) async {
    if (!mounted) return;
    final navigator = Navigator.of(context);

    final tokens = data['tokens'] as Map<String, dynamic>?;
    final accessToken = tokens?['accessToken'] as String? ?? data['accessToken'] as String?;
    Map<String, dynamic>? apiUser;
    if (data['user'] is Map<String, dynamic>) {
      apiUser = data['user'] as Map<String, dynamic>?;
    } else if (data['profile'] is Map<String, dynamic>) {
      apiUser = data['profile'] as Map<String, dynamic>?;
    } else if (data['account'] is Map<String, dynamic>) {
      apiUser = data['account'] as Map<String, dynamic>?;
    }

    debugPrint('[Auth Login] API data.keys: ${data.keys.join(", ")}');
    debugPrint('[Auth Login] accessToken present: ${accessToken != null}');
    debugPrint('[Auth Login] apiUser present: ${apiUser != null}');
    if (apiUser != null) {
      debugPrint('[Auth Login] apiUser keys: ${apiUser.keys.join(", ")}');
      debugPrint('[Auth Login] apiUser role: "${apiUser['role']}"');
    }

    if (accessToken != null) {
      final repo = ref.read(authRepositoryProvider);
      await repo.setTokens(accessToken, '');
    }

    String? roleStr;
    String? nameStr;
    String? emailStr;
    String? phoneStr;
    String? userIdStr;

    if (accessToken != null) {
      final jwtUser = decodeUserFromJwt(accessToken);
      if (jwtUser != null) {
        roleStr = jwtUser.role.isNotEmpty ? jwtUser.role : null;
        nameStr = jwtUser.name.isNotEmpty ? jwtUser.name : null;
        emailStr = jwtUser.email.isNotEmpty ? jwtUser.email : null;
        phoneStr = jwtUser.phone.isNotEmpty ? jwtUser.phone : null;
        userIdStr = jwtUser.userId.isNotEmpty ? jwtUser.userId : null;
      }
    }

    roleStr ??= apiUser?['role'] as String?;
    nameStr ??= apiUser?['name'] as String?;
    nameStr ??= apiUser?['fullName'] as String?;
    nameStr ??= apiUser?['full_name'] as String?;
    nameStr ??= apiUser?['displayName'] as String?;
    nameStr ??= apiUser?['username'] as String?;
    emailStr ??= apiUser?['email'] as String? ?? socialEmail;
    phoneStr ??= apiUser?['phone'] as String?;
    userIdStr ??= _extractUserIdFromData(apiUser);

    roleStr ??= data['role'] as String?;
    nameStr ??= data['name'] as String?;
    emailStr ??= data['email'] as String?;
    phoneStr ??= data['phone'] as String?;
    userIdStr ??= data['id'] as String? ?? data['_id'] as String? ?? data['userId'] as String?;

    await ref.read(currentUserProvider.notifier).update(
      name: nameStr,
      email: emailStr,
      phone: phoneStr,
      role: roleStr,
      userId: userIdStr,
    );

    await ref.read(currentUserProvider.notifier).refreshFromToken();

    final resolvedRole = roleStr ?? 'customer';
    ref.read(activeRoleProvider.notifier).state = apiToUserRole(resolvedRole);
    debugPrint('[Auth Login] Stored role string: "$resolvedRole" -> UserRole.${apiToUserRole(resolvedRole).name}');
    await ref.read(authProvider.notifier).authenticate(resolvedRole);

    if (!mounted) return;
    TextInput.finishAutofillContext();
    navigator.push(
      MaterialPageRoute(
        builder: (_) => const LoginSuccessPage(),
      ),
    );
  }

  Future<void> _signInWithGoogle() async {
    if (_loadingProvider != null) return;
    setState(() => _loadingProvider = 'google');

    try {
      final idToken = await _socialAuthService.signInWithGoogle();
      if (!mounted) return;
      if (idToken == null) {
        setState(() => _loadingProvider = null);
        return;
      }

      final repo = ref.read(authRepositoryProvider);
      final data = await repo.socialLogin(idToken: idToken, role: 'customer');
      await _handleLoginSuccess(data);
    } on AuthException catch (e) {
      if (!mounted) return;
      final notifier = ref.read(loginFormProvider.notifier);
      notifier.setError(e.message);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final notifier = ref.read(loginFormProvider.notifier);
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        notifier.setError('No account found with these credentials. Please sign up first.');
      } else {
        notifier.setError('Google sign-in failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      final notifier = ref.read(loginFormProvider.notifier);
      notifier.setError('Google sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loadingProvider = null);
    }
  }

  // Re-enable when Apple Developer account is obtained and
  // "Sign in with Apple" capability is added in Xcode.
  // ignore: unused_element
  Future<void> _signInWithApple() async {
    if (_loadingProvider != null) return;
    setState(() => _loadingProvider = 'apple');

    try {
      final idToken = await _socialAuthService.signInWithApple();
      if (!mounted) return;
      if (idToken == null) {
        setState(() => _loadingProvider = null);
        return;
      }

      final repo = ref.read(authRepositoryProvider);
      final data = await repo.socialLogin(idToken: idToken, role: 'customer');
      await _handleLoginSuccess(data);
    } on AuthException catch (e) {
      if (!mounted) return;
      ref.read(loginFormProvider.notifier).setError(e.message);
    } catch (e) {
      if (!mounted) return;
      ref.read(loginFormProvider.notifier).setError('Apple sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loadingProvider = null);
    }
  }

  Future<void> _signInWithFacebook() async {
    if (_loadingProvider != null) return;
    setState(() => _loadingProvider = 'facebook');

    try {
      final idToken = await _socialAuthService.signInWithFacebook();
      if (!mounted) return;
      if (idToken == null) {
        setState(() => _loadingProvider = null);
        return;
      }

      final repo = ref.read(authRepositoryProvider);
      final data = await repo.socialLogin(idToken: idToken, role: 'customer');
      await _handleLoginSuccess(data);
    } on AuthException catch (e) {
      if (!mounted) return;
      ref.read(loginFormProvider.notifier).setError(e.message);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final notifier = ref.read(loginFormProvider.notifier);
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        notifier.setError('No account found with these credentials. Please sign up first.');
      } else {
        notifier.setError('Facebook sign-in failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      ref.read(loginFormProvider.notifier).setError('Facebook sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loadingProvider = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(loginFormProvider);
    final notifier = ref.read(loginFormProvider.notifier);
    ref.watch(pendingVerificationProvider);
    final showVerifyPanel = form.needsVerification ||
        (form.error != null && isUnverifiedAccountMessage(form.error!));
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputRadius = BorderRadius.circular(12);
    final labelSize = isTablet ? 16.0 : 14.0;
    final inputFontSize = isTablet ? 16.0 : 15.0;

    final emailBorderColor = form.emailError ? AppColors.error : AppColors.border;
    final passwordBorderColor = form.passwordError ? AppColors.error : AppColors.border;

    InputDecoration fieldDecoration({
      String? hint,
      Widget? suffix,
      Color? borderColor,
    }) =>
        InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: inputFontSize,
            fontWeight: FontWeight.w400,
            color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
          ),
          suffixIcon: suffix,
          filled: true,
          fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 18,
            vertical: isTablet ? 20 : 17,
          ),
            enabledBorder: OutlineInputBorder(
            borderRadius: inputRadius,
            borderSide: BorderSide(color: borderColor ?? (isDark ? AppColors.borderDark : AppColors.border), width: 1.4),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: inputRadius,
            borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border, width: 2.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: inputRadius,
            borderSide: BorderSide(color: AppColors.error, width: 1.4),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: inputRadius,
            borderSide: BorderSide(color: AppColors.error, width: 2.0),
          ),
        );

    Widget fieldLabel(String text) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: RichText(
                text: TextSpan(
              text: text,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: labelSize,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : AppColors.black,
              ),
            ),
          ),
        );

    TextStyle inputStyle() => TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: inputFontSize,
          color: isDark ? AppColors.textPrimaryDark : AppColors.black,
        );

    final canPop = Navigator.of(context).canPop();

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(16.0, size.height * 0.04, 16.0, size.height * 0.03),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              if (canPop)
                Padding(
                  padding: EdgeInsets.only(bottom: size.height * 0.03),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: SizedBox(
                      height: isTablet ? 44 : 38,
                      width: isTablet ? 44 : 38,
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                        iconSize: isTablet ? 20 : 18,
                          style: IconButton.styleFrom(
                          backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
                          foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                            side: BorderSide(
                                color: isDark ? AppColors.borderDark : AppColors.border, width: 1.2),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ),
                ),
              SizedBox(height: size.height * 0.025),
                Text(
                'Welcome back',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 34 : 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: size.height * 0.01),
              Text(
                'Log in to your account',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 16 : 14,
                  fontWeight: FontWeight.w500,
                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                ),
              ),
              SizedBox(height: size.height * 0.045),
              AutofillGroup(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    fieldLabel('Email Address'),
                    TextField(
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      onChanged: notifier.setEmail,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.username, AutofillHints.email],
                      style: inputStyle(),
                      decoration: fieldDecoration(
                                hint: 'Enter here',
                        borderColor: emailBorderColor,
                      ),
                    ),
                    SizedBox(height: isTablet ? 22 : 18),
                      Text(
                      'Password',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: labelSize,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                      ),
                    ),
                    TextField(
                      focusNode: _passwordFocus,
                      onChanged: notifier.setPassword,
                      obscureText: !form.passwordVisible,
                      textInputAction: TextInputAction.done,
                      autofillHints: const [AutofillHints.password],
                      style: inputStyle(),
                      decoration: fieldDecoration(
                        hint: 'Enter password here',
                        borderColor: passwordBorderColor,
                        suffix: GestureDetector(
                          onTap: notifier.togglePassword,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                              child: Icon(
                              form.passwordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
                              size: isTablet ? 22 : 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (form.error != null && !showVerifyPanel)
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.error,
                          size: isTablet ? 20 : 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                form.error!,
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: isTablet ? 13 : 12,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.error,
                                  height: 1.4,
                                ),
                              ),
                              if (form.isWrongPasswordError)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => ForgotPasswordEmailPage(initialEmail: form.email),
                                      ),
                                    ),
                                    child: Text(
                                      'Forgot Password?',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: isTablet ? 13 : 12,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (showVerifyPanel)
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 8),
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isTablet ? 18 : 16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.error.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          form.error ?? 'Account not verified',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 14 : 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.error,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: isTablet ? 14 : 12),
                        SizedBox(
                          width: double.infinity,
                          height: isTablet ? 48 : 44,
                          child: ElevatedButton(
                            onPressed: _isVerifying ? null : _goVerify,
                              style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              disabledBackgroundColor: isDark ? AppColors.borderDark : AppColors.border,
                              shape: const StadiumBorder(),
                              elevation: 0,
                              textStyle: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet ? 15 : 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: _isVerifying
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: AppColors.white,
                                    ),
                                  )
                                : const Text('Verify Account'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              const SizedBox(height: 16),
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Do not have an account? ',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                    children: [
                      WidgetSpan(
                        child: GestureDetector(
                          onTap: () {
                            final nav = Navigator.of(context);
                            if (nav.canPop()) {
                              nav.maybePop();
                            } else {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const QuestionnaireScreen(),
                                ),
                              );
                            }
                          },
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet ? 15 : 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  'Or Create Account with',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 14 : 12,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  _SocialButton(
                    icon: 'assets/icons/google.png',
                    onTap: _signInWithGoogle,
                    loading: _loadingProvider == 'google',
                  ),
                  const SizedBox(width: 12),
                  _SocialButton(
                    icon: 'assets/icons/facebook.png',
                    onTap: _signInWithFacebook,
                    loading: _loadingProvider == 'facebook',
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    ),
    bottomNavigationBar: Padding(
      padding: EdgeInsets.fromLTRB(16.0, 8.0, 16.0, MediaQuery.of(context).padding.bottom + 4.0),
        child: SizedBox(
          width: double.infinity,
          height: isTablet ? 64 : 56,
          child: ElevatedButton(
            onPressed: form.isValid && !form.isLoading && _loadingProvider == null
                ? () async {
                    try {
                      final repo = ref.read(authRepositoryProvider);
                      final notifier = ref.read(loginFormProvider.notifier);
                      final data = await notifier.login(repo);
                      if (data != null) {
                        await _handleLoginSuccess(data);
                      }
                    } catch (_) {
                      if (!mounted) return;
                      ref.read(loginFormProvider.notifier).setError('Something went wrong. Please try again.');
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: isDark ? AppColors.borderDark : AppColors.border,
                disabledForegroundColor: isDark ? AppColors.textDisabledDark : AppColors.gray2,
                shape: const StadiumBorder(),
                elevation: 0,
                textStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 18 : 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            child: form.isLoading
                ? SizedBox(
                    width: 22,
                    height: 22,
                    child: const CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: AppColors.white,
                      ),
                  )
                : const Text('Log in'),
        ),
      ),
    ),
  );
  }

  String _extractUserIdFromData(Map<String, dynamic>? user) {
    if (user == null) return '';
    return (user['_id'] ?? user['id'] ?? user['userId'] ?? '') as String;
  }
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  final bool loading;

  const _SocialButton({
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: loading ? null : onTap,
        child: Container(
          height: isTablet ? 60 : 54,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.border, width: 1.4),
          ),
          child: Center(
            child: loading
                ? SizedBox(
                    width: isTablet ? 22 : 20,
                    height: isTablet ? 22 : 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                    ),
                  )
                : Image.asset(
                    icon,
                    width: isTablet ? 28 : 24,
                    height: isTablet ? 28 : 24,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                  ),
          ),
        ),
      ),
    );
  }
}
