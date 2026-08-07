// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appbar_settings => 'Settings';

  @override
  String get menu_dark_mode => 'Dark Mode';

  @override
  String get menu_security => 'Security';

  @override
  String get menu_language => 'Language';

  @override
  String get menu_notifications => 'Notifications';

  @override
  String get menu_privacy_policy => 'Privacy policy';

  @override
  String get menu_terms_of_service => 'Terms of service';

  @override
  String translate_to(String lang) {
    return 'Translate to $lang';
  }

  @override
  String get translate_show_original => 'Show original';

  @override
  String get translate_retry => 'Translation failed. Tap to retry.';

  @override
  String get menu_reset_password => 'Reset Password';

  @override
  String get menu_fingerprint => 'Fingerprint';

  @override
  String get section_preferences => 'Preferences';

  @override
  String get section_general => 'General';

  @override
  String get section_support => 'Support';

  @override
  String get language_screen_title => 'Language';

  @override
  String get language_en => 'English';

  @override
  String get language_ha => 'Hausa';

  @override
  String get language_ig => 'Igbo';

  @override
  String get language_yo => 'Yoruba';

  @override
  String get language_pcm => 'Nigerian Pidgin';

  @override
  String get nav_home => 'Home';

  @override
  String get nav_products => 'Products';

  @override
  String get nav_cart => 'Cart';

  @override
  String get nav_orders => 'Orders';

  @override
  String get nav_profile => 'Profile';

  @override
  String get nav_riders => 'Riders';

  @override
  String get nav_deliveries => 'Deliveries';

  @override
  String get nav_wallet => 'Wallet';

  @override
  String get category_all => 'All';

  @override
  String get category_vegetables => 'Vegetables';

  @override
  String get category_foodstuff => 'Foodstuff';

  @override
  String get category_fruits => 'Fruits';

  @override
  String get category_meat => 'Meat';

  @override
  String get category_fish => 'Fish';

  @override
  String get retry => 'Retry';

  @override
  String get see_all => 'See All';

  @override
  String get loading_ellipsis => 'Loading...';

  @override
  String get failed_to_load => 'Failed to load';

  @override
  String home_greeting(String name) {
    return 'Welcome $name,';
  }

  @override
  String get home_search_hint => 'Search stores, vegetables, fruits etc.';

  @override
  String get home_featured_stores => 'Featured Stores';

  @override
  String get home_categories => 'Categories';

  @override
  String get home_available_sellers => 'Available Sellers';

  @override
  String get home_no_sellers_found => 'No sellers found';

  @override
  String get home_search_empty_hint => 'Try searching for something else';

  @override
  String get home_error_loading =>
      'Could not load products.\nPull down to retry.';

  @override
  String get home_open_now => 'Open Now';

  @override
  String get home_closed => 'Closed';

  @override
  String get home_free => 'Free';

  @override
  String get home_free_delivery => 'Free delivery';

  @override
  String get products_search_hint => 'Search vegetables, fruits etc.';

  @override
  String get products_categories => 'Categories';

  @override
  String get products_browse => 'Browse products';

  @override
  String get products_no_products => 'No products';

  @override
  String get products_no_products_category =>
      'No products found in this category';

  @override
  String get products_add => 'Add';

  @override
  String get products_sold_out_badge => 'Sold out';

  @override
  String get orders_title => 'Orders';

  @override
  String get orders_history => 'Order history';

  @override
  String get orders_active => 'Active';

  @override
  String get orders_pending => 'Pending';

  @override
  String get orders_completed => 'Completed';

  @override
  String get orders_no_active => 'No active orders';

  @override
  String get orders_no_active_desc => 'Active orders will appear here.';

  @override
  String get orders_no_pending => 'No pending orders';

  @override
  String get orders_no_pending_desc => 'Pending orders will appear here.';

  @override
  String get orders_no_completed => 'No completed orders';

  @override
  String get orders_no_completed_desc => 'Completed orders will appear here.';

  @override
  String get orders_no_history => 'No order history';

  @override
  String get orders_no_history_desc => 'Past orders will appear here.';

  @override
  String get orders_status_active => 'Active';

  @override
  String get orders_status_awaiting => 'Awaiting';

  @override
  String get orders_status_completed => 'Completed';

  @override
  String get cart_title => 'Cart';

  @override
  String get cart_empty => 'Your cart is empty';

  @override
  String get cart_empty_desc => 'Browse products and add items to your cart';

  @override
  String get cart_available => 'Available for checkout';

  @override
  String get cart_sold_out_section => 'Sold out';

  @override
  String get cart_total => 'Total';

  @override
  String get cart_checkout => 'Proceed to Checkout';

  @override
  String get dialog_sign_out_title => 'Are you sure you want to sign out?';

  @override
  String get dialog_yes => 'Yes';

  @override
  String get dialog_back_to_home => 'Back to Home';

  @override
  String get dialog_cancel => 'Cancel';

  @override
  String get dialog_clear_cart_title => 'Clear cart?';

  @override
  String get dialog_clear_cart_body =>
      'Are you sure you want to remove all items?';

  @override
  String get dialog_clear => 'Clear';

  @override
  String get menu_profile_label => 'Profile';

  @override
  String get menu_address_book => 'Address book';

  @override
  String get menu_messages => 'Messages';

  @override
  String get menu_alert_preferences => 'Alert preferences';

  @override
  String get menu_help_support => 'Help & Support';

  @override
  String get menu_settings_label => 'Settings';

  @override
  String get menu_sign_out => 'Sign out';

  @override
  String get menu_dark_mode_label => 'Dark mode';

  @override
  String get menu_earnings => 'Earnings';

  @override
  String get menu_bank_payouts => 'Bank & Payouts';

  @override
  String get menu_wallet_label => 'Wallet';

  @override
  String get product_no_reviews => 'No reviews yet';

  @override
  String get product_be_first_review => 'Be the first to leave a review';

  @override
  String get review_hint => 'Share your honest experience';

  @override
  String get review_submit => 'Submit Review';

  @override
  String get review_view_orders => 'View Orders';

  @override
  String get review_back_homepage => 'Back to Homepage';

  @override
  String get receipt_view => 'View Receipt';

  @override
  String get receipt_date => 'Date:';

  @override
  String get receipt_time => 'Time:';

  @override
  String get receipt_to => 'To:';

  @override
  String get receipt_for => 'For:';

  @override
  String get receipt_delivery => 'Delivery';

  @override
  String get receipt_subtotal => 'Sub Total';

  @override
  String get receipt_rate_items => 'Rate Items';

  @override
  String get checkout_bank_transfer => 'Bank transfer';

  @override
  String get checkout_bank_transfer_desc => 'Transfer to the seller\'s account';

  @override
  String get checkout_saved_card => 'Saved card';

  @override
  String get checkout_paystack => 'Paystack';

  @override
  String get checkout_delivery_fee => 'Delivery fee';

  @override
  String get checkout_commission => 'Service fee';

  @override
  String get checkout_total_label => 'Total';

  @override
  String get checkout_add_address => 'Add new address';

  @override
  String get checkout_add_address_hint => 'Please add a delivery address';

  @override
  String get order_detail_delivery => 'Delivery';

  @override
  String get order_detail_subtotal => 'Sub Total';

  @override
  String get order_detail_delivery_address => 'Delivery address';

  @override
  String get order_detail_payment_method => 'Payment method';

  @override
  String get order_detail_message_seller => 'Message Seller';

  @override
  String get order_detail_ordered => 'Ordered';

  @override
  String get order_detail_confirmed => 'Confirmed';

  @override
  String get order_detail_shipped => 'Shipped';

  @override
  String get order_detail_delivered => 'Delivered';

  @override
  String get profile_updated_success => 'Profile updated successfully';

  @override
  String get profile_update => 'Update';

  @override
  String get profile_no_session => 'No session found. Please log in again.';

  @override
  String get profile_refreshed => 'Profile refreshed';

  @override
  String get profile_refresh_error => 'Could not refresh profile data.';

  @override
  String get address_no_saved => 'No saved addresses';

  @override
  String get address_deleted => 'Address deleted';

  @override
  String get address_added => 'Address added!';

  @override
  String get address_saved => 'Address saved!';

  @override
  String get address_hint_home => 'Home';

  @override
  String get address_hint_type => 'Type here';

  @override
  String get address_hint_enter => 'Enter here';

  @override
  String get address_saving => 'Saving...';

  @override
  String get address_add => 'Add address';

  @override
  String get address_save => 'Save address';

  @override
  String seller_home_greeting(String name) {
    return 'Welcome $name,';
  }

  @override
  String get seller_home_search_hint => 'Search vegetables, fruits e.t.c';

  @override
  String get seller_home_best_sellers => 'Best sellers';

  @override
  String get seller_home_no_best_sellers => 'No best sellers yet';

  @override
  String get seller_home_no_best_sellers_desc =>
      'Products with the highest sales will appear here.';

  @override
  String get seller_home_available_products => 'Available products';

  @override
  String get seller_home_pending_approval => 'Products pending approval';

  @override
  String get seller_home_no_products => 'No products yet';

  @override
  String get seller_home_pending_approval_desc =>
      'Your products are awaiting admin review. They will appear here once approved.';

  @override
  String get seller_home_add_first_product =>
      'Add your first product to start selling.';

  @override
  String get seller_home_products_in_stock => 'Products in stock';

  @override
  String get seller_home_pending_orders => 'Pending orders';

  @override
  String get seller_home_add_new_product => 'Add new product';

  @override
  String get product_pending_review => 'Pending Review';

  @override
  String get product_pending_review_message =>
      'Admin is reviewing this product. It will appear once approved.';

  @override
  String get seller_categories_title => 'Categories';

  @override
  String get seller_products_title => 'Products';

  @override
  String get seller_orders_title => 'Orders';

  @override
  String get seller_orders_history => 'Order history';

  @override
  String get seller_orders_active => 'Active';

  @override
  String get seller_orders_pending => 'Pending';

  @override
  String get seller_orders_completed => 'Completed';

  @override
  String get seller_orders_confirmed => 'Confirmed';

  @override
  String get seller_orders_processed => 'Processed';

  @override
  String get seller_orders_shipped => 'Shipped';

  @override
  String get seller_orders_delivered => 'Delivered';

  @override
  String seller_orders_to(String customerName) {
    return 'To: $customerName';
  }

  @override
  String seller_orders_rider(String riderName) {
    return 'Rider: $riderName';
  }

  @override
  String get seller_orders_price => 'Price: ';

  @override
  String seller_orders_placed_on(String date) {
    return 'Placed on $date.';
  }

  @override
  String get seller_orders_assign_rider => 'Assign Rider';

  @override
  String get seller_orders_no_active => 'No active orders';

  @override
  String get seller_orders_no_active_desc => 'Active orders will appear here.';

  @override
  String get seller_orders_no_pending => 'No pending orders';

  @override
  String get seller_orders_no_pending_desc =>
      'Orders awaiting rider assignment will appear here.';

  @override
  String get seller_orders_no_completed => 'No completed orders';

  @override
  String get seller_orders_no_completed_desc =>
      'Completed orders will appear here.';

  @override
  String get seller_orders_no_history => 'No order history';

  @override
  String get seller_orders_no_history_desc => 'Past orders will appear here.';

  @override
  String get seller_orders_status_completed => 'Completed';

  @override
  String get product_type_standard => 'Standard';

  @override
  String get product_type_fragile => 'Fragile';

  @override
  String get product_type_bulky => 'Bulky';

  @override
  String get product_type_heavy => 'Heavy';

  @override
  String get seller_product_list_available => 'Available';

  @override
  String get seller_product_list_out_of_stock => 'Out of stock';

  @override
  String get seller_product_list_no_available => 'No products available';

  @override
  String get seller_product_list_no_available_desc =>
      'Products you add will appear here.';

  @override
  String get seller_product_list_no_out_of_stock => 'No out-of-stock products';

  @override
  String get seller_product_list_all_in_stock =>
      'All your products are in stock.';

  @override
  String get seller_add_product_title => 'Add Product';

  @override
  String get seller_add_product_select_hint =>
      'Please select a category and at least one image';

  @override
  String get seller_add_product_name_price_hint =>
      'Please enter product name and price';

  @override
  String get seller_add_product_success => 'Product added successfully';

  @override
  String seller_add_product_failed(String error) {
    return 'Failed to create product: $error';
  }

  @override
  String get earnings_title => 'Earnings';

  @override
  String get earnings_youve_earned => 'You\'ve earned ';

  @override
  String get earnings_available_withdrawal => ' available for withdrawal.';

  @override
  String get earnings_loading => 'Loading earnings...';

  @override
  String get earnings_error => 'Could not load earnings.';

  @override
  String earnings_breakdown(
    String available,
    String pending,
    String withdrawn,
  ) {
    return 'Available: $available | Pending: $pending | Withdrawn: $withdrawn';
  }

  @override
  String get earnings_total => 'Total Earnings';

  @override
  String get earnings_history => 'Earning history';

  @override
  String get earnings_actions => 'Actions';

  @override
  String get earnings_manage_bank => 'Manage bank account';

  @override
  String get earnings_withdraw => 'Withdraw';

  @override
  String get earnings_set_default => 'Set as default';

  @override
  String get password_mismatch => 'Passwords do not match';

  @override
  String get password_updated => 'Password updated successfully';

  @override
  String get password_confirm_new => 'Confirm new password';

  @override
  String get location_pickup => 'Pickup location';

  @override
  String get location_dropoff => 'Dropoff location';

  @override
  String rider_home_greeting(String name) {
    return 'Welcome $name,';
  }

  @override
  String get rider_online => 'You are online';

  @override
  String get rider_go_online => 'Go online to receive delivery requests';

  @override
  String get rider_total_earnings => 'Total Earnings';

  @override
  String get rider_payment_history => 'Payment history';

  @override
  String get rider_completed_today => 'Completed deliveries today';

  @override
  String get rider_pending_deliveries => 'Pending deliveries';

  @override
  String get rider_active_delivery => 'Active delivery';

  @override
  String get rider_no_active_deliveries => 'No active deliveries';

  @override
  String get rider_live_location => 'Live location';

  @override
  String get rider_accept_delivery => 'Accept delivery';

  @override
  String get rider_heading_to_pick => 'Heading to pick';

  @override
  String get rider_picked_up => 'Picked up';

  @override
  String get rider_delivered_label => 'Delivered';

  @override
  String get rider_delivery_soon => 'Soon';

  @override
  String get rider_deliveries_title => 'Deliveries';

  @override
  String get rider_delivery_history => 'Delivery history';

  @override
  String get rider_deliveries_active => 'Active';

  @override
  String get rider_deliveries_pending => 'Pending';

  @override
  String get rider_deliveries_completed => 'Completed';

  @override
  String get rider_no_deliveries => 'No Deliveries Yet';

  @override
  String get rider_no_deliveries_desc =>
      'When you complete a delivery run, your full summary history will appear right here.';

  @override
  String get rider_no_completed_deliveries => 'No Completed Deliveries';

  @override
  String get rider_no_completed_deliveries_desc =>
      'Your completed delivery history will appear here once you finish your first run.';

  @override
  String rider_order_ref(String orderRef) {
    return 'Order $orderRef';
  }

  @override
  String rider_to_customer(String customerName) {
    return 'To: $customerName';
  }

  @override
  String get rider_status_completed => 'Completed';

  @override
  String get wallet_title => 'Wallet';

  @override
  String get wallet_earned_prefix => 'You\'ve earned ';

  @override
  String get wallet_earned_suffix => ' so far this week. You are doing great.';

  @override
  String get wallet_set_default => 'Set as default';

  @override
  String get wallet_history => 'Earning history';

  @override
  String wallet_breakdown(String percent, String amount) {
    return '$percent% of $amount total lifetime earnings';
  }

  @override
  String get wallet_actions => 'Actions';

  @override
  String get wallet_manage_bank => 'Manage bank account';

  @override
  String get wallet_withdraw => 'Withdraw';

  @override
  String get rider_withdraw_btn => 'Withdraw';

  @override
  String get rider_enter_hint => 'Enter here';

  @override
  String get rider_fill_fields_hint => 'Please fill all fields';

  @override
  String get rider_bank_add_tab => 'Add bank account';

  @override
  String get rider_bank_manage_tab => 'Manage bank accounts';

  @override
  String get rider_bank_added => 'Bank account added';

  @override
  String get rider_bank_add_button => 'Add bank account';

  @override
  String get rider_profile_update => 'Update';

  @override
  String get notif_empty_title => 'No notifications';

  @override
  String get notif_empty_desc => 'You\'re all caught up!';

  @override
  String get notif_today => 'Today';

  @override
  String get notif_older => 'Older';

  @override
  String get support_phone => 'Phone';

  @override
  String get support_email => 'Email';

  @override
  String get snackbar_fill_fields => 'Please fill all fields';

  @override
  String get snackbar_bank_added => 'Bank account added';

  @override
  String get snackbar_password_mismatch => 'Passwords do not match';

  @override
  String get snackbar_password_updated => 'Password updated successfully';

  @override
  String snackbar_amount_exceeds(String amount) {
    return 'Amount exceeds available balance of ₦$amount';
  }

  @override
  String snackbar_withdrawal_initiated(String withdrawalAmount) {
    return 'Withdrawal of ₦$withdrawalAmount initiated';
  }

  @override
  String snackbar_status_updated(String status) {
    return 'Status updated to $status';
  }

  @override
  String snackbar_update_failed(String error) {
    return 'Update failed: $error';
  }

  @override
  String get snackbar_select_category_image =>
      'Please select a category and at least one image';

  @override
  String get snackbar_enter_name_price => 'Please enter product name and price';

  @override
  String get snackbar_product_added => 'Product added successfully';

  @override
  String snackbar_product_failed(String error) {
    return 'Failed to create product: $error';
  }

  @override
  String get payment_placing_order => 'Placing Order...';

  @override
  String get payment_initiating => 'Initiating Payment...';

  @override
  String get payment_processing => 'Processing Payment';

  @override
  String get payment_verifying => 'Verifying Payment...';

  @override
  String get payment_success => 'Payment Successful';

  @override
  String get payment_failed => 'Payment Failed';

  @override
  String get payment_check_manually =>
      'We\'re verifying your transaction. Tap to check manually.';

  @override
  String get payment_check_now => 'Check Now';

  @override
  String get payment_go_home => 'Back to Home';

  @override
  String get payment_verifying_background =>
      'Verifying payment in the background...';

  @override
  String get payment_order_placed => 'Order placed successfully';

  @override
  String get products_out_of_stock => 'Out of Stock';

  @override
  String get stock_error_title => 'Out of Stock';

  @override
  String get stock_error_message =>
      'Some items in your basket are no longer available in the requested quantity. Please update your basket to proceed.';

  @override
  String get stock_error_review_basket => 'Review Basket';
}
