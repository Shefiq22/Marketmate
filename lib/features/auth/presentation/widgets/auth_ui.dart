import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Shared visual tokens for auth screens — fixed spacing to avoid bloated layouts.
abstract final class AuthSpacing {
  static const double screenH = 20;
  static const double screenV = 24;
  static const double section = 24;
  static const double field = 16;
  static const double tight = 8;
  static const double labelGap = 6;
  static const double buttonH = 52;
  static const double maxWidth = 480;
  static const double inputRadius = 14;
  static const double socialH = 50;
}

/// Builds a consistent input decoration for auth forms.
InputDecoration authFieldDecoration(
  BuildContext context, {
  String? hint,
  Widget? suffix,
  Widget? prefix,
  Color? borderColor,
  Color? focusedBorderColor,
}) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final radius = BorderRadius.circular(AuthSpacing.inputRadius);
  final defaultBorder =
      borderColor ?? (isDark ? AppColors.borderDark : AppColors.border);

  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontFamily: 'Plus Jakarta Sans',
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
    ),
    suffixIcon: suffix,
    prefixIcon: prefix,
    filled: true,
    fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    enabledBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(color: defaultBorder, width: 1.2),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: BorderSide(
        color: focusedBorderColor ?? AppColors.primary,
        width: 1.5,
      ),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: AppColors.error, width: 1.2),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: radius,
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
  );
}

TextStyle authInputStyle(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: isDark ? AppColors.textPrimaryDark : AppColors.black,
  );
}

TextStyle authLabelStyle(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return TextStyle(
    fontFamily: 'Plus Jakarta Sans',
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: isDark ? AppColors.textPrimaryDark : AppColors.black,
    letterSpacing: 0.1,
  );
}

/// Premium auth screen header with eyebrow + title + optional subtitle.
class AuthHeader extends StatelessWidget {
  final String? eyebrow;
  final String title;
  final String? subtitle;

  const AuthHeader({
    super.key,
    this.eyebrow,
    required this.title,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (eyebrow != null) ...[
          Text(
            eyebrow!,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.black,
            letterSpacing: -0.6,
            height: 1.15,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(
            subtitle!,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

/// Required field label with asterisk.
class AuthFieldLabel extends StatelessWidget {
  final String text;
  final bool required;

  const AuthFieldLabel(this.text, {super.key, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AuthSpacing.labelGap),
      child: RichText(
        text: TextSpan(
          text: text,
          style: authLabelStyle(context),
          children: required
              ? const [
                  TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppColors.error),
                  ),
                ]
              : null,
        ),
      ),
    );
  }
}

/// Horizontal divider with centered label.
class AuthOrDivider extends StatelessWidget {
  final String label;

  const AuthOrDivider({super.key, this.label = 'or continue with'});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lineColor = isDark ? AppColors.borderDark : AppColors.border;

    return Row(
      children: [
        Expanded(child: Divider(color: lineColor, height: 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
            ),
          ),
        ),
        Expanded(child: Divider(color: lineColor, height: 1)),
      ],
    );
  }
}

/// Social sign-in button with icon.
class AuthSocialButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;
  final bool loading;

  const AuthSocialButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: loading ? null : onTap,
        child: Container(
          height: AuthSpacing.socialH,
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDark : AppColors.white,
            borderRadius: BorderRadius.circular(AuthSpacing.inputRadius),
            border: Border.all(
              color: isDark ? AppColors.borderDark : AppColors.border,
              width: 1.2,
            ),
          ),
          child: Center(
            child: loading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                    ),
                  )
                : Image.asset(
                    icon,
                    width: 22,
                    height: 22,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                  ),
          ),
        ),
      ),
    );
  }
}

/// Inline auth link row (e.g. "Don't have an account? Sign up").
class AuthLinkRow extends StatelessWidget {
  final String prefix;
  final String linkText;
  final VoidCallback onTap;

  const AuthLinkRow({
    super.key,
    required this.prefix,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: RichText(
          text: TextSpan(
            text: prefix,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
            ),
            children: [
              TextSpan(
                text: linkText,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Error banner for auth forms.
class AuthErrorBanner extends StatelessWidget {
  final String message;
  final Widget? action;

  const AuthErrorBanner({super.key, required this.message, this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.error, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message,
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.error,
                    height: 1.4,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: 6),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Primary CTA button for auth screens.
class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final enabled = onPressed != null && !loading;

    return SizedBox(
      width: double.infinity,
      height: AuthSpacing.buttonH,
      child: ElevatedButton(
        onPressed: enabled ? onPressed : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: isDark ? AppColors.borderDark : AppColors.border,
          disabledForegroundColor: isDark ? AppColors.textDisabledDark : AppColors.gray2,
          foregroundColor: AppColors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AuthSpacing.inputRadius),
          ),
          textStyle: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        child: loading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppColors.white,
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Wraps auth screen body with consistent padding and max width.
class AuthScreenBody extends StatelessWidget {
  final Widget child;
  final Widget? bottomBar;

  const AuthScreenBody({super.key, required this.child, this.bottomBar});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: AuthSpacing.maxWidth),
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AuthSpacing.screenH,
                AuthSpacing.screenV,
                AuthSpacing.screenH,
                AuthSpacing.section,
              ),
              child: child,
            ),
          ),
        ),
      ),
      bottomNavigationBar: bottomBar != null
          ? Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
                border: Border(
                  top: BorderSide(
                    color: isDark ? AppColors.dividerDark : AppColors.divider,
                  ),
                ),
              ),
              padding: EdgeInsets.fromLTRB(
                AuthSpacing.screenH,
                12,
                AuthSpacing.screenH,
                bottomInset + 12,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AuthSpacing.maxWidth),
                child: bottomBar,
              ),
            )
          : null,
    );
  }
}

/// Compact password requirement chip.
class AuthPasswordRequirement extends StatelessWidget {
  final String label;
  final bool met;

  const AuthPasswordRequirement({
    super.key,
    required this.label,
    required this.met,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 14,
          color: met ? AppColors.primary : AppColors.error.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 11,
              fontWeight: met ? FontWeight.w600 : FontWeight.w400,
              color: met ? AppColors.primary : AppColors.error.withValues(alpha: 0.85),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
