class ApiEndpoints {
  ApiEndpoints._();

  static const String _v1 = '/api/v1';

  // Auth
  static const String register = '$_v1/auth/register';
  static const String verifyEmail = '$_v1/auth/verify-email';
  static const String verifyPhone = '$_v1/auth/verify-phone';
  static const String login = '$_v1/auth/login';
  static const String logout = '$_v1/auth/logout';
  static const String refreshToken = '$_v1/auth/refresh-token';
  static const String forgotPassword = '$_v1/auth/forgot-password';
  static const String resetPassword = '$_v1/auth/reset-password';
  static const String resendOtp = '$_v1/auth/resend-otp';

  // Products
  static const String products = '$_v1/products';
  static String productById(String id) => '$_v1/products/$id';
  static String productApprove(String id) => '$_v1/products/$id/approve';
  static String productReviews(String id) => '$_v1/products/$id/reviews';
  static String productView(String id) => '$_v1/products/$id/view';

  // Cart
  static const String cart = '$_v1/cart';
  static const String cartItems = '$_v1/cart/items';
  static String cartItem(String productId) => '$_v1/cart/items/$productId';

  // Orders
  static const String orders = '$_v1/orders';
  static String orderById(String id) => '$_v1/orders/$id';
  static String orderAccept(String id) => '$_v1/orders/$id/accept';
  static String orderPreparing(String id) => '$_v1/orders/$id/preparing';
  static String orderReady(String id) => '$_v1/orders/$id/ready';
  static String orderAssignRider(String id) => '$_v1/orders/$id/assign-rider';
  static String orderPickupConfirm(String id) => '$_v1/orders/$id/pickup-confirm';
  static String orderArrived(String id) => '$_v1/orders/$id/arrived';
  static String orderComplete(String id) => '$_v1/orders/$id/complete';
  static String orderCancel(String id) => '$_v1/orders/$id/cancel';
  static String orderTracking(String id) => '$_v1/orders/$id/tracking';
  static String orderRiderSuggest(String orderId) => '$_v1/orders/$orderId/riders/suggest';

  // Payments
  static const String paymentsInitiate = '$_v1/payments/initiate';
  static const String paymentsVirtualAccount = '$_v1/payments/virtual-account/assign';
  static const String paymentsWebhook = '$_v1/payments/webhook';
  static String paymentStatus(String orderId) => '$_v1/payments/$orderId/status';
  static String paymentReceipt(String orderId) => '$_v1/payments/$orderId/receipt';

  // Riders
  static const String ridersSearch = '$_v1/riders/search';
  static const String ridersMeOrders = '$_v1/riders/me/orders';
  static const String ridersMeStatus = '$_v1/riders/me/status';
  static const String ridersActiveOrder = '$_v1/riders/orders/active';
  static const String ridersPendingAssignments = '$_v1/riders/assignments/pending';
  static const String ridersLocation = '$_v1/riders/location';
  static String riderReviews(String riderId) => '$_v1/riders/$riderId/reviews';

  // Messages
  static String messages(String orderId) => '$_v1/orders/$orderId/messages';
  static String messagesRead(String orderId) => '$_v1/orders/$orderId/messages/read';

  // Notifications
  static const String notifications = '$_v1/notifications';
  static String notificationRead(String id) => '$_v1/notifications/$id/read';
  static const String notificationsReadAll = '$_v1/notifications/read-all';

  // Devices
  static const String devicesRegister = '$_v1/devices/register';

  // Uploads
  static const String uploadSignature = '$_v1/uploads/signature';

  // Profile
  static const String myProfile = '$_v1/users/me';
  static const String deleteMe = '$_v1/users/me';

  // Referrals
  static const String referralsMe = '$_v1/referrals/me';

  // Wallet
  static const String walletMe = '$_v1/wallet/me';

  // Orders — customer confirms delivery
  static String orderCustomerComplete(String id) => '$_v1/orders/$id/customer-complete';

  // Analytics — Customer
  static const String analyticsDiscovery = '$_v1/analytics/discovery';
  static const String analyticsTopProducts = '$_v1/analytics/top-products';

  // Notifications — tokens
  static const String notificationTokens = '$_v1/notifications/tokens';

  // Health
  static const String health = '/health';

  // Sellers
  static const String sellersOnboarding = '$_v1/sellers/onboarding';
  static const String sellersMe = '$_v1/sellers/me';
  static const String sellersMeProducts = '$_v1/sellers/me/products';
  static const String sellersMeEarnings = '$_v1/sellers/me/earnings';
  static const String sellersMeAnalytics = '$_v1/sellers/me/analytics';
  static const String sellersMeBestSelling = '$_v1/sellers/me/products/best-selling';
  static const String sellersProfile = '$_v1/sellers/profile';
  static const String sellersDashboard = '$_v1/sellers/dashboard';
  static const String sellersOrders = '$_v1/sellers/orders';
  static String sellerOrderPickupCode(String id) => '$_v1/sellers/orders/$id/pickup-code';

  // Riders
  static const String ridersMe = '$_v1/riders/me';
  static const String ridersMeWallet = '$_v1/riders/me/wallet';
  static const String ridersMeWalletWithdraw = '$_v1/riders/me/wallet/withdraw';
  static const String ridersMeBank = '$_v1/riders/me/bank';
}
