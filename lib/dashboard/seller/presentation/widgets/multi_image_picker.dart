import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/dashboard/seller/providers/product_image_notifier.dart';

class MultiImagePicker extends ConsumerWidget {
  const MultiImagePicker({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final images = ref.watch(productImagesProvider);
    final notifier = ref.read(productImagesProvider.notifier);
    final isTablet = MediaQuery.sizeOf(context).shortestSide >= 600;
    final thumbSize = isTablet ? 100.0 : 88.0;

    return SizedBox(
      height: thumbSize + 4,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: images.length + (notifier.remaining > 0 ? 1 : 0),
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          if (index >= images.length) {
            return _AddSlot(
              size: thumbSize,
              remaining: notifier.remaining,
              onTap: () => _showPickOptions(context, notifier),
            );
          }
          return _ImageTile(
            slot: images[index],
            size: thumbSize,
            onRemove: () => notifier.removeAt(index),
          );
        },
      ),
    );
  }

  void _showPickOptions(BuildContext context, ProductImagesNotifier notifier) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 24),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_outlined,
                    color: AppColors.primary),
              ),
              title: const Text(
                'Take a photo',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                notifier.pickFromCamera();
              },
            ),
            ListTile(
              leading: Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.primarySurface,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_outlined,
                    color: AppColors.primary),
              ),
              title: const Text(
                'Choose from gallery',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                notifier.pickFromFiles();
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _AddSlot extends StatelessWidget {
  final double size;
  final int remaining;
  final VoidCallback onTap;

  const _AddSlot({
    required this.size,
    required this.remaining,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: CustomPaint(
        size: Size(size, size),
        painter: _DashBorderPainter(
          color: isDark ? AppColors.borderDark : AppColors.border,
        ),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: isDark
                ? AppColors.cardDark.withAlpha(100)
                : AppColors.gray1,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt_outlined,
                color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                '$remaining/5',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color:
                      isDark ? AppColors.textSecondaryDark : AppColors.gray2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  final ImageSlot slot;
  final double size;
  final VoidCallback onRemove;

  const _ImageTile({
    required this.slot,
    required this.size,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Image.file(
              slot.file,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.gray1,
                child: const Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.gray2,
                ),
              ),
            ),
          ),
          if (slot.status != ImageSlotStatus.uploading)
            Positioned(
              top: -4,
              right: -4,
              child: GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color.fromRGBO(0, 0, 0, 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          if (slot.status == ImageSlotStatus.uploading)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.black.withAlpha(100),
              ),
              child: const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          if (slot.status == ImageSlotStatus.failed)
            Positioned(
              bottom: 4,
              left: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(200),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Failed',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _DashBorderPainter extends CustomPainter {
  final Color color;

  _DashBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(16),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + 6).clamp(0.0, metric.length);
        final segment = metric.extractPath(distance, end);
        canvas.drawPath(segment, paint);
        distance += 10;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashBorderPainter oldDelegate) =>
      oldDelegate.color != color;
}
