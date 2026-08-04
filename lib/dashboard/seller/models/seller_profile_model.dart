class StoreAddress {
  final String street;
  final String city;
  final String state;
  final List<double>? coordinates;

  const StoreAddress({
    required this.street,
    required this.city,
    required this.state,
    this.coordinates,
  });

  factory StoreAddress.fromJson(Map<String, dynamic> json) => StoreAddress(
    street: json['street'] as String? ?? '',
    city: json['city'] as String? ?? '',
    state: json['state'] as String? ?? '',
    coordinates: json['coordinates'] != null
        ? (json['coordinates'] as List).cast<double>()
        : null,
  );

  Map<String, dynamic> toJson() => {
    'street': street,
    'city': city,
    'state': state,
    if (coordinates != null) 'coordinates': coordinates,
  };
}

class SellerProfileModel {
  final String id;
  final String name;
  final String storeName;
  final String storeDescription;
  final StoreAddress? storeAddress;
  final List<String> productCategories;
  final double rating;
  final bool isApproved;
  final int totalProducts;
  final int totalOrders;
  final String? email;
  final String? phone;

  const SellerProfileModel({
    required this.id,
    required this.name,
    required this.storeName,
    this.storeDescription = '',
    this.storeAddress,
    this.productCategories = const [],
    this.rating = 0,
    this.isApproved = false,
    this.totalProducts = 0,
    this.totalOrders = 0,
    this.email,
    this.phone,
  });

  factory SellerProfileModel.fromJson(Map<String, dynamic> json) {
    final storeAddrRaw = json['storeAddress'];
    return SellerProfileModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      storeName: json['storeName'] as String? ?? '',
      storeDescription: json['storeDescription'] as String? ?? '',
      storeAddress: storeAddrRaw is Map
          ? StoreAddress.fromJson(storeAddrRaw as Map<String, dynamic>)
          : null,
      productCategories: (json['productCategories'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      isApproved: json['isApproved'] as bool? ?? false,
      totalProducts: json['totalProducts'] as int? ?? 0,
      totalOrders: json['totalOrders'] as int? ?? 0,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
    );
  }

  String get initials {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    final first = parts.first.isNotEmpty ? parts.first[0] : '';
    final last = parts.length > 1 && parts.last.isNotEmpty ? parts.last[0] : '';
    return '$first$last'.toUpperCase();
  }

  String get approvalStatus => isApproved ? 'Approved' : 'Pending Approval';
}
