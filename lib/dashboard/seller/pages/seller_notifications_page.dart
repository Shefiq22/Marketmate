import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../buyer/widgets/common_widgets.dart';

class _NotificationItem {
  final String id;
  final String message;
  final String time;
  final bool isToday;
  _NotificationItem({
    required this.id,
    required this.message,
    required this.time,
    required this.isToday,
  });
}

final _mockNotifications = [
  _NotificationItem(
    id: '1',
    message:
        "Payment of #45,000.00 has been made into your account from Market Make.",
    time: '12:00pm',
    isToday: true,
  ),
  _NotificationItem(
    id: '2',
    message:
        "Reminder: The 'Gourmet Greens' buyer from Verdant Valley Farms is looking for fresh arugula. Offer your supply now!",
    time: '10:30am',
    isToday: true,
  ),
  _NotificationItem(
    id: '3',
    message:
        "Payment of #45,000.00 has been made into your account from Market Make.",
    time: '2 days ago',
    isToday: false,
  ),
  _NotificationItem(
    id: '4',
    message:
        "Hot deal! 'Golden Sunrise' peaches are in high demand. List your supply to get premium prices from local bakeries.",
    time: '2 days ago',
    isToday: false,
  ),
  _NotificationItem(
    id: '5',
    message:
        "Price drop alert! The price of 'Ruby Red Tomatoes' has decreased by 15% at Farmer John's Market.",
    time: '2 days ago',
    isToday: false,
  ),
];

class SellerNotificationsPage extends StatefulWidget {
  const SellerNotificationsPage({super.key});

  @override
  State<SellerNotificationsPage> createState() =>
      _SellerNotificationsPageState();
}

class _SellerNotificationsPageState
    extends State<SellerNotificationsPage> {
  bool _hasData = true;

  void _handleClearAll() {
    setState(() => _hasData = false);
  }

  void _showNotificationDetail(
    BuildContext context,
    _NotificationItem item,
    bool isTablet,
    bool isDark,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.45 * 255).round()),
      builder: (_) => _NotificationDetailDialog(
        item: item,
        isTablet: isTablet,
        isDark: isDark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasData = _hasData;

    final todayItems = _mockNotifications.where((n) => n.isToday).toList();
    final olderItems = _mockNotifications.where((n) => !n.isToday).toList();

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
          if (hasData)
            TextButton(
              onPressed: _handleClearAll,
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
            child: !hasData
                ? EmptyState(
                    emoji: '🔔',
                    title: AppLocalizations.of(context)!.notif_empty_title,
                    subtitle: AppLocalizations.of(context)!.notif_empty_desc,
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24.0),
                        if (todayItems.isNotEmpty) ...[
                          _SectionLabel(label: AppLocalizations.of(context)!.notif_today, isDark: isDark),
                          const SizedBox(height: 8.0),
                          ...todayItems.map(
                            (n) => _NotifTile(
                              item: n,
                              isTablet: isTablet,
                              isDark: isDark,
                              onTap: () =>
                                  _showNotificationDetail(context, n, isTablet, isDark),
                            ),
                          ),
                        ],
                        if (olderItems.isNotEmpty) ...[
                          const SizedBox(height: 24.0),
                          _SectionLabel(label: AppLocalizations.of(context)!.notif_older, isDark: isDark),
                          const SizedBox(height: 8.0),
                          ...olderItems.map(
                            (n) => _NotifTile(
                              item: n,
                              isTablet: isTablet,
                              isDark: isDark,
                              onTap: () =>
                                  _showNotificationDetail(context, n, isTablet, isDark),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24.0),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionLabel({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: 'Plus Jakarta Sans',
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: isDark ? AppColors.textSecondaryDark : Colors.grey[600],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final _NotificationItem item;
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
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
                      Text(
                        item.message,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            height: 32.0,
            thickness: 0.8,
            color: isDark ? Colors.grey[700] : Colors.grey[200],
          ),
        ],
      ),
    );
  }
}

class _NotificationDetailDialog extends StatelessWidget {
  final _NotificationItem item;
  final bool isTablet;
  final bool isDark;
  const _NotificationDetailDialog({
    required this.item,
    required this.isTablet,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    return Dialog(
      backgroundColor: isDark ? AppColors.cardDark : Colors.white,
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
              'Message',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 20 : 18,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textPrimaryDark : Colors.black,
              ),
            ),
            SizedBox(height: size.height * 0.027),
            Text(
              item.message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 15 : 14,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                height: 1.6,
              ),
            ),
            SizedBox(height: size.height * 0.027),
            Text(
              item.isToday
                  ? 'Today | ${item.time}'
                  : '${item.time} | ${item.time}',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: isTablet ? 13 : 12,
                color: AppColors.gray2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
