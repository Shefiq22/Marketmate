class SellerDashboardStats {
  final int totalProducts;
  final int pendingOrders;

  const SellerDashboardStats({
    this.totalProducts = 0,
    this.pendingOrders = 0,
  });

  factory SellerDashboardStats.fromJson(Map<String, dynamic> json) =>
      SellerDashboardStats(
        totalProducts: json['totalProducts'] as int? ?? 0,
        pendingOrders: json['pendingOrders'] as int? ?? 0,
      );

  SellerDashboardStats copyWith({int? totalProducts, int? pendingOrders}) =>
      SellerDashboardStats(
        totalProducts: totalProducts ?? this.totalProducts,
        pendingOrders: pendingOrders ?? this.pendingOrders,
      );
}
