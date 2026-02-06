import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/subscription_plan.dart';
import '../services/subscription_service.dart';

// Subscription Service Provider
final subscriptionServiceProvider = Provider<SubscriptionService>(
  (ref) => SubscriptionService(),
);

// Subscriptions FutureProvider
final subscriptionsProvider = FutureProvider<List<SubscriptionPlan>>((
  ref,
) async {
  final service = ref.read(subscriptionServiceProvider);
  return await service.fetchSubscriptions();
});
