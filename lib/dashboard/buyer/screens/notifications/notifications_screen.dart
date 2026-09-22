import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/dashboard/buyer/models/models.dart';
import 'package:market_mate/dashboard/buyer/providers/notifications_provider.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../widgets/common_widgets.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  Future<void> _refresh() async {
    ref.invalidate(notificationsProvider);
    await ref.read(notificationsProvider.future);
  }

  Future<void> _markRead(AppNotification n) async {
    if (n.isRead) return;
    try {
      await ref.read(notificationsRepositoryProvider).markRead(n.id);
    } catch (_) {}
    if (!mounted) return;
    ref.invalidate(notificationsProvider);
  }

  Future<void> _clearAll() async {
    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
    } catch (_) {}
    if (!mounted) return;
    ref.invalidate(notificationsProvider);
  }

  Future<void> _delete(AppNotification n) async {
    try {
      await ref.read(notificationsRepositoryProvider).delete(n.id);
    } catch (_) {}
    if (!mounted) return;
    ref.invalidate(notificationsProvider);
  }

  void _showDetail(BuildContext context, AppNotification item, bool isTablet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.45 * 255).round()),
      builder: (ctx) => _NotifDetailDialog(
        item: item,
        isTablet: isTablet,
        isDark: isDark,
        onDelete: () => _delete(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, size: 20.0, color: isDark ? AppColors.textPrimaryDark : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          "Notifications",
          style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: isDark ? AppColors.textPrimaryDark : Colors.black),
        ),
        centerTitle: false,
        actions: [
          if (notificationsAsync.asData?.value.isNotEmpty ?? false)
            TextButton(
              onPressed: _clearAll,
              child: const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Text(
                  "Clear all",
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 14.0),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: notificationsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Could not load notifications',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textPrimaryDark : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Pull to refresh or try again later.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 13,
                        color: AppColors.gray2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _refresh,
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return EmptyState(
                    emoji: '🔔',
                    title: AppLocalizations.of(context)!.notif_empty_title,
                    subtitle: AppLocalizations.of(context)!.notif_empty_desc,
                  );
                }
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      thickness: 0.8,
                      color: isDark ? Colors.grey[700] : Colors.grey[200],
                    ),
                    itemBuilder: (context, index) {
                      final n = items[index];
                      return _NotifTile(
                        item: n,
                        isTablet: isTablet,
                        isDark: isDark,
                        onTap: () {
                          _markRead(n);
                          _showDetail(context, n, isTablet);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final AppNotification item;
  final bool isTablet;
  final bool isDark;
  final VoidCallback onTap;
  const _NotifTile({
    required this.item,
    required this.isTablet,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = item.imageUrl;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: isTablet ? 40 : 36,
              height: isTablet ? 40 : 36,
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.green.withValues(alpha: 0.20)
                    : Colors.green.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/icons/messages.svg',
                  width: isTablet ? 20 : 18,
                  height: isTablet ? 20 : 18,
                  semanticsLabel: 'Messages icon',
                  fit: BoxFit.contain,
                  colorFilter: ColorFilter.mode(
                    isDark ? Colors.white : Colors.green,
                    BlendMode.srcIn,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item.title.isNotEmpty) ...[
                    Text(
                      item.title,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textPrimaryDark : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    item.body,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 13,
                      color: isDark ? AppColors.textPrimaryDark : Colors.black,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    item.time,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 12,
                      color: isDark ? AppColors.textSecondaryDark : Colors.grey[500],
                    ),
                  ),
                  if (imageUrl != null && imageUrl.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: 160,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotifDetailDialog extends StatelessWidget {
  final AppNotification item;
  final bool isTablet;
  final bool isDark;
  final VoidCallback onDelete;
  const _NotifDetailDialog({
    required this.item,
    required this.isTablet,
    required this.isDark,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final imageUrl = item.imageUrl;
    return Dialog(
      backgroundColor: isDark ? AppColors.elevatedDark : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(
          size.shortestSide >= 600 ? size.width * 0.047 : size.height * 0.036,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: size.shortestSide >= 600
                      ? size.width * 0.047
                      : size.width * 0.053,
                  height: size.shortestSide >= 600
                      ? size.width * 0.047
                      : size.width * 0.053,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16,
                    color: isDark ? AppColors.textPrimaryDark : Colors.black,
                  ),
                ),
              ),
            ),
            SizedBox(height: size.height * 0.013),
            Text(
              item.title.isNotEmpty ? item.title : 'Notification',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: size.height * 0.027),
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  height: 200,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                ),
              ),
              SizedBox(height: size.height * 0.02),
            ],
            Text(
              item.body,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 15 : 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            Text(
              item.time,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 13 : 12,
                color: AppColors.gray2,
              ),
            ),
            SizedBox(height: size.height * 0.02),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onDelete();
              },
              icon: const Icon(Icons.delete_outline, size: 18),
              label: const Text('Delete'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                textStyle: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}