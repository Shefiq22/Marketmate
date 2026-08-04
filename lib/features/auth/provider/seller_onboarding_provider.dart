import 'package:flutter_riverpod/flutter_riverpod.dart';

class SellerOnboardingFormState {
  final int internalStep;
  final String storeName;
  final String storeDescription;
  final String street;
  final String city;
  final String state;
  final String phoneNumber;
  final List<String> productCategories;
  final String idType;
  final String idNumber;
  final String idImageUrl;
  final bool isLoading;
  final String? error;

  const SellerOnboardingFormState({
    this.internalStep = 0,
    this.storeName = '',
    this.storeDescription = '',
    this.street = '',
    this.city = '',
    this.state = '',
    this.phoneNumber = '',
    this.productCategories = const [],
    this.idType = '',
    this.idNumber = '',
    this.idImageUrl = '',
    this.isLoading = false,
    this.error,
  });

  SellerOnboardingFormState copyWith({
    int? internalStep,
    String? storeName,
    String? storeDescription,
    String? street,
    String? city,
    String? state,
    String? phoneNumber,
    List<String>? productCategories,
    String? idType,
    String? idNumber,
    String? idImageUrl,
    bool? isLoading,
    String? error,
  }) => SellerOnboardingFormState(
    internalStep: internalStep ?? this.internalStep,
    storeName: storeName ?? this.storeName,
    storeDescription: storeDescription ?? this.storeDescription,
    street: street ?? this.street,
    city: city ?? this.city,
    state: state ?? this.state,
    phoneNumber: phoneNumber ?? this.phoneNumber,
    productCategories: productCategories ?? this.productCategories,
    idType: idType ?? this.idType,
    idNumber: idNumber ?? this.idNumber,
    idImageUrl: idImageUrl ?? this.idImageUrl,
    isLoading: isLoading ?? this.isLoading,
    error: error,
  );

  bool get step1Valid =>
      storeName.trim().isNotEmpty &&
      street.trim().isNotEmpty &&
      city.trim().isNotEmpty &&
      state.trim().isNotEmpty;

  bool get step2Valid => productCategories.isNotEmpty;

  bool get step3Valid =>
      idType.isNotEmpty &&
      idNumber.trim().isNotEmpty &&
      idImageUrl.isNotEmpty;

  bool get isComplete => step1Valid && step2Valid && step3Valid;

  Map<String, dynamic> toJson() => {
    'storeName': storeName.trim(),
    'storeDescription': storeDescription.trim(),
    'storeAddress': {
      'street': street.trim(),
      'city': city.trim(),
      'state': state.trim(),
    },
    if (phoneNumber.trim().isNotEmpty) 'phoneNumber': phoneNumber.trim(),
    'productCategories': productCategories,
    'kyc': {
      'idType': idType,
      'idNumber': idNumber.trim(),
      'idImageUrl': idImageUrl,
    },
  };
}

class SellerOnboardingNotifier extends Notifier<SellerOnboardingFormState> {
  @override
  SellerOnboardingFormState build() => const SellerOnboardingFormState();

  void reset() => state = const SellerOnboardingFormState();
  void setInternalStep(int v) => state = state.copyWith(internalStep: v);
  void setStoreName(String v) => state = state.copyWith(storeName: v, error: null);
  void setStoreDescription(String v) => state = state.copyWith(storeDescription: v, error: null);
  void setStreet(String v) => state = state.copyWith(street: v, error: null);
  void setCity(String v) => state = state.copyWith(city: v, error: null);
  void setStateVal(String v) => state = state.copyWith(state: v, error: null);
  void setPhoneNumber(String v) => state = state.copyWith(phoneNumber: v, error: null);
  void toggleCategory(String cat) {
    final current = List<String>.from(state.productCategories);
    if (current.contains(cat)) {
      current.remove(cat);
    } else {
      current.add(cat);
    }
    state = state.copyWith(productCategories: current, error: null);
  }
  void setIdType(String v) => state = state.copyWith(idType: v, error: null);
  void setIdNumber(String v) => state = state.copyWith(idNumber: v, error: null);
  void setIdImageUrl(String v) => state = state.copyWith(idImageUrl: v, error: null);
  void setError(String v) => state = state.copyWith(isLoading: false, error: v);
  void setLoading(bool v) => state = state.copyWith(isLoading: v);
}

final sellerOnboardingFormProvider =
    NotifierProvider<SellerOnboardingNotifier, SellerOnboardingFormState>(
  SellerOnboardingNotifier.new,
);
