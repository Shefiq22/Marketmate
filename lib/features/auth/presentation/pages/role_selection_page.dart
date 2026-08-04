import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/features/auth/provider/auth_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/role_option_card.dart';

class RoleSelectionPage extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const RoleSelectionPage({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedRoleProvider);
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = isTablet ? size.width * 0.1 : size.width * 0.055;
    final cardGap = size.height * 0.018;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, size.height * 0.012, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hello,',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 22 : 18,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.black,
            ),
          ),
          SizedBox(height: size.height * 0.009),
          Text(
            'Who are you?',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 42 : 34,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textPrimaryDark : AppColors.black,
              letterSpacing: -0.8,
            ),
          ),
          SizedBox(height: size.height * 0.06),
          RoleOptionCard(
            label: 'Farmer or Wholesaler',
            selected: selected == UserRole.farmerOrWholesaler,
            onTap: () => ref.read(selectedRoleProvider.notifier).state =
                UserRole.farmerOrWholesaler,
          ),
          SizedBox(height: cardGap),
          RoleOptionCard(
            label: 'Retailer or Consumer',
            selected: selected == UserRole.retailerOrConsumer,
            onTap: () => ref.read(selectedRoleProvider.notifier).state =
                UserRole.retailerOrConsumer,
          ),
          SizedBox(height: cardGap),
          RoleOptionCard(
            label: 'Rider',
            selected: selected == UserRole.rider,
            onTap: () =>
                ref.read(selectedRoleProvider.notifier).state = UserRole.rider,
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: isTablet ? size.height * 0.086 : size.height * 0.077,
            child: ElevatedButton(
              onPressed: selected != null ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: isDark
                    ? AppColors.borderDark
                    : AppColors.border,
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
              child: const Text('Next'),
            ),
          ),
          SizedBox(height: padding.bottom + size.height * 0.036),
        ],
      ),
    );
  }
}
