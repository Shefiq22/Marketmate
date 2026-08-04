import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_mate/dashboard/seller/data/mock_products.dart';
import 'package:market_mate/features/auth/provider/seller_onboarding_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/document_picker_sheet.dart';

const _idTypes = [
  "Driver's Licence",
  'National ID',
  'International Passport',
  "Voter's Card",
  'NIN',
];

class SellerOnboardingPage extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const SellerOnboardingPage({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  @override
  ConsumerState<SellerOnboardingPage> createState() =>
      _SellerOnboardingPageState();
}

class _SellerOnboardingPageState
    extends ConsumerState<SellerOnboardingPage> {
  bool _currentStepValid(SellerOnboardingFormState form) {
    switch (form.internalStep) {
      case 0: return form.step1Valid;
      case 1: return form.step2Valid;
      case 2: return form.step3Valid;
      default: return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(sellerOnboardingFormProvider);
    final notifier = ref.read(sellerOnboardingFormProvider.notifier);
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = isTablet ? size.width * 0.1 : size.width * 0.055;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, size.height * 0.012, hPad, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: _buildStep(form, notifier, size, isTablet, isDark),
            ),
          ),
          if (form.error != null)
            Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.012),
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
          Padding(
            padding: EdgeInsets.fromLTRB(
              0,
              size.height * 0.018,
              0,
              padding.bottom + size.height * 0.036,
            ),
            child: Row(
              children: [
                if (form.internalStep > 0)
                  Expanded(
                    child: SizedBox(
                      height: isTablet ? size.height * 0.086 : size.height * 0.077,
                      child: OutlinedButton(
                        onPressed: () =>
                            notifier.setInternalStep(form.internalStep - 1),
                        style: OutlinedButton.styleFrom(
                          shape: const StadiumBorder(),
                          side: BorderSide(
                            color: isDark ? AppColors.borderDark : AppColors.border,
                          ),
                          textStyle: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: isTablet ? 18 : 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Back'),
                      ),
                    ),
                  ),
                if (form.internalStep > 0) SizedBox(width: size.width * 0.032),
                Expanded(
                  child: SizedBox(
                    height: isTablet ? size.height * 0.086 : size.height * 0.077,
                      child: ElevatedButton(
                          onPressed: _currentStepValid(form) && !form.isLoading
                              ? () => _handleNext(form, notifier)
                              : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor: isDark
                            ? AppColors.borderDark
                            : AppColors.border,
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
                          : Text(
                              form.internalStep < 2 ? 'Next' : 'Submit',
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _handleNext(
    SellerOnboardingFormState form,
    SellerOnboardingNotifier notifier,
  ) {
    if (form.internalStep == 2) {
      widget.onNext();
      return;
    }
    notifier.setInternalStep(form.internalStep + 1);
  }

  Widget _buildStep(
    SellerOnboardingFormState form,
    SellerOnboardingNotifier notifier,
    Size size,
    bool isTablet,
    bool isDark,
  ) {
    switch (form.internalStep) {
      case 0:
        return _StoreInfoStep(
          form: form,
          notifier: notifier,
          size: size,
          isTablet: isTablet,
          isDark: isDark,
        );
      case 1:
        return _CategoriesStep(
          form: form,
          notifier: notifier,
          size: size,
          isTablet: isTablet,
          isDark: isDark,
        );
      case 2:
        return _KycStep(
          form: form,
          notifier: notifier,
          size: size,
          isTablet: isTablet,
          isDark: isDark,
        );
      default:
        return const SizedBox();
    }
  }
}

class _StoreInfoStep extends StatelessWidget {
  final SellerOnboardingFormState form;
  final SellerOnboardingNotifier notifier;
  final Size size;
  final bool isTablet;
  final bool isDark;

  const _StoreInfoStep({
    required this.form,
    required this.notifier,
    required this.size,
    required this.isTablet,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tell us about',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: size.height * 0.006),
        Text(
          'Your store',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: isTablet ? 42 : 34,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.black,
            letterSpacing: -0.8,
          ),
        ),
        SizedBox(height: size.height * 0.03),
        _FieldLabel(text: 'Store name', isTablet: isTablet, size: size),
        SizedBox(height: size.height * 0.012),
        _InputField(
          hint: 'Enter store name',
          value: form.storeName,
          onChanged: notifier.setStoreName,
          isTablet: isTablet,
          size: size,
          isDark: isDark,
        ),
        SizedBox(height: size.height * 0.024),
        _FieldLabel(
          text: 'Store description',
          isTablet: isTablet,
          size: size,
          required: false,
        ),
        SizedBox(height: size.height * 0.012),
        _InputField(
          hint: 'Describe your store (optional)',
          value: form.storeDescription,
          onChanged: notifier.setStoreDescription,
          isTablet: isTablet,
          size: size,
          isDark: isDark,
          maxLines: 3,
        ),
        SizedBox(height: size.height * 0.024),
        _FieldLabel(text: 'Street address', isTablet: isTablet, size: size),
        SizedBox(height: size.height * 0.012),
        _InputField(
          hint: 'Enter street address',
          value: form.street,
          onChanged: notifier.setStreet,
          isTablet: isTablet,
          size: size,
          isDark: isDark,
        ),
        SizedBox(height: size.height * 0.024),
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(text: 'City', isTablet: isTablet, size: size),
                  SizedBox(height: size.height * 0.012),
                  _InputField(
                    hint: 'City',
                    value: form.city,
                    onChanged: notifier.setCity,
                    isTablet: isTablet,
                    size: size,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            SizedBox(width: size.width * 0.032),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _FieldLabel(text: 'State', isTablet: isTablet, size: size),
                  SizedBox(height: size.height * 0.012),
                  _InputField(
                    hint: 'State',
                    value: form.state,
                    onChanged: notifier.setStateVal,
                    isTablet: isTablet,
                    size: size,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: size.height * 0.024),
        _FieldLabel(
          text: 'Phone number',
          isTablet: isTablet,
          size: size,
          required: false,
        ),
        SizedBox(height: size.height * 0.012),
        _InputField(
          hint: 'Phone number (optional)',
          value: form.phoneNumber,
          onChanged: notifier.setPhoneNumber,
          isTablet: isTablet,
          size: size,
          isDark: isDark,
          keyboardType: TextInputType.phone,
        ),
      ],
    );
  }
}

class _CategoriesStep extends StatelessWidget {
  final SellerOnboardingFormState form;
  final SellerOnboardingNotifier notifier;
  final Size size;
  final bool isTablet;
  final bool isDark;

  const _CategoriesStep({
    required this.form,
    required this.notifier,
    required this.size,
    required this.isTablet,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final categories =
        allCategories.where((c) => c != 'All').toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'What do you',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: size.height * 0.006),
        Text(
          'sell?',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: isTablet ? 42 : 34,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.black,
            letterSpacing: -0.8,
          ),
        ),
        SizedBox(height: size.height * 0.012),
        Text(
          'Select the categories that best describe your products',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: isTablet ? 15 : 13,
            fontWeight: FontWeight.w400,
            color: AppColors.gray2,
          ),
        ),
        SizedBox(height: size.height * 0.03),
        Wrap(
          spacing: size.width * 0.028,
          runSpacing: size.height * 0.016,
          children: categories.map((cat) {
            final selected = form.productCategories.contains(cat);
            return GestureDetector(
              onTap: () => notifier.toggleCategory(cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(
                  horizontal: size.width * 0.05,
                  vertical: size.height * 0.016,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: selected
                        ? AppColors.primary
                        : (isDark ? AppColors.borderDark : AppColors.border),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  cat,
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 15 : 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? AppColors.white : (isDark ? AppColors.textPrimaryDark : AppColors.black),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _KycStep extends ConsumerWidget {
  final SellerOnboardingFormState form;
  final SellerOnboardingNotifier notifier;
  final Size size;
  final bool isTablet;
  final bool isDark;

  const _KycStep({
    required this.form,
    required this.notifier,
    required this.size,
    required this.isTablet,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Almost done',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: isTablet ? 22 : 18,
            fontWeight: FontWeight.w500,
            color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
          ),
        ),
        SizedBox(height: size.height * 0.006),
        Text(
          'Verify identity',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: isTablet ? 42 : 34,
            fontWeight: FontWeight.w800,
            color: isDark ? AppColors.textPrimaryDark : AppColors.black,
            letterSpacing: -0.8,
          ),
        ),
        SizedBox(height: size.height * 0.012),
        Text(
          'Upload a valid ID to verify your identity',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: isTablet ? 15 : 13,
            fontWeight: FontWeight.w400,
            color: AppColors.gray2,
          ),
        ),
        SizedBox(height: size.height * 0.03),
        _FieldLabel(text: 'ID type', isTablet: isTablet, size: size),
        SizedBox(height: size.height * 0.012),
        DropdownButtonFormField<String>(
          hint: Text(
            'Select ID type',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 15 : 14,
              color: AppColors.gray2,
            ),
          ),
          items: _idTypes
              .map(
                (t) => DropdownMenuItem(
                  value: t,
                  child: Text(
                    t,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 15 : 14,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) notifier.setIdType(v);
          },
          decoration: InputDecoration(
            filled: true,
            fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: size.width * 0.04,
              vertical: size.height * 0.022,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
                width: 1.4,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: isDark ? AppColors.borderDark : AppColors.border,
                width: 2.0,
              ),
            ),
          ),
        ),
        SizedBox(height: size.height * 0.024),
        _FieldLabel(text: 'ID number', isTablet: isTablet, size: size),
        SizedBox(height: size.height * 0.012),
        _InputField(
          hint: 'Enter ID number',
          value: form.idNumber,
          onChanged: notifier.setIdNumber,
          isTablet: isTablet,
          size: size,
          isDark: isDark,
        ),
        SizedBox(height: size.height * 0.024),
        _FieldLabel(text: 'Upload ID image', isTablet: isTablet, size: size),
        SizedBox(height: size.height * 0.012),
        GestureDetector(
          onTap: form.idImageUrl.isEmpty
              ? () => _pickIdImage(context, ref)
              : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: size.width * 0.044,
              vertical: size.height * 0.021,
            ),
            decoration: BoxDecoration(
              color: form.idImageUrl.isNotEmpty
                  ? AppColors.primarySurface
                  : (isDark ? AppColors.surfaceDark : AppColors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: form.idImageUrl.isNotEmpty
                    ? AppColors.primary.withAlpha((0.4 * 255).round())
                    : AppColors.border,
                width: form.idImageUrl.isNotEmpty ? 1.5 : 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  form.idImageUrl.isNotEmpty
                      ? Icons.check_circle_outline_rounded
                      : Icons.upload_file_outlined,
                  color: form.idImageUrl.isNotEmpty
                      ? AppColors.primary
                      : AppColors.gray2,
                  size: isTablet ? 22 : 20,
                ),
                SizedBox(width: size.width * 0.032),
                Expanded(
                  child: Text(
                    form.idImageUrl.isNotEmpty
                        ? form.idImageUrl
                        : 'Upload ID image',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: form.idImageUrl.isNotEmpty
                          ? FontWeight.w600
                          : FontWeight.w400,
                      color: form.idImageUrl.isNotEmpty
                          ? (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.black)
                          : AppColors.gray2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (form.idImageUrl.isNotEmpty) ...[
                  SizedBox(width: size.width * 0.022),
                  GestureDetector(
                    onTap: () => _pickIdImage(context, ref),
                    child: Text(
                      'Replace',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: isTablet ? 13 : 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickIdImage(BuildContext context, WidgetRef ref) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DocumentPickerSheet(
        documentLabel: 'ID image',
        onCamera: () async {
          try {
            final picker = ImagePicker();
            final file = await picker.pickImage(source: ImageSource.camera);
            return file?.name;
          } catch (e) {
            return null;
          }
        },
        onFilePicker: () async {
          try {
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'heic', 'webp'],
            );
            return result?.files.single.name;
          } catch (e) {
            return null;
          }
        },
      ),
    );
    if (result != null) {
      ref.read(sellerOnboardingFormProvider.notifier).setIdImageUrl(result);
    }
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final bool isTablet;
  final Size size;
  final bool required;

  const _FieldLabel({
    required this.text,
    required this.isTablet,
    required this.size,
    this.required = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return RichText(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: isTablet ? 15 : 14,
          fontWeight: FontWeight.w700,
          color: isDark ? AppColors.textPrimaryDark : AppColors.black,
        ),
        children: [
          if (required)
            const TextSpan(
              text: ' *',
              style: TextStyle(color: AppColors.error),
            ),
        ],
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;
  final bool isTablet;
  final Size size;
  final bool isDark;
  final int? maxLines;
  final TextInputType? keyboardType;

  const _InputField({
    required this.hint,
    required this.value,
    required this.onChanged,
    required this.isTablet,
    required this.size,
    required this.isDark,
    this.maxLines,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      maxLines: maxLines,
      keyboardType: keyboardType,
      style: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: isTablet ? 16 : 15,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.textPrimaryDark : AppColors.black,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: isTablet ? 15 : 14,
          fontWeight: FontWeight.w400,
          color: AppColors.gray2,
        ),
        filled: true,
        fillColor: isDark ? AppColors.surfaceDark : AppColors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: size.width * 0.04,
          vertical: size.height * 0.022,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 1.4,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? AppColors.borderDark : AppColors.border,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
