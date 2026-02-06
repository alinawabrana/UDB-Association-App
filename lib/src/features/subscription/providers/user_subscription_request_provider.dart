import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_subscription_request_model.dart';
import '../services/user_subscription_request_service.dart';
import '../../auth/provider/auth_providers.dart';

// User Subscription Request Service Provider
final userSubscriptionRequestServiceProvider =
    Provider<UserSubscriptionRequestService>(
      (ref) => UserSubscriptionRequestService(),
    );

// User Subscription Requests FutureProvider
final userSubscriptionRequestsProvider =
    FutureProvider<UserSubscriptionRequestResponse>((ref) async {
      final service = ref.read(userSubscriptionRequestServiceProvider);
      final token = ref.watch(authTokenProvider);

      if (token == null) {
        throw Exception('User not authenticated');
      }

      return await service.fetchUserSubscriptionRequests(token: token);
    });

// Provider to get current user's subscription request
final currentUserSubscriptionRequestProvider =
    FutureProvider<UserSubscriptionRequest?>((ref) async {
      final requestsAsync = await ref.watch(
        userSubscriptionRequestsProvider.future,
      );
      final userAsync = await ref.watch(profileProvider.future);

      // Log all subscription requests
      print('=== USER SUBSCRIPTION REQUESTS API RESPONSE ===');
      print('Total requests: ${requestsAsync.data.length}');
      for (int i = 0; i < requestsAsync.data.length; i++) {
        final request = requestsAsync.data[i];
        print('Request $i: ${request.toJson()}');
      }
      print('=== END USER SUBSCRIPTION REQUESTS RESPONSE ===');

      // Parse user id to int for comparison
      final userId = int.tryParse(userAsync.id ?? '');
      if (userId == null) {
        print('User ID is null, returning null');
        return null;
      }

      print('Current user ID: $userId');

      // Find the subscription request for the current user
      final userRequests = requestsAsync.data.where(
        (request) => request.userId == userId,
      );

      print('User requests found: ${userRequests.length}');

      if (userRequests.isEmpty) {
        print('No user requests found, returning null');
        return null;
      }

      // Return the most recent request
      final sortedRequests = userRequests.toList();
      sortedRequests.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      final selectedRequest = sortedRequests.first;

      print('Selected request (most recent): ${selectedRequest.toJson()}');
      print('Status: ${selectedRequest.status}');
      print('Is approved: ${selectedRequest.isApproved}');
      print('Is expired: ${selectedRequest.isExpired}');
      print('Is active: ${selectedRequest.isActive}');

      return selectedRequest;
    });
