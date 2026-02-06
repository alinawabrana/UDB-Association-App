import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_service.dart';
import '../../auth/provider/auth_providers.dart';

/// Provider to fetch shipping addresses
final shippingAddressesProvider =
    FutureProvider.autoDispose<List<Map<String, dynamic>>>((ref) async {
      final authToken = ref.read(authTokenProvider);
      if (authToken == null) {
        throw Exception('User not authenticated');
      }

      try {
        final addresses = await ApiService.fetchShippingAddresses(
          authToken: authToken,
        );
        return addresses;
      } catch (e) {
        print('Error fetching shipping addresses: $e');
        throw Exception('Failed to fetch shipping addresses: $e');
      }
    });

/// Provider to create shipping address
final createShippingAddressProvider =
    FutureProvider.family<void, Map<String, dynamic>>((ref, addressData) async {
      final authToken = ref.read(authTokenProvider);
      if (authToken == null) {
        throw Exception('User not authenticated');
      }

      try {
        await ApiService.createShippingAddress(
          authToken: authToken,
          firstName: addressData['first_name'] as String,
          lastName: addressData['last_name'] as String,
          addressLine1: addressData['address_line1'] as String,
          city: addressData['city'] as String?,
          state: addressData['state'] as String?,
          zipCode: addressData['zip_code'] as String?,
          country: addressData['country'] as String?,
          phone: addressData['phone'] as String?,
          isDefault: addressData['is_default'] as bool?,
        );

        // Refresh the addresses list
        ref.invalidate(shippingAddressesProvider);
      } catch (e) {
        print('Error creating shipping address: $e');
        throw Exception('Failed to create shipping address: $e');
      }
    });

/// Provider to refresh shipping addresses
final refreshShippingAddressesProvider = FutureProvider<void>((ref) async {
  ref.invalidate(shippingAddressesProvider);
  await ref.read(shippingAddressesProvider.future);
});

/// Provider to process checkout
final checkoutProvider =
    FutureProvider.family<Map<String, dynamic>, Map<String, dynamic>>((
      ref,
      checkoutData,
    ) async {
      final authToken = ref.read(authTokenProvider);
      if (authToken == null) {
        throw Exception('User not authenticated');
      }

      try {
        final response = await ApiService.processCheckout(
          authToken: authToken,
          shippingAddressId: checkoutData['shipping_address_id'] as int,
          paymentMethod: checkoutData['payment_method'] as String?,
          selectedCartItemIds: checkoutData['items'] as List<int>?,
        );
        return response;
      } catch (e) {
        print('Error processing checkout: $e');
        throw Exception('Failed to process checkout: $e');
      }
    });
