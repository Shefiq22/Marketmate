import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:market_mate/features/auth/provider/rider_documents_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../widgets/document_picker_sheet.dart';

class RiderDocumentsPage extends ConsumerWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const RiderDocumentsPage({
    super.key,
    required this.onNext,
    required this.onBack,
  });

  Future<String?> _pickFromCamera(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(source: ImageSource.camera);
      return file?.name;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera unavailable on this device.')),
        );
      }
      return null;
    }
  }

  Future<String?> _pickFromFiles(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx',
          'jpg',
          'jpeg',
          'png',
          'heic',
          'webp',
          'tiff',
          'bmp',
        ],
      );
      return result?.files.single.name;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open file picker: ${e.toString()}'),
          ),
        );
      }
      return null;
    }
  }

  Future<void> _showPickerSheet(
    BuildContext context,
    WidgetRef ref,
    RiderDocument doc,
  ) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DocumentPickerSheet(
        documentLabel: doc.label,
        onCamera: () => _pickFromCamera(context),
        onFilePicker: () => _pickFromFiles(context),
      ),
    );
    if (result != null) {
      ref.read(riderDocumentsProvider.notifier).setDocument(doc, result);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final docs = ref.watch(riderDocumentsProvider);
    final allUploaded = ref.watch(riderDocumentsProvider.notifier).allUploaded;
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = isTablet ? size.width * 0.1 : size.width * 0.055;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(hPad, size.height * 0.012, hPad, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'A little bit more',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 22 : 18,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Continue',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 42 : 34,
                    fontWeight: FontWeight.w800,
                    color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                    letterSpacing: -0.8,
                  ),
                ),
                SizedBox(height: size.height * 0.03),
                ...RiderDocument.values.map((doc) {
                  final fileName = docs[doc];
                  return Padding(
                    padding: EdgeInsets.only(bottom: size.height * 0.027),
                    child: _DocumentField(
                      label: doc.label,
                      fileName: fileName,
                      isTablet: isTablet,
                      onTap: () => _showPickerSheet(context, ref, doc),
                      onReplace: () => _showPickerSheet(context, ref, doc),
                    ),
                  );
                }),
                SizedBox(
                  height: isTablet ? size.height * 0.023 : size.height * 0.014,
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(
            hPad,
            size.height * 0.018,
            hPad,
            padding.bottom + size.height * 0.036,
          ),
          child: SizedBox(
            width: double.infinity,
            height: isTablet ? size.height * 0.086 : size.height * 0.077,
            child: ElevatedButton(
              onPressed: allUploaded ? onNext : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: isDark ? AppColors.borderDark : AppColors.border,
                disabledForegroundColor: AppColors.gray2,
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
        ),
      ],
    );
  }
}

class _DocumentField extends StatelessWidget {
  final String label;
  final String? fileName;
  final bool isTablet;
  final VoidCallback onTap;
  final VoidCallback onReplace;

  const _DocumentField({
    required this.label,
    required this.fileName,
    required this.isTablet,
    required this.onTap,
    required this.onReplace,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasFile = fileName != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: isTablet ? 15 : 14,
              fontWeight: FontWeight.w700,
              color: isDark ? AppColors.textPrimaryDark : AppColors.black,
            ),
            children: const [
              TextSpan(
                text: ' *',
                style: TextStyle(color: AppColors.error),
              ),
            ],
          ),
        ),
        SizedBox(height: size.height * 0.012),
        GestureDetector(
          onTap: hasFile ? null : onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? size.width * 0.055 : size.width * 0.044,
              vertical: isTablet ? size.height * 0.026 : size.height * 0.021,
            ),
            decoration: BoxDecoration(
              color: hasFile
                  ? AppColors.primarySurface
                  : (isDark ? AppColors.surfaceDark : AppColors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasFile
                    ? AppColors.primary.withAlpha((0.4 * 255).round())
                    : AppColors.border,
                width: hasFile ? 1.5 : 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasFile ? Icons.delete_outline_rounded : Icons.link_rounded,
                  color: hasFile ? AppColors.primary : AppColors.gray2,
                  size: isTablet ? 22 : 20,
                ),
                SizedBox(
                  width: isTablet ? size.width * 0.038 : size.width * 0.032,
                ),
                Expanded(
                  child: Text(
                    hasFile ? fileName! : 'Attach document here',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 15 : 13,
                      fontWeight: hasFile ? FontWeight.w600 : FontWeight.w400,
                      color: hasFile
                          ? (isDark
                                ? AppColors.textPrimaryDark
                                : AppColors.black)
                          : AppColors.gray2,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (hasFile) ...[
                  SizedBox(width: size.width * 0.022),
                  GestureDetector(
                    onTap: onReplace,
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
}
