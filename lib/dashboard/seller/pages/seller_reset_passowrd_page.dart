import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/core/providers/theme_provider.dart';

class SellerResetPasswordPage extends ConsumerStatefulWidget {
  const SellerResetPasswordPage({super.key});

  @override
  ConsumerState<SellerResetPasswordPage> createState() =>
      _SellerResetPasswordPageState();
}

class _SellerResetPasswordPageState
    extends ConsumerState<SellerResetPasswordPage> {
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ref.watch(isDarkModeProvider);
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final hPad = isTablet ? size.width * 0.08 : 20.0;

    Widget fieldLabel(String text) => Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 20),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 15 : 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.black,
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            '*',
            style: TextStyle(color: AppColors.error, fontSize: 14),
          ),
        ],
      ),
    );

    Widget passwordField(
      TextEditingController ctrl,
      bool visible,
      VoidCallback toggle, {
      String? hint,
    }) {
      return TextField(
        controller: ctrl,
        obscureText: !visible,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: isTablet ? 15 : 14,
          color: isDark ? AppColors.textPrimaryDark : AppColors.black,
        ),
        decoration: InputDecoration(
          hintText: hint ?? 'Enter password here',
          hintStyle: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: isTablet ? 15 : 14,
            color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
          ),
          suffixIcon: GestureDetector(
            onTap: toggle,
            child: Icon(
              visible
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: isDark ? AppColors.cardDark : AppColors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.border,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Icon(
                    Icons.chevron_left_rounded,
                    size: 28,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  hPad,
                  0,
                  hPad,
                  padding.bottom + 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reset password',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 26 : 22,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.black,
                      ),
                    ),
                    fieldLabel('Current Password'),
                    passwordField(
                      _currentCtrl,
                      _showCurrent,
                      () => setState(() => _showCurrent = !_showCurrent),
                    ),
                    fieldLabel('New Password'),
                    passwordField(
                      _newCtrl,
                      _showNew,
                      () => setState(() => _showNew = !_showNew),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        'Should be at least 8 characters',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: isTablet ? 13 : 12,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    fieldLabel('Confirm new Password'),
                    passwordField(
                      _confirmCtrl,
                      _showConfirm,
                      () => setState(() => _showConfirm = !_showConfirm),
                    ),
                    const SizedBox(height: 36),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_newCtrl.text.length < 8) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Password must be at least 8 characters',
                                ),
                              ),
                            );
                            return;
                          }
                          if (_newCtrl.text != _confirmCtrl.text) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.password_mismatch),
                              ),
                            );
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(AppLocalizations.of(context)!.password_updated),
                            ),
                          );
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          minimumSize: Size(0, isTablet ? 56 : 52),
                          shape: const StadiumBorder(),
                          elevation: 0,
                          textStyle: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 17 : 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: Text(AppLocalizations.of(context)!.password_confirm_new),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
