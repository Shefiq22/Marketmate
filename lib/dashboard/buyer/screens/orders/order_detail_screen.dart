import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:market_mate/core/utils/order_status_utils.dart';
import 'package:market_mate/features/chat/presentation/pages/order_chat_page.dart';
import 'package:market_mate/l10n/app_localizations.dart';
import '../../theme/app_theme.dart';
import '../../models/models.dart';
import '../../providers/orders_provider.dart';
import '../../widgets/common_widgets.dart';
import 'order_complete_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20.0),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        title: Text(
          'Order ${order.displayId}',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.white : AppColors.text,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Placed on ${order.placedDate}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.grey500,
                          ),
                        ),
                      ),
                      _StatusBadge(status: order.status),
                    ],
                  ),

                  const SizedBox(height: 24.0),

                  _OrderProgress(order: order),

                  if (orderAwaitsCustomerConfirmation(order.status)) ...[
                    const SizedBox(height: 16.0),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OrderCompleteScreen(order: order),
                          ),
                        ),
                        icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
                        label: const Text('Complete Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 24.0),

                  const Text(
                    'Order Items',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 18.0),

                  ...order.items.map(
                    (item) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.border,
                        ),
                      ),
                      child: Row(
                        children: [
                          AppNetworkImage(
                            imageUrl: item.product.imageUrl,
                            width: 64,
                            height: 64,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.product.category,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.grey500,
                                  ),
                                ),
                                Text(
                                  item.product.name,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark
                                        ? AppColors.white
                                        : AppColors.black,
                                  ),
                                ),
                                Text(
                                  formatPrice(item.product.price),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Text(
                          '× ${item.quantity}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.grey700,
                          ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24.0),

                  _PriceRow(
                    label: '${order.items.length} items',
                    value: formatPrice(order.total - order.deliveryFee),
                  ),
                  _PriceRow(
                    label: AppLocalizations.of(context)!.order_detail_delivery,
                    value: formatPrice(order.deliveryFee),
                  ),
                  Divider(
                    color: isDark ? AppColors.darkDivider : AppColors.border,
                  ),
                  _PriceRow(
                    label: AppLocalizations.of(context)!.order_detail_subtotal,
                    value: formatPrice(order.total),
                    bold: true,
                  ),

                  const SizedBox(height: 24.0),

                  Row(
                    children: [
                      Expanded(
                        child: _InfoBox(
                          icon: Icons.location_on_outlined,
                          title: AppLocalizations.of(context)!.order_detail_delivery_address,
                          content: order.deliveryAddress,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _InfoBox(
                          icon: Icons.payment_outlined,
                          title: AppLocalizations.of(context)!.order_detail_payment_method,
                          content: order.paymentMethod,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => OrderChatPage(
                            orderId: order.id,
                            targetName: 'Seller',
                            targetRole: 'seller',
                          ),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                      label: Text(AppLocalizations.of(context)!.order_detail_message_seller),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final group = OrderStatusUtils.tabGroup(status);
    final color = group == 'active'
        ? AppColors.primary
        : group == 'pending'
        ? AppColors.orange
        : AppColors.grey500;
    final label = group == 'active'
        ? 'Active'
        : group == 'pending'
        ? 'Pending'
        : 'Completed';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

String _formatTimestamp(String raw) {
  final dt = DateTime.tryParse(raw);
  if (dt == null) return '';
  return DateFormat('MMMM d, y — hh:mm a').format(dt.toLocal());
}

class _OrderProgress extends StatelessWidget {
  final Order order;
  const _OrderProgress({required this.order});

  String _dateFor(List<String> matchStatuses) {
    final matches =
        order.statusHistory.where((e) => matchStatuses.contains(e.status));
    if (matches.isEmpty) return '';
    return _formatTimestamp(matches.last.changedAt);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    final currentStep = OrderStatusUtils.trackingStep(order.status).index;

    final steps = [
      {'label': l10n.order_detail_ordered, 'done': true},
      {'label': l10n.order_detail_confirmed, 'done': currentStep >= 1},
      {'label': l10n.order_detail_shipped, 'done': currentStep >= 2},
      {'label': l10n.order_detail_delivered, 'done': currentStep >= 3},
    ];

    final items = [
      {
        'title': l10n.order_detail_ordered,
        'subtitle': 'Your order has been received',
        'date': _dateFor(['pending', 'order_accepted']),
        'done': true,
      },
      {
        'title': l10n.order_detail_confirmed,
        'subtitle': "We've confirmed your order",
        'date': _dateFor(['order_accepted']),
        'done': currentStep >= 1,
      },
      {
        'title': l10n.order_detail_shipped,
        'subtitle': 'Your order is on the way',
        'date': _dateFor(['in_transit', 'rider_assigned', 'ready_for_pickup']),
        'done': currentStep >= 2,
      },
      {
        'title': l10n.order_detail_delivered,
        'subtitle': 'Expected delivery',
        'date': _dateFor(['order_arrived', 'completed', 'delivered']),
        'done': currentStep >= 3,
      },
    ];

    return Column(
      children: [
        Row(
          children: List.generate(steps.length, (i) {
            final done = steps[i]['done'] as bool;
            return Expanded(
              child: Row(
                children: [
                  Column(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: done ? AppColors.primary : AppColors.grey300,
                        ),
                        child: done
                            ? const Icon(
                                Icons.check,
                                size: 12,
                                color: AppColors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        steps[i]['label'] as String,
                        style: TextStyle(
                          fontSize: 10,
                          color: done
                              ? AppColors.primary
                              : (isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.grey400),
                          fontWeight: done ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  if (i < steps.length - 1)
                    Expanded(
                      child: Container(
                        height: 2,
                        margin: const EdgeInsets.only(bottom: 20),
                        color: done
                            ? AppColors.primary
                            : (isDark
                                  ? AppColors.darkDivider
                                  : AppColors.grey300),
                      ),
                    ),
                ],
              ),
            );
          }),
        ),
        const SizedBox(height: 24.0),
        if (order.statusHistory.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Detailed timeline unavailable for this order.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkTextSecondary : AppColors.grey400,
              ),
            ),
          )
        else
          ...items.map((item) {
            final done = item['done'] as bool;
            final date = item['date'] as String;
            return Padding(
              padding: const EdgeInsets.only(bottom: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    margin: const EdgeInsets.only(top: 2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: done ? AppColors.primary : AppColors.grey300,
                      border: Border.all(
                        color: done ? AppColors.primary : AppColors.grey300,
                        width: 2,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: done
                                ? (isDark ? AppColors.white : AppColors.text)
                                : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.grey400),
                          ),
                        ),
                        Text(
                          item['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 12,
                            color: done
                                ? (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.textSecondary)
                                : (isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.grey300),
                          ),
                        ),
                        if (date.isNotEmpty)
                          Text(
                            date,
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.grey400,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}

class _PriceRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  const _PriceRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
              color: bold
                  ? (isDark ? AppColors.white : AppColors.text)
                  : (isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              color: bold
                  ? AppColors.primary
                  : (isDark ? AppColors.white : AppColors.text),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String title;
  final String content;
  const _InfoBox({
    required this.icon,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 14,
                color: isDark ? AppColors.darkTextSecondary : AppColors.grey500,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? AppColors.white : AppColors.text,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
