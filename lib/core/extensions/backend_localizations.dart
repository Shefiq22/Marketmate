import 'package:flutter/material.dart';

/// Translates backend dynamic data (order statuses, categories, etc.)
/// using inline lookup maps — NOT ARB keys — because these are
/// database values, not static UI strings.
extension BackendLocalizations on BuildContext {
  String translateOrderStatus(String status) {
    final locale = Localizations.localeOf(this).languageCode;
    final map = _orderStatusTranslations[status];
    return map?[locale] ?? map?['en'] ?? status;
  }

  String translateCategory(String category) {
    final locale = Localizations.localeOf(this).languageCode;
    final map = _categoryTranslations[category.toLowerCase()];
    return map?[locale] ?? map?['en'] ?? category;
  }

  String translateDeliveryClass(String deliveryClass) {
    final locale = Localizations.localeOf(this).languageCode;
    final key = deliveryClass
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
    final map = _deliveryClassTranslations[key];
    return map?[locale] ?? map?['en'] ?? deliveryClass;
  }

  String translateProductType(String type) {
    final locale = Localizations.localeOf(this).languageCode;
    final map = _productTypeTranslations[type.toLowerCase()];
    return map?[locale] ?? map?['en'] ?? type;
  }
}

const _orderStatusTranslations = <String, Map<String, String>>{
  'pending': {
    'en': 'Pending',
    'ha': 'Ana jira',
    'ig': 'Na-echere',
    'yo': 'Òṣísẹ́ǹkù',
    'pcm': 'Pending',
  },
  'order_accepted': {
    'en': 'Accepted',
    'ha': 'An karɓa',
    'ig': 'Anabatara',
    'yo': 'Ti gbà',
    'pcm': 'Accepted',
  },
  'preparing_order': {
    'en': 'Preparing',
    'ha': 'Ana shirya',
    'ig': 'Na-akwado',
    'yo': 'Ń mura',
    'pcm': 'Preparing',
  },
  'ready_for_pickup': {
    'en': 'Ready for Pickup',
    'ha': 'Shirye don ɗauka',
    'ig': 'Dị njikere iburu',
    'yo': 'Ń ṣetán fún gbígba',
    'pcm': 'Ready for Pickup',
  },
  'rider_assigned': {
    'en': 'Rider Assigned',
    'ha': 'An sanya mahayi',
    'ig': 'Ekenyela onye nnyefe',
    'yo': 'Ti yan awakọ̀',
    'pcm': 'Rider don assign',
  },
  'in_transit': {
    'en': 'In Transit',
    'ha': 'Ana kan hanya',
    'ig': "N'ụzọ",
    'yo': 'Ń lọ',
    'pcm': 'In Transit',
  },
  'order_arrived': {
    'en': 'Arrived',
    'ha': 'Ya isa',
    'ig': 'Eruola',
    'yo': 'Ti dé',
    'pcm': 'Don arrive',
  },
  'completed': {
    'en': 'Completed',
    'ha': 'An kammala',
    'ig': 'Emechara',
    'yo': 'Ti parí',
    'pcm': 'Don finish',
  },
  'cancelled': {
    'en': 'Cancelled',
    'ha': 'An soke',
    'ig': 'Akagbuola',
    'yo': 'Ti fagilé',
    'pcm': 'Cancelled',
  },
  'rejected': {
    'en': 'Rejected',
    'ha': 'An ƙi',
    'ig': 'Ajụrụla',
    'yo': 'Ti kọ̀',
    'pcm': 'Rejected',
  },
};

const _categoryTranslations = <String, Map<String, String>>{
  'all': {
    'en': 'All',
    'ha': 'Duka',
    'ig': 'Nile',
    'yo': 'Gbogbo',
    'pcm': 'All',
  },
  'vegetables': {
    'en': 'Vegetables',
    'ha': 'Kayan lambu',
    'ig': 'Akwụkwọ nri',
    'yo': 'Ẹ̀fọ́',
    'pcm': 'Vegetables',
  },
  'foodstuff': {
    'en': 'Foodstuff',
    'ha': 'Kayan abinci',
    'ig': 'Nri nri',
    'yo': 'Oúnjẹ',
    'pcm': 'Foodstuff',
  },
  'fruits': {
    'en': 'Fruits',
    'ha': "Ya'yan itatuwa",
    'ig': 'Mkpụrụ osisi',
    'yo': 'Èso',
    'pcm': 'Fruits',
  },
  'meat': {
    'en': 'Meat',
    'ha': 'Nama',
    'ig': 'Anụ',
    'yo': 'Eran',
    'pcm': 'Meat',
  },
  'fish': {
    'en': 'Fish',
    'ha': 'Kifi',
    'ig': 'Azụ',
    'yo': 'Eja',
    'pcm': 'Fish',
  },
  'groceries': {
    'en': 'Groceries',
    'ha': 'Kayan miya',
    'ig': 'Ngwa nri',
    'yo': 'Ohun títà',
    'pcm': 'Groceries',
  },
  'electronics': {
    'en': 'Electronics',
    'ha': "Na'ura mai aiki",
    'ig': 'Ngwa eletrọnik',
    'yo': 'Ẹ̀rọ',
    'pcm': 'Electronics',
  },
  'fashion': {
    'en': 'Fashion',
    'ha': 'Salon',
    'ig': 'Ejiji',
    'yo': 'Aṣọ',
    'pcm': 'Fashion',
  },
};

const _deliveryClassTranslations = <String, Map<String, String>>{
  'standard': {
    'en': 'Standard',
    'ha': 'Daidaitacce',
    'ig': 'Ọkọlọtọ',
    'yo': 'Bóṣèwọ́n',
    'pcm': 'Standard',
  },
  'express': {
    'en': 'Express',
    'ha': 'Gaggauce',
    'ig': 'Ọsọ',
    'yo': 'Yára',
    'pcm': 'Express',
  },
  'same_day': {
    'en': 'Same Day',
    'ha': 'Rana guda',
    'ig': 'Otu ụbọchị',
    'yo': 'Ọjọ́ kan náà',
    'pcm': 'Same Day',
  },
};

const _productTypeTranslations = <String, Map<String, String>>{
  'standard': {
    'en': 'Standard',
    'ha': 'Daidaitacce',
    'ig': 'Ọkọlọtọ',
    'yo': 'Bóṣèwọ́n',
    'pcm': 'Standard',
  },
  'fragile': {
    'en': 'Fragile',
    'ha': 'Mai karyewa',
    'ig': 'Na-emebi emebi',
    'yo': 'Ohun tó ń fọ́',
    'pcm': 'Fragile',
  },
  'bulky': {
    'en': 'Bulky',
    'ha': 'Mai girma',
    'ig': 'Nnukwu',
    'yo': 'Tó tóbi',
    'pcm': 'Bulky',
  },
  'heavy': {
    'en': 'Heavy',
    'ha': 'Mai nauyi',
    'ig': 'Dị arọ',
    'yo': 'Tó wúwo',
    'pcm': 'Heavy',
  },
};
