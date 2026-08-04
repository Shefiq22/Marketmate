import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/theme/app_colors.dart';

class OtpField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final FocusNode? nextFocus;
  final FocusNode? prevFocus;
  final ValueChanged<String> onChanged;

  const OtpField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    this.nextFocus,
    this.prevFocus,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final boxSize = isTablet ? 60.0 : 48.0;

    return SizedBox(
      width: boxSize,
      height: boxSize,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: isTablet ? 26 : 22,
          fontWeight: FontWeight.w600,
          color: isDark ? AppColors.textPrimaryDark : AppColors.black,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
          contentPadding: EdgeInsets.zero,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? AppColors.borderDark : AppColors.border, width: 1.2),
              ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.8),
          ),
        ),
        onChanged: (v) {
          onChanged(v);
          if (v.isNotEmpty && nextFocus != null) {
            nextFocus!.requestFocus();
          } else if (v.isEmpty && prevFocus != null) {
            prevFocus!.requestFocus();
          }
        },
      ),
    );
  }
}
