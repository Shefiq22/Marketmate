import 'package:flutter/material.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../widgets/common_widgets.dart';

class ReviewScreen extends StatefulWidget {
  final List<CartItem> items;
  const ReviewScreen({super.key, required this.items});
  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 4;
  final _commentCtrl = TextEditingController();
  final List<String> _tags = [];
  bool _submitted = false;

  final _tagOptions = [
    'Fast delivery',
    'Great quality',
    'Fresh products',
    'Tasty and big',
    'Would recommend',
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_submitted) return _SuccessView();

    final firstItem = widget.items.first;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Back
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Icon(
                    Icons.arrow_back_ios_new,
                    size: 18,
                    color: isDark ? AppColors.darkText : AppColors.text,
                  ),
                ),
              ),
            ),
            // Product
            AppNetworkImage(
              imageUrl: firstItem.product.imageUrl,
              width: 80,
              height: 80,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(height: 8),
            Text(
              firstItem.product.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.text,
              ),
            ),
            Text(
              'Quantity ${firstItem.quantity}',
              style: TextStyle(
                fontSize: 12,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.grey500,
              ),
            ),

            const SizedBox(height: 28),
            Text(
              'How was your order?',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.darkText : AppColors.text,
              ),
            ),
            const SizedBox(height: 16),

            // Stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return GestureDetector(
                  onTap: () => setState(() => _rating = i + 1),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < _rating
                          ? Icons.star_rounded
                          : Icons.star_outline_rounded,
                      size: 36,
                      color: i < _rating ? AppColors.star : AppColors.grey300,
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            Text(
              _rating >= 4
                  ? 'Very good!'
                  : _rating == 3
                  ? 'Good'
                  : 'Could be better',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.darkTextSecondary
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Give a review?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkText : AppColors.text,
              ),
            ),
            const SizedBox(height: 10),

            // Tags
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: _tagOptions.map((tag) {
                final selected = _tags.contains(tag);
                return GestureDetector(
                  onTap: () => setState(() {
                    selected ? _tags.remove(tag) : _tags.add(tag);
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? (isDark
                                ? AppColors.primaryDark.withAlpha(0x40)
                                : AppColors.primaryBg)
                          : (isDark ? AppColors.darkCard : AppColors.grey100),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: selected
                            ? AppColors.primary
                            : (isDark ? AppColors.darkBorder : AppColors.grey200),
                      ),
                    ),
                    child: Text(
                      tag,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: selected
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.textSecondary),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.review_hint,
                hintStyle: TextStyle(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.grey500,
                ),
              ),
            ),

            const SizedBox(height: 20),
            GreenButton(
              label: AppLocalizations.of(context)!.review_submit,
              onTap: () => setState(() => _submitted = true),
            ),
          ],
        ),
      ),
    );
  }
}

class _SuccessView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 20),
              Text(
                'Review submitted!',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.darkText : AppColors.text,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Thank you for your feedback. It helps our sellers improve.',
                style: TextStyle(
                  fontSize: 14,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              GreenButton(
                label: AppLocalizations.of(context)!.review_back_homepage,
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),
              const SizedBox(height: 12),
              GreenButton(
                label: AppLocalizations.of(context)!.review_view_orders,
                outlined: true,
                onTap: () => Navigator.of(context).popUntil((r) => r.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
