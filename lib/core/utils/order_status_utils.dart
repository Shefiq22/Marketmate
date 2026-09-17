import 'package:market_mate/dashboard/seller/models/order_model.dart'
    show OrderStatus;

/// The ONLY place raw backend status strings get interpreted.
///
/// These strings are not new — they are exactly what
/// `OrderModel._mapStatus` / `_mapTabStatus` already used in the seller
/// dashboard. This class just makes that logic reusable by buyer and rider
/// screens instead of leaving the buyer's tab filter comparing against the
/// wrong raw strings ('active'/'pending'/'completed') that the backend
/// never actually sends.
class OrderStatusUtils {
  OrderStatusUtils._();

  /// Every raw status string the app currently understands. Keep in sync
  /// with the backend enum — if a new status arrives it will be caught by
  /// the assert in [tabGroup]/[trackingStep].
  static const List<String> knownStatuses = [
    'pending',
    'order_accepted',
    'preparing_order',
    'ready_for_pickup',
    'rider_assigned',
    'in_transit',
    'order_arrived',
    'delivered',
    'completed',
    'cancelled',
    'rejected',
  ];

  /// Buckets ANY raw backend status into the tab group ('active',
  /// 'pending', 'completed', 'cancelled') used by every buyer/seller/rider
  /// list screen.
  static String tabGroup(String rawStatus) {
    switch (rawStatus) {
      case 'completed':
      case 'order_arrived':
        return 'completed';
      case 'cancelled':
      case 'rejected':
        return 'cancelled';
      case 'pending':
      case 'order_accepted':
        return 'pending';
      default:
        assert(false, 'Unmapped order status: $rawStatus');
        return 'active';
    }
  }

  /// Maps ANY raw backend status onto the 4-step pipeline every progress
  /// bar / timeline in the app renders.
  static OrderStatus trackingStep(String rawStatus) {
    switch (rawStatus) {
      case 'completed':
      case 'order_arrived':
        return OrderStatus.delivered;
      case 'in_transit':
      case 'rider_assigned':
      case 'ready_for_pickup':
        return OrderStatus.shipped;
      case 'preparing_order':
      case 'order_accepted':
        return OrderStatus.processed;
      default:
        assert(false, 'Unmapped order status: $rawStatus');
        return OrderStatus.confirmed;
    }
  }
}