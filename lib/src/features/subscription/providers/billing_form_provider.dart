import 'package:flutter_riverpod/flutter_riverpod.dart';

class BillingFormState {
  final String billingAddress;
  final String customerEmail;
  final String customerName;
  final String phone;
  final String businessName;
  final String shopTagline;
  final String shopDetail;
  final bool isSameAsUser;
  final bool isLoading;
  final String? error;

  const BillingFormState({
    this.billingAddress = '',
    this.customerEmail = '',
    this.customerName = '',
    this.phone = '',
    this.businessName = '',
    this.shopTagline = '',
    this.shopDetail = '',
    this.isSameAsUser = false,
    this.isLoading = false,
    this.error,
  });

  BillingFormState copyWith({
    String? billingAddress,
    String? customerEmail,
    String? customerName,
    String? phone,
    String? businessName,
    String? shopTagline,
    String? shopDetail,
    bool? isSameAsUser,
    bool? isLoading,
    String? error,
  }) => BillingFormState(
    billingAddress: billingAddress ?? this.billingAddress,
    customerEmail: customerEmail ?? this.customerEmail,
    customerName: customerName ?? this.customerName,
    phone: phone ?? this.phone,
    businessName: businessName ?? this.businessName,
    shopTagline: shopTagline ?? this.shopTagline,
    shopDetail: shopDetail ?? this.shopDetail,
    isSameAsUser: isSameAsUser ?? this.isSameAsUser,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );

  bool get isFormValid {
    return customerEmail.isNotEmpty &&
        customerName.isNotEmpty &&
        phone.isNotEmpty &&
        businessName.isNotEmpty;
  }
}

class BillingFormController extends StateNotifier<BillingFormState> {
  BillingFormController() : super(const BillingFormState());

  void updateAddress(String value) {
    state = state.copyWith(billingAddress: value);
  }

  void updateCustomerEmail(String value) {
    state = state.copyWith(customerEmail: value);
  }

  void updateCustomerName(String value) {
    state = state.copyWith(customerName: value);
  }

  void updatePhone(String value) {
    state = state.copyWith(phone: value);
  }

  void updateBusinessName(String value) {
    state = state.copyWith(businessName: value);
  }

  void updateShopTagline(String value) {
    state = state.copyWith(shopTagline: value);
  }

  void updateShopDetail(String value) {
    state = state.copyWith(shopDetail: value);
  }

  void toggleSameAsUser(bool value) {
    if (value) {
      // When enabling "same as user", we need to get the current user data
      // This will be handled by the widget that calls this method
      state = state.copyWith(isSameAsUser: value);
    } else {
      // When disabling "same as user", keep current values but allow editing
      state = state.copyWith(isSameAsUser: value);
    }
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  void prefillWithUserData({
    required String email,
    required String name,
    String? phone,
    String? address,
    String? businessName,
    String? shopDetails,
  }) {
    state = state.copyWith(
      customerEmail: email,
      customerName: name,
      phone: phone ?? '',
      billingAddress: address ?? '',
      businessName: businessName ?? '',
      shopDetail: shopDetails ?? '',
    );
  }

  void reset() {
    state = const BillingFormState();
  }
}

final billingFormProvider =
    StateNotifierProvider<BillingFormController, BillingFormState>((ref) {
      return BillingFormController();
    });
