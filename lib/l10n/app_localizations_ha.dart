// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Hausa (`ha`).
class AppLocalizationsHa extends AppLocalizations {
  AppLocalizationsHa([String locale = 'ha']) : super(locale);

  @override
  String get appbar_settings => 'Saituna';

  @override
  String get menu_dark_mode => 'Yanayin Duhu';

  @override
  String get menu_security => 'Tsaro';

  @override
  String get menu_language => 'Harshe';

  @override
  String get menu_notifications => 'Sanarwa';

  @override
  String get menu_privacy_policy => 'Manufar Keɓantawa';

  @override
  String get menu_terms_of_service => 'Sharuɗɗan Sabis';

  @override
  String translate_to(String lang) {
    return 'Fassara zuwa $lang';
  }

  @override
  String get translate_show_original => 'Nuna asali';

  @override
  String get translate_retry => 'Fassarar ta gaza. Danna don sake gwadawa.';

  @override
  String get menu_reset_password => 'Sake Saita Kalmar Sirri';

  @override
  String get menu_fingerprint => 'Tambarin Yatsa';

  @override
  String get section_preferences => 'Zaɓuɓɓuka';

  @override
  String get section_general => 'Gabaɗaya';

  @override
  String get section_support => 'Taimako';

  @override
  String get language_screen_title => 'Harshe';

  @override
  String get language_en => 'English';

  @override
  String get language_ha => 'Harshen Hausa';

  @override
  String get language_ig => 'Asụsụ Igbo';

  @override
  String get language_yo => 'Èdè Yorùbá';

  @override
  String get language_pcm => 'Pidgin English';

  @override
  String get nav_home => 'Gida';

  @override
  String get nav_products => 'Kayayyaki';

  @override
  String get nav_cart => 'Kwando';

  @override
  String get nav_orders => 'Umarni';

  @override
  String get nav_profile => 'Bayanan Kai';

  @override
  String get nav_riders => 'Masu Bayarwa';

  @override
  String get nav_deliveries => 'Bayarwa';

  @override
  String get nav_wallet => 'Jaka';

  @override
  String get category_all => 'Duka';

  @override
  String get category_vegetables => 'Kayan Lambu';

  @override
  String get category_foodstuff => 'Kayan Abinci';

  @override
  String get category_fruits => '\'Ya\'yan Itatuwa';

  @override
  String get category_meat => 'Nama';

  @override
  String get category_fish => 'Kifi';

  @override
  String get retry => 'Sake gwadawa';

  @override
  String get see_all => 'Duba Duka';

  @override
  String get loading_ellipsis => 'Ana ɗauka...';

  @override
  String get failed_to_load => 'An kasa ɗauka';

  @override
  String home_greeting(String name) {
    return 'Barka da zuwa $name,';
  }

  @override
  String get home_search_hint =>
      'Nemo shaguna, kayan lambu, \'ya\'yan itatuwa da sauransu.';

  @override
  String get home_featured_stores => 'Fitattun Shaguna';

  @override
  String get home_categories => 'Rukunoni';

  @override
  String get home_available_sellers => 'Masu Sayarwa';

  @override
  String get home_no_sellers_found => 'Ba a sami masu sayarwa ba';

  @override
  String get home_search_empty_hint => 'Gwada neman wani abu daban';

  @override
  String get home_error_loading =>
      'An kasa ɗaukar kayayyaki.\nJa ƙasa don sake gwadawa.';

  @override
  String get home_open_now => 'Buɗe Yanzu';

  @override
  String get home_closed => 'Rufe';

  @override
  String get home_free => 'Kyauta';

  @override
  String get home_free_delivery => 'Bayarwa kyauta';

  @override
  String get products_search_hint =>
      'Nemo kayan lambu, \'ya\'yan itatuwa da sauransu.';

  @override
  String get products_categories => 'Rukunoni';

  @override
  String get products_browse => 'Bincika kayayyaki';

  @override
  String get products_no_products => 'Babu kayayyaki';

  @override
  String get products_no_products_category =>
      'Ba a sami kayayyaki a wannan rukuni ba';

  @override
  String get products_add => 'Ƙara';

  @override
  String get products_sold_out_badge => 'An sayar';

  @override
  String get orders_title => 'Umarni';

  @override
  String get orders_history => 'Tarihin umarni';

  @override
  String get orders_active => 'Aiki';

  @override
  String get orders_pending => 'Ana jira';

  @override
  String get orders_completed => 'An kammala';

  @override
  String get orders_no_active => 'Babu umarni masu aiki';

  @override
  String get orders_no_active_desc => 'Umarni masu aiki za su bayyana a nan.';

  @override
  String get orders_no_pending => 'Babu umarni masu jiran aiki';

  @override
  String get orders_no_pending_desc =>
      'Umarni masu jiran aiki za su bayyana a nan.';

  @override
  String get orders_no_completed => 'Babu umarni da aka kammala';

  @override
  String get orders_no_completed_desc =>
      'Umarni da aka kammala za su bayyana a nan.';

  @override
  String get orders_no_history => 'Babu tarihin umarni';

  @override
  String get orders_no_history_desc =>
      'Umarnin da suka gabata za su bayyana a nan.';

  @override
  String get orders_status_active => 'Aiki';

  @override
  String get orders_status_awaiting => 'Ana jira';

  @override
  String get orders_status_completed => 'An kammala';

  @override
  String get cart_title => 'Kwando';

  @override
  String get cart_empty => 'Kwandon ku babu komai';

  @override
  String get cart_empty_desc =>
      'Bincika kayayyaki kuma ƙara abubuwa a cikin kwandon ku';

  @override
  String get cart_available => 'Ana iya siya';

  @override
  String get cart_sold_out_section => 'An sayar';

  @override
  String get cart_total => 'Jimla';

  @override
  String get cart_checkout => 'Ci gaba da Siyayya';

  @override
  String get dialog_sign_out_title => 'Shin kuna tabbatar da fitarwa?';

  @override
  String get dialog_yes => 'E';

  @override
  String get dialog_back_to_home => 'Koma Gida';

  @override
  String get dialog_cancel => 'Soke';

  @override
  String get dialog_clear_cart_title => 'Share kwando?';

  @override
  String get dialog_clear_cart_body =>
      'Shin kuna tabbatar da cire duk abubuwa?';

  @override
  String get dialog_clear => 'Share';

  @override
  String get menu_profile_label => 'Bayanan Kai';

  @override
  String get menu_address_book => 'Littafin adireshi';

  @override
  String get menu_messages => 'Saƙonni';

  @override
  String get menu_alert_preferences => 'Zaɓin faɗakarwa';

  @override
  String get menu_help_support => 'Taimako';

  @override
  String get menu_settings_label => 'Saituna';

  @override
  String get menu_sign_out => 'Fita';

  @override
  String get menu_dark_mode_label => 'Yanayin duhu';

  @override
  String get menu_earnings => 'Kuɗaɗe';

  @override
  String get menu_bank_payouts => 'Banki da Biya';

  @override
  String get menu_wallet_label => 'Jaka';

  @override
  String get product_no_reviews => 'Babu sharhi tukuna';

  @override
  String get product_be_first_review => 'Ka zama farkon mai sharhi';

  @override
  String get review_hint => 'Raba gogewar ku ta gaske';

  @override
  String get review_submit => 'Gabatar da Sharhi';

  @override
  String get review_view_orders => 'Duba Umarni';

  @override
  String get review_back_homepage => 'Koma Gida';

  @override
  String get receipt_view => 'Duba Rasit';

  @override
  String get receipt_date => 'Kwanan wata:';

  @override
  String get receipt_time => 'Lokaci:';

  @override
  String get receipt_to => 'Zuwa:';

  @override
  String get receipt_for => 'Don:';

  @override
  String get receipt_delivery => 'Bayarwa';

  @override
  String get receipt_subtotal => 'Jimlar Ƙasa';

  @override
  String get receipt_rate_items => 'Ƙididdiga Kayayyaki';

  @override
  String get checkout_bank_transfer => 'Canja wuri na banki';

  @override
  String get checkout_bank_transfer_desc =>
      'Canja wuri zuwa asusun mai sayarwa';

  @override
  String get checkout_saved_card => 'Katin da aka ajiye';

  @override
  String get checkout_paystack => 'Paystack';

  @override
  String get checkout_delivery_fee => 'Kuɗin bayarwa';

  @override
  String get checkout_commission => 'Kuɗin sabis';

  @override
  String get checkout_total_label => 'Jimla';

  @override
  String get checkout_add_address => 'Ƙara sabon adireshi';

  @override
  String get checkout_add_address_hint =>
      'Da fatan za a ƙara adireshin bayarwa';

  @override
  String get order_detail_delivery => 'Bayarwa';

  @override
  String get order_detail_subtotal => 'Jimlar Ƙasa';

  @override
  String get order_detail_delivery_address => 'Adireshin bayarwa';

  @override
  String get order_detail_payment_method => 'Hanyar biya';

  @override
  String get order_detail_message_seller => 'Saƙo ga mai sayarwa';

  @override
  String get order_detail_ordered => 'An yi oda';

  @override
  String get order_detail_confirmed => 'An tabbatar';

  @override
  String get order_detail_shipped => 'An aika';

  @override
  String get order_detail_delivered => 'An bayar';

  @override
  String get profile_updated_success => 'An sabunta bayananka cikin nasara';

  @override
  String get profile_update => 'Sabunta';

  @override
  String get profile_no_session =>
      'Ba a sami zaman ba. Da fatan za a shiga kuma.';

  @override
  String get profile_refreshed => 'An sabunta bayananka';

  @override
  String get profile_refresh_error => 'An kasa sabunta bayananka.';

  @override
  String get address_no_saved => 'Babu adireshin da aka ajiye';

  @override
  String get address_deleted => 'An share adireshin';

  @override
  String get address_added => 'An ƙara adireshin!';

  @override
  String get address_saved => 'An ajiye adireshin!';

  @override
  String get address_hint_home => 'Gida';

  @override
  String get address_hint_type => 'Rubuta a nan';

  @override
  String get address_hint_enter => 'Shigar a nan';

  @override
  String get address_saving => 'Ana ajiyewa...';

  @override
  String get address_add => 'Ƙara adireshi';

  @override
  String get address_save => 'Ajiye adireshi';

  @override
  String seller_home_greeting(String name) {
    return 'Barka da zuwa $name,';
  }

  @override
  String get seller_home_search_hint =>
      'Nemo kayan lambu, \'ya\'yan itatuwa da sauransu.';

  @override
  String get seller_home_best_sellers => 'Mafi kyawun masu sayarwa';

  @override
  String get seller_home_no_best_sellers =>
      'Babu mafi kyawun masu sayarwa tukuna';

  @override
  String get seller_home_no_best_sellers_desc =>
      'Kayayyakin da suka fi siyarwa za su bayyana a nan.';

  @override
  String get seller_home_available_products => 'Kayayyakin da ake da su';

  @override
  String get seller_home_pending_approval => 'Kayayyakin da ke jiran amincewa';

  @override
  String get seller_home_no_products => 'Babu kayayyaki tukuna';

  @override
  String get seller_home_pending_approval_desc =>
      'Kayayyakinku suna jiran bita na admin. Za su bayyana a nan da zarar an amince.';

  @override
  String get seller_home_add_first_product =>
      'Ƙara kayayyakinku na farko don fara siyarwa.';

  @override
  String get seller_home_products_in_stock => 'Kayayyaki a hannu';

  @override
  String get seller_home_pending_orders => 'Umarni masu jiran aiki';

  @override
  String get seller_home_add_new_product => 'Ƙara sabon kayayyaki';

  @override
  String get product_pending_review => 'Ana Jiran Bita';

  @override
  String get product_pending_review_message =>
      'Admin naa bitar wannan samfurin. Zai bayyana da zarar an amince.';

  @override
  String get seller_categories_title => 'Rukunoni';

  @override
  String get seller_products_title => 'Kayayyaki';

  @override
  String get seller_orders_title => 'Umarni';

  @override
  String get seller_orders_history => 'Tarihin umarni';

  @override
  String get seller_orders_active => 'Aiki';

  @override
  String get seller_orders_pending => 'Ana jira';

  @override
  String get seller_orders_completed => 'An kammala';

  @override
  String get seller_orders_confirmed => 'An tabbatar';

  @override
  String get seller_orders_processed => 'An sarrafa';

  @override
  String get seller_orders_shipped => 'An aika';

  @override
  String get seller_orders_delivered => 'An bayar';

  @override
  String seller_orders_to(String customerName) {
    return 'Zuwa: $customerName';
  }

  @override
  String seller_orders_rider(String riderName) {
    return 'Mai bayarwa: $riderName';
  }

  @override
  String get seller_orders_price => 'Farashi: ';

  @override
  String seller_orders_placed_on(String date) {
    return 'An saka a $date.';
  }

  @override
  String get seller_orders_assign_rider => 'Sanya Mai Bayarwa';

  @override
  String get seller_orders_no_active => 'Babu umarni masu aiki';

  @override
  String get seller_orders_no_active_desc =>
      'Umarni masu aiki za su bayyana a nan.';

  @override
  String get seller_orders_no_pending => 'Babu umarni masu jiran aiki';

  @override
  String get seller_orders_no_pending_desc =>
      'Umarni masu jiran sanya mai bayarwa za su bayyana a nan.';

  @override
  String get seller_orders_no_completed => 'Babu umarni da aka kammala';

  @override
  String get seller_orders_no_completed_desc =>
      'Umarni da aka kammala za su bayyana a nan.';

  @override
  String get seller_orders_no_history => 'Babu tarihin umarni';

  @override
  String get seller_orders_no_history_desc =>
      'Umarnin da suka gabata za su bayyana a nan.';

  @override
  String get seller_orders_status_completed => 'An kammala';

  @override
  String get product_type_standard => 'Misali';

  @override
  String get product_type_fragile => 'Mai karye';

  @override
  String get product_type_bulky => 'Mai girma';

  @override
  String get product_type_heavy => 'Mai nauyi';

  @override
  String get seller_product_list_available => 'Akwai';

  @override
  String get seller_product_list_out_of_stock => 'Babu a hannu';

  @override
  String get seller_product_list_no_available => 'Babu kayayyaki da ake da su';

  @override
  String get seller_product_list_no_available_desc =>
      'Kayayyakin da kuka ƙara za su bayyana a nan.';

  @override
  String get seller_product_list_no_out_of_stock =>
      'Babu kayayyakin da ba a hannu';

  @override
  String get seller_product_list_all_in_stock =>
      'Duk kayayyakinku suna a hannu.';

  @override
  String get seller_add_product_title => 'Ƙara Kayayyaki';

  @override
  String get seller_add_product_select_hint =>
      'Da fatan za a zaɓi rukuni da aƙalla hoto ɗaya';

  @override
  String get seller_add_product_name_price_hint =>
      'Da fatan za a shigar da sunan kayayyaki da farashi';

  @override
  String get seller_add_product_success => 'An ƙara kayayyaki cikin nasara';

  @override
  String seller_add_product_failed(String error) {
    return 'An kasa ƙirƙirar kayayyaki: $error';
  }

  @override
  String get earnings_title => 'Kuɗaɗe';

  @override
  String get earnings_youve_earned => 'Kun samu ';

  @override
  String get earnings_available_withdrawal => ' da ake iya cirewa.';

  @override
  String get earnings_loading => 'Ana ɗaukar kuɗaɗe...';

  @override
  String get earnings_error => 'An kasa ɗaukar kuɗaɗe.';

  @override
  String earnings_breakdown(
    String available,
    String pending,
    String withdrawn,
  ) {
    return 'Akwai: $available | Ana jira: $pending | An cire: $withdrawn';
  }

  @override
  String get earnings_total => 'Jimlar Kuɗaɗe';

  @override
  String get earnings_history => 'Tarihin kuɗaɗe';

  @override
  String get earnings_actions => 'Ayyuka';

  @override
  String get earnings_manage_bank => 'Sarrafa asusun banki';

  @override
  String get earnings_withdraw => 'Cire';

  @override
  String get earnings_set_default => 'Saita ta asali';

  @override
  String get password_mismatch => 'Kalmomin sirri ba su dace ba';

  @override
  String get password_updated => 'An sabunta kalmar sirri cikin nasara';

  @override
  String get password_confirm_new => 'Tabbatar da sabuwar kalmar sirri';

  @override
  String get location_pickup => 'Wurin ɗauka';

  @override
  String get location_dropoff => 'Wurin sauka';

  @override
  String rider_home_greeting(String name) {
    return 'Barka da zuwa $name,';
  }

  @override
  String get rider_online => 'Kuna kan layi';

  @override
  String get rider_go_online => 'Shiga kan layi don karɓar buƙatun bayarwa';

  @override
  String get rider_total_earnings => 'Jimlar Kuɗaɗe';

  @override
  String get rider_payment_history => 'Tarihin biya';

  @override
  String get rider_completed_today => 'Bayarwa da aka kammala yau';

  @override
  String get rider_pending_deliveries => 'Bayarwa masu jiran aiki';

  @override
  String get rider_active_delivery => 'Bayarwa mai aiki';

  @override
  String get rider_no_active_deliveries => 'Babu bayarwa mai aiki';

  @override
  String get rider_live_location => 'Wurin kai tsaye';

  @override
  String get rider_accept_delivery => 'Karɓar bayarwa';

  @override
  String get rider_heading_to_pick => 'Ana zuwa ɗauka';

  @override
  String get rider_picked_up => 'An ɗauka';

  @override
  String get rider_delivered_label => 'An bayar';

  @override
  String get rider_delivery_soon => 'Ba da daɗewa';

  @override
  String get rider_deliveries_title => 'Bayarwa';

  @override
  String get rider_delivery_history => 'Tarihin bayarwa';

  @override
  String get rider_deliveries_active => 'Aiki';

  @override
  String get rider_deliveries_pending => 'Ana jira';

  @override
  String get rider_deliveries_completed => 'An kammala';

  @override
  String get rider_no_deliveries => 'Babu Bayarwa Tukuna';

  @override
  String get rider_no_deliveries_desc =>
      'Lokacin da kuka kammala tafiyar bayarwa, cikakken tarihin ku zai bayyana a nan.';

  @override
  String get rider_no_completed_deliveries => 'Babu Bayarwa da Aka Kammala';

  @override
  String get rider_no_completed_deliveries_desc =>
      'Tarihin bayarwar ku da aka kammala zai bayyana a nan da zarar kun gama tafiyarku ta farko.';

  @override
  String rider_order_ref(String orderRef) {
    return 'Oda $orderRef';
  }

  @override
  String rider_to_customer(String customerName) {
    return 'Zuwa: $customerName';
  }

  @override
  String get rider_status_completed => 'An kammala';

  @override
  String get wallet_title => 'Jaka';

  @override
  String get wallet_earned_prefix => 'Kun samu ';

  @override
  String get wallet_earned_suffix => ' a wannan satin. Kuna yin kyau sosai.';

  @override
  String get wallet_set_default => 'Saita ta asali';

  @override
  String get wallet_history => 'Tarihin kuɗaɗe';

  @override
  String wallet_breakdown(String percent, String amount) {
    return '$percent% na $amount jimlar kuɗaɗe na rayuwa';
  }

  @override
  String get wallet_actions => 'Ayyuka';

  @override
  String get wallet_manage_bank => 'Sarrafa asusun banki';

  @override
  String get wallet_withdraw => 'Cire';

  @override
  String get rider_withdraw_btn => 'Cire';

  @override
  String get rider_enter_hint => 'Shigar a nan';

  @override
  String get rider_fill_fields_hint => 'Da fatan za a cika duk filaye';

  @override
  String get rider_bank_add_tab => 'Ƙara asusun banki';

  @override
  String get rider_bank_manage_tab => 'Sarrafa asusun banki';

  @override
  String get rider_bank_added => 'An ƙara asusun banki';

  @override
  String get rider_bank_add_button => 'Ƙara asusun banki';

  @override
  String get rider_profile_update => 'Sabunta';

  @override
  String get notif_empty_title => 'Babu sanarwa';

  @override
  String get notif_empty_desc => 'An kama komai!';

  @override
  String get notif_today => 'Yau';

  @override
  String get notif_older => 'Tsoho';

  @override
  String get support_phone => 'Waya';

  @override
  String get support_email => 'Imel';

  @override
  String get snackbar_fill_fields => 'Da fatan za a cika duk filaye';

  @override
  String get snackbar_bank_added => 'An ƙara asusun banki';

  @override
  String get snackbar_password_mismatch => 'Kalmomin sirri ba su dace ba';

  @override
  String get snackbar_password_updated =>
      'An sabunta kalmar sirri cikin nasara';

  @override
  String snackbar_amount_exceeds(String amount) {
    return 'Adadin ya wuce ma\'aunin da ake da shi na ₦$amount';
  }

  @override
  String snackbar_withdrawal_initiated(String withdrawalAmount) {
    return 'An fara cire ₦$withdrawalAmount';
  }

  @override
  String snackbar_status_updated(String status) {
    return 'An sabunta matsayi zuwa $status';
  }

  @override
  String snackbar_update_failed(String error) {
    return 'Sabuntawa ta kasa: $error';
  }

  @override
  String get snackbar_select_category_image =>
      'Da fatan za a zaɓi rukuni da aƙalla hoto ɗaya';

  @override
  String get snackbar_enter_name_price =>
      'Da fatan za a shigar da sunan kayayyaki da farashi';

  @override
  String get snackbar_product_added => 'An ƙara kayayyaki cikin nasara';

  @override
  String snackbar_product_failed(String error) {
    return 'An kasa ƙirƙirar kayayyaki: $error';
  }

  @override
  String get payment_placing_order => 'Ana yin oda...';

  @override
  String get payment_initiating => 'Ana fara biyan kuɗi...';

  @override
  String get payment_processing => 'Ana aiwatar da biyan kuɗi';

  @override
  String get payment_verifying => 'Ana tabbatar da biyan kuɗi...';

  @override
  String get payment_success => 'Biyan kuɗi ya yi nasara';

  @override
  String get payment_failed => 'Biyan kuɗi ya gaza';

  @override
  String get payment_check_manually =>
      'Muna tabbatar da ma\'amalar ku. Danna don duba da hannu.';

  @override
  String get payment_check_now => 'Duba Yanzu';

  @override
  String get payment_go_home => 'Koma Gida';

  @override
  String get payment_verifying_background =>
      'Ana tabbatar da biyan kuɗi a bango...';

  @override
  String get payment_order_placed => 'An yi oda cikin nasara';

  @override
  String get products_out_of_stock => 'Babu Kaya';

  @override
  String get stock_error_title => 'Babu Kaya';

  @override
  String get stock_error_message =>
      'Wasu abubuwa a cikin kwandon ku ba su samuwa a adadin da aka nema. Da fatan za a sabunta kwandon ku don ci gaba.';

  @override
  String get stock_error_review_basket => 'Duba Kwando';
}
