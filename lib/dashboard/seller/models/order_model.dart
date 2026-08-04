enum OrderStatus { confirmed, processed, shipped, delivered }

enum OrderTabStatus { active, pending, completed, cancelled }

class OrderItem {
  final String name;
  final String imageAsset;
  final int quantity;
  final double unitPrice;

  const OrderItem({
    required this.name,
    required this.imageAsset,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
    name: json['name'] as String? ?? '',
    imageAsset: json['imageUrl'] as String? ??
        json['imageAsset'] as String? ??
        '',
    quantity: json['quantity'] as int? ?? 0,
    unitPrice: (json['unitPrice'] as num?)?.toDouble() ??
        (json['price'] as num?)?.toDouble() ??
        0,
  );

  double get total => unitPrice * quantity;

  String get formattedUnit => '₦${_fmt(unitPrice)}';
  String get formattedTotal => '₦${_fmt(total)}';

  static String _fmt(double v) {
    final s = v.toStringAsFixed(0);
    final buf = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write(',');
      buf.write(s[i]);
    }
    return buf.toString();
  }
}

class OrderTimelineStep {
  final String label;
  final String date;
  final String time;
  final bool completed;

  const OrderTimelineStep({
    required this.label,
    required this.date,
    required this.time,
    required this.completed,
  });

  factory OrderTimelineStep.fromJson(Map<String, dynamic> json) =>
      OrderTimelineStep(
        label: json['label'] as String? ?? json['status'] as String? ?? '',
        date: json['date'] as String? ?? '',
        time: json['time'] as String? ?? '',
        completed: json['completed'] as bool? ?? false,
      );
}

class OrderModel {
  final String id;
  final String orderRef;
  final String customerName;
  final String placedDate;
  final String dateRange;
  final OrderStatus currentStatus;
  final OrderTabStatus tabStatus;
  final String? riderName;
  final String? riderCode;
  final String? riderStatusLabel;
  final String? lastUpdate;
  final String? lastLocation;
  final String? estimatedDelivery;
  final List<OrderItem> items;
  final String deliveryAddress;
  final String paymentMethod;
  final String maskedCard;
  final List<OrderTimelineStep> timeline;
  final String status;
  final Map<String, dynamic> pricing;
  final Map<String, dynamic> payment;

  const OrderModel({
    required this.id,
    required this.orderRef,
    required this.customerName,
    required this.placedDate,
    required this.dateRange,
    required this.currentStatus,
    required this.tabStatus,
    this.riderName,
    this.riderCode,
    this.riderStatusLabel,
    this.lastUpdate,
    this.lastLocation,
    this.estimatedDelivery,
    required this.items,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.maskedCard,
    this.timeline = const [],
    this.status = 'pending',
    this.pricing = const {},
    this.payment = const {},
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    final pricingMap = json['pricing'] as Map<String, dynamic>? ?? {};
    final paymentMap = json['payment'] as Map<String, dynamic>? ?? {};
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((i) => OrderItem.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];
    final timelineList = (json['timeline'] as List<dynamic>?)
            ?.map(
              (t) => OrderTimelineStep.fromJson(t as Map<String, dynamic>),
            )
            .toList() ??
        [];

    final apiStatus = json['status'] as String? ?? 'pending';
    final localStatus = _mapStatus(apiStatus);
    final localTab = _mapTabStatus(apiStatus);

    return OrderModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      orderRef: json['orderNumber'] as String? ??
          json['orderRef'] as String? ??
          '',
      customerName: json['customerName'] as String? ?? '',
      placedDate: json['placedDate'] as String? ??
          json['createdAt'] as String? ??
          '',
      dateRange: json['dateRange'] as String? ?? '',
      currentStatus: localStatus,
      tabStatus: localTab,
      riderName: json['rider'] is Map ? (json['rider'] as Map)['name'] as String? : null,
      riderCode: json['riderCode'] as String?,
      riderStatusLabel: json['riderStatusLabel'] as String?,
      lastUpdate: json['lastUpdate'] as String?,
      lastLocation: json['lastLocation'] as String?,
      estimatedDelivery: json['estimatedDelivery'] as String? ??
          json['eta'] as String?,
      items: itemsList,
      deliveryAddress: json['deliveryAddress'] as String? ??
          (json['deliveryAddress'] as Map<String, dynamic>?)?.toString() ??
          '',
      paymentMethod: paymentMap['method'] as String? ??
          json['paymentMethod'] as String? ??
          '',
      maskedCard: json['maskedCard'] as String? ?? '',
      timeline: timelineList,
      status: apiStatus,
      pricing: pricingMap,
      payment: paymentMap,
    );
  }

  static OrderStatus _mapStatus(String s) {
    switch (s) {
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
        return OrderStatus.confirmed;
    }
  }

  static OrderTabStatus _mapTabStatus(String s) {
    switch (s) {
      case 'completed':
      case 'order_arrived':
        return OrderTabStatus.completed;
      case 'pending':
      case 'order_accepted':
        return OrderTabStatus.pending;
      case 'cancelled':
      case 'rejected':
        return OrderTabStatus.cancelled;
      default:
        return OrderTabStatus.active;
    }
  }

  double get total {
    if (pricing.isNotEmpty) {
      return ((pricing['total'] as num?)?.toDouble() ?? 0) / 100;
    }
    return items.fold(0, (sum, i) => sum + i.total);
  }

  String get formattedTotal => '₦${OrderItem._fmt(total)}';
}
