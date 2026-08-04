import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/core/network/api_client.dart';
import 'package:market_mate/core/network/api_endpoints.dart';
import 'package:market_mate/core/theme/app_colors.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';
import 'package:market_mate/features/chat/presentation/pages/order_chat_page.dart';
import 'package:market_mate/l10n/app_localizations.dart';

final _messagesConversationsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final currentUser = ref.watch(currentUserProvider);
  final role = currentUser?.role ?? 'customer';
  final client = ApiClient();

  final ApiResponse res;
  switch (role) {
    case 'seller':
      res = await client.get(ApiEndpoints.sellersOrders);
    case 'rider':
      res = await client.get(ApiEndpoints.ridersMeOrders);
    default:
      res = await client.get(ApiEndpoints.orders);
  }

  if (!res.success) throw Exception(res.message);
  return res.dataList.cast<Map<String, dynamic>>();
});

class SellerMessagesPage extends ConsumerStatefulWidget {
  const SellerMessagesPage({super.key});

  @override
  ConsumerState<SellerMessagesPage> createState() => _SellerMessagesPageState();
}

class _SellerMessagesPageState extends ConsumerState<SellerMessagesPage> {
  final _searchCtrl = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final padding = MediaQuery.paddingOf(context);
    final isTablet = size.shortestSide >= 600;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hPad = isTablet ? size.width * 0.08 : 20.0;
    final conversationsAsync = ref.watch(_messagesConversationsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
              child: GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Icon(
                  Icons.chevron_left_rounded,
                  size: 28,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 16),
              child: Text(
                AppLocalizations.of(context)!.menu_messages,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 26 : 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v),
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: isTablet ? 15 : 14,
                  color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                ),
                decoration: InputDecoration(
                  hintText: 'Search here',
                  hintStyle: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: isTablet ? 15 : 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: isDark ? AppColors.cardDark : AppColors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: BorderSide(
                      color: isDark ? AppColors.borderDark : AppColors.border,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(100),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: conversationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      'Could not load conversations.\n$e',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontSize: 14,
                        color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
                data: (orders) {
                  final filtered = orders.where((o) {
                    final id = (o['_id'] ?? o['id'] ?? '').toString().toLowerCase();
                    return _query.isEmpty || id.contains(_query.toLowerCase());
                  }).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 48,
                            color: AppColors.gray2,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No conversations yet',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Your order conversations will appear here',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 13,
                              color: AppColors.gray2,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    padding: EdgeInsets.fromLTRB(hPad, 8, hPad, padding.bottom + 16),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => Divider(
                      height: 1,
                      color: isDark ? AppColors.dividerDark : AppColors.divider,
                    ),
                    itemBuilder: (_, i) {
                      final order = filtered[i];
                      final orderId = (order['_id'] ?? order['id'] ?? '').toString();
                      final shortId = orderId.length > 8 ? orderId.substring(0, 8) : orderId;
                      final status = (order['status'] ?? 'pending').toString();
                      final customerName = order['customerId'] is Map
                          ? ((order['customerId'] as Map)['name'] ?? 'Customer').toString()
                          : 'Customer';

                      return GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => OrderChatPage(
                              orderId: orderId,
                              targetName: customerName,
                              targetRole: 'customer',
                            ),
                          ),
                        ),
                        behavior: HitTestBehavior.opaque,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: isTablet ? 28 : 24,
                                backgroundColor: isDark ? AppColors.cardDark : AppColors.gray1,
                                child: Icon(
                                  Icons.receipt_long_rounded,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.gray2,
                                  size: isTablet ? 28 : 24,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Order #$shortId',
                                      style: TextStyle(
                                        fontFamily: 'Plus Jakarta Sans',
                                        fontSize: isTablet ? 16 : 14,
                                        fontWeight: FontWeight.w600,
                                        color: isDark ? AppColors.textPrimaryDark : AppColors.black,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _statusColor(status).withAlpha((0.15 * 255).round()),
                                            borderRadius: BorderRadius.circular(100),
                                          ),
                                          child: Text(
                                            status.replaceAll('_', ' '),
                                            style: TextStyle(
                                              fontFamily: 'Plus Jakarta Sans',
                                              fontSize: isTablet ? 12 : 11,
                                              fontWeight: FontWeight.w500,
                                              color: _statusColor(status),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.chevron_right_rounded,
                                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondary,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return AppColors.secondary;
      case 'order_accepted':
      case 'preparing_order':
        return AppColors.primary;
      case 'in_transit':
      case 'rider_assigned':
        return const Color(0xFF2196F3);
      case 'completed':
        return const Color(0xFF4CAF50);
      case 'cancelled':
        return const Color(0xFFF44336);
      default:
        return AppColors.gray2;
    }
  }
}
