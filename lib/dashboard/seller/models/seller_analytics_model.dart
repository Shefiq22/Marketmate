import 'product_model.dart';
import 'seller_earnings_model.dart';

class AnalyticsOverview {
  final int totalRevenueKobo;
  final int totalOrders;
  final int completedOrders;
  final int cancelledOrders;
  final int rejectedOrders;
  final int averageOrderValueKobo;
  final int newCustomers;
  final int returningCustomers;

  const AnalyticsOverview({
    this.totalRevenueKobo = 0,
    this.totalOrders = 0,
    this.completedOrders = 0,
    this.cancelledOrders = 0,
    this.rejectedOrders = 0,
    this.averageOrderValueKobo = 0,
    this.newCustomers = 0,
    this.returningCustomers = 0,
  });

  factory AnalyticsOverview.fromJson(Map<String, dynamic> json) =>
      AnalyticsOverview(
        totalRevenueKobo: json['totalRevenue'] as int? ?? 0,
        totalOrders: json['totalOrders'] as int? ?? 0,
        completedOrders: json['completedOrders'] as int? ?? 0,
        cancelledOrders: json['cancelledOrders'] as int? ?? 0,
        rejectedOrders: json['rejectedOrders'] as int? ?? 0,
        averageOrderValueKobo: json['averageOrderValue'] as int? ?? 0,
        newCustomers: json['newCustomers'] as int? ?? 0,
        returningCustomers: json['returningCustomers'] as int? ?? 0,
      );

  double get totalRevenueNaira => totalRevenueKobo / 100;
  double get avgOrderValueNaira => averageOrderValueKobo / 100;
}

class RevenueChartPoint {
  final String date;
  final int revenueKobo;
  final int orders;

  const RevenueChartPoint({
    required this.date,
    this.revenueKobo = 0,
    this.orders = 0,
  });

  factory RevenueChartPoint.fromJson(Map<String, dynamic> json) =>
      RevenueChartPoint(
        date: json['date'] as String? ?? '',
        revenueKobo: json['revenue'] as int? ?? 0,
        orders: json['orders'] as int? ?? 0,
      );

  double get revenueNaira => revenueKobo / 100;
}

class TopProduct {
  final int rank;
  final ProductModel product;
  final int totalSold;
  final int revenueKobo;
  final double averageRating;

  const TopProduct({
    required this.rank,
    required this.product,
    this.totalSold = 0,
    this.revenueKobo = 0,
    this.averageRating = 0,
  });

  factory TopProduct.fromJson(Map<String, dynamic> json) {
    final productData = json['product'] as Map<String, dynamic>? ?? {};
    return TopProduct(
      rank: json['rank'] as int? ?? 0,
      product: ProductModel.fromJson(productData),
      totalSold: json['totalSold'] as int? ?? 0,
      revenueKobo: json['revenue'] as int? ?? 0,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
    );
  }
}

class OrdersByStatus {
  final int pending;
  final int orderAccepted;
  final int inTransit;
  final int completed;
  final int cancelled;

  const OrdersByStatus({
    this.pending = 0,
    this.orderAccepted = 0,
    this.inTransit = 0,
    this.completed = 0,
    this.cancelled = 0,
  });

  factory OrdersByStatus.fromJson(Map<String, dynamic> json) => OrdersByStatus(
    pending: json['pending'] as int? ?? 0,
    orderAccepted: json['order_accepted'] as int? ?? 0,
    inTransit: json['in_transit'] as int? ?? 0,
    completed: json['completed'] as int? ?? 0,
    cancelled: json['cancelled'] as int? ?? 0,
  );

  int get total => pending + orderAccepted + inTransit + completed + cancelled;
}

class RatingsSummary {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> distribution;

  const RatingsSummary({
    this.averageRating = 0,
    this.totalReviews = 0,
    this.distribution = const {},
  });

  factory RatingsSummary.fromJson(Map<String, dynamic> json) {
    final distRaw = json['distribution'] as Map<String, dynamic>?;
    final dist = <int, int>{};
    if (distRaw != null) {
      for (final entry in distRaw.entries) {
        final key = int.tryParse(entry.key) ?? 0;
        final val = entry.value as int? ?? 0;
        dist[key] = val;
      }
    }
    return RatingsSummary(
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0,
      totalReviews: json['totalReviews'] as int? ?? 0,
      distribution: dist,
    );
  }
}

class CustomerInsight {
  final String customerId;
  final String name;
  final int totalOrders;
  final int totalSpendKobo;

  const CustomerInsight({
    required this.customerId,
    required this.name,
    this.totalOrders = 0,
    this.totalSpendKobo = 0,
  });

  factory CustomerInsight.fromJson(Map<String, dynamic> json) =>
      CustomerInsight(
        customerId: json['customerId'] as String? ?? '',
        name: json['name'] as String? ?? '',
        totalOrders: json['totalOrders'] as int? ?? 0,
        totalSpendKobo: json['totalSpend'] as int? ?? 0,
      );
}

class CustomerInsights {
  final List<CustomerInsight> topCustomers;
  final double repeatRate;

  const CustomerInsights({
    this.topCustomers = const [],
    this.repeatRate = 0,
  });

  factory CustomerInsights.fromJson(Map<String, dynamic> json) {
    final list = (json['topCustomers'] as List<dynamic>?)
            ?.map(
              (e) => CustomerInsight.fromJson(e as Map<String, dynamic>),
            )
            .toList() ??
        [];
    return CustomerInsights(
      topCustomers: list,
      repeatRate: (json['repeatRate'] as num?)?.toDouble() ?? 0,
    );
  }
}

class SellerAnalyticsModel {
  final String period;
  final AnalyticsOverview overview;
  final List<RevenueChartPoint> revenueChart;
  final List<TopProduct> topProducts;
  final OrdersByStatus ordersByStatus;
  final CustomerInsights customerInsights;
  final RatingsSummary ratingsSummary;
  final SellerEarningsModel earnings;

  const SellerAnalyticsModel({
    this.period = '30d',
    this.overview = const AnalyticsOverview(),
    this.revenueChart = const [],
    this.topProducts = const [],
    this.ordersByStatus = const OrdersByStatus(),
    this.customerInsights = const CustomerInsights(),
    this.ratingsSummary = const RatingsSummary(),
    this.earnings = const SellerEarningsModel(),
  });

  factory SellerAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return SellerAnalyticsModel(
      period: json['period'] as String? ?? '30d',
      overview: AnalyticsOverview.fromJson(
        (json['overview'] as Map<String, dynamic>?) ?? {},
      ),
      revenueChart: (json['revenueChart'] as List<dynamic>?)
              ?.map((e) => RevenueChartPoint.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      topProducts: (json['topProducts'] as List<dynamic>?)
              ?.map((e) => TopProduct.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      ordersByStatus: OrdersByStatus.fromJson(
        (json['ordersByStatus'] as Map<String, dynamic>?) ?? {},
      ),
      customerInsights: CustomerInsights.fromJson(
        (json['customerInsights'] as Map<String, dynamic>?) ?? {},
      ),
      ratingsSummary: RatingsSummary.fromJson(
        (json['ratingsSummary'] as Map<String, dynamic>?) ?? {},
      ),
      earnings: SellerEarningsModel.fromJson(
        (json['earnings'] as Map<String, dynamic>?) ?? {},
      ),
    );
  }
}
