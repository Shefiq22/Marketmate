import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/core/providers/locale_provider.dart';

class LanguagePage extends ConsumerWidget {
  const LanguagePage({super.key});

  static const _languages = [
    _Lang('en', 'English', 'English'),
    _Lang('ha', 'Harshen Hausa', 'Hausa'),
    _Lang('ig', 'Asụsụ Igbo', 'Igbo'),
    _Lang('yo', 'Èdè Yorùbá', 'Yoruba'),
    _Lang('pcm', 'Pidgin', 'Nigerian Pidgin'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLocale = ref.watch(localeProvider);
    final currentCode = currentLocale.languageCode;

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      appBar: AppBar(
        backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, size: 20, color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Language',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _languages.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: isDark ? AppColors.dividerDark : AppColors.divider,
          ),
          itemBuilder: (context, index) {
            final lang = _languages[index];
            final selected = currentCode == lang.code;
            return _LanguageRow(
              lang: lang,
              isSelected: selected,
              isDark: isDark,
              onTap: () {
                ref.read(localeProvider.notifier).setLocale(Locale(lang.code));
                Navigator.of(context).pop();
              },
            );
          },
        ),
      ),
    );
  }
}

class _Lang {
  final String code;
  final String nativeName;
  final String localizedName;
  const _Lang(this.code, this.nativeName, this.localizedName);
}

class _LanguageRow extends StatelessWidget {
  final _Lang lang;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _LanguageRow({
    required this.lang,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang.nativeName,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lang.localizedName,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_rounded, size: 16, color: Colors.white),
              ),
          ],
        ),
      ),
    );
  }
}
