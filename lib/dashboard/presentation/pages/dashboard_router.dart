import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:market_mate/dashboard/buyer/buyer_main.dart';
import 'package:market_mate/dashboard/rider/presentation/pages/rider_dashboard.dart';
import 'package:market_mate/dashboard/seller/pages/seller_main_screen.dart';
import 'package:market_mate/features/auth/provider/auth_provider.dart';
import 'package:market_mate/features/auth/provider/current_user_provider.dart';

class DashboardRouter extends ConsumerStatefulWidget {
  const DashboardRouter({super.key});

  @override
  ConsumerState<DashboardRouter> createState() => _DashboardRouterState();
}

class _DashboardRouterState extends ConsumerState<DashboardRouter> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();

    // Defer dashboard construction to post-frame so the navigation
    // transition from the splash screen completes before we build
    // the potentially heavy widget tree.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _ready = true);
    });

    // Token refresh can happen in background; it will trigger a rebuild
    // via currentUserProvider when done.
    Future.microtask(
      () => ref.read(currentUserProvider.notifier).refreshFromToken(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show a lightweight loading screen on the first frame so the
    // navigation transition from splash completes without blocking
    // on the full dashboard widget tree.
    if (!_ready) {
      return const SizedBox.shrink();
    }

    final currentUser = ref.watch(currentUserProvider);

    UserRole role;
    if (currentUser != null && currentUser.role.isNotEmpty) {
      role = apiToUserRole(currentUser.role);
      debugPrint(
        '[DashboardRouter] From currentUserProvider (role="${currentUser.role}") → ${role.name}',
      );
    } else {
      role = ref.watch(activeRoleProvider);
      debugPrint('[DashboardRouter] From activeRoleProvider → ${role.name}');
    }

    final widget = switch (role) {
      UserRole.farmerOrWholesaler => const SellerMainScreen(),
      UserRole.retailerOrConsumer => const BuyerDashboard(),
      UserRole.rider => const RiderDashboard(),
    };
    debugPrint(
      '[DashboardRouter] Routing to: $runtimeType → ${widget.runtimeType}',
    );
    return widget;
  }
}
