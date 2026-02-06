import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/common/widgets/heading_tile.dart';
import 'package:udb_association/src/features/subscription/providers/subscription_booking_provider.dart';
import 'package:udb_association/src/features/subscription/providers/user_subscription_status_provider.dart';
import 'package:udb_association/src/features/subscription/providers/user_subscription_request_provider.dart';
import 'package:udb_association/src/features/subscription/models/subscription_booking_model.dart';
import 'package:udb_association/src/features/subscription/models/user_subscription_request_model.dart';

class MembershipStatusSection extends ConsumerWidget {
  final String? userRole;
  final UserSubscriptionStatus? subscriptionStatus;
  final SubscriptionBooking? subscriptionBooking;

  const MembershipStatusSection({
    super.key,
    this.userRole,
    this.subscriptionStatus,
    this.subscriptionBooking,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If parameters are provided, use them directly
    if (userRole != null) {
      if (userRole == 'user' && subscriptionStatus != null) {
        return _buildUserSubscriptionCard(context, subscriptionStatus!);
      } else if (userRole == 'member' || userRole == 'vendor') {
        return _buildMemberSubscriptionCard(context, subscriptionBooking);
      }
    }

    // Fallback to original logic for other roles
    final subscriptionAsync = ref.watch(currentUserSubscriptionProvider);

    return subscriptionAsync.when(
      data: (subscription) {
        // If no subscription found, don't show the card
        if (subscription == null) {
          return const SizedBox.shrink();
        }

        return _buildMembershipCard(context, subscription);
      },
      loading: () => _buildLoadingCard(),
      error: (err, stack) => const SizedBox.shrink(), // Hide on error
    );
  }

  Widget _buildMembershipCard(
    BuildContext context,
    SubscriptionBooking subscription,
  ) {
    final l10n = context.l10n;
    final planName =
        subscription.subscription?.type ??
        l10n.translate('profile_plan_unknown');
    final planDisplayName =
        planName.substring(0, 1).toUpperCase() + planName.substring(1);

    // Use updated_at as the subscription period start date
    final startDate = subscription.updatedAt;
    final originalExpiryDate = subscription.expiryDate;

    print('=== MEMBERSHIP STATUS CALCULATION ===');
    print('Start date (updated_at): $startDate');
    print('Original expiry date: $originalExpiryDate');
    print('Same day check: ${_isSameDay(startDate, originalExpiryDate)}');

    // Calculate expiry date based on subscription duration if needed
    DateTime expiryDate;
    if (_isSameDay(startDate, originalExpiryDate)) {
      // If they're the same day, calculate expiry from start date based on duration
      final duration =
          subscription.subscription?.duration.toLowerCase() ?? 'monthly';
      expiryDate = _calculateExpiryFromStartDate(startDate, duration);
      print('Calculated expiry from start date: $expiryDate');
    } else {
      // Use the original expiry date
      expiryDate = originalExpiryDate;
      print('Using original expiry date: $expiryDate');
    }
    print('=== END MEMBERSHIP STATUS CALCULATION ===');

    final formattedDate = DateFormat(
      'MMM dd, yyyy',
      l10n.locale.toLanguageTag(),
    ).format(expiryDate);
    print('Formatted date: $formattedDate');
    final daysRemaining = _calculateDaysRemaining(expiryDate);
    final isActive =
        expiryDate.isAfter(DateTime.now()) &&
        subscription.paymentStatus.toLowerCase() == 'paid';

    // Calculate progress based on actual subscription period
    final subscriptionDuration =
        subscription.subscription?.duration.toLowerCase() ?? 'monthly';

    // Calculate actual subscription period from start (updated_at) to expiry
    final actualSubscriptionDays = expiryDate.difference(startDate).inDays;
    final daysPassed = actualSubscriptionDays - daysRemaining;

    // Progress bar shows how much of the subscription period has passed
    // 0.0 = just started, 1.0 = fully expired
    final progress = actualSubscriptionDays > 0
        ? (daysPassed / actualSubscriptionDays).clamp(0.0, 1.0)
        : 0.0;

    print('=== PROGRESS BAR CALCULATION ===');
    print('Subscription duration: $subscriptionDuration');
    print('Start date (updated_at): $startDate');
    print('Expiry date: $expiryDate');
    print('Actual subscription days: $actualSubscriptionDays');
    print('Days passed: $daysPassed');
    print('Days remaining: $daysRemaining');
    print('Progress: ${(progress * 100).toInt()}%');
    print('=== END PROGRESS BAR CALCULATION ===');

    // Determine progress bar color based on remaining days
    Color progressColor;
    if (daysRemaining <= 0) {
      progressColor = const Color(0xFFEF4444); // Red - expired
    } else if (daysRemaining <= 3) {
      progressColor = const Color(0xFFF59E0B); // Orange - expiring soon
    } else if (daysRemaining <= 7) {
      progressColor = const Color(0xFF3B82F6); // Blue - expiring in a week
    } else {
      progressColor = const Color(0xFF10B981); // Green - plenty of time
    }

    // Determine color based on plan type
    Color planColor;
    switch (planName.toLowerCase()) {
      case 'basic':
        planColor = const Color(0xFF2563EB);
        break;
      case 'premium':
        planColor = const Color(0xFF6B7B47);
        break;
      case 'standard':
        planColor = const Color(0xFF059669);
        break;
      default:
        planColor = const Color(0xFF6B7B47);
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: HeadingTile(
              icon: Iconsax.star1,
              headingTitle: context.l10n.translate('profile_membership_title'),
            ),
          ),

          // Divider (full width)
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              spacing: 16,
              children: [
                // Current Plan Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.translate('profile_membership_current_plan'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: planColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        planDisplayName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                // Renewal Date Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      context.l10n.translate('profile_membership_expiry'),
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: isActive
                            ? const Color(0xFF1F2937)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),

                // Status indicator
                if (!isActive)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFEF4444),
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            context.l10n.translate(
                              'profile_membership_expired_body',
                            ),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFEF4444),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Days Remaining Card (only show if active)
                if (isActive && daysRemaining >= 0)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        // Days Remaining Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.l10n.translate(
                                'profile_membership_days_remaining',
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF6B7280),
                              ),
                            ),
                            Text(
                              context.l10n.translate(
                                daysRemaining == 1
                                    ? 'profile_membership_day_singular'
                                    : 'profile_membership_days_plural',
                                params: {'count': daysRemaining.toString()},
                              ),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: planColor,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        // Progress Bar (shows subscription progress)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  context.l10n.translate(
                                    'profile_membership_progress_title',
                                  ),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: const Color(0xFF6B7280),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${(progress * 100).toInt()}%',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: progressColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              width: double.infinity,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFFD1D5DB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: progress.clamp(0.0, 1.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: progressColor,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _getProgressDescription(
                                context.l10n,
                                progress,
                                daysRemaining,
                                actualSubscriptionDays,
                              ),
                              style: const TextStyle(
                                fontSize: 11,
                                color: const Color(0xFF6B7280),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSubscriptionCard(
    BuildContext context,
    UserSubscriptionStatus status,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: HeadingTile(
              icon: Iconsax.star1,
              headingTitle: context.l10n.translate('profile_user_subscription'),
            ),
          ),

          // Divider (full width)
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildUserSubscriptionContent(context, status),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSubscriptionCard(
    BuildContext context,
    SubscriptionBooking? subscription,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section Title
          Padding(
            padding: const EdgeInsets.all(16),
            child: HeadingTile(
              icon: Iconsax.star1,
              headingTitle: userRole == 'vendor'
                  ? context.l10n.translate('profile_vendor_status_title')
                  : context.l10n.translate('profile_membership_title'),
            ),
          ),

          // Divider (full width)
          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: _buildMemberSubscriptionContent(context, subscription),
          ),
        ],
      ),
    );
  }

  Widget _buildUserSubscriptionContent(
    BuildContext context,
    UserSubscriptionStatus status,
  ) {
    switch (status) {
      case UserSubscriptionStatus.noSubscription:
        return _buildNoSubscriptionContent(context, 'user');
      case UserSubscriptionStatus.pending:
        return _buildPendingSubscriptionContent(context);
      case UserSubscriptionStatus.approved:
        return _buildApprovedSubscriptionContent(context);
      case UserSubscriptionStatus.expired:
        return _buildExpiredSubscriptionContent(context, 'user');
      case UserSubscriptionStatus.loading:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildMemberSubscriptionContent(
    BuildContext context,
    SubscriptionBooking? subscription,
  ) {
    if (subscription == null) {
      return _buildNoSubscriptionContent(context, userRole ?? 'member');
    }

    // Check if subscription is expired
    final isExpired = subscription.expiryDate.isBefore(DateTime.now());

    if (isExpired) {
      return _buildExpiredSubscriptionContent(context, userRole ?? 'member');
    } else {
      return _buildActiveSubscriptionContent(context, subscription);
    }
  }

  Widget _buildNoSubscriptionContent(BuildContext context, String role) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              Icon(
                Icons.subscriptions_outlined,
                size: 48,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 12),
              Text(
                context.l10n.translate('membership_no_subscription_title'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                role == 'user'
                    ? context.l10n.translate(
                        'membership_no_subscription_user_hint',
                      )
                    : role == 'vendor'
                    ? context.l10n.translate(
                        'membership_no_subscription_vendor_hint',
                      )
                    : context.l10n.translate(
                        'membership_no_subscription_member_hint',
                      ),
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showSubscriptionOptionsDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B7B47),
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  context.l10n.translate('subscription_subscribe_now'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPendingSubscriptionContent(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.pending_outlined,
                size: 48,
                color: Color(0xFFF59E0B),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.translate('membership_pending_title'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF92400E),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.translate('membership_pending_message'),
                style: const TextStyle(fontSize: 14, color: Color(0xFF92400E)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApprovedSubscriptionContent(BuildContext context) {
    // For approved user subscriptions, show the same detailed info as members
    // We need to get the subscription data from the user subscription request
    return Consumer(
      builder: (context, ref, child) {
        final userSubscriptionAsync = ref.watch(
          currentUserSubscriptionRequestProvider,
        );

        return userSubscriptionAsync.when(
          data: (subscriptionRequest) {
            if (subscriptionRequest == null) {
              return _buildSimpleApprovedContent(context);
            }

            // Create a mock SubscriptionBooking-like object for display
            final mockSubscription = _createMockSubscriptionFromRequest(
              subscriptionRequest,
            );
            return _buildActiveSubscriptionContent(context, mockSubscription);
          },
          loading: () => _buildSimpleApprovedContent(context),
          error: (_, __) => _buildSimpleApprovedContent(context),
        );
      },
    );
  }

  Widget _buildSimpleApprovedContent(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 48,
                color: Color(0xFF059669),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.translate('membership_active_title'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF065F46),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.translate('membership_active_message'),
                style: const TextStyle(fontSize: 14, color: Color(0xFF065F46)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Create a mock SubscriptionBooking object from UserSubscriptionRequest for display purposes
  SubscriptionBooking _createMockSubscriptionFromRequest(
    UserSubscriptionRequest request,
  ) {
    // Calculate expiry date based on subscription duration
    // Use updated_at as the subscription period start date
    final startDate = request.updatedAt;
    final duration = request.subscription?.duration ?? 'monthly';
    DateTime expiryDate;

    switch (duration.toLowerCase()) {
      case 'weekly':
        expiryDate = startDate.add(const Duration(days: 7));
        break;
      case 'monthly':
        // Add 1 month to the start date
        final year = startDate.year;
        final month = startDate.month;
        final day = startDate.day;

        int targetYear = year;
        int targetMonth = month + 1;

        // Handle year rollover
        if (targetMonth > 12) {
          targetMonth = 1;
          targetYear++;
        }

        // Try to create the date with the same day
        try {
          expiryDate = DateTime(
            targetYear,
            targetMonth,
            day,
            startDate.hour,
            startDate.minute,
            startDate.second,
          );
        } catch (e) {
          // If the day doesn't exist in the target month, use the last day
          expiryDate = DateTime(
            targetYear,
            targetMonth + 1,
            0,
            startDate.hour,
            startDate.minute,
            startDate.second,
          );
        }
        break;
      case 'annual':
      case 'yearly':
        expiryDate = DateTime(
          startDate.year + 1,
          startDate.month,
          startDate.day,
          startDate.hour,
          startDate.minute,
          startDate.second,
        );
        break;
      default:
        // Default to monthly
        final year = startDate.year;
        final month = startDate.month;
        final day = startDate.day;

        int targetYear = year;
        int targetMonth = month + 1;

        if (targetMonth > 12) {
          targetMonth = 1;
          targetYear++;
        }

        try {
          expiryDate = DateTime(
            targetYear,
            targetMonth,
            day,
            startDate.hour,
            startDate.minute,
            startDate.second,
          );
        } catch (e) {
          expiryDate = DateTime(
            targetYear,
            targetMonth + 1,
            0,
            startDate.hour,
            startDate.minute,
            startDate.second,
          );
        }
    }

    return SubscriptionBooking(
      id: request.id,
      userId: request.userId,
      subscriptionId: request.subscriptionId,
      paymentStatus: 'paid', // Since it's approved
      bookingDate: request.createdAt,
      expiryDate: expiryDate,
      amount: request.subscription?.price ?? '0.00',
      createdAt: request.createdAt,
      updatedAt: request.updatedAt,
      subscription: request.subscription,
    );
  }

  Widget _buildExpiredSubscriptionContent(BuildContext context, String role) {
    final l10n = context.l10n;
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFFEE2E2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 48,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.translate('membership_expired_title'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF991B1B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.translate('membership_expired_message'),
                style: const TextStyle(fontSize: 14, color: Color(0xFF991B1B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _showSubscriptionOptionsDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.translate('subscription_renew_button')),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActiveSubscriptionContent(
    BuildContext context,
    SubscriptionBooking subscription,
  ) {
    // Use the existing _buildMembershipCard logic for active subscriptions
    return _buildMembershipCard(context, subscription);
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: HeadingTile(
              icon: Iconsax.star1,
              headingTitle: 'Membership Status',
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E7EB)),
          const Padding(
            padding: EdgeInsets.all(40),
            child: Center(child: CircularProgressIndicator()),
          ),
        ],
      ),
    );
  }

  /// Check if two dates are on the same day
  bool _isSameDay(DateTime date1, DateTime date2) {
    print('=== SAME DAY CHECK ===');
    print('Date 1: $date1');
    print('Date 2: $date2');
    print(
      'Date 1 year: ${date1.year}, month: ${date1.month}, day: ${date1.day}',
    );
    print(
      'Date 2 year: ${date2.year}, month: ${date2.month}, day: ${date2.day}',
    );

    final isSame =
        date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;

    print('Same day result: $isSame');
    print('=== END SAME DAY CHECK ===');
    return isSame;
  }

  /// Calculate expiry date from start date based on duration
  DateTime _calculateExpiryFromStartDate(DateTime startDate, String duration) {
    print('=== EXPIRY CALCULATION FROM START DATE ===');
    print('Input startDate: $startDate');
    print('Duration: $duration');

    DateTime expiryDate;

    switch (duration.toLowerCase()) {
      case 'weekly':
        expiryDate = startDate.add(const Duration(days: 7));
        break;
      case 'monthly':
        // Calculate the target month and year
        int targetYear = startDate.year;
        int targetMonth = startDate.month + 1;

        print('Initial target year: $targetYear');
        print('Initial target month: $targetMonth');

        // Handle year rollover (December -> January)
        if (targetMonth > 12) {
          targetMonth = 1;
          targetYear++;
          print(
            'Year rollover: new year = $targetYear, new month = $targetMonth',
          );
        }

        // Try to create the date with the same day
        try {
          expiryDate = DateTime(
            targetYear,
            targetMonth,
            startDate.day,
            startDate.hour,
            startDate.minute,
            startDate.second,
          );
          print('Successfully created monthly expiry: $expiryDate');
        } catch (e) {
          print('Error creating date: $e');
          // If the day doesn't exist in the target month (e.g., Jan 31 -> Feb 31)
          // Use the last day of the target month
          expiryDate = DateTime(
            targetYear,
            targetMonth + 1, // Go to next month
            0, // Day 0 gives us the last day of the previous month
            startDate.hour,
            startDate.minute,
            startDate.second,
          );
          print('Created fallback monthly expiry: $expiryDate');
        }
        break;
      case 'annual':
      case 'yearly':
        expiryDate = DateTime(
          startDate.year + 1,
          startDate.month,
          startDate.day,
          startDate.hour,
          startDate.minute,
          startDate.second,
        );
        break;
      default:
        // Default to monthly
        int targetYear = startDate.year;
        int targetMonth = startDate.month + 1;

        if (targetMonth > 12) {
          targetMonth = 1;
          targetYear++;
        }

        try {
          expiryDate = DateTime(
            targetYear,
            targetMonth,
            startDate.day,
            startDate.hour,
            startDate.minute,
            startDate.second,
          );
        } catch (e) {
          expiryDate = DateTime(
            targetYear,
            targetMonth + 1,
            0,
            startDate.hour,
            startDate.minute,
            startDate.second,
          );
        }
    }

    print('Final expiry date: $expiryDate');
    print('=== END EXPIRY CALCULATION ===');
    return expiryDate;
  }

  /// Calculate days remaining until expiry
  int _calculateDaysRemaining(DateTime expiryDate) {
    final difference = expiryDate.difference(DateTime.now());
    return difference.inDays;
  }

  /// Get progress description based on progress and remaining days
  String _getProgressDescription(
    AppLocalizations l10n,
    double progress,
    int daysRemaining,
    int totalDays,
  ) {
    if (daysRemaining <= 0) {
      return l10n.translate('membership_progress_expired');
    } else if (daysRemaining <= 1) {
      return l10n.translate('membership_progress_expires_tomorrow');
    } else if (daysRemaining <= 3) {
      return l10n.translate(
        'membership_progress_expires_soon',
        params: {'count': daysRemaining.toString()},
      );
    } else if (daysRemaining <= 7) {
      return l10n.translate(
        'membership_progress_expires_days',
        params: {'count': daysRemaining.toString()},
      );
    } else if (progress < 0.25) {
      return l10n.translate(
        'membership_progress_just_started',
        params: {
          'remaining': daysRemaining.toString(),
          'total': totalDays.toString(),
        },
      );
    } else if (progress < 0.5) {
      return l10n.translate(
        'membership_progress_early',
        params: {
          'remaining': daysRemaining.toString(),
          'total': totalDays.toString(),
        },
      );
    } else if (progress < 0.75) {
      return l10n.translate(
        'membership_progress_midway',
        params: {
          'remaining': daysRemaining.toString(),
          'total': totalDays.toString(),
        },
      );
    } else {
      return l10n.translate(
        'membership_progress_near_end',
        params: {
          'remaining': daysRemaining.toString(),
          'total': totalDays.toString(),
        },
      );
    }
  }

  void _showSubscriptionOptionsDialog(BuildContext context) {
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            l10n.translate('membership_dialog_title'),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.translate('membership_dialog_subtitle'),
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 20),
              _buildSubscriptionOption(
                context,
                title: l10n.translate('membership_option_member_title'),
                description: l10n.translate(
                  'membership_option_member_description',
                ),
                icon: Iconsax.user,
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/profile/subscription_selection?type=member');
                },
              ),
              const SizedBox(height: 12),
              _buildSubscriptionOption(
                context,
                title: l10n.translate('membership_option_vendor_title'),
                description: l10n.translate(
                  'membership_option_vendor_description',
                ),
                icon: Iconsax.shop,
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/profile/subscription_selection?type=vendor');
                },
              ),
              const SizedBox(height: 12),
              _buildSubscriptionOption(
                context,
                title: l10n.translate('membership_option_user_title'),
                description: l10n.translate(
                  'membership_option_user_description',
                ),
                icon: Iconsax.star1,
                onTap: () {
                  Navigator.of(context).pop();
                  context.go('/profile/subscription_selection?type=user');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.translate('common_cancel'),
                style: const TextStyle(color: Color(0xFF6B7280)),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubscriptionOption(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6B7B47).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: const Color(0xFF6B7B47), size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Color(0xFF9CA3AF),
            ),
          ],
        ),
      ),
    );
  }
}
