import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_booking_model.dart';
import '../services/subscription_booking_service.dart';
import '../../auth/provider/auth_providers.dart';

// Subscription Booking Service Provider
final subscriptionBookingServiceProvider = Provider<SubscriptionBookingService>(
  (ref) => SubscriptionBookingService(),
);

// Subscription Bookings FutureProvider
final subscriptionBookingsProvider =
    FutureProvider<SubscriptionBookingResponse>((ref) async {
      final service = ref.read(subscriptionBookingServiceProvider);
      final token = ref.watch(authTokenProvider);

      if (token == null) {
        throw Exception('User not authenticated');
      }

      return await service.fetchSubscriptionBookings(token: token);
    });

// Provider to get current user's active subscription
final currentUserSubscriptionProvider = FutureProvider<SubscriptionBooking?>((
  ref,
) async {
  final bookingsAsync = ref.watch(subscriptionBookingsProvider);
  final userAsync = ref.watch(profileProvider);

  return bookingsAsync.when(
    data: (bookingsResponse) async {
      final user = await userAsync.when(
        data: (user) => user,
        loading: () => null,
        error: (_, __) => null,
      );

      if (user == null) {
        print('User is null, returning null');
        return null;
      }

      // Log all subscription bookings
      print('=== SUBSCRIPTION BOOKINGS API RESPONSE ===');
      print('Total bookings: ${bookingsResponse.data.length}');
      for (int i = 0; i < bookingsResponse.data.length; i++) {
        final booking = bookingsResponse.data[i];
        print('Booking $i: ${booking.toJson()}');
      }
      print('=== END SUBSCRIPTION BOOKINGS RESPONSE ===');

      // Parse user id to int for comparison
      final userId = int.tryParse(user.id ?? '');
      if (userId == null) {
        print('User ID is null, returning null');
        return null;
      }

      print('Current user ID: $userId');

      // Find the subscription booking for the current user
      final userBookings = bookingsResponse.data.where(
        (booking) => booking.userId == userId,
      );

      print('User bookings found: ${userBookings.length}');

      if (userBookings.isEmpty) {
        print('No user bookings found, returning null');
        return null;
      }

      // Return the most recent active subscription
      final activeBookings = userBookings.where((b) => b.isActive).toList();
      print('Active bookings: ${activeBookings.length}');

      if (activeBookings.isEmpty) {
        // If no active, return the most recent one
        userBookings.toList().sort(
          (a, b) => b.createdAt.compareTo(a.createdAt),
        );
        final selectedBooking = userBookings.first;
        print('Selected booking (most recent): ${selectedBooking.toJson()}');
        print('Created date: ${selectedBooking.createdAt}');
        print('Expiry date: ${selectedBooking.expiryDate}');
        print(
          'Same day check: ${selectedBooking.createdAt.year == selectedBooking.expiryDate.year && selectedBooking.createdAt.month == selectedBooking.expiryDate.month && selectedBooking.createdAt.day == selectedBooking.expiryDate.day}',
        );
        return selectedBooking;
      }

      // Return the one with the latest expiry date
      activeBookings.sort((a, b) => b.expiryDate.compareTo(a.expiryDate));
      final selectedBooking = activeBookings.first;
      print('Selected booking (latest expiry): ${selectedBooking.toJson()}');
      print('Created date: ${selectedBooking.createdAt}');
      print('Expiry date: ${selectedBooking.expiryDate}');
      print(
        'Same day check: ${selectedBooking.createdAt.year == selectedBooking.expiryDate.year && selectedBooking.createdAt.month == selectedBooking.expiryDate.month && selectedBooking.createdAt.day == selectedBooking.expiryDate.day}',
      );
      return selectedBooking;
    },
    loading: () async {
      print('Subscription bookings loading...');
      return null;
    },
    error: (error, stack) async {
      print('Error loading subscription bookings: $error');
      return null;
    },
  );
});
