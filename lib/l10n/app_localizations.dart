import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ha.dart';
import 'app_localizations_ig.dart';
import 'app_localizations_pcm.dart';
import 'app_localizations_yo.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ha'),
    Locale('ig'),
    Locale('pcm'),
    Locale('yo'),
  ];

  /// No description provided for @appbar_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get appbar_settings;

  /// No description provided for @menu_dark_mode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get menu_dark_mode;

  /// No description provided for @menu_security.
  ///
  /// In en, this message translates to:
  /// **'Security'**
  String get menu_security;

  /// No description provided for @menu_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get menu_language;

  /// No description provided for @menu_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get menu_notifications;

  /// No description provided for @menu_privacy_policy.
  ///
  /// In en, this message translates to:
  /// **'Privacy policy'**
  String get menu_privacy_policy;

  /// No description provided for @menu_terms_of_service.
  ///
  /// In en, this message translates to:
  /// **'Terms of service'**
  String get menu_terms_of_service;

  /// Button label to translate text to a given language
  ///
  /// In en, this message translates to:
  /// **'Translate to {lang}'**
  String translate_to(String lang);

  /// No description provided for @translate_show_original.
  ///
  /// In en, this message translates to:
  /// **'Show original'**
  String get translate_show_original;

  /// No description provided for @translate_retry.
  ///
  /// In en, this message translates to:
  /// **'Translation failed. Tap to retry.'**
  String get translate_retry;

  /// No description provided for @menu_reset_password.
  ///
  /// In en, this message translates to:
  /// **'Reset Password'**
  String get menu_reset_password;

  /// No description provided for @menu_fingerprint.
  ///
  /// In en, this message translates to:
  /// **'Fingerprint'**
  String get menu_fingerprint;

  /// No description provided for @section_preferences.
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get section_preferences;

  /// No description provided for @section_general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get section_general;

  /// No description provided for @section_support.
  ///
  /// In en, this message translates to:
  /// **'Support'**
  String get section_support;

  /// No description provided for @language_screen_title.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language_screen_title;

  /// No description provided for @language_en.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_en;

  /// No description provided for @language_ha.
  ///
  /// In en, this message translates to:
  /// **'Hausa'**
  String get language_ha;

  /// No description provided for @language_ig.
  ///
  /// In en, this message translates to:
  /// **'Igbo'**
  String get language_ig;

  /// No description provided for @language_yo.
  ///
  /// In en, this message translates to:
  /// **'Yoruba'**
  String get language_yo;

  /// No description provided for @language_pcm.
  ///
  /// In en, this message translates to:
  /// **'Nigerian Pidgin'**
  String get language_pcm;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get nav_products;

  /// No description provided for @nav_cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get nav_cart;

  /// No description provided for @nav_orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get nav_orders;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get nav_profile;

  /// No description provided for @nav_riders.
  ///
  /// In en, this message translates to:
  /// **'Riders'**
  String get nav_riders;

  /// No description provided for @nav_deliveries.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get nav_deliveries;

  /// No description provided for @nav_wallet.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get nav_wallet;

  /// No description provided for @category_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get category_all;

  /// No description provided for @category_vegetables.
  ///
  /// In en, this message translates to:
  /// **'Vegetables'**
  String get category_vegetables;

  /// No description provided for @category_foodstuff.
  ///
  /// In en, this message translates to:
  /// **'Foodstuff'**
  String get category_foodstuff;

  /// No description provided for @category_fruits.
  ///
  /// In en, this message translates to:
  /// **'Fruits'**
  String get category_fruits;

  /// No description provided for @category_meat.
  ///
  /// In en, this message translates to:
  /// **'Meat'**
  String get category_meat;

  /// No description provided for @category_fish.
  ///
  /// In en, this message translates to:
  /// **'Fish'**
  String get category_fish;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @see_all.
  ///
  /// In en, this message translates to:
  /// **'See All'**
  String get see_all;

  /// No description provided for @loading_ellipsis.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading_ellipsis;

  /// No description provided for @failed_to_load.
  ///
  /// In en, this message translates to:
  /// **'Failed to load'**
  String get failed_to_load;

  /// No description provided for @home_greeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name},'**
  String home_greeting(String name);

  /// No description provided for @home_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search stores, vegetables, fruits etc.'**
  String get home_search_hint;

  /// No description provided for @home_featured_stores.
  ///
  /// In en, this message translates to:
  /// **'Featured Stores'**
  String get home_featured_stores;

  /// No description provided for @home_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get home_categories;

  /// No description provided for @home_available_sellers.
  ///
  /// In en, this message translates to:
  /// **'Available Sellers'**
  String get home_available_sellers;

  /// No description provided for @home_no_sellers_found.
  ///
  /// In en, this message translates to:
  /// **'No sellers found'**
  String get home_no_sellers_found;

  /// No description provided for @home_search_empty_hint.
  ///
  /// In en, this message translates to:
  /// **'Try searching for something else'**
  String get home_search_empty_hint;

  /// No description provided for @home_error_loading.
  ///
  /// In en, this message translates to:
  /// **'Could not load products.\nPull down to retry.'**
  String get home_error_loading;

  /// No description provided for @home_open_now.
  ///
  /// In en, this message translates to:
  /// **'Open Now'**
  String get home_open_now;

  /// No description provided for @home_closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get home_closed;

  /// No description provided for @home_free.
  ///
  /// In en, this message translates to:
  /// **'Free'**
  String get home_free;

  /// No description provided for @home_free_delivery.
  ///
  /// In en, this message translates to:
  /// **'Free delivery'**
  String get home_free_delivery;

  /// No description provided for @products_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search vegetables, fruits etc.'**
  String get products_search_hint;

  /// No description provided for @products_categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get products_categories;

  /// No description provided for @products_browse.
  ///
  /// In en, this message translates to:
  /// **'Browse products'**
  String get products_browse;

  /// No description provided for @products_no_products.
  ///
  /// In en, this message translates to:
  /// **'No products'**
  String get products_no_products;

  /// No description provided for @products_no_products_category.
  ///
  /// In en, this message translates to:
  /// **'No products found in this category'**
  String get products_no_products_category;

  /// No description provided for @products_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get products_add;

  /// No description provided for @products_sold_out_badge.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get products_sold_out_badge;

  /// No description provided for @orders_title.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders_title;

  /// No description provided for @orders_history.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get orders_history;

  /// No description provided for @orders_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get orders_active;

  /// No description provided for @orders_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orders_pending;

  /// No description provided for @orders_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get orders_completed;

  /// No description provided for @orders_no_active.
  ///
  /// In en, this message translates to:
  /// **'No active orders'**
  String get orders_no_active;

  /// No description provided for @orders_no_active_desc.
  ///
  /// In en, this message translates to:
  /// **'Active orders will appear here.'**
  String get orders_no_active_desc;

  /// No description provided for @orders_no_pending.
  ///
  /// In en, this message translates to:
  /// **'No pending orders'**
  String get orders_no_pending;

  /// No description provided for @orders_no_pending_desc.
  ///
  /// In en, this message translates to:
  /// **'Pending orders will appear here.'**
  String get orders_no_pending_desc;

  /// No description provided for @orders_no_completed.
  ///
  /// In en, this message translates to:
  /// **'No completed orders'**
  String get orders_no_completed;

  /// No description provided for @orders_no_completed_desc.
  ///
  /// In en, this message translates to:
  /// **'Completed orders will appear here.'**
  String get orders_no_completed_desc;

  /// No description provided for @orders_no_history.
  ///
  /// In en, this message translates to:
  /// **'No order history'**
  String get orders_no_history;

  /// No description provided for @orders_no_history_desc.
  ///
  /// In en, this message translates to:
  /// **'Past orders will appear here.'**
  String get orders_no_history_desc;

  /// No description provided for @orders_status_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get orders_status_active;

  /// No description provided for @orders_status_awaiting.
  ///
  /// In en, this message translates to:
  /// **'Awaiting'**
  String get orders_status_awaiting;

  /// No description provided for @orders_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get orders_status_completed;

  /// No description provided for @cart_title.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart_title;

  /// No description provided for @cart_empty.
  ///
  /// In en, this message translates to:
  /// **'Your cart is empty'**
  String get cart_empty;

  /// No description provided for @cart_empty_desc.
  ///
  /// In en, this message translates to:
  /// **'Browse products and add items to your cart'**
  String get cart_empty_desc;

  /// No description provided for @cart_available.
  ///
  /// In en, this message translates to:
  /// **'Available for checkout'**
  String get cart_available;

  /// No description provided for @cart_sold_out_section.
  ///
  /// In en, this message translates to:
  /// **'Sold out'**
  String get cart_sold_out_section;

  /// No description provided for @cart_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get cart_total;

  /// No description provided for @cart_checkout.
  ///
  /// In en, this message translates to:
  /// **'Proceed to Checkout'**
  String get cart_checkout;

  /// No description provided for @dialog_sign_out_title.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to sign out?'**
  String get dialog_sign_out_title;

  /// No description provided for @dialog_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get dialog_yes;

  /// No description provided for @dialog_back_to_home.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get dialog_back_to_home;

  /// No description provided for @dialog_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get dialog_cancel;

  /// No description provided for @dialog_clear_cart_title.
  ///
  /// In en, this message translates to:
  /// **'Clear cart?'**
  String get dialog_clear_cart_title;

  /// No description provided for @dialog_clear_cart_body.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove all items?'**
  String get dialog_clear_cart_body;

  /// No description provided for @dialog_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get dialog_clear;

  /// No description provided for @menu_profile_label.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get menu_profile_label;

  /// No description provided for @menu_address_book.
  ///
  /// In en, this message translates to:
  /// **'Address book'**
  String get menu_address_book;

  /// No description provided for @menu_messages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get menu_messages;

  /// No description provided for @menu_alert_preferences.
  ///
  /// In en, this message translates to:
  /// **'Alert preferences'**
  String get menu_alert_preferences;

  /// No description provided for @menu_help_support.
  ///
  /// In en, this message translates to:
  /// **'Help & Support'**
  String get menu_help_support;

  /// No description provided for @menu_settings_label.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menu_settings_label;

  /// No description provided for @menu_sign_out.
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get menu_sign_out;

  /// No description provided for @menu_dark_mode_label.
  ///
  /// In en, this message translates to:
  /// **'Dark mode'**
  String get menu_dark_mode_label;

  /// No description provided for @menu_earnings.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get menu_earnings;

  /// No description provided for @menu_bank_payouts.
  ///
  /// In en, this message translates to:
  /// **'Bank & Payouts'**
  String get menu_bank_payouts;

  /// No description provided for @menu_wallet_label.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get menu_wallet_label;

  /// No description provided for @product_no_reviews.
  ///
  /// In en, this message translates to:
  /// **'No reviews yet'**
  String get product_no_reviews;

  /// No description provided for @product_be_first_review.
  ///
  /// In en, this message translates to:
  /// **'Be the first to leave a review'**
  String get product_be_first_review;

  /// No description provided for @review_hint.
  ///
  /// In en, this message translates to:
  /// **'Share your honest experience'**
  String get review_hint;

  /// No description provided for @review_submit.
  ///
  /// In en, this message translates to:
  /// **'Submit Review'**
  String get review_submit;

  /// No description provided for @review_view_orders.
  ///
  /// In en, this message translates to:
  /// **'View Orders'**
  String get review_view_orders;

  /// No description provided for @review_back_homepage.
  ///
  /// In en, this message translates to:
  /// **'Back to Homepage'**
  String get review_back_homepage;

  /// No description provided for @receipt_view.
  ///
  /// In en, this message translates to:
  /// **'View Receipt'**
  String get receipt_view;

  /// No description provided for @receipt_date.
  ///
  /// In en, this message translates to:
  /// **'Date:'**
  String get receipt_date;

  /// No description provided for @receipt_time.
  ///
  /// In en, this message translates to:
  /// **'Time:'**
  String get receipt_time;

  /// No description provided for @receipt_to.
  ///
  /// In en, this message translates to:
  /// **'To:'**
  String get receipt_to;

  /// No description provided for @receipt_for.
  ///
  /// In en, this message translates to:
  /// **'For:'**
  String get receipt_for;

  /// No description provided for @receipt_delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get receipt_delivery;

  /// No description provided for @receipt_subtotal.
  ///
  /// In en, this message translates to:
  /// **'Sub Total'**
  String get receipt_subtotal;

  /// No description provided for @receipt_rate_items.
  ///
  /// In en, this message translates to:
  /// **'Rate Items'**
  String get receipt_rate_items;

  /// No description provided for @checkout_bank_transfer.
  ///
  /// In en, this message translates to:
  /// **'Bank transfer'**
  String get checkout_bank_transfer;

  /// No description provided for @checkout_bank_transfer_desc.
  ///
  /// In en, this message translates to:
  /// **'Transfer to the seller\'s account'**
  String get checkout_bank_transfer_desc;

  /// No description provided for @checkout_saved_card.
  ///
  /// In en, this message translates to:
  /// **'Saved card'**
  String get checkout_saved_card;

  /// No description provided for @checkout_paystack.
  ///
  /// In en, this message translates to:
  /// **'Paystack'**
  String get checkout_paystack;

  /// No description provided for @checkout_delivery_fee.
  ///
  /// In en, this message translates to:
  /// **'Delivery fee'**
  String get checkout_delivery_fee;

  /// No description provided for @checkout_commission.
  ///
  /// In en, this message translates to:
  /// **'Commission (0.05%)'**
  String get checkout_commission;

  /// No description provided for @checkout_total_label.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get checkout_total_label;

  /// No description provided for @checkout_add_address.
  ///
  /// In en, this message translates to:
  /// **'Add new address'**
  String get checkout_add_address;

  /// No description provided for @checkout_add_address_hint.
  ///
  /// In en, this message translates to:
  /// **'Please add a delivery address'**
  String get checkout_add_address_hint;

  /// No description provided for @order_detail_delivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get order_detail_delivery;

  /// No description provided for @order_detail_subtotal.
  ///
  /// In en, this message translates to:
  /// **'Sub Total'**
  String get order_detail_subtotal;

  /// No description provided for @order_detail_delivery_address.
  ///
  /// In en, this message translates to:
  /// **'Delivery address'**
  String get order_detail_delivery_address;

  /// No description provided for @order_detail_payment_method.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get order_detail_payment_method;

  /// No description provided for @order_detail_message_seller.
  ///
  /// In en, this message translates to:
  /// **'Message Seller'**
  String get order_detail_message_seller;

  /// No description provided for @order_detail_ordered.
  ///
  /// In en, this message translates to:
  /// **'Ordered'**
  String get order_detail_ordered;

  /// No description provided for @order_detail_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get order_detail_confirmed;

  /// No description provided for @order_detail_shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get order_detail_shipped;

  /// No description provided for @order_detail_delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get order_detail_delivered;

  /// No description provided for @profile_updated_success.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profile_updated_success;

  /// No description provided for @profile_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get profile_update;

  /// No description provided for @profile_no_session.
  ///
  /// In en, this message translates to:
  /// **'No session found. Please log in again.'**
  String get profile_no_session;

  /// No description provided for @profile_refreshed.
  ///
  /// In en, this message translates to:
  /// **'Profile refreshed'**
  String get profile_refreshed;

  /// No description provided for @profile_refresh_error.
  ///
  /// In en, this message translates to:
  /// **'Could not refresh profile data.'**
  String get profile_refresh_error;

  /// No description provided for @address_no_saved.
  ///
  /// In en, this message translates to:
  /// **'No saved addresses'**
  String get address_no_saved;

  /// No description provided for @address_deleted.
  ///
  /// In en, this message translates to:
  /// **'Address deleted'**
  String get address_deleted;

  /// No description provided for @address_added.
  ///
  /// In en, this message translates to:
  /// **'Address added!'**
  String get address_added;

  /// No description provided for @address_saved.
  ///
  /// In en, this message translates to:
  /// **'Address saved!'**
  String get address_saved;

  /// No description provided for @address_hint_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get address_hint_home;

  /// No description provided for @address_hint_type.
  ///
  /// In en, this message translates to:
  /// **'Type here'**
  String get address_hint_type;

  /// No description provided for @address_hint_enter.
  ///
  /// In en, this message translates to:
  /// **'Enter here'**
  String get address_hint_enter;

  /// No description provided for @address_saving.
  ///
  /// In en, this message translates to:
  /// **'Saving...'**
  String get address_saving;

  /// No description provided for @address_add.
  ///
  /// In en, this message translates to:
  /// **'Add address'**
  String get address_add;

  /// No description provided for @address_save.
  ///
  /// In en, this message translates to:
  /// **'Save address'**
  String get address_save;

  /// No description provided for @seller_home_greeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name},'**
  String seller_home_greeting(String name);

  /// No description provided for @seller_home_search_hint.
  ///
  /// In en, this message translates to:
  /// **'Search vegetables, fruits e.t.c'**
  String get seller_home_search_hint;

  /// No description provided for @seller_home_best_sellers.
  ///
  /// In en, this message translates to:
  /// **'Best sellers'**
  String get seller_home_best_sellers;

  /// No description provided for @seller_home_no_best_sellers.
  ///
  /// In en, this message translates to:
  /// **'No best sellers yet'**
  String get seller_home_no_best_sellers;

  /// No description provided for @seller_home_no_best_sellers_desc.
  ///
  /// In en, this message translates to:
  /// **'Products with the highest sales will appear here.'**
  String get seller_home_no_best_sellers_desc;

  /// No description provided for @seller_home_available_products.
  ///
  /// In en, this message translates to:
  /// **'Available products'**
  String get seller_home_available_products;

  /// No description provided for @seller_home_pending_approval.
  ///
  /// In en, this message translates to:
  /// **'Products pending approval'**
  String get seller_home_pending_approval;

  /// No description provided for @seller_home_no_products.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get seller_home_no_products;

  /// No description provided for @seller_home_pending_approval_desc.
  ///
  /// In en, this message translates to:
  /// **'Your products are awaiting admin review. They will appear here once approved.'**
  String get seller_home_pending_approval_desc;

  /// No description provided for @seller_home_add_first_product.
  ///
  /// In en, this message translates to:
  /// **'Add your first product to start selling.'**
  String get seller_home_add_first_product;

  /// No description provided for @seller_home_products_in_stock.
  ///
  /// In en, this message translates to:
  /// **'Products in stock'**
  String get seller_home_products_in_stock;

  /// No description provided for @seller_home_pending_orders.
  ///
  /// In en, this message translates to:
  /// **'Pending orders'**
  String get seller_home_pending_orders;

  /// No description provided for @seller_home_add_new_product.
  ///
  /// In en, this message translates to:
  /// **'Add new product'**
  String get seller_home_add_new_product;

  /// No description provided for @product_pending_review.
  ///
  /// In en, this message translates to:
  /// **'Pending Review'**
  String get product_pending_review;

  /// No description provided for @product_pending_review_message.
  ///
  /// In en, this message translates to:
  /// **'Admin is reviewing this product. It will appear once approved.'**
  String get product_pending_review_message;

  /// No description provided for @seller_categories_title.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get seller_categories_title;

  /// No description provided for @seller_products_title.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get seller_products_title;

  /// No description provided for @seller_orders_title.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get seller_orders_title;

  /// No description provided for @seller_orders_history.
  ///
  /// In en, this message translates to:
  /// **'Order history'**
  String get seller_orders_history;

  /// No description provided for @seller_orders_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get seller_orders_active;

  /// No description provided for @seller_orders_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get seller_orders_pending;

  /// No description provided for @seller_orders_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get seller_orders_completed;

  /// No description provided for @seller_orders_confirmed.
  ///
  /// In en, this message translates to:
  /// **'Confirmed'**
  String get seller_orders_confirmed;

  /// No description provided for @seller_orders_processed.
  ///
  /// In en, this message translates to:
  /// **'Processed'**
  String get seller_orders_processed;

  /// No description provided for @seller_orders_shipped.
  ///
  /// In en, this message translates to:
  /// **'Shipped'**
  String get seller_orders_shipped;

  /// No description provided for @seller_orders_delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get seller_orders_delivered;

  /// No description provided for @seller_orders_to.
  ///
  /// In en, this message translates to:
  /// **'To: {customerName}'**
  String seller_orders_to(String customerName);

  /// No description provided for @seller_orders_rider.
  ///
  /// In en, this message translates to:
  /// **'Rider: {riderName}'**
  String seller_orders_rider(String riderName);

  /// No description provided for @seller_orders_price.
  ///
  /// In en, this message translates to:
  /// **'Price: '**
  String get seller_orders_price;

  /// No description provided for @seller_orders_placed_on.
  ///
  /// In en, this message translates to:
  /// **'Placed on {date}.'**
  String seller_orders_placed_on(String date);

  /// No description provided for @seller_orders_assign_rider.
  ///
  /// In en, this message translates to:
  /// **'Assign Rider'**
  String get seller_orders_assign_rider;

  /// No description provided for @seller_orders_no_active.
  ///
  /// In en, this message translates to:
  /// **'No active orders'**
  String get seller_orders_no_active;

  /// No description provided for @seller_orders_no_active_desc.
  ///
  /// In en, this message translates to:
  /// **'Active orders will appear here.'**
  String get seller_orders_no_active_desc;

  /// No description provided for @seller_orders_no_pending.
  ///
  /// In en, this message translates to:
  /// **'No pending orders'**
  String get seller_orders_no_pending;

  /// No description provided for @seller_orders_no_pending_desc.
  ///
  /// In en, this message translates to:
  /// **'Orders awaiting rider assignment will appear here.'**
  String get seller_orders_no_pending_desc;

  /// No description provided for @seller_orders_no_completed.
  ///
  /// In en, this message translates to:
  /// **'No completed orders'**
  String get seller_orders_no_completed;

  /// No description provided for @seller_orders_no_completed_desc.
  ///
  /// In en, this message translates to:
  /// **'Completed orders will appear here.'**
  String get seller_orders_no_completed_desc;

  /// No description provided for @seller_orders_no_history.
  ///
  /// In en, this message translates to:
  /// **'No order history'**
  String get seller_orders_no_history;

  /// No description provided for @seller_orders_no_history_desc.
  ///
  /// In en, this message translates to:
  /// **'Past orders will appear here.'**
  String get seller_orders_no_history_desc;

  /// No description provided for @seller_orders_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get seller_orders_status_completed;

  /// No description provided for @product_type_standard.
  ///
  /// In en, this message translates to:
  /// **'Standard'**
  String get product_type_standard;

  /// No description provided for @product_type_fragile.
  ///
  /// In en, this message translates to:
  /// **'Fragile'**
  String get product_type_fragile;

  /// No description provided for @product_type_bulky.
  ///
  /// In en, this message translates to:
  /// **'Bulky'**
  String get product_type_bulky;

  /// No description provided for @product_type_heavy.
  ///
  /// In en, this message translates to:
  /// **'Heavy'**
  String get product_type_heavy;

  /// No description provided for @seller_product_list_available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get seller_product_list_available;

  /// No description provided for @seller_product_list_out_of_stock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get seller_product_list_out_of_stock;

  /// No description provided for @seller_product_list_no_available.
  ///
  /// In en, this message translates to:
  /// **'No products available'**
  String get seller_product_list_no_available;

  /// No description provided for @seller_product_list_no_available_desc.
  ///
  /// In en, this message translates to:
  /// **'Products you add will appear here.'**
  String get seller_product_list_no_available_desc;

  /// No description provided for @seller_product_list_no_out_of_stock.
  ///
  /// In en, this message translates to:
  /// **'No out-of-stock products'**
  String get seller_product_list_no_out_of_stock;

  /// No description provided for @seller_product_list_all_in_stock.
  ///
  /// In en, this message translates to:
  /// **'All your products are in stock.'**
  String get seller_product_list_all_in_stock;

  /// No description provided for @seller_add_product_title.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get seller_add_product_title;

  /// No description provided for @seller_add_product_select_hint.
  ///
  /// In en, this message translates to:
  /// **'Please select a category and at least one image'**
  String get seller_add_product_select_hint;

  /// No description provided for @seller_add_product_name_price_hint.
  ///
  /// In en, this message translates to:
  /// **'Please enter product name and price'**
  String get seller_add_product_name_price_hint;

  /// No description provided for @seller_add_product_success.
  ///
  /// In en, this message translates to:
  /// **'Product added successfully'**
  String get seller_add_product_success;

  /// No description provided for @seller_add_product_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create product: {error}'**
  String seller_add_product_failed(String error);

  /// No description provided for @earnings_title.
  ///
  /// In en, this message translates to:
  /// **'Earnings'**
  String get earnings_title;

  /// No description provided for @earnings_youve_earned.
  ///
  /// In en, this message translates to:
  /// **'You\'ve earned '**
  String get earnings_youve_earned;

  /// No description provided for @earnings_available_withdrawal.
  ///
  /// In en, this message translates to:
  /// **' available for withdrawal.'**
  String get earnings_available_withdrawal;

  /// No description provided for @earnings_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading earnings...'**
  String get earnings_loading;

  /// No description provided for @earnings_error.
  ///
  /// In en, this message translates to:
  /// **'Could not load earnings.'**
  String get earnings_error;

  /// No description provided for @earnings_breakdown.
  ///
  /// In en, this message translates to:
  /// **'Available: {available} | Pending: {pending} | Withdrawn: {withdrawn}'**
  String earnings_breakdown(String available, String pending, String withdrawn);

  /// No description provided for @earnings_total.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get earnings_total;

  /// No description provided for @earnings_history.
  ///
  /// In en, this message translates to:
  /// **'Earning history'**
  String get earnings_history;

  /// No description provided for @earnings_actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get earnings_actions;

  /// No description provided for @earnings_manage_bank.
  ///
  /// In en, this message translates to:
  /// **'Manage bank account'**
  String get earnings_manage_bank;

  /// No description provided for @earnings_withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get earnings_withdraw;

  /// No description provided for @earnings_set_default.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get earnings_set_default;

  /// No description provided for @password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get password_mismatch;

  /// No description provided for @password_updated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get password_updated;

  /// No description provided for @password_confirm_new.
  ///
  /// In en, this message translates to:
  /// **'Confirm new password'**
  String get password_confirm_new;

  /// No description provided for @location_pickup.
  ///
  /// In en, this message translates to:
  /// **'Pickup location'**
  String get location_pickup;

  /// No description provided for @location_dropoff.
  ///
  /// In en, this message translates to:
  /// **'Dropoff location'**
  String get location_dropoff;

  /// No description provided for @rider_home_greeting.
  ///
  /// In en, this message translates to:
  /// **'Welcome {name},'**
  String rider_home_greeting(String name);

  /// No description provided for @rider_online.
  ///
  /// In en, this message translates to:
  /// **'You are online'**
  String get rider_online;

  /// No description provided for @rider_go_online.
  ///
  /// In en, this message translates to:
  /// **'Go online to receive delivery requests'**
  String get rider_go_online;

  /// No description provided for @rider_total_earnings.
  ///
  /// In en, this message translates to:
  /// **'Total Earnings'**
  String get rider_total_earnings;

  /// No description provided for @rider_payment_history.
  ///
  /// In en, this message translates to:
  /// **'Payment history'**
  String get rider_payment_history;

  /// No description provided for @rider_completed_today.
  ///
  /// In en, this message translates to:
  /// **'Completed deliveries today'**
  String get rider_completed_today;

  /// No description provided for @rider_pending_deliveries.
  ///
  /// In en, this message translates to:
  /// **'Pending deliveries'**
  String get rider_pending_deliveries;

  /// No description provided for @rider_active_delivery.
  ///
  /// In en, this message translates to:
  /// **'Active delivery'**
  String get rider_active_delivery;

  /// No description provided for @rider_no_active_deliveries.
  ///
  /// In en, this message translates to:
  /// **'No active deliveries'**
  String get rider_no_active_deliveries;

  /// No description provided for @rider_live_location.
  ///
  /// In en, this message translates to:
  /// **'Live location'**
  String get rider_live_location;

  /// No description provided for @rider_accept_delivery.
  ///
  /// In en, this message translates to:
  /// **'Accept delivery'**
  String get rider_accept_delivery;

  /// No description provided for @rider_heading_to_pick.
  ///
  /// In en, this message translates to:
  /// **'Heading to pick'**
  String get rider_heading_to_pick;

  /// No description provided for @rider_picked_up.
  ///
  /// In en, this message translates to:
  /// **'Picked up'**
  String get rider_picked_up;

  /// No description provided for @rider_delivered_label.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get rider_delivered_label;

  /// No description provided for @rider_delivery_soon.
  ///
  /// In en, this message translates to:
  /// **'Soon'**
  String get rider_delivery_soon;

  /// No description provided for @rider_deliveries_title.
  ///
  /// In en, this message translates to:
  /// **'Deliveries'**
  String get rider_deliveries_title;

  /// No description provided for @rider_delivery_history.
  ///
  /// In en, this message translates to:
  /// **'Delivery history'**
  String get rider_delivery_history;

  /// No description provided for @rider_deliveries_active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get rider_deliveries_active;

  /// No description provided for @rider_deliveries_pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get rider_deliveries_pending;

  /// No description provided for @rider_deliveries_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get rider_deliveries_completed;

  /// No description provided for @rider_no_deliveries.
  ///
  /// In en, this message translates to:
  /// **'No Deliveries Yet'**
  String get rider_no_deliveries;

  /// No description provided for @rider_no_deliveries_desc.
  ///
  /// In en, this message translates to:
  /// **'When you complete a delivery run, your full summary history will appear right here.'**
  String get rider_no_deliveries_desc;

  /// No description provided for @rider_no_completed_deliveries.
  ///
  /// In en, this message translates to:
  /// **'No Completed Deliveries'**
  String get rider_no_completed_deliveries;

  /// No description provided for @rider_no_completed_deliveries_desc.
  ///
  /// In en, this message translates to:
  /// **'Your completed delivery history will appear here once you finish your first run.'**
  String get rider_no_completed_deliveries_desc;

  /// No description provided for @rider_order_ref.
  ///
  /// In en, this message translates to:
  /// **'Order {orderRef}'**
  String rider_order_ref(String orderRef);

  /// No description provided for @rider_to_customer.
  ///
  /// In en, this message translates to:
  /// **'To: {customerName}'**
  String rider_to_customer(String customerName);

  /// No description provided for @rider_status_completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get rider_status_completed;

  /// No description provided for @wallet_title.
  ///
  /// In en, this message translates to:
  /// **'Wallet'**
  String get wallet_title;

  /// No description provided for @wallet_earned_prefix.
  ///
  /// In en, this message translates to:
  /// **'You\'ve earned '**
  String get wallet_earned_prefix;

  /// No description provided for @wallet_earned_suffix.
  ///
  /// In en, this message translates to:
  /// **' so far this week. You are doing great.'**
  String get wallet_earned_suffix;

  /// No description provided for @wallet_set_default.
  ///
  /// In en, this message translates to:
  /// **'Set as default'**
  String get wallet_set_default;

  /// No description provided for @wallet_history.
  ///
  /// In en, this message translates to:
  /// **'Earning history'**
  String get wallet_history;

  /// No description provided for @wallet_breakdown.
  ///
  /// In en, this message translates to:
  /// **'{percent}% of {amount} total lifetime earnings'**
  String wallet_breakdown(String percent, String amount);

  /// No description provided for @wallet_actions.
  ///
  /// In en, this message translates to:
  /// **'Actions'**
  String get wallet_actions;

  /// No description provided for @wallet_manage_bank.
  ///
  /// In en, this message translates to:
  /// **'Manage bank account'**
  String get wallet_manage_bank;

  /// No description provided for @wallet_withdraw.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get wallet_withdraw;

  /// No description provided for @rider_withdraw_btn.
  ///
  /// In en, this message translates to:
  /// **'Withdraw'**
  String get rider_withdraw_btn;

  /// No description provided for @rider_enter_hint.
  ///
  /// In en, this message translates to:
  /// **'Enter here'**
  String get rider_enter_hint;

  /// No description provided for @rider_fill_fields_hint.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get rider_fill_fields_hint;

  /// No description provided for @rider_bank_add_tab.
  ///
  /// In en, this message translates to:
  /// **'Add bank account'**
  String get rider_bank_add_tab;

  /// No description provided for @rider_bank_manage_tab.
  ///
  /// In en, this message translates to:
  /// **'Manage bank accounts'**
  String get rider_bank_manage_tab;

  /// No description provided for @rider_bank_added.
  ///
  /// In en, this message translates to:
  /// **'Bank account added'**
  String get rider_bank_added;

  /// No description provided for @rider_bank_add_button.
  ///
  /// In en, this message translates to:
  /// **'Add bank account'**
  String get rider_bank_add_button;

  /// No description provided for @rider_profile_update.
  ///
  /// In en, this message translates to:
  /// **'Update'**
  String get rider_profile_update;

  /// No description provided for @notif_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No notifications'**
  String get notif_empty_title;

  /// No description provided for @notif_empty_desc.
  ///
  /// In en, this message translates to:
  /// **'You\'re all caught up!'**
  String get notif_empty_desc;

  /// No description provided for @notif_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get notif_today;

  /// No description provided for @notif_older.
  ///
  /// In en, this message translates to:
  /// **'Older'**
  String get notif_older;

  /// No description provided for @support_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get support_phone;

  /// No description provided for @support_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get support_email;

  /// No description provided for @snackbar_fill_fields.
  ///
  /// In en, this message translates to:
  /// **'Please fill all fields'**
  String get snackbar_fill_fields;

  /// No description provided for @snackbar_bank_added.
  ///
  /// In en, this message translates to:
  /// **'Bank account added'**
  String get snackbar_bank_added;

  /// No description provided for @snackbar_password_mismatch.
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get snackbar_password_mismatch;

  /// No description provided for @snackbar_password_updated.
  ///
  /// In en, this message translates to:
  /// **'Password updated successfully'**
  String get snackbar_password_updated;

  /// No description provided for @snackbar_amount_exceeds.
  ///
  /// In en, this message translates to:
  /// **'Amount exceeds available balance of ₦{amount}'**
  String snackbar_amount_exceeds(String amount);

  /// No description provided for @snackbar_withdrawal_initiated.
  ///
  /// In en, this message translates to:
  /// **'Withdrawal of ₦{withdrawalAmount} initiated'**
  String snackbar_withdrawal_initiated(String withdrawalAmount);

  /// No description provided for @snackbar_status_updated.
  ///
  /// In en, this message translates to:
  /// **'Status updated to {status}'**
  String snackbar_status_updated(String status);

  /// No description provided for @snackbar_update_failed.
  ///
  /// In en, this message translates to:
  /// **'Update failed: {error}'**
  String snackbar_update_failed(String error);

  /// No description provided for @snackbar_select_category_image.
  ///
  /// In en, this message translates to:
  /// **'Please select a category and at least one image'**
  String get snackbar_select_category_image;

  /// No description provided for @snackbar_enter_name_price.
  ///
  /// In en, this message translates to:
  /// **'Please enter product name and price'**
  String get snackbar_enter_name_price;

  /// No description provided for @snackbar_product_added.
  ///
  /// In en, this message translates to:
  /// **'Product added successfully'**
  String get snackbar_product_added;

  /// No description provided for @snackbar_product_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to create product: {error}'**
  String snackbar_product_failed(String error);

  /// No description provided for @payment_placing_order.
  ///
  /// In en, this message translates to:
  /// **'Placing Order...'**
  String get payment_placing_order;

  /// No description provided for @payment_initiating.
  ///
  /// In en, this message translates to:
  /// **'Initiating Payment...'**
  String get payment_initiating;

  /// No description provided for @payment_processing.
  ///
  /// In en, this message translates to:
  /// **'Processing Payment'**
  String get payment_processing;

  /// No description provided for @payment_verifying.
  ///
  /// In en, this message translates to:
  /// **'Verifying Payment...'**
  String get payment_verifying;

  /// No description provided for @payment_success.
  ///
  /// In en, this message translates to:
  /// **'Payment Successful'**
  String get payment_success;

  /// No description provided for @payment_failed.
  ///
  /// In en, this message translates to:
  /// **'Payment Failed'**
  String get payment_failed;

  /// No description provided for @payment_check_manually.
  ///
  /// In en, this message translates to:
  /// **'We\'re verifying your transaction. Tap to check manually.'**
  String get payment_check_manually;

  /// No description provided for @payment_check_now.
  ///
  /// In en, this message translates to:
  /// **'Check Now'**
  String get payment_check_now;

  /// No description provided for @payment_go_home.
  ///
  /// In en, this message translates to:
  /// **'Back to Home'**
  String get payment_go_home;

  /// No description provided for @payment_verifying_background.
  ///
  /// In en, this message translates to:
  /// **'Verifying payment in the background...'**
  String get payment_verifying_background;

  /// No description provided for @payment_order_placed.
  ///
  /// In en, this message translates to:
  /// **'Order placed successfully'**
  String get payment_order_placed;

  /// No description provided for @products_out_of_stock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get products_out_of_stock;

  /// No description provided for @stock_error_title.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get stock_error_title;

  /// No description provided for @stock_error_message.
  ///
  /// In en, this message translates to:
  /// **'Some items in your basket are no longer available in the requested quantity. Please update your basket to proceed.'**
  String get stock_error_message;

  /// No description provided for @stock_error_review_basket.
  ///
  /// In en, this message translates to:
  /// **'Review Basket'**
  String get stock_error_review_basket;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ha', 'ig', 'pcm', 'yo'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ha':
      return AppLocalizationsHa();
    case 'ig':
      return AppLocalizationsIg();
    case 'pcm':
      return AppLocalizationsPcm();
    case 'yo':
      return AppLocalizationsYo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
