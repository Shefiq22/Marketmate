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
import 'login_page.dart';

class RegisterPage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const RegisterPage({super.key, required this.onNext, required this.onBack});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _nameFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _passwordTouched = false;
  bool _emailTouched = false;
  bool _phoneTouched = false;
  String? _loadingProvider;
  final _socialAuthService = SocialAuthService();

  bool _hasUpper(String v) => v.contains(RegExp(r'[A-Z]'));
  bool _hasLower(String v) => v.contains(RegExp(r'[a-z]'));
  bool _hasDigit(String v) => v.contains(RegExp(r'[0-9]'));
  bool _hasSymbol(String v) =>
      v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-+=\[\]\\;/]'));
  bool _hasLength(String v) => v.length >= 8;

  bool _passwordValid(String v) =>
      _hasUpper(v) &&
      _hasLower(v) &&
      _hasDigit(v) &&
      _hasSymbol(v) &&
      _hasLength(v);

  bool _phoneValid(String v) =>
      v.trim().length == 11 && RegExp(r'^\d+$').hasMatch(v.trim());

  bool _emailValid(String v) {
    final emailRegex = RegExp(
      r'^[\w.+\-]+@(gmail|yahoo|outlook|hotmail|icloud|me|live|protonmail|zoho|yandex|aol|msn|([a-zA-Z0-9\-]+\.[a-zA-Z]{2,}))\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(v.trim());
  }

  Future<void> _handleSocialLoginSuccess(
    Map<String, dynamic> data, {
    String? socialEmail,
  }) async {
    if (!mounted) return;

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
    userIdStr ??= (apiUser?['_id'] ?? apiUser?['id'] ?? apiUser?['userId']) as String?;

    roleStr ??= data['role'] as String?;
    nameStr ??= data['name'] as String?;
    emailStr ??= data['email'] as String?;
    phoneStr ??= data['phone'] as String?;
    userIdStr ??= (data['id'] ?? data['_id'] ?? data['userId']) as String?;

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
    await ref.read(authProvider.notifier).authenticate(resolvedRole);

    if (!mounted) return;
    TextInput.finishAutofillContext();
    widget.onNext();
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
      final selectedRole = ref.read(selectedRoleProvider);
      final roleStr = selectedRole == UserRole.rider
          ? 'rider'
          : selectedRole == UserRole.farmerOrWholesaler
              ? 'seller'
              : 'customer';
      final data = await repo.socialLogin(idToken: idToken, role: roleStr);
      await _handleSocialLoginSuccess(data);
    } on AuthException catch (e) {
      if (!mounted) return;
      ref.read(registerFormProvider.notifier).setError(e.message);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final notifier = ref.read(registerFormProvider.notifier);
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        notifier.setError('No account found with these credentials. Please sign up first.');
      } else {
        notifier.setError('Google sign-in failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      ref.read(registerFormProvider.notifier).setError('Google sign-in failed. Please try again.');
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
      final selectedRole = ref.read(selectedRoleProvider);
      final roleStr = selectedRole == UserRole.rider
          ? 'rider'
          : selectedRole == UserRole.farmerOrWholesaler
              ? 'seller'
              : 'customer';
      final data = await repo.socialLogin(idToken: idToken, role: roleStr);
      await _handleSocialLoginSuccess(data);
    } on AuthException catch (e) {
      if (!mounted) return;
      ref.read(registerFormProvider.notifier).setError(e.message);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      final notifier = ref.read(registerFormProvider.notifier);
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        notifier.setError('No account found with these credentials. Please sign up first.');
      } else {
        notifier.setError('Facebook sign-in failed. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      ref.read(registerFormProvider.notifier).setError('Facebook sign-in failed. Please try again.');
    } finally {
      if (mounted) setState(() => _loadingProvider = null);
    }
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(registerFormProvider);
    final notifier = ref.read(registerFormProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final passwordValid = _passwordValid(form.password);
    final emailValid = _emailValid(form.email);
    final phoneValid = _phoneValid(form.phone);
    final formValid =
        form.name.trim().isNotEmpty &&
        phoneValid &&
        emailValid &&
        passwordValid;

    Color? emailBorderColor() {
      if (!_emailTouched) return null;
      return emailValid ? null : AppColors.error;
    }

    Color? phoneBorderColor() {
      if (!_phoneTouched) return null;
      return phoneValid ? null : AppColors.error;
    }

    Color? passwordBorderColor() {
      if (!_passwordTouched) return null;
      return passwordValid ? null : AppColors.error;
    }

    return AuthScreenBody(
      bottomBar: AuthPrimaryButton(
        label: 'Continue',
        loading: form.isLoading,
        onPressed: (formValid && !form.isLoading)
            ? () async {
                final userId = await notifier.register();
                if (userId != null && mounted) {
                  await ref
                      .read(pendingVerificationProvider.notifier)
                      .save(userId, form.email);
                  if (mounted) {
                    TextInput.finishAutofillContext();
                    widget.onNext();
                  }
                }
              }
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AuthHeader(
            eyebrow: 'Almost there',
            title: 'Create your account',
            subtitle: 'Fill in your details to get started.',
          ),
          const SizedBox(height: AuthSpacing.section),
          AutofillGroup(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AuthFieldLabel('Full name', required: true),
                TextField(
                  focusNode: _nameFocus,
                  onChanged: notifier.setName,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _phoneFocus.requestFocus(),
                  autofillHints: const [AutofillHints.name],
                  style: authInputStyle(context),
                  decoration: authFieldDecoration(
                    context,
                    hint: 'John Doe',
                    suffix: Icon(
                      Icons.person_outline_rounded,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(height: AuthSpacing.field),
                const AuthFieldLabel('Phone number', required: true),
                TextField(
                  focusNode: _phoneFocus,
                  onChanged: (v) {
                    notifier.setPhone(v);
                    if (!_phoneTouched && v.isNotEmpty) {
                      setState(() => _phoneTouched = true);
                    }
                  },
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(11),
                  ],
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _emailFocus.requestFocus(),
                  autofillHints: const [AutofillHints.telephoneNumber],
                  style: authInputStyle(context),
                  decoration: authFieldDecoration(
                    context,
                    hint: '08012345678',
                    borderColor: phoneBorderColor(),
                    prefix: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icons/flag_ng.png',
                            width: 24,
                            height: 16,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Text('🇳🇬', style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 1,
                            height: 20,
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          const SizedBox(width: 6),
                        ],
                      ),
                    ),
                  ),
                ),
                if (_phoneTouched && !phoneValid) ...[
                  const SizedBox(height: AuthSpacing.tight),
                  Text(
                    'Phone number must be exactly 11 digits',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error.withValues(alpha: 0.9),
                    ),
                  ),
                ],
                const SizedBox(height: AuthSpacing.field),
                const AuthFieldLabel('Email', required: true),
                TextField(
                  focusNode: _emailFocus,
                  onChanged: (v) {
                    notifier.setEmail(v);
                    if (!_emailTouched && v.isNotEmpty) {
                      setState(() => _emailTouched = true);
                    }
                  },
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => _passwordFocus.requestFocus(),
                  autofillHints: const [AutofillHints.email],
                  style: authInputStyle(context),
                  decoration: authFieldDecoration(
                    context,
                    hint: 'you@example.com',
                    borderColor: emailBorderColor(),
                    suffix: _emailTouched
                        ? Icon(
                            emailValid
                                ? Icons.check_circle_outline_rounded
                                : Icons.cancel_outlined,
                            color: emailValid ? AppColors.primary : AppColors.error,
                            size: 20,
                          )
                        : null,
                  ),
                ),
                if (_emailTouched && !emailValid) ...[
                  const SizedBox(height: AuthSpacing.tight),
                  Text(
                    'Enter a valid email address',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.error.withValues(alpha: 0.9),
                    ),
                  ),
                ],
                const SizedBox(height: AuthSpacing.field),
                const AuthFieldLabel('Password', required: true),
                TextField(
                  focusNode: _passwordFocus,
                  onChanged: (v) {
                    notifier.setPassword(v);
                    if (!_passwordTouched && v.isNotEmpty) {
                      setState(() => _passwordTouched = true);
                    }
                  },
                  obscureText: !form.passwordVisible,
                  textInputAction: TextInputAction.done,
                  autofillHints: const [AutofillHints.newPassword],
                  style: authInputStyle(context),
                  decoration: authFieldDecoration(
                    context,
                    hint: 'Create a strong password',
                    borderColor: passwordBorderColor(),
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
                if (_passwordTouched) ...[
                  const SizedBox(height: AuthSpacing.tight),
                  Wrap(
                    spacing: 12,
                    runSpacing: 6,
                    children: [
                      AuthPasswordRequirement(
                        label: '8+ chars',
                        met: _hasLength(form.password),
                      ),
                      AuthPasswordRequirement(
                        label: 'Uppercase',
                        met: _hasUpper(form.password),
                      ),
                      AuthPasswordRequirement(
                        label: 'Lowercase',
                        met: _hasLower(form.password),
                      ),
                      AuthPasswordRequirement(
                        label: 'Number',
                        met: _hasDigit(form.password),
                      ),
                      AuthPasswordRequirement(
                        label: 'Symbol',
                        met: _hasSymbol(form.password),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: AuthSpacing.field),
                const AuthFieldLabel('Referral code'),
                TextField(
                  onChanged: notifier.setReferralCode,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  style: authInputStyle(context),
                  decoration: authFieldDecoration(
                    context,
                    hint: 'Optional',
                    prefix: Icon(
                      Icons.card_giftcard_outlined,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
                      size: 20,
                    ),
                  ),
                ),
                if (form.error != null) ...[
                  const SizedBox(height: AuthSpacing.field),
                  AuthErrorBanner(message: form.error!),
                ],
              ],
            ),
          ),
          const SizedBox(height: AuthSpacing.section),
          AuthLinkRow(
            prefix: 'Already have an account? ',
            linkText: 'Log in',
            onTap: () => Navigator.of(context, rootNavigator: true).push(
              MaterialPageRoute(builder: (_) => const LoginPage()),
            ),
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
}

