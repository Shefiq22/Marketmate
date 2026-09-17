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
import '../widgets/auth_ui.dart';
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
    } catch (e, st) {
      if (!mounted) return;
      debugPrint('[SocialLogin] Google login error: $e');
      debugPrint('[SocialLogin] Stack: $st');
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
    } catch (e, st) {
      if (!mounted) return;
      debugPrint('[SocialLogin] Apple login error: $e');
      debugPrint('[SocialLogin] Stack: $st');
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
    } catch (e, st) {
      if (!mounted) return;
      debugPrint('[SocialLogin] Facebook login error: $e');
      debugPrint('[SocialLogin] Stack: $st');
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final canPop = Navigator.of(context).canPop();

    final emailBorderColor = form.emailError ? AppColors.error : null;
    final passwordBorderColor = form.passwordError ? AppColors.error : null;

    return AuthScreenBody(
      bottomBar: AuthPrimaryButton(
        label: 'Log in',
        loading: form.isLoading,
        onPressed: form.isValid && !form.isLoading && _loadingProvider == null
            ? () async {
                try {
                  final repo = ref.read(authRepositoryProvider);
                  final loginNotifier = ref.read(loginFormProvider.notifier);
                  final data = await loginNotifier.login(repo);
                  if (data != null) {
                    await _handleLoginSuccess(data);
                  }
                } catch (_) {
                  if (!mounted) return;
                  ref.read(loginFormProvider.notifier).setError(
                        'Something went wrong. Please try again.',
                      );
                }
              }
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (canPop) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => Navigator.of(context).maybePop(),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                style: IconButton.styleFrom(
                  backgroundColor: isDark ? AppColors.cardDark : AppColors.white,
                  foregroundColor: isDark ? AppColors.textPrimaryDark : AppColors.black,
                  minimumSize: const Size(40, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AuthSpacing.section),
          ],
          const AuthHeader(
            title: 'Welcome back',
            subtitle: 'Sign in to continue shopping fresh produce.',
          ),
          const SizedBox(height: AuthSpacing.section),
          AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthFieldLabel('Email address'),
                TextField(
                  focusNode: _emailFocus,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: notifier.setEmail,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.username, AutofillHints.email],
                  style: authInputStyle(context),
                  decoration: authFieldDecoration(
                    context,
                    hint: 'you@example.com',
                    borderColor: emailBorderColor,
                  ),
                ),
                const SizedBox(height: AuthSpacing.field),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AuthFieldLabel('Password'),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ForgotPasswordEmailPage(initialEmail: form.email),
                        ),
                      ),
                      child: Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                TextField(
                  focusNode: _passwordFocus,
                  onChanged: notifier.setPassword,
                  obscureText: !form.passwordVisible,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.password],
                  style: authInputStyle(context),
                  decoration: authFieldDecoration(
                    context,
                    hint: 'Enter your password',
                    borderColor: passwordBorderColor,
                    suffix: GestureDetector(
                      onTap: notifier.togglePassword,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(
                          form.passwordVisible
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (form.error != null && !showVerifyPanel) ...[
            const SizedBox(height: AuthSpacing.field),
            AuthErrorBanner(
              message: form.error!,
              action: form.isWrongPasswordError
                  ? GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ForgotPasswordEmailPage(initialEmail: form.email),
                        ),
                      ),
                      child: const Text(
                        'Reset password',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
          if (showVerifyPanel) ...[
            const SizedBox(height: AuthSpacing.field),
            AuthErrorBanner(
              message: form.error ?? 'Account not verified',
              action: AuthPrimaryButton(
                label: 'Verify account',
                loading: _isVerifying,
                onPressed: _isVerifying ? null : _goVerify,
              ),
            ),
          ],
          const SizedBox(height: AuthSpacing.section),
          AuthLinkRow(
            prefix: "Don't have an account? ",
            linkText: 'Sign up',
            onTap: () {
              final nav = Navigator.of(context);
              if (nav.canPop()) {
                nav.maybePop();
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const QuestionnaireScreen()),
                );
              }
            },
          ),
          const SizedBox(height: AuthSpacing.section),
          const AuthOrDivider(),
          const SizedBox(height: AuthSpacing.field),
          Row(
            children: [
              AuthSocialButton(
                icon: 'assets/icons/google.png',
                onTap: _signInWithGoogle,
                loading: _loadingProvider == 'google',
              ),
              const SizedBox(width: 12),
              AuthSocialButton(
                icon: 'assets/icons/facebook.png',
                onTap: _signInWithFacebook,
                loading: _loadingProvider == 'facebook',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _extractUserIdFromData(Map<String, dynamic>? user) {
    if (user == null) return '';
    return (user['_id'] ?? user['id'] ?? user['userId'] ?? '') as String;
  }
}

