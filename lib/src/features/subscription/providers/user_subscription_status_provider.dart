import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/provider/auth_providers.dart';
import 'user_subscription_request_provider.dart';

/// Provider to check if user has approved subscription for companies tab visibility
final userHasApprovedSubscriptionProvider = FutureProvider<bool>((ref) async {
  final token = ref.watch(authTokenProvider);

  if (token == null) return false;

  try {
    final user = await ref.watch(profileProvider.future);
    final userRole = user.role?.toLowerCase();

    // Only check subscription for 'user' role
    if (userRole != 'user') {
      return true; // Show companies tab for non-user roles
    }

    final service = ref.read(userSubscriptionRequestServiceProvider);
    final response = await service.fetchUserSubscriptionRequests(token: token);

    // Parse user id to int for comparison
    final userId = int.tryParse(user.id ?? '');
    if (userId == null) return false;

    // Find the subscription request for the current user
    final userRequests = response.data.where(
      (request) => request.userId == userId,
    );

    if (userRequests.isEmpty) return false;

    // Return the most recent request
    final sortedRequests = userRequests.toList();
    sortedRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final selectedRequest = sortedRequests.first;

    // Only show companies tab if user has approved and active subscription
    return selectedRequest.isActive;
  } catch (e) {
    print('Error checking subscription status: $e');
    return false; // Hide companies tab on error
  }
});

/// Provider to get the current user's subscription status for quick access
final userSubscriptionStatusProvider = FutureProvider<UserSubscriptionStatus>((
  ref,
) async {
  final token = ref.watch(authTokenProvider);
  final userAsync = ref.watch(profileProvider);

  if (token == null) return UserSubscriptionStatus.noSubscription;

  return userAsync.when(
    data: (user) async {
      final userRole = user.role?.toLowerCase();

      // Only check subscription for 'user' role
      if (userRole != 'user') {
        return UserSubscriptionStatus
            .approved; // Non-user roles are considered approved
      }

      try {
        final service = ref.read(userSubscriptionRequestServiceProvider);
        final response = await service.fetchUserSubscriptionRequests(
          token: token,
        );

        // Parse user id to int for comparison
        final userId = int.tryParse(user.id ?? '');
        if (userId == null) return UserSubscriptionStatus.noSubscription;

        // Find the subscription request for the current user
        final userRequests = response.data.where(
          (request) => request.userId == userId,
        );

        if (userRequests.isEmpty) return UserSubscriptionStatus.noSubscription;

        // Return the most recent request
        final sortedRequests = userRequests.toList();
        sortedRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final selectedRequest = sortedRequests.first;

        if (selectedRequest.isActive) {
          return UserSubscriptionStatus.approved;
        } else if (selectedRequest.isPending) {
          return UserSubscriptionStatus.pending;
        } else if (selectedRequest.isExpired) {
          return UserSubscriptionStatus.expired;
        } else {
          return UserSubscriptionStatus.noSubscription;
        }
      } catch (e) {
        print('Error checking subscription status: $e');
        return UserSubscriptionStatus.noSubscription;
      }
    },
    loading: () => UserSubscriptionStatus.loading,
    error: (_, __) => UserSubscriptionStatus.noSubscription,
  );
});

/// Enum for subscription status
enum UserSubscriptionStatus {
  noSubscription,
  pending,
  approved,
  expired,
  loading,
}
