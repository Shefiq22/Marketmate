import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import 'package:market_mate/dashboard/rider/providers/rider_dashboard_provider.dart';

class RiderWithdrawPage extends ConsumerStatefulWidget {
  const RiderWithdrawPage({super.key});

  @override
  ConsumerState<RiderWithdrawPage> createState() => _RiderWithdrawPageState();
}

class _RiderWithdrawPageState extends ConsumerState<RiderWithdrawPage> {
  String? _selectedAccount;
  bool _accountExpanded = false;
  final _amountCtrl = TextEditingController();

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final hPad = isTablet ? size.width * 0.08 : 20.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final accounts = ref.watch(bankAccountsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
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
                    color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
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
                      l10n.rider_withdraw_btn,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 26 : 22,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Text(
                      'Select account to withdraw to',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 15 : 14,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _accountExpanded = !_accountExpanded),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _accountExpanded
                                ? AppColors.primary
                                : (isDark
                                      ? AppColors.borderDark
                                      : AppColors.border),
                            width: _accountExpanded ? 1.8 : 1.2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _selectedAccount ?? 'Choose',
                              style: TextStyle(
                                fontFamily: 'Plus Jakarta Sans',
                                fontSize: isTablet ? 15 : 14,
                                color: _selectedAccount != null
                                    ? (isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary)
                                    : (isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.gray2),
                              ),
                            ),
                            AnimatedRotation(
                              turns: _accountExpanded ? 0.5 : 0,
                              duration: const Duration(milliseconds: 200),
                              child: Icon(
                                Icons.keyboard_arrow_down_rounded,
                                color: isDark
                                    ? AppColors.textSecondaryDark
                                    : AppColors.gray2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_accountExpanded)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.surfaceDark
                              : AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.border,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadowLight,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: accounts.map((acc) {
                            final label = '${acc['bank']} - ${acc['number']}';
                            final sel = _selectedAccount == label;
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedAccount = label;
                                _accountExpanded = false;
                              }),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                color: sel
                                    ? AppColors.primarySurface
                                    : Colors.transparent,
                                child: Text(
                                  label,
                                  style: TextStyle(
                                    fontFamily: 'Plus Jakarta Sans',
                                    fontSize: isTablet ? 14 : 13,
                                    fontWeight: sel
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: sel
                                        ? AppColors.primary
                                        : (isDark
                                              ? AppColors.textPrimaryDark
                                              : AppColors.textPrimary),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Enter amount',
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 15 : 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () =>
                              setState(() => _amountCtrl.text = '45000'),
                          child: Text(
                            'Max',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: isTablet ? 15 : 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _amountCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 15 : 14,
                        color: isDark
                            ? AppColors.textPrimaryDark
                            : AppColors.textPrimary,
                      ),
                      decoration: InputDecoration(
                        hintText: l10n.rider_enter_hint,
                        hintStyle: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: isTablet ? 15 : 14,
                          color: isDark
                              ? AppColors.textSecondaryDark
                              : AppColors.gray2,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.surfaceDark
                            : AppColors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.primary,
                            width: 1.8,
                          ),
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
      bottomNavigationBar: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 12.0, 20.0, 12.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_selectedAccount == null ||
                    _amountCtrl.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.rider_fill_fields_hint),
                    ),
                  );
                  return;
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Withdrawal of #${_amountCtrl.text} initiated',
                    ),
                  ),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                minimumSize: Size(0, isTablet ? 56 : 52),
                shape: const StadiumBorder(),
                elevation: 0,
                textStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 17 : 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(l10n.rider_withdraw_btn),
            ),
          ),
        ),
      ),
    );
  }
}
