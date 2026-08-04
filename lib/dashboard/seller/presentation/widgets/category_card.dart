import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/mock_products.dart';

class CategoryCard extends StatelessWidget {
  final String category;
  final VoidCallback onTap;

  const CategoryCard({super.key, required this.category, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final imgSize = isTablet ? 80.0 : 66.0;
    final glowSize = isTablet ? 108.0 : 90.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        splashColor: AppColors.primary.withValues(alpha: 0.18),
        highlightColor: AppColors.primary.withValues(alpha: 0.08),
        onTap: () {
          debugPrint('[CategoryTap] Tapped on category: $category');
          onTap();
        },
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF242836),
                Color(0xFF1A1D27),
              ],
              stops: [0.0, 1.0],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.06),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.35),
                blurRadius: 20,
                offset: const Offset(0, 8),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.04),
                blurRadius: 24,
                offset: const Offset(0, 4),
                spreadRadius: -2,
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Glow + Image stack ──
              SizedBox(
                width: glowSize,
                height: glowSize,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow
                    Container(
                      width: glowSize,
                      height: glowSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.12),
                            AppColors.primary.withValues(alpha: 0.0),
                          ],
                          stops: const [0.0, 1.0],
                        ),
                      ),
                    ),
                    // Image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        categoryImages[category] ?? '',
                        width: imgSize,
                        height: imgSize,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Container(
                          width: imgSize,
                          height: imgSize,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            Icons.category_outlined,
                            color: AppColors.primary,
                            size: isTablet ? 36 : 30,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: isTablet ? 14 : 10),

              // ── Category label ──
              Text(
                category,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 15 : 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.88),
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
