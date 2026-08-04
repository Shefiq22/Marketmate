import 'package:flutter/foundation.dart';

class Product {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageUrl;
  final String description;
  final double rating;
  final int reviewCount;
  final int stock;
  final bool isAvailable;
  final bool isApproved;
  final List<Review> reviews;
  final String? sellerId;
  final String? sellerName;
  final String? unit;
  final List<String> images;
  final bool isPerishable;
  final double estimatedWeightKg;
  final String deliveryClass;

  bool get inStock => stock > 0 && isAvailable && isApproved;

  // Locale-specific variant fields (Option 2 — Multi-Column Schema)
  final String? nameHa;
  final String? nameIg;
  final String? nameYo;
  final String? namePcm;
  final String? descriptionHa;
  final String? descriptionIg;
  final String? descriptionYo;
  final String? descriptionPcm;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.description,
    this.rating = 4.0,
    this.reviewCount = 0,
    this.stock = 0,
    this.isAvailable = false,
    this.isApproved = false,
    this.reviews = const [],
    this.sellerId,
    this.sellerName,
    this.unit,
    this.images = const [],
    this.isPerishable = false,
    this.estimatedWeightKg = 1.0,
    this.deliveryClass = 'standard',
    this.nameHa,
    this.nameIg,
    this.nameYo,
    this.namePcm,
    this.descriptionHa,
    this.descriptionIg,
    this.descriptionYo,
    this.descriptionPcm,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final images = json['images'] as List<dynamic>?;

    // ── Bulletproof stock parsing (handles int, double, String, null) ──
    final rawStock = json['stock'];
    int parsedStock;
    if (rawStock is int) {
      parsedStock = rawStock;
    } else if (rawStock is double) {
      parsedStock = rawStock.toInt();
    } else if (rawStock is String) {
      parsedStock = int.tryParse(rawStock) ?? 0;
    } else {
      parsedStock = 0;
    }

    // ── Bulletproof bool parsing (handles bool, int 0/1, String) ──
    bool parseBool(dynamic raw, {bool fallback = false}) {
      if (raw is bool) return raw;
      if (raw is int) return raw != 0;
      if (raw is String) return raw.toLowerCase() == 'true';
      return fallback;
    }

    debugPrint(
      '[ProductParse] id=${json['_id']}  '
      'rawStock=${rawStock.runtimeType}=$rawStock  '
      'parsedStock=$parsedStock  '
      'rawAvailable=${json['isAvailable']}  '
      'rawApproved=${json['isApproved']}',
    );

    return Product(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      price: ((json['price'] as num?)?.toDouble() ?? 0.0) / 100,
      imageUrl: (images != null && images.isNotEmpty)
          ? images.first as String
          : (json['imageUrl'] ?? json['image'] ?? ''),
      description: json['description'] ?? '',
      rating: (json['averageRating'] as num?)?.toDouble() ??
          (json['rating'] as num?)?.toDouble() ??
          4.0,
      reviewCount: (json['reviewCount'] is num)
          ? (json['reviewCount'] as num).toInt()
          : json['reviews']?.length ?? 0,
      stock: parsedStock,
      isAvailable: parseBool(json['isAvailable'], fallback: parsedStock > 0),
      isApproved: parseBool(json['isApproved'], fallback: true),
      reviews:
          (json['reviews'] as List<dynamic>?)
              ?.map((r) => Review.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      sellerId: _resolveId(json['sellerId']),
      sellerName: json['sellerName']?.toString(),
      unit: json['unit']?.toString(),
      images: (images ?? []).map((e) => e.toString()).toList(),
      isPerishable: parseBool(json['isPerishable']),
      estimatedWeightKg: (json['estimatedWeightKg'] as num?)?.toDouble() ?? 1.0,
      deliveryClass: json['deliveryClass'] ?? 'standard',
      nameHa: json['name_ha']?.toString(),
      nameIg: json['name_ig']?.toString(),
      nameYo: json['name_yo']?.toString(),
      namePcm: json['name_pcm']?.toString(),
      descriptionHa: json['description_ha']?.toString(),
      descriptionIg: json['description_ig']?.toString(),
      descriptionYo: json['description_yo']?.toString(),
      descriptionPcm: json['description_pcm']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'category': category,
    'price': price,
    'imageUrl': imageUrl,
    'description': description,
    'stock': stock,
    'isAvailable': isAvailable,
    'isApproved': isApproved,
    'isPerishable': isPerishable,
    'estimatedWeightKg': estimatedWeightKg,
    'deliveryClass': deliveryClass,
  };

  /// Returns the product name localized to the given [locale].
  String localizedName(String locale) => _pickLocalized(locale, nameHa, nameIg, nameYo, namePcm) ?? name;

  /// Returns the product description localized to the given [locale].
  String localizedDescription(String locale) => _pickLocalized(locale, descriptionHa, descriptionIg, descriptionYo, descriptionPcm) ?? description;

  String? _pickLocalized(String locale, String? ha, String? ig, String? yo, String? pcm) {
    switch (locale) {
      case 'ha': return ha;
      case 'ig': return ig;
      case 'yo': return yo;
      case 'pcm': return pcm;
      default: return null;
    }
  }

  static String _resolveId(dynamic value) {
    if (value == null) return '';
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      final oid = value['\$oid'];
      if (oid is String) return oid;
    }
    return value.toString();
  }
}

class Vendor {
  final String sellerId;
  final String sellerName;
  final List<Product> products;
  final double averageRating;
  final String? deliveryFee;
  final String? deliveryTime;
  final String? imageUrl;
  final List<String> categories;

  const Vendor({
    required this.sellerId,
    required this.sellerName,
    required this.products,
    this.averageRating = 0.0,
    this.deliveryFee,
    this.deliveryTime,
    this.imageUrl,
    this.categories = const [],
  });

  bool get isAvailable => products.any((p) => p.inStock);

  String get coverImageUrl =>
      imageUrl ??
      products.firstWhere(
        (p) => p.images.isNotEmpty,
        orElse: () => products.first,
      ).imageUrl;
}

class Review {
  final String id;
  final String userName;
  final String comment;
  final double rating;
  final String date;

  const Review({
    required this.id,
    required this.userName,
    required this.comment,
    required this.rating,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      id: json['_id'] ?? json['id'] ?? '',
      userName: json['userName'] ?? json['user'] ?? '',
      comment: json['comment'] ?? json['text'] ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      date: json['date'] ?? json['createdAt'] ?? '',
    );
  }
}

class CartItem {
  final Product product;
  int quantity;
  bool selected;
  bool outOfStock;
  String? stockWarning;

  CartItem({
    required this.product,
    this.quantity = 1,
    this.selected = true,
    this.outOfStock = false,
    this.stockWarning,
  });

  double get total => product.price * quantity;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      product: Product.fromJson(json['product'] ?? json),
      quantity: json['quantity'] ?? 1,
      selected: json['selected'] ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'productId': product.id,
    'quantity': quantity,
  };
}

class Order {
  final String id;
  final String displayId;
  final List<CartItem> items;
  final double total;
  final double deliveryFee;
  final String status;
  final String placedDate;
  final String deliveryAddress;
  final String paymentMethod;
  final String? receiptNumber;
  final String? checkoutSessionId;
  final String? paymentStatus;

  const Order({
    required this.id,
    required this.displayId,
    required this.items,
    required this.total,
    required this.deliveryFee,
    required this.status,
    required this.placedDate,
    required this.deliveryAddress,
    required this.paymentMethod,
    this.receiptNumber,
    this.checkoutSessionId,
    this.paymentStatus,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    final items =
        (json['items'] as List<dynamic>?)
            ?.map((i) => CartItem.fromJson(i as Map<String, dynamic>))
            .toList() ??
        [];
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      displayId: json['displayId'] ?? json['orderId'] ?? '',
      items: items,
      total: ((json['total'] as num?)?.toDouble() ?? 0.0) / 100,
      deliveryFee: ((json['deliveryFee'] as num?)?.toDouble() ?? 0.0) / 100,
      status: json['status'] ?? 'pending',
      placedDate: json['placedDate'] ?? json['createdAt'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      paymentMethod: json['paymentMethod'] ?? 'card',
      receiptNumber: json['receiptNumber'],
      checkoutSessionId: json['checkoutSessionId'],
      paymentStatus: json['paymentStatus'],
    );
  }
}



class UserAddress {
  final String id;
  final String name;
  final String address;
  final String phone;
  final bool isDefault;
  final double? latitude;
  final double? longitude;

  const UserAddress({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.isDefault = false,
    this.latitude,
    this.longitude,
  });

  factory UserAddress.fromJson(Map<String, dynamic> json) {
    return UserAddress(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['label'] ?? '',
      address: json['address'] ?? json['text'] ?? '',
      phone: json['phone'] ?? '',
      isDefault: json['isDefault'] ?? json['default'] ?? false,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'address': address,
    'phone': phone,
    'isDefault': isDefault,
    'latitude': latitude,
    'longitude': longitude,
  };
}

class AppNotification {
  final String id;
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final String type;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    this.type = 'info',
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['_id'] ?? json['id'] ?? '',
      title: json['title'] ?? '',
      body: json['body'] ?? json['message'] ?? '',
      time: json['time'] ?? json['createdAt'] ?? '',
      isRead: json['isRead'] ?? json['read'] ?? false,
      type: json['type'] ?? 'info',
    );
  }
}
