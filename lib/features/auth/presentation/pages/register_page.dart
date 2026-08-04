import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/features/auth/provider/auth_provider.dart';
import 'package:market_mate/features/auth/provider/pending_verification_provider.dart';
import '../../../../core/theme/app_colors.dart';
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
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelSize = isTablet ? 16.0 : 14.0;
    final inputFontSize = isTablet ? 16.0 : 15.0;
    final inputRadius = BorderRadius.circular(12);

    final passwordValid = _passwordValid(form.password);
    final emailValid = _emailValid(form.email);
    final phoneValid = _phoneValid(form.phone);
    final formValid =
        form.name.trim().isNotEmpty &&
        phoneValid &&
        emailValid &&
        passwordValid;

    Color emailBorderColor() {
      if (!_emailTouched) return AppColors.border;
      return emailValid ? AppColors.border : AppColors.error;
    }

    Color phoneBorderColor() {
      if (!_phoneTouched) return AppColors.border;
      return phoneValid ? AppColors.border : AppColors.error;
    }

    Color passwordBorderColor() {
      if (!_passwordTouched) return AppColors.border;
      return passwordValid ? AppColors.border : AppColors.error;
    }

    InputDecoration fieldDecoration({
      String? hint,
      Widget? suffix,
      Widget? prefix,
      Color? borderColor,
      Color? focusedBorderColor,
    }) => InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: inputFontSize,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
      ),
      suffixIcon: suffix,
      prefixIcon: prefix,
      filled: true,
      fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
      contentPadding: EdgeInsets.symmetric(
        horizontal: size.width * 0.04,
        vertical: isTablet ? size.height * 0.026 : size.height * 0.022,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(
          color:
              borderColor ?? (isDark ? AppColors.borderDark : AppColors.border),
          width: 1.4,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: inputRadius,
        borderSide: BorderSide(
          color:
              focusedBorderColor ??
              (isDark ? AppColors.borderDark : AppColors.border),
          width: 2.0,
        ),
      ),
    );

    Widget fieldLabel(String text) => Padding(
      padding: EdgeInsets.only(bottom: size.height * 0.012),
      child: RichText(
        text: TextSpan(
          text: text,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: labelSize,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.black,
          ),
          children: const [
            TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error),
            ),
          ],
        ),
      ),
    );

    TextStyle inputStyle() => TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: inputFontSize,
      fontWeight: FontWeight.w500,
      color: isDark ? AppColors.textPrimaryDark : AppColors.black,
    );

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text(
                  'Almost there',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: size.height * 0.008),
                Text(
                  'Register here',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 42 : 34,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                    letterSpacing: -0.8,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      fieldLabel('Full name'),
                      TextField(
                        focusNode: _nameFocus,
                        onChanged: notifier.setName,
                        textInputAction: TextInputAction.next,
                        onSubmitted: (_) => _phoneFocus.requestFocus(),
                        autofillHints: const [AutofillHints.name],
                        style: inputStyle(),
                        decoration: fieldDecoration(
                          hint: 'Enter full name here',
                          suffix: Padding(
                            padding: EdgeInsets.all(size.height * 0.018),
                            child: Icon(
                              Icons.person_outline_rounded,
                              color: AppColors.gray2,
                              size: isTablet ? 22 : 20,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: isTablet ? size.height * 0.029 : size.height * 0.024,
                      ),
                      fieldLabel('Phone number'),
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
                        style: inputStyle(),
                        decoration: fieldDecoration(
                          hint: '+234',
                          borderColor: phoneBorderColor(),
                          focusedBorderColor: phoneBorderColor(),
                          prefix: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: size.width * 0.038,
                              vertical: size.height * 0.018,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/icons/flag_ng.png',
                                  width: 28,
                                  height: 20,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Text(
                                        '🇳🇬',
                                        style: TextStyle(fontSize: 18),
                                      ),
                                ),
                                SizedBox(width: size.width * 0.017),
                                const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.gray2,
                                  size: 18,
                                ),
                                SizedBox(width: size.width * 0.027),
                                Container(
                                  width: 1,
                                  height: size.height * 0.029,
                                  color: isDark ? AppColors.borderDark : AppColors.border,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (_phoneTouched && !phoneValid) ...[
                        SizedBox(height: size.height * 0.008),
                        Text(
                          'Phone number must be exactly 11 digits',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 12 : 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      SizedBox(
                        height: isTablet ? size.height * 0.029 : size.height * 0.024,
                      ),
                      fieldLabel('Email'),
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
                        style: inputStyle(),
                        decoration: fieldDecoration(
                          hint: 'Enter email here',
                          borderColor: emailBorderColor(),
                          focusedBorderColor: emailBorderColor(),
                          suffix: _emailTouched
                              ? Padding(
                                  padding: EdgeInsets.all(size.height * 0.018),
                                  child: Icon(
                                    emailValid
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.cancel_outlined,
                                    color: emailValid
                                        ? (isDark ? AppColors.borderDark : AppColors.border)
                                        : AppColors.error,
                                    size: isTablet ? 22 : 20,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      if (_emailTouched && !emailValid) ...[
                        SizedBox(height: size.height * 0.008),
                        Text(
                          'Enter a valid email address (e.g. name@gmail.com)',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 12 : 11,
                            fontWeight: FontWeight.w500,
                            color: AppColors.error,
                          ),
                        ),
                      ],
                      SizedBox(
                        height: isTablet ? size.height * 0.029 : size.height * 0.024,
                      ),
                      fieldLabel('Password'),
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
                        style: inputStyle(),
                        decoration: fieldDecoration(
                          hint: 'Enter password here',
                          borderColor: passwordBorderColor(),
                          focusedBorderColor: passwordBorderColor(),
                          suffix: GestureDetector(
                            onTap: notifier.togglePassword,
                            child: Padding(
                              padding: EdgeInsets.all(size.height * 0.018),
                              child: Icon(
                                form.passwordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: _passwordTouched
                                    ? passwordBorderColor()
                                    : AppColors.gray2,
                                size: isTablet ? 22 : 20,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (_passwordTouched) ...[
                        SizedBox(height: size.height * 0.013),
                        _PasswordRequirementLine(
                          label: 'At least 8 characters',
                          met: _hasLength(form.password),
                          isTablet: isTablet,
                        ),
                        _PasswordRequirementLine(
                          label: 'One uppercase letter',
                          met: _hasUpper(form.password),
                          isTablet: isTablet,
                        ),
                        _PasswordRequirementLine(
                          label: 'One lowercase letter',
                          met: _hasLower(form.password),
                          isTablet: isTablet,
                        ),
                        _PasswordRequirementLine(
                          label: 'One number',
                          met: _hasDigit(form.password),
                          isTablet: isTablet,
                        ),
                        _PasswordRequirementLine(
                          label: 'One symbol  (!@#\$%^&*...)',
                          met: _hasSymbol(form.password),
                          isTablet: isTablet,
                        ),
                      ],
                      if (form.error != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: size.height * 0.016),
                          child: Text(
                            form.error!,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: isTablet ? 13 : 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: size.height * 0.021),
                Center(
                  child: RichText(
                    text: TextSpan(
                      text: 'Already have an account? ',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 15 : 13,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      children: [
                        WidgetSpan(
                          child: GestureDetector(
                            onTap: () =>
                                Navigator.of(context, rootNavigator: true).push(
                                  MaterialPageRoute(
                                    builder: (_) => const LoginPage(),
                                  ),
                                ),
                            child: Text(
                              'Log in',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet ? 15 : 13,
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? AppColors.primaryLight
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.027),
                Center(
                  child: Text(
                    'Or Create Account with',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 14 : 12,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.gray2,
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.019),
                Row(
                  children: [
                    Expanded(
                      child: _SocialButton(
                        icon: 'assets/icons/google.png',
                        onTap: () {},
                      ),
                    ),
                    SizedBox(width: size.width * 0.032),
                    Expanded(
                      child: _SocialButton(
                        icon: 'assets/icons/facebook.png',
                        onTap: () {},
                      ),
                    ),
                    SizedBox(width: size.width * 0.032),
                    Expanded(
                      child: _SocialButton(
                        icon: 'assets/icons/apple.png',
                        onTap: () {},
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
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
          height: isTablet ? size.height * 0.086 : size.height * 0.075,
          child: ElevatedButton(
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
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              disabledBackgroundColor: isDark ? AppColors.borderDark : AppColors.border,
              disabledForegroundColor: AppColors.gray2,
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
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.white,
                    ),
                  )
                : const Text('Next'),
          ),
        ),
      ),
    ),
  );
  }
}

class _PasswordRequirementLine extends StatelessWidget {
  final String label;
  final bool met;
  final bool isTablet;

  const _PasswordRequirementLine({
    required this.label,
    required this.met,
    required this.isTablet,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Padding(
      padding: EdgeInsets.only(top: size.height * 0.007),
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
          SizedBox(width: size.width * 0.027),
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
}

class _SocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _SocialButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isTablet ? size.height * 0.08 : size.height * 0.072,
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1.4,
          ),
        ),
        child: Center(
          child: Image.asset(
            icon,
            width: isTablet ? 28 : 24,
            height: isTablet ? 28 : 24,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),
      ),
    );
  }
}
