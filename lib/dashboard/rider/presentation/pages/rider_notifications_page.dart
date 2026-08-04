import 'package:flutter/material.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../../buyer/widgets/common_widgets.dart';

class _RNotifItem {
  final String id;
  final String message;
  final String time;
  final bool isToday;
  _RNotifItem({
    required this.id,
    required this.message,
    required this.time,
    required this.isToday,
  });
}

final _riderMockNotifications = [
  _RNotifItem(
    id: '1',
    message:
        'New delivery assigned: Order AG-2026-6789 from Mutiat Alasela. Pick up at 12, Kola street, Surulere, Lagos.',
    time: '10:00am',
    isToday: true,
  ),
  _RNotifItem(
    id: '2',
    message:
        'Reminder: You have a pending delivery to Maurice Iwu. Please proceed to the pickup location.',
    time: '09:30am',
    isToday: true,
  ),
  _RNotifItem(
    id: '3',
    message:
        'Payment of #8,500 has been credited to your wallet for Order 156-NJNK.',
    time: '2 days ago',
    isToday: false,
  ),
  _RNotifItem(
    id: '4',
    message:
        'Delivery confirmed: Order 124-BHHUJ marked as delivered. Great job!',
    time: '2 days ago',
    isToday: false,
  ),
];

class RiderNotificationsPage extends StatefulWidget {
  const RiderNotificationsPage({super.key});

  @override
  State<RiderNotificationsPage> createState() =>
      _RiderNotificationsPageState();
}

class _RiderNotificationsPageState extends State<RiderNotificationsPage> {
  bool _hasData = true;

  void _handleClearAll() {
    setState(() => _hasData = false);
  }

  void _showDetail(BuildContext context, _RNotifItem item, bool isTablet) {
    final size = MediaQuery.sizeOf(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha((0.45 * 255).round()),
      builder: (_) => Dialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final dialogPad = constraints.maxWidth < 400
                ? size.width * 0.06
                : (isTablet ? 28.0 : 24.0);
            return Padding(
              padding: EdgeInsets.all(dialogPad),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: isDark
                                ? AppColors.borderDark
                                : AppColors.border,
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: isDark
                              ? AppColors.textPrimaryDark
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: size.height * 0.014),
                  Text(
                    'Message',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 20 : 18,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : Colors.black,
                    ),
                  ),
                  SizedBox(height: size.height * 0.024),
                  Text(
                    item.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 15 : 14,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(height: size.height * 0.024),
                  Text(
                    item.isToday
                        ? 'Today | ${item.time}'
                        : '${item.time} | ${item.time}',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: isTablet ? 13 : 12,
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.gray2,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasData = _hasData;

    final todayItems = _riderMockNotifications.where((n) => n.isToday).toList();
    final olderItems = _riderMockNotifications
        .where((n) => !n.isToday)
        .toList();

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
                            (item) => _NotifTile(
                              item: item,
                              isTablet: isTablet,
                              isDark: isDark,
                              onTap: () => _showDetail(context, item, isTablet),
                            ),
                          ),
                        ],
                        if (olderItems.isNotEmpty) ...[
                          const SizedBox(height: 24.0),
                          _SectionLabel(label: AppLocalizations.of(context)!.notif_older, isDark: isDark),
                          const SizedBox(height: 8.0),
                          ...olderItems.map(
                            (item) => _NotifTile(
                              item: item,
                              isTablet: isTablet,
                              isDark: isDark,
                              onTap: () => _showDetail(context, item, isTablet),
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
  final _RNotifItem item;
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
                    child: Icon(
                      Icons.notifications_outlined,
                      color: isDark ? Colors.white : Colors.green,
                      size: isTablet ? 20 : 18,
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
