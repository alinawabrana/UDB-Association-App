import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Subscription Type Enum
enum SubscriptionType { member, vendor }

/// Provider to track which subscription type the user selected
final subscriptionTypeProvider = StateProvider<SubscriptionType?>(
  (ref) => null,
);
