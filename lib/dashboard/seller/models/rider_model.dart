class RiderReview {
  final String reviewerName;
  final String comment;
  final String date;
  const RiderReview({
    required this.reviewerName,
    required this.comment,
    required this.date,
  });
}

class RiderModel {
  final String id;
  final String name;
  final int completedDeliveries;
  final double rating;
  final double distanceKm;
  final String vehicleInfo;
  final String plateNumber;
  final bool isVerified;
  final Map<int, double> ratingBreakdown;
  final List<RiderReview> reviews;
  final double lat;
  final double lng;

  const RiderModel({
    required this.id,
    required this.name,
    required this.completedDeliveries,
    required this.rating,
    required this.distanceKm,
    required this.vehicleInfo,
    required this.plateNumber,
    this.isVerified = true,
    this.ratingBreakdown = const {3: 100, 2: 0, 1: 0},
    this.reviews = const [],
    this.lat = 6.5244,
    this.lng = 3.3792,
  });

  String get formattedRating => '${rating.toStringAsFixed(1)}/4.0';
  String get formattedDistance => '${distanceKm.toStringAsFixed(0)}km away';
}
