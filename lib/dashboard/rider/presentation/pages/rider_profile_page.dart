import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/core/providers/theme_provider.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';

class RiderProfilePage extends ConsumerStatefulWidget {
  const RiderProfilePage({super.key});

  @override
  ConsumerState<RiderProfilePage> createState() => _RiderProfilePageState();
}

class _RiderProfilePageState extends ConsumerState<RiderProfilePage> {
  late TextEditingController _nameCtrl;
  late TextEditingController _emailCtrl;
  late TextEditingController _phoneCtrl;
  bool _emailVisible = false;
  bool _populated = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameCtrl = TextEditingController(text: user?.name ?? '');
    _emailCtrl = TextEditingController(text: user?.email ?? '');
    _phoneCtrl = TextEditingController(text: user?.phone ?? '');
    _populated = user != null;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    if (!_populated && user != null) {
      _nameCtrl.text = user.name;
      _emailCtrl.text = user.email;
      _phoneCtrl.text = user.phone;
      _populated = true;
    }
    final isDark = ref.watch(isDarkModeProvider);
    final l10n = AppLocalizations.of(context)!;

    InputDecoration fieldDec({Widget? suffix}) => InputDecoration(
      filled: true,
      fillColor: isDark ? AppColors.cardDark : AppColors.white,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    );

    Widget label(String text, {bool required = false}) => Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 20),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
            ),
          ),
          if (required) ...[
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: AppColors.error, fontSize: 14),
            ),
          ],
        ],
      ),
    );

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.scaffoldDark
          : AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20.0),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          l10n.menu_profile_label,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshProfile,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 24),
                      Center(
                        child: Stack(
                          children: [
                            Container(
                              width: 88,
                              height: 88,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primarySurface,
                                border: Border.all(
                                  color: AppColors.primary,
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  _initials(_nameCtrl.text),
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.camera_alt_outlined,
                                  size: 16,
                                  color: AppColors.textOnPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: Text(
                          _nameCtrl.text,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                      label('Full name'),
                      TextField(
                        controller: _nameCtrl,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        decoration: fieldDec(
                          suffix: Icon(
                            Icons.person_outline_rounded,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.gray2,
                            size: 20,
                          ),
                        ),
                      ),
                      label('Email'),
                      TextField(
                        controller: _emailCtrl,
                        obscureText: !_emailVisible,
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : AppColors.textPrimary,
                        ),
                        decoration: fieldDec(
                          suffix: GestureDetector(
                            onTap: () =>
                                setState(() => _emailVisible = !_emailVisible),
                            child: Icon(
                              Icons.visibility_off_outlined,
                              color: isDark
                                  ? AppColors.textSecondaryDark
                                  : AppColors.gray2,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                      label('Phone number', required: true),
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.cardDark : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.border,
                          ),
                        ),
                        child: Row(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 16,
                              ),
                              child: Row(
                                children: [
                                  Image.asset(
                                    'assets/icons/flag_ng.png',
                                    width: 28,
                                    height: 20,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Text('🇳🇬'),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: isDark
                                        ? AppColors.textSecondaryDark
                                        : AppColors.gray2,
                                    size: 18,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 24,
                              color: isDark
                                  ? AppColors.borderDark
                                  : AppColors.border,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '+234',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: 14,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: TextField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly,
                                ],
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 14,
                                  color: isDark
                                      ? AppColors.textPrimaryDark
                                      : AppColors.textPrimary,
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      label('Role'),
                      TextField(
                        enabled: false,
                        controller: TextEditingController(
                          text:
                              ref
                                  .watch(currentUserProvider)
                                  ?.role
                                  .toUpperCase() ??
                              'RIDER',
                        ),
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 14,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.textSecondary,
                        ),
                        decoration: fieldDec(
                          suffix: Icon(
                            Icons.person_rounded,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.gray2,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 12.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                await ref
                    .read(currentUserProvider.notifier)
                    .update(
                      name: _nameCtrl.text,
                      email: _emailCtrl.text,
                      phone: _phoneCtrl.text,
                    );
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.profile_updated_success),
                  ),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                minimumSize: Size(0, 52),
                shape: const StadiumBorder(),
                elevation: 0,
                textStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(l10n.rider_profile_update),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _refreshProfile() async {
    final l10n = AppLocalizations.of(context)!;
    final user = ref.read(currentUserProvider);
    if (user != null) {
      await ref
          .read(currentUserProvider.notifier)
          .update(
            name: user.name.isNotEmpty ? user.name : null,
            email: user.email.isNotEmpty ? user.email : null,
            phone: user.phone.isNotEmpty ? user.phone : null,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.profile_refreshed),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  String _initials(String fullName) {
    if (fullName.isEmpty) return '?';
    final parts = fullName.trim().split(' ');
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }
}
