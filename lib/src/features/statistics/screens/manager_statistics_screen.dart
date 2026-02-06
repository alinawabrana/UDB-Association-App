import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/utils/constants/urls.dart';
import 'package:udb_association/src/features/surveys/services/branch_users_service.dart';
import 'package:udb_association/src/features/auth/models/user_model.dart';
import 'package:udb_association/src/features/events/providers/event_provider.dart';
import 'package:udb_association/src/features/events/models/event_model.dart';
import 'package:udb_association/src/features/subscription/providers/user_subscription_request_provider.dart';
import 'package:udb_association/src/features/subscription/models/user_subscription_request_model.dart';

// Analytics data for monthly member registrations
class MonthlyMemberData {
  final String month;
  final int memberCount;

  const MonthlyMemberData({required this.month, required this.memberCount});
}

// Helper class to generate monthly member registration data
class MemberAnalytics {
  final List<MonthlyMemberData> monthlyData;
  final int totalMembers;
  final int totalManagers;

  const MemberAnalytics({
    required this.monthlyData,
    required this.totalMembers,
    required this.totalManagers,
  });

  factory MemberAnalytics.fromBranchUsers(List<User> users) {
    print('🔍 [MEMBER ANALYTICS] Processing ${users.length} total users');

    // Filter out managers to get only members
    final members = users
        .where((user) => user.role?.toLowerCase() != 'manager')
        .toList();
    final managers = users
        .where((user) => user.role?.toLowerCase() == 'manager')
        .toList();

    print(
      '👥 [MEMBER ANALYTICS] Found ${members.length} members and ${managers.length} managers',
    );
    for (final member in members) {
      print(
        '👤 [MEMBER ANALYTICS] Member: ${member.name}, Role: ${member.role}, CreatedAt: ${member.userCreatedAt}',
      );
    }

    // Generate monthly data based on member creation dates
    final monthlyData = _generateMonthlyDataFromMembers(members);

    return MemberAnalytics(
      monthlyData: monthlyData,
      totalMembers: members.length,
      totalManagers: managers.length,
    );
  }

  static List<MonthlyMemberData> _generateMonthlyDataFromMembers(
    List<User> members,
  ) {
    print(
      '🔍 [MONTHLY DATA] Processing ${members.length} members for monthly data',
    );

    // Group members by month based on creation dates
    final Map<String, int> monthlyMembers = {};

    // Initialize all months with 0 members
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    for (final month in months) {
      monthlyMembers[month] = 0;
    }

    // Count members by month
    for (final member in members) {
      print('👤 [MONTHLY DATA] Processing member: ${member.name}');
      print('📅 [MONTHLY DATA] Member createdAt: ${member.userCreatedAt}');

      try {
        if (member.userCreatedAt != null) {
          final memberDate = member.userCreatedAt!;
          final monthIndex = memberDate.month - 1;
          print(
            '📊 [MONTHLY DATA] Member month index: $monthIndex (${memberDate.month})',
          );

          if (monthIndex >= 0 && monthIndex < months.length) {
            final monthName = months[monthIndex];
            monthlyMembers[monthName] = (monthlyMembers[monthName] ?? 0) + 1;
            print(
              '✅ [MONTHLY DATA] Added member to $monthName, count: ${monthlyMembers[monthName]}',
            );
          }
        } else {
          print('⚠️ [MONTHLY DATA] Member ${member.name} has null createdAt');
        }
      } catch (e) {
        print('❌ [MONTHLY DATA] Error processing member ${member.name}: $e');
        continue;
      }
    }

    print('📈 [MONTHLY DATA] Monthly members map: $monthlyMembers');

    // Convert to MonthlyMemberData list (show last 6 months)
    final currentMonth = DateTime.now().month;
    print('🗓️ [MONTHLY DATA] Current month: $currentMonth');
    final dataPoints = <MonthlyMemberData>[];

    for (int i = 5; i >= 0; i--) {
      final monthIndex = (currentMonth - 1 - i + 12) % 12;
      final monthName = months[monthIndex];
      final memberCount = monthlyMembers[monthName] ?? 0;
      dataPoints.add(
        MonthlyMemberData(month: monthName, memberCount: memberCount),
      );
      print('📊 [MONTHLY DATA] Month $monthName: $memberCount members');
    }

    print(
      '🎯 [MONTHLY DATA] Final data points: ${dataPoints.map((d) => '${d.month}: ${d.memberCount}').join(', ')}',
    );
    return dataPoints;
  }
}

class ManagerStatisticsScreen extends ConsumerStatefulWidget {
  const ManagerStatisticsScreen({super.key});

  @override
  ConsumerState<ManagerStatisticsScreen> createState() =>
      _ManagerStatisticsScreenState();
}

class _ManagerStatisticsScreenState
    extends ConsumerState<ManagerStatisticsScreen> {
  String selectedDuration = 'last_6_months';

  // Helper method to calculate event statistics
  Map<String, dynamic> _calculateEventStatistics(
    List<EventModel> events,
    int? branchId,
  ) {
    // Filter events by branch
    final branchEvents = events.where((event) {
      return event.targetBranchId == branchId;
    }).toList();

    final totalEvents = branchEvents.length;

    // Calculate events this month
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthEnd = DateTime(now.year, now.month + 1, 0);

    final thisMonthEvents = branchEvents.where((event) {
      final createdAt = event.createdAt;
      return createdAt.isAfter(
            thisMonthStart.subtract(const Duration(days: 1)),
          ) &&
          createdAt.isBefore(thisMonthEnd.add(const Duration(days: 1)));
    }).length;

    // Calculate events previous month
    final previousMonthStart = DateTime(now.year, now.month - 1, 1);
    final previousMonthEnd = DateTime(now.year, now.month, 0);

    final previousMonthEvents = branchEvents.where((event) {
      final createdAt = event.createdAt;
      return createdAt.isAfter(
            previousMonthStart.subtract(const Duration(days: 1)),
          ) &&
          createdAt.isBefore(previousMonthEnd.add(const Duration(days: 1)));
    }).length;

    // Calculate percentage change
    String eventChange;
    if (previousMonthEvents == 0) {
      eventChange = thisMonthEvents > 0 ? '+100%' : '0%';
    } else {
      final change =
          ((thisMonthEvents - previousMonthEvents) / previousMonthEvents * 100)
              .round();
      eventChange = change >= 0 ? '+$change%' : '$change%';
    }

    return {
      'totalEvents': totalEvents,
      'thisMonthEvents': thisMonthEvents,
      'previousMonthEvents': previousMonthEvents,
      'eventChange': eventChange,
    };
  }

  // Helper method to calculate subscription statistics
  Map<String, dynamic> _calculateSubscriptionStatistics(
    List<UserSubscriptionRequest> subscriptions,
  ) {
    // Calculate subscriptions this month
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthEnd = DateTime(now.year, now.month + 1, 0);

    final thisMonthSubscriptions = subscriptions.where((sub) {
      final updatedAt = sub.updatedAt;
      return updatedAt.isAfter(
            thisMonthStart.subtract(const Duration(days: 1)),
          ) &&
          updatedAt.isBefore(thisMonthEnd.add(const Duration(days: 1)));
    }).length;

    // Calculate subscriptions previous month
    final previousMonthStart = DateTime(now.year, now.month - 1, 1);
    final previousMonthEnd = DateTime(now.year, now.month, 0);

    final previousMonthSubscriptions = subscriptions.where((sub) {
      final updatedAt = sub.updatedAt;
      return updatedAt.isAfter(
            previousMonthStart.subtract(const Duration(days: 1)),
          ) &&
          updatedAt.isBefore(previousMonthEnd.add(const Duration(days: 1)));
    }).length;

    // Calculate percentage change
    String subscriptionChange;
    if (previousMonthSubscriptions == 0) {
      subscriptionChange = thisMonthSubscriptions > 0 ? '+100%' : '0%';
    } else {
      final change =
          ((thisMonthSubscriptions - previousMonthSubscriptions) /
                  previousMonthSubscriptions *
                  100)
              .round();
      subscriptionChange = change >= 0 ? '+$change%' : '$change%';
    }

    return {
      'thisMonthSubscriptions': thisMonthSubscriptions,
      'previousMonthSubscriptions': previousMonthSubscriptions,
      'subscriptionChange': subscriptionChange,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final userAsync = ref.watch(profileProvider);
    final user = userAsync.value;

    // Get branch users using the same service as survey analysis
    final branchUsersAsync = user != null && user.branchId != null
        ? ref.watch(BranchUsersService.branchUsersProvider(user.branchId!))
        : const AsyncValue<List<User>>.loading();

    // Get events
    final eventsAsync = ref.watch(eventsProvider);

    // Get subscription requests
    final subscriptionsAsync = ref.watch(userSubscriptionRequestsProvider);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Text(
          l10n.translate('manager_statistics_title'),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6B7C32),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          // Profile picture
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Builder(
              builder: (context) {
                final profileImageUrl = user?.profileImage != null
                    ? ApiUrls.getProfileImageUrl(user!.profileImage)
                    : '';

                return CircleAvatar(
                  radius: 16,
                  child: profileImageUrl.isNotEmpty
                      ? ClipOval(
                          child: Image.network(
                            profileImageUrl,
                            width: 32,
                            height: 32,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 20,
                              );
                            },
                          ),
                        )
                      : const Icon(Icons.person, color: Colors.white, size: 20),
                );
              },
            ),
          ),
        ],
      ),
      body: branchUsersAsync.when(
        data: (branchUsers) {
          final memberAnalytics = MemberAnalytics.fromBranchUsers(branchUsers);

          return eventsAsync.when(
            data: (events) {
              return subscriptionsAsync.when(
                data: (subscriptionsResponse) {
                  // Calculate event statistics
                  final eventStats = _calculateEventStatistics(
                    events,
                    user?.branchId,
                  );

                  // Calculate subscription statistics
                  final subscriptionStats = _calculateSubscriptionStatistics(
                    subscriptionsResponse.data,
                  );

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top Cards Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildTopCard(
                                icon: Icons.people,
                                analysis:
                                    null, // No percentage badge for Total Members
                                value: memberAnalytics.totalMembers.toString(),
                                label: l10n.translate(
                                  'manager_statistics_members',
                                ),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF6B8E23),
                                    Color(0xFF556B2F),
                                  ],
                                  stops: [0.0, 0.7071],
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildTopCard(
                                icon: Icons.event,
                                analysis: eventStats['eventChange'] as String,
                                value: eventStats['totalEvents'].toString(),
                                label: l10n.translate(
                                  'manager_statistics_events',
                                ),
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF1E40AF),
                                    Color(0xFF1E3A8A),
                                  ],
                                  stops: [0.0, 0.7071],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Monthly Progress Card
                        _buildMonthlyProgressCard(
                          l10n,
                          memberAnalytics.monthlyData,
                        ),
                        const SizedBox(height: 16),

                        // Quick Statistics Card
                        _buildQuickStatisticsCard(
                          l10n,
                          thisMonthSubscriptions:
                              subscriptionStats['thisMonthSubscriptions']
                                  as int,
                          subscriptionChange:
                              subscriptionStats['subscriptionChange'] as String,
                          thisMonthEvents: eventStats['thisMonthEvents'] as int,
                          eventChange: eventStats['eventChange'] as String,
                        ),
                        const SizedBox(height: 25),

                        // Subscription Trends Card
                        _buildSubscriptionTrendsCard(l10n),
                        const SizedBox(height: 16),

                        // Recent Reports Section
                        // _buildRecentReportsSection(),
                      ],
                    ),
                  );
                },
                loading: () => const Center(
                  child: CircularProgressIndicator(color: Color(0xFF6B8E23)),
                ),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Color(0xFFEF4444),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.translate(
                          'manager_statistics_error_subscriptions',
                        ),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B7280),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.invalidate(userSubscriptionRequestsProvider);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6B8E23),
                          foregroundColor: Colors.white,
                        ),
                        child: Text(l10n.translate('retry')),
                      ),
                    ],
                  ),
                ),
              );
            },
            loading: () => const Center(
              child: CircularProgressIndicator(color: Color(0xFF6B8E23)),
            ),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Color(0xFFEF4444),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.translate('events_error_title'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF6B7280),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.invalidate(eventsProvider);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B8E23),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(l10n.translate('retry')),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Color(0xFF6B8E23)),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 80,
                color: Color(0xFFEF4444),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.translate('statistics_error_title'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (user != null && user.branchId != null) {
                    ref.invalidate(
                      BranchUsersService.branchUsersProvider(user.branchId!),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6B8E23),
                  foregroundColor: Colors.white,
                ),
                child: Text(l10n.translate('retry')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopCard({
    required IconData icon,
    String? analysis, // Make analysis optional
    required String value,
    required String label,
    required Gradient gradient,
  }) {
    return Container(
      height: 116,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 25, color: Colors.white),
              if (analysis != null) ...[
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    analysis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthlyProgressCard(
    AppLocalizations l10n,
    List<MonthlyMemberData> monthlyData,
  ) {
    print(
      '📊 [MONTHLY PROGRESS CARD] Building chart with ${monthlyData.length} data points',
    );
    for (int i = 0; i < monthlyData.length; i++) {
      print(
        '📊 [MONTHLY PROGRESS CARD] Data point $i: ${monthlyData[i].month} = ${monthlyData[i].memberCount} members',
      );
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.translate('manager_statistics_monthly_progress'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              Icon(Icons.calendar_month, color: Color(0xff6B8E23), size: 20),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: (monthlyData.length - 1).toDouble(),
                minY: 0,
                maxY: _calculateMaxY(monthlyData).clamp(1.0, double.infinity),
                gridData: FlGridData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= monthlyData.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          _localizedMonth(l10n, monthlyData[index].month),
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                      reservedSize: 30,
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: monthlyData.asMap().entries.map((entry) {
                      final spot = FlSpot(
                        entry.key.toDouble(),
                        entry.value.memberCount.toDouble(),
                      );
                      print(
                        '📊 [CHART DATA] Spot ${entry.key}: ${entry.value.month} = ${entry.value.memberCount} members',
                      );
                      return spot;
                    }).toList(),
                    isCurved: true,
                    color: const Color(0xFF6B8E23),
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFF6B8E23).withOpacity(0.3),
                          const Color(0xFF6B8E23).withOpacity(0.1),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatisticsCard(
    AppLocalizations l10n, {
    required int thisMonthSubscriptions,
    required String subscriptionChange,
    required int thisMonthEvents,
    required String eventChange,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          // Title Section
          Container(
            height: 57,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
            decoration: const BoxDecoration(
              color: Color(0xFFF9FAFB),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              ),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                l10n.translate('manager_statistics_quick_stats'),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
            ),
          ),
          // New Subscriptions
          _buildQuickStatItem(
            icon: Icons.person_add,
            title: l10n.translate('manager_statistics_new_subscriptions'),
            subtitle: l10n.translate('manager_statistics_this_month'),
            count: thisMonthSubscriptions.toString(),
            analysis: subscriptionChange,
            iconBgColor: const Color(0xFF6B8E23).withOpacity(0.1),
            iconColor: const Color(0xFF6B8E23),
            hasBottomBorder: true,
          ),
          // Events Organized This Month
          _buildQuickStatItem(
            icon: Icons.event,
            title: l10n.translate('manager_statistics_events_organized'),
            subtitle: l10n.translate('manager_statistics_this_month'),
            count: thisMonthEvents.toString(),
            analysis: eventChange,
            iconBgColor: const Color(0xFF1E40AF).withOpacity(0.1),
            iconColor: const Color(0xFF1E40AF),
            hasBottomBorder: false,
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required String count,
    required String analysis,
    required Color iconBgColor,
    required Color iconColor,
    required bool hasBottomBorder,
  }) {
    Color analysisColor;
    if (analysis.startsWith('+')) {
      // Remove '+' and '%' to get the number
      final percentStr = analysis.substring(1, analysis.length - 1);
      final percent = int.tryParse(percentStr) ?? 0;
      if (percent > 9) {
        analysisColor = const Color(0xFF16A34A);
      } else {
        analysisColor = const Color(0xFF2563EB);
      }
    } else if (analysis.startsWith('-')) {
      // Negative percentage
      analysisColor = Colors.redAccent;
    } else {
      // No change or zero
      analysisColor = const Color(0xFF2563EB);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        border: hasBottomBorder
            ? const Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
              )
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF111827),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                count,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              Text(
                analysis,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: analysisColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionTrendsCard(AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                l10n.translate('manager_statistics_subscription_trends'),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(
                        l10n.translate('manager_statistics_select_duration'),
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDurationOption(l10n, 'last_month'),
                          _buildDurationOption(l10n, 'last_6_months'),
                          _buildDurationOption(l10n, 'last_year'),
                        ],
                      ),
                    ),
                  );
                },
                child: Container(
                  width: 128,
                  height: 40,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 88,
                        child: Text(
                          _durationLabel(l10n, selectedDuration),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 16),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B8E23),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.translate('manager_statistics_legend_new'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E40AF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    l10n.translate('manager_statistics_legend_renewed'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 100,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final months = List.generate(
                          6,
                          (index) => DateFormat(
                            'MMM',
                            l10n.locale.toLanguageTag(),
                          ).format(DateTime(2000, index + 1)),
                        );
                        final index = value.toInt();
                        if (index < 0 || index >= months.length) {
                          return const SizedBox.shrink();
                        }
                        return Text(
                          months[index],
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                          ),
                        );
                      },
                    ),
                  ),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 50,
                      getTitlesWidget: (value, meta) {
                        if (value == 0 || value == 50 || value == 100) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.grey,
                            ),
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 50,
                  getDrawingHorizontalLine: (value) {
                    return FlLine(
                      color: Colors.grey.withOpacity(0.2),
                      strokeWidth: 1,
                    );
                  },
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: 45,
                        color: const Color(0xFF6B8E23),
                        width: 12,
                      ),
                      BarChartRodData(
                        toY: 35,
                        color: const Color(0xFF1E40AF),
                        width: 12,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: 55,
                        color: const Color(0xFF6B8E23),
                        width: 12,
                      ),
                      BarChartRodData(
                        toY: 40,
                        color: const Color(0xFF1E40AF),
                        width: 12,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: 65,
                        color: const Color(0xFF6B8E23),
                        width: 12,
                      ),
                      BarChartRodData(
                        toY: 50,
                        color: const Color(0xFF1E40AF),
                        width: 12,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 3,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: 70,
                        color: const Color(0xFF6B8E23),
                        width: 12,
                      ),
                      BarChartRodData(
                        toY: 55,
                        color: const Color(0xFF1E40AF),
                        width: 12,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 4,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: 80,
                        color: const Color(0xFF6B8E23),
                        width: 12,
                      ),
                      BarChartRodData(
                        toY: 65,
                        color: const Color(0xFF1E40AF),
                        width: 12,
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 5,
                    barsSpace: 4,
                    barRods: [
                      BarChartRodData(
                        toY: 85,
                        color: const Color(0xFF6B8E23),
                        width: 12,
                      ),
                      BarChartRodData(
                        toY: 70,
                        color: const Color(0xFF1E40AF),
                        width: 12,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationOption(AppLocalizations l10n, String duration) {
    return ListTile(
      title: Text(_durationLabel(l10n, duration)),
      onTap: () {
        setState(() {
          selectedDuration = duration;
        });
        Navigator.pop(context);
      },
    );
  }

  String _localizedMonth(AppLocalizations l10n, String monthAbbrev) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final index = months.indexWhere(
      (m) => m.toLowerCase() == monthAbbrev.toLowerCase(),
    );
    if (index == -1) {
      return monthAbbrev;
    }

    return DateFormat(
      'MMM',
      l10n.locale.toLanguageTag(),
    ).format(DateTime(2000, index + 1));
  }

  String _durationLabel(AppLocalizations l10n, String duration) {
    switch (duration) {
      case 'last_month':
        return l10n.translate('manager_statistics_duration_last_month');
      case 'last_year':
        return l10n.translate('manager_statistics_duration_last_year');
      case 'last_6_months':
      default:
        return l10n.translate('manager_statistics_duration_last_6_months');
    }
  }

  // Helper method to calculate max Y value for the chart
  double _calculateMaxY(List<MonthlyMemberData> monthlyData) {
    if (monthlyData.isEmpty) {
      print(
        '⚠️ [CHART Y-AXIS] Monthly data is empty, returning default max Y: 10.0',
      );
      return 10.0;
    }

    final maxCount = monthlyData
        .map((data) => data.memberCount)
        .reduce((a, b) => a > b ? a : b);

    // Add some padding to the max value
    final maxY = (maxCount * 1.2).ceilToDouble();
    print(
      '📊 [CHART Y-AXIS] Max member count: $maxCount, calculated max Y: $maxY',
    );
    return maxY;
  }

  // Widget _buildRecentReportsSection() {
  //   return Container(
  //     decoration: BoxDecoration(
  //       color: Colors.white,
  //       borderRadius: BorderRadius.circular(12),
  //       border: Border.all(color: const Color(0xFFE5E7EB)),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         // Title Section
  //         Container(
  //           padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  //           decoration: const BoxDecoration(
  //             color: Color(0xFFF9FAFB),
  //             borderRadius: BorderRadius.only(
  //               topLeft: Radius.circular(12),
  //               topRight: Radius.circular(12),
  //             ),
  //             border: Border(
  //               bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
  //             ),
  //           ),
  //           child: Row(
  //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //             children: [
  //               const Text(
  //                 'Recent Reports',
  //                 style: TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w600,
  //                   color: Color(0xFF111827),
  //                 ),
  //               ),
  //               TextButton(
  //                 onPressed: () {},
  //                 child: const Text(
  //                   'View All',
  //                   style: TextStyle(
  //                     fontSize: 14,
  //                     fontWeight: FontWeight.w500,
  //                     color: Color(0xFF6B8E23),
  //                   ),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         _buildReportItem(
  //           icon: Icons.help_outline,
  //           title: 'Monthly Activity Report',
  //           subtitle: 'Generated 2 hours ago',
  //           iconBgColor: const Color(0xFF1E40AF).withOpacity(0.1),
  //           iconColor: const Color(0xFF1E40AF),
  //           hasBottomBorder: true,
  //         ),
  //         _buildReportItem(
  //           icon: Icons.pie_chart,
  //           title: 'Membership Analysis',
  //           subtitle: 'Generated yesterday',
  //           iconBgColor: const Color(0xFF6B8E23).withOpacity(0.1),
  //           iconColor: const Color(0xFF6B8E23),
  //           hasBottomBorder: true,
  //         ),
  //         _buildReportItem(
  //           icon: Icons.bar_chart,
  //           title: 'Financial Summary',
  //           subtitle: 'Generated 3 days ago',
  //           iconBgColor: const Color(0xFFF3E8FF),
  //           iconColor: const Color(0xFF9333EA),
  //           hasBottomBorder: false,
  //         ),
  //       ],
  //     ),
  //   );
  // }

  // Widget _buildReportItem({
  //   required IconData icon,
  //   required String title,
  //   required String subtitle,
  //   required Color iconBgColor,
  //   required Color iconColor,
  //   required bool hasBottomBorder,
  // }) {
  //   return Container(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
  //     decoration: BoxDecoration(
  //       border: hasBottomBorder
  //           ? const Border(
  //               bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
  //             )
  //           : null,
  //     ),
  //     child: Row(
  //       children: [
  //         Container(
  //           width: 40,
  //           height: 40,
  //           decoration: BoxDecoration(
  //             color: iconBgColor,
  //             borderRadius: BorderRadius.circular(8),
  //           ),
  //           child: Icon(icon, size: 20, color: iconColor),
  //         ),
  //         const SizedBox(width: 12),
  //         Expanded(
  //           child: Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 title,
  //                 style: const TextStyle(
  //                   fontSize: 16,
  //                   fontWeight: FontWeight.w500,
  //                   color: Color(0xFF111827),
  //                 ),
  //               ),
  //               Text(
  //                 subtitle,
  //                 style: const TextStyle(
  //                   fontSize: 14,
  //                   fontWeight: FontWeight.w400,
  //                   color: Color(0xFF6B7280),
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ),
  //         Container(
  //           width: 32,
  //           height: 40,
  //           alignment: Alignment.center,
  //           child: Icon(
  //             Icons.download,
  //             size: 16,
  //             color: const Color(0xFF9CA3AF),
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
}
