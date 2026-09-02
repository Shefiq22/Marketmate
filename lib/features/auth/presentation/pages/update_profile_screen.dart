import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/dashboard/presentation/pages/dashboard_router.dart';
import 'package:market_mate/features/auth/data/auth_repository.dart';
import 'package:market_mate/features/auth/provider/auth_provider.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import '../../../../core/theme/app_colors.dart';

/// Mandatory profile step shown right after sign-up (especially social
/// sign-up) when the account has no phone number yet. The screen cannot be
/// dismissed — back gestures are blocked and the continue button refuses to
/// move on until a valid 11-digit phone number is saved.
class UpdateProfileScreen extends ConsumerStatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  ConsumerState<UpdateProfileScreen> createState() =>
      _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends ConsumerState<UpdateProfileScreen> {
  final _phoneCtrl = TextEditingController();
  final _phoneFocus = FocusNode();
  bool _saving = false;
  String? _error;

  bool _phoneValid(String v) =>
      v.trim().length == 11 && RegExp(r'^\d+$').hasMatch(v.trim());

  @override
  void initState() {
    super.initState();
    // Self-heal false positives: if the server actually has a phone number
    // on file (stale local cache), skip straight to the dashboard.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(currentUserProvider.notifier).refreshFromToken();
      if (!mounted) return;
      final phone = ref.read(currentUserProvider)?.phone.trim() ?? '';
      if (phone.isNotEmpty) await _finish();
    });
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await ref.read(authProvider.notifier).completeProfileUpdate();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DashboardRouter()),
      (route) => false,
    );
  }

  Future<void> _save() async {
    if (_saving) return;
    final raw = _phoneCtrl.text.trim();
    if (raw.isEmpty) {
      setState(() => _error = 'Please input your phone number');
      _phoneFocus.requestFocus();
      return;
    }
    if (!_phoneValid(raw)) {
      setState(() => _error = 'Phone number must be exactly 11 digits');
      _phoneFocus.requestFocus();
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final repo = ref.read(authRepositoryProvider);
      final formatted = await repo.updateProfile(phone: raw);
      await ref.read(currentUserProvider.notifier).update(phone: formatted);
      await _finish();
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error =
            'Could not save your phone number. Check your connection and try again.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final inputRadius = BorderRadius.circular(12);
    final inputFontSize = isTablet ? 16.0 : 15.0;
    final borderColor = _error != null ? AppColors.error : AppColors.border;

    return PopScope(
      canPop: false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor:
            isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
        body: SingleChildScrollView(
          child: SafeArea(
            child: Padding(
              padding:
                  EdgeInsets.fromLTRB(24.0, size.height * 0.08, 24.0, 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete your\nprofile',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 34 : 28,
                      fontWeight: FontWeight.bold,
                      color:
                          isDark ? AppColors.textPrimaryDark : AppColors.black,
                      letterSpacing: -0.5,
                      height: 1.25,
                    ),
                  ),
                  SizedBox(height: size.height * 0.015),
                  Text(
                    'Almost done! Please add your phone number to finish '
                    'setting up your account.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: size.height * 0.05),
                  Text(
                    'Phone number',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 16 : 14,
                      fontWeight: FontWeight.w700,
                      color:
                          isDark ? AppColors.textPrimaryDark : AppColors.black,
                    ),
                  ),
                  SizedBox(height: size.height * 0.012),
                  TextField(
                    focusNode: _phoneFocus,
                    controller: _phoneCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(11),
                    ],
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _save(),
                    onChanged: (_) {
                      if (_error != null) setState(() => _error = null);
                    },
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: inputFontSize,
                      color:
                          isDark ? AppColors.textPrimaryDark : AppColors.black,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter here',
                      hintStyle: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: inputFontSize,
                        fontWeight: FontWeight.w400,
                        color:
                            isDark ? AppColors.textSecondaryDark : AppColors.gray2,
                      ),
                      filled: true,
                      fillColor:
                          isDark ? AppColors.surfaceDark : AppColors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: isTablet ? 20 : 17,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: inputRadius,
                        borderSide:
                            BorderSide(color: borderColor, width: 1.4),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: inputRadius,
                        borderSide:
                            BorderSide(color: borderColor, width: 2.0),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: inputRadius,
                        borderSide:
                            BorderSide(color: AppColors.error, width: 1.4),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: inputRadius,
                        borderSide:
                            BorderSide(color: AppColors.error, width: 2.0),
                      ),
                      prefix: Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: size.width * 0.038),
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
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    SizedBox(height: size.height * 0.01),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.error,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _error!,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: isTablet ? 13 : 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.error,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, padding.bottom + 12),
            child: SizedBox(
              width: double.infinity,
              height: isTablet ? 64 : 56,
              child: ElevatedButton(
                onPressed: _saving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  disabledBackgroundColor:
                      isDark ? AppColors.borderDark : AppColors.border,
                  disabledForegroundColor: isDark
                      ? AppColors.textDisabledDark
                      : AppColors.gray2,
                  shape: const StadiumBorder(),
                  elevation: 0,
                  textStyle: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 18 : 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: _saving
                    ? SizedBox(
                        width: 22,
                        height: 22,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.white,
                        ),
                      )
                    : const Text('Save & Continue'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
