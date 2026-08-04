import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/dashboard/seller/providers/seller_bank_account_provider.dart';

class SellerManageBankPage extends ConsumerStatefulWidget {
  const SellerManageBankPage({super.key});

  @override
  ConsumerState<SellerManageBankPage> createState() =>
      _SellerManageBankPageState();
}

class _SellerManageBankPageState extends ConsumerState<SellerManageBankPage> {
  bool _showAdd = true;
  String? _selectedBank;
  bool _bankExpanded = false;
  final _accountNumberCtrl = TextEditingController();
  final _accountNameCtrl = TextEditingController();

  @override
  void dispose() {
    _accountNumberCtrl.dispose();
    _accountNameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accounts = ref.watch(sellerBankAccountsProvider);
    final defaultIdx = ref.watch(sellerDefaultBankIndexProvider);

    InputDecoration fieldDec({String? hint}) => InputDecoration(
      hintText: hint ?? 'Enter here',
      hintStyle: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
      ),
      filled: true,
      fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
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

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
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
          'Manage Bank',
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  _STabButton(
                    label: 'Add bank account',
                    selected: _showAdd,
                    onTap: () => setState(() => _showAdd = true),
                  ),
                  const SizedBox(width: 10),
                  _STabButton(
                    label: 'Mange bank accounts',
                    selected: !_showAdd,
                    onTap: () => setState(() => _showAdd = false),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _showAdd
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 24.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select bank',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () =>
                                setState(() => _bankExpanded = !_bankExpanded),
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
                                  color: _bankExpanded
                                      ? AppColors.primary
                                      : isDark
                                      ? AppColors.borderDark
                                      : AppColors.border,
                                  width: _bankExpanded ? 1.8 : 1.2,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _selectedBank ?? 'Choose',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 14,
                                      color: _selectedBank != null
                                          ? (isDark
                                                ? AppColors.textPrimaryDark
                                                : AppColors.textPrimary)
                                          : (isDark
                                                ? AppColors.textSecondaryDark
                                                : AppColors.gray2),
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: _bankExpanded ? 0.5 : 0,
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
                          if (_bankExpanded)
                            Container(
                              margin: const EdgeInsets.only(top: 4),
                              constraints: const BoxConstraints(maxHeight: 200),
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
                              child: ListView(
                                shrinkWrap: true,
                                children: sellerNigerianBanks
                                    .map(
                                      (b) => GestureDetector(
                                        onTap: () => setState(() {
                                          _selectedBank = b;
                                          _bankExpanded = false;
                                        }),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                          color: _selectedBank == b
                                              ? AppColors.primarySurface
                                              : Colors.transparent,
                                          child: Text(
                                            b,
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: 13,
                                              fontWeight: _selectedBank == b
                                                  ? FontWeight.w600
                                                  : FontWeight.w400,
                                              color: _selectedBank == b
                                                  ? AppColors.primary
                                                  : isDark
                                                  ? AppColors.textPrimaryDark
                                                  : AppColors.textPrimary,
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ),
                          const SizedBox(height: 20),
                          Text(
                            'Enter account number',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _accountNumberCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(10),
                            ],
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                            decoration: fieldDec(),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Enter account name',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _accountNameCtrl,
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              color: isDark
                                  ? AppColors.textPrimaryDark
                                  : AppColors.textPrimary,
                            ),
                            decoration: fieldDec(),
                          ),
                          const SizedBox(height: 36),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_selectedBank == null ||
                                    _accountNumberCtrl.text.isEmpty ||
                                    _accountNameCtrl.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please fill all fields'),
                                    ),
                                  );
                                  return;
                                }
                                ref
                                    .read(sellerBankAccountsProvider.notifier)
                                    .state = [
                                  ...accounts,
                                  {
                                    'name': _accountNameCtrl.text,
                                    'number': _accountNumberCtrl.text,
                                    'bank': _selectedBank!,
                                  },
                                ];
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Bank account added'),
                                  ),
                                );
                                setState(() {
                                  _selectedBank = null;
                                  _accountNumberCtrl.clear();
                                  _accountNameCtrl.clear();
                                  _showAdd = false;
                                });
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
                              child: const Text('Add bank account'),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 16.0),
                      itemCount: accounts.length,
                      separatorBuilder: (_, _) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final acc = accounts[i];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    acc['name'] ?? '',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? AppColors.textPrimaryDark
                                          : AppColors.textPrimary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    acc['number'] ?? '',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    acc['bank'] ?? '',
                                    style: TextStyle(
                                      fontFamily: 'Plus Jakarta Sans',
                                      fontSize: 12,
                                      color: isDark
                                          ? AppColors.textSecondaryDark
                                          : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  ref
                                      .read(
                                        sellerDefaultBankIndexProvider.notifier,
                                      )
                                      .state = i;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        '${acc['bank']} set as default',
                                      ),
                                    ),
                                  );
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      'Set as default',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: 12,
                                        color: AppColors.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Container(
                                      width: 16,
                                      height: 16,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.secondary,
                                        ),
                                        color: defaultIdx == i
                                            ? AppColors.secondary
                                            : Colors.transparent,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _STabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _STabButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : isDark
                ? AppColors.borderDark
                : AppColors.border,
            width: selected ? 1.8 : 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? AppColors.primary
                : isDark
                ? AppColors.textSecondaryDark
                : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
