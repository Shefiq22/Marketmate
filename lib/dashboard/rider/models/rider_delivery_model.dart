enum RiderDeliveryStatus { active, pending, completed }

enum RiderDeliveryStep { accepted, headingToPick, pickedUp, delivered }

class RiderDeliveryItem {
  final String name;
  final String imageAsset;
  final int quantity;
  final double unitPrice;

  const RiderDeliveryItem({
    required this.name,
    required this.imageAsset,
    required this.quantity,
    required this.unitPrice,
  });

  double get total => unitPrice * quantity;

  String get formattedUnit => '#${_fmt(unitPrice)}';
  String get formattedTotal => '#${_fmt(total)}';

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

class RiderDeliveryModel {
  final String id;
  final String orderRef;
  final String customerName;
  final String placedDate;
  final String dateRange;
  final String pickupAddress;
  final String dropoffAddress;
  final RiderDeliveryStatus status;
  final RiderDeliveryStep currentStep;
  final String riderName;
  final String riderCode;
  final String riderStatus;
  final String lastUpdate;
  final String lastLocation;
  final String estimatedDelivery;
  final List<RiderDeliveryItem> items;
  final String deliveryAddress;
  final String paymentMethod;
  final String maskedCard;

  const RiderDeliveryModel({
    required this.id,
    required this.orderRef,
    required this.customerName,
    required this.placedDate,
    required this.dateRange,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.status,
    required this.currentStep,
    required this.riderName,
    required this.riderCode,
    required this.riderStatus,
    required this.lastUpdate,
    required this.lastLocation,
    required this.estimatedDelivery,
    required this.items,
    required this.deliveryAddress,
    required this.paymentMethod,
    required this.maskedCard,
  });

  double get total => items.fold(0, (s, i) => s + i.total);

  String get formattedTotal => '#${RiderDeliveryItem._fmt(total)}';

  /// Tolerant parser for live API responses (active order / pending
  /// assignments). Every field falls back to a safe default so a missing or
  /// differently-named key never crashes the UI.
  factory RiderDeliveryModel.fromJson(Map<String, dynamic> json) {
    String s(String key) => json[key] is String ? json[key] as String : '';
    Object? o(String key) => json[key];
    String nested(Object? value) {
      if (value == null) return '';
      if (value is String) return value;
      if (value is Map) {
        return (value['name'] ?? value['address'] ?? value['title'] ?? value['formatted'])
            .toString();
      }
      return value.toString();
    }

    final customer = o('customer');
    final pickup = o('pickupAddress') ?? o('pickup') ?? o('from');
    final dropoff = o('dropoffAddress') ?? o('dropoff') ?? o('to');

    final statusRaw = (s('status').isEmpty ? s('deliveryStatus') : s('status')).toLowerCase();
    final status = statusRaw.contains('complete')
        ? RiderDeliveryStatus.completed
        : statusRaw.contains('pending') || statusRaw.contains('assign')
            ? RiderDeliveryStatus.pending
            : RiderDeliveryStatus.active;

    final stepRaw = (s('currentStep').isEmpty ? s('step') : s('currentStep')).toLowerCase();
    final currentStep = stepRaw.contains('deliver')
        ? RiderDeliveryStep.delivered
        : stepRaw.contains('pick')
            ? RiderDeliveryStep.pickedUp
            : stepRaw.contains('heading') || stepRaw.contains('arrive')
                ? RiderDeliveryStep.headingToPick
                : RiderDeliveryStep.accepted;

    final itemsRaw = o('items');
    final items = <RiderDeliveryItem>[];
    if (itemsRaw is List) {
      for (final raw in itemsRaw) {
        if (raw is Map<String, dynamic>) {
          final price = (raw['price'] ?? raw['unitPrice'] ?? raw['amount'] ?? 0);
          final qty = raw['quantity'] ?? raw['qty'] ?? 1;
          items.add(RiderDeliveryItem(
            name: (raw['name'] ?? raw['productName'] ?? raw['title'] ?? '').toString(),
            imageAsset: (raw['image'] ?? raw['imageUrl'] ?? '').toString(),
            quantity: qty is num ? qty.toInt() : 1,
            unitPrice: price is num
                ? price.toDouble()
                : double.tryParse(price.toString()) ?? 0,
          ));
        }
      }
    }

    return RiderDeliveryModel(
      id: s('id').isEmpty ? s('_id') : s('id'),
      orderRef: s('orderRef').isEmpty ? s('order_ref') : s('orderRef'),
      customerName: nested(customer),
      placedDate: s('placedDate').isEmpty ? s('createdAt') : s('placedDate'),
      dateRange: s('dateRange'),
      pickupAddress: nested(pickup),
      dropoffAddress: nested(dropoff),
      status: status,
      currentStep: currentStep,
      riderName: s('riderName'),
      riderCode: s('riderCode'),
      riderStatus: s('riderStatus'),
      lastUpdate: s('lastUpdate').isEmpty ? s('updatedAt') : s('lastUpdate'),
      lastLocation: s('lastLocation'),
      estimatedDelivery: s('estimatedDelivery'),
      items: items,
      deliveryAddress: s('deliveryAddress').isEmpty ? nested(dropoff) : s('deliveryAddress'),
      paymentMethod: s('paymentMethod'),
      maskedCard: s('maskedCard'),
    );
  }
}
