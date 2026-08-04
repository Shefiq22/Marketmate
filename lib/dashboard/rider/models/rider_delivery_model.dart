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
}
