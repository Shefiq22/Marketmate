class ReviewModel {
  final String reviewerName;
  final String comment;
  final String date;
  final int stars;

  const ReviewModel({
    required this.reviewerName,
    required this.comment,
    required this.date,
    required this.stars,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
    reviewerName: json['reviewerName'] as String? ?? '',
    comment: json['comment'] as String? ?? '',
    date: json['date'] as String? ?? '',
    stars: json['stars'] as int? ?? 0,
  );
}

class ProductModel {
  final String id;
  final String name;
  final String category;
  final double price;
  final String imageAsset;
  final List<String> images;
  final String description;
  final bool inStock;
  final List<ReviewModel> reviews;
  final Map<int, double> ratingBreakdown;
  final double averageRating;
  final int reviewCount;
  final bool isAvailable;
  final bool isApproved;

  // Locale-specific variant fields (Option 2 — Multi-Column Schema)
  final String? nameHa;
  final String? nameIg;
  final String? nameYo;
  final String? namePcm;
  final String? descriptionHa;
  final String? descriptionIg;
  final String? descriptionYo;
  final String? descriptionPcm;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageAsset,
    this.images = const [],
    required this.description,
    required this.inStock,
    this.reviews = const [],
    this.ratingBreakdown = const {3: 100, 2: 0, 1: 0},
    this.averageRating = 0,
    this.reviewCount = 0,
    this.isAvailable = true,
    this.isApproved = true,
    this.nameHa,
    this.nameIg,
    this.nameYo,
    this.namePcm,
    this.descriptionHa,
    this.descriptionIg,
    this.descriptionYo,
    this.descriptionPcm,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final rawImages = json['images'] as List<dynamic>?;
    final parsedImages = rawImages?.map((e) => e as String).toList() ?? <String>[];
    final legacyImage = json['imageAsset'] as String? ?? '';
    final firstImage = parsedImages.isNotEmpty
        ? parsedImages.first
        : legacyImage;
    return ProductModel(
      id: json['_id'] as String? ?? json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      imageAsset: firstImage,
      images: parsedImages.isNotEmpty
          ? parsedImages
          : (legacyImage.isNotEmpty ? [legacyImage] : const []),
      description: json['description'] as String? ?? '',
      inStock: json['isAvailable'] as bool? ?? json['inStock'] as bool? ?? false,
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((r) => ReviewModel.fromJson(r as Map<String, dynamic>))
              .toList() ??
          [],
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      reviewCount: json['reviewCount'] as int? ?? 0,
      isAvailable: json['isAvailable'] as bool? ?? true,
      isApproved: json['isApproved'] as bool? ?? true,
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
    'description': description,
    'price': (price * 100).round(),
    'category': category,
    'images': images.isNotEmpty ? images : [imageAsset],
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

  String get formattedPrice {
    final formatted = price.toStringAsFixed(
      price.truncateToDouble() == price ? 0 : 2,
    );
    return '₦${_addCommas(formatted)}';
  }

  static String _addCommas(String s) {
    final parts = s.split('.');
    final intPart = parts[0];
    final result = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) result.write(',');
      result.write(intPart[i]);
    }
    if (parts.length > 1) {
      result.write('.');
      result.write(parts[1]);
    }
    return result.toString();
  }
}
