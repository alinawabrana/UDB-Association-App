import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';
import 'package:udb_association/src/common/widgets/circular_container.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/src/features/events/models/event_model.dart';
import 'package:udb_association/src/features/events/providers/event_provider.dart';
import 'package:udb_association/src/features/events/screens/event_detail_screen.dart';
import 'package:udb_association/src/router/app_router.dart';
import 'package:udb_association/utils/constants/urls.dart';

class EventsScreen extends ConsumerStatefulWidget {
  const EventsScreen({super.key});

  @override
  ConsumerState<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends ConsumerState<EventsScreen> {
  @override
  Widget build(BuildContext context) {
    final filterState = ref.watch(eventFilterProvider);
    final filteredEvents = ref.watch(filteredEventsProvider);
    final upcomingEvents = ref.watch(upcomingEventsProvider);
    final allEvents = ref.watch(eventsProvider);
    final calendarEvents = ref.watch(calendarEventsProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header
          _buildHeader(ref),

          // Scrollable body including calendar
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Month/Year Navigation and Days
                  _buildMonthYearSection(ref, filterState),

                  // Calendar Grid
                  _buildCalendarGrid(ref, filterState, calendarEvents),

                  // Search Field
                  _buildSearchField(),

                  // Filter Chips
                  _buildFilterChips(ref, filterState),

                  // Events List
                  allEvents.when(
                    data: (events) => _buildEventsList(
                      filteredEvents,
                      filterState,
                      upcomingEvents,
                    ),
                    loading: () => const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (error, stack) => _ErrorStateWidget(
                      context: context,
                      ref: ref,
                      error: error,
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

  Widget _buildHeader(WidgetRef ref) {
    final l10n = context.l10n;
    final profileAsync = ref.watch(profileProvider);

    return Container(
      height: 80,
      decoration: const BoxDecoration(color: Color(0xFF6B7F39)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              // Calendar Icon
              const CircularContainer(
                width: 32,
                height: 32,
                backgroundColor: Colors.white,
                iconColor: Color(0xFF6B7F39),
                icon: Icons.calendar_today,
              ),
              const SizedBox(width: 12),
              // Calendar Text
              Text(
                l10n.translate('events_calendar_title'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              // Notification Bell
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Color(0xFF6B7F39),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Profile Image
              profileAsync.when(
                data: (user) {
                  final profileImageUrl = user.profile?.profileImage;
                  final fullImageUrl = ApiUrls.getProfileImageUrl(profileImageUrl);
                  return Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: fullImageUrl.isNotEmpty
                        ? CircleAvatar(
                            backgroundImage: NetworkImage(fullImageUrl),
                          )
                        : const CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(
                              Icons.person,
                              color: Color(0xFF6B7F39),
                              size: 20,
                            ),
                          ),
                  );
                },
                loading: () => Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF6B7F39),
                      ),
                    ),
                  ),
                ),
                error: (_, __) => Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      color: Color(0xFF6B7F39),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMonthYearSection(WidgetRef ref, EventFilterState filterState) {
    final monthYear = DateFormat('MMMM yyyy').format(filterState.selectedDate);
    final l10n = context.l10n;
    final weekdayLabels = <String>[
      l10n.translate('events_day_sun'),
      l10n.translate('events_day_mon'),
      l10n.translate('events_day_tue'),
      l10n.translate('events_day_wed'),
      l10n.translate('events_day_thu'),
      l10n.translate('events_day_fri'),
      l10n.translate('events_day_sat'),
    ];

    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Thin green bar at top
          Container(
            height: 4,
            color: const Color(0xFF6B7F39),
            width: double.infinity,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16.0,
            ),
            child: Row(
              children: [
                // Month/Year text at left (large, bold)
                Expanded(
                  child: Text(
                    monthYear,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
                // Month dropdown button
                Container(
                  height: 32,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Month',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF374151),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFF374151),
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Previous Month button (square)
                GestureDetector(
                  onTap: () {
                    final newDate = DateTime(
                      filterState.selectedDate.year,
                      filterState.selectedDate.month - 1,
                    );
                    ref
                        .read(eventFilterProvider.notifier)
                        .setSelectedDate(newDate);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF374151),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Next Month button (square)
                GestureDetector(
                  onTap: () {
                    final newDate = DateTime(
                      filterState.selectedDate.year,
                      filterState.selectedDate.month + 1,
                    );
                    ref
                        .read(eventFilterProvider.notifier)
                        .setSelectedDate(newDate);
                  },
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFE5E7EB)),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF374151),
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Days of Week
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: weekdayLabels.map(_DayLabel.new).toList(),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(
    WidgetRef ref,
    EventFilterState filterState,
    Map<DateTime, List<EventModel>> calendarEvents,
  ) {
    final firstDayOfMonth = DateTime(
      filterState.selectedDate.year,
      filterState.selectedDate.month,
      1,
    );
    final lastDayOfMonth = DateTime(
      filterState.selectedDate.year,
      filterState.selectedDate.month + 1,
      0,
    );
    final firstDayWeekday =
        firstDayOfMonth.weekday % 7; // Convert to 0-based Sunday start

    final daysInMonth = lastDayOfMonth.day;
    final totalCells = firstDayWeekday + daysInMonth;
    final weeks = (totalCells / 7).ceil();

    return GestureDetector(
      onPanEnd: (details) {
        // Swipe right - previous month
        if (details.velocity.pixelsPerSecond.dx > 500) {
          final newDate = DateTime(
            filterState.selectedDate.year,
            filterState.selectedDate.month - 1,
          );
          ref.read(eventFilterProvider.notifier).setSelectedDate(newDate);
        }
        // Swipe left - next month
        else if (details.velocity.pixelsPerSecond.dx < -500) {
          final newDate = DateTime(
            filterState.selectedDate.year,
            filterState.selectedDate.month + 1,
          );
          ref.read(eventFilterProvider.notifier).setSelectedDate(newDate);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(weeks, (weekIndex) {
            return Row(
              children: List.generate(7, (dayIndex) {
                final cellIndex = weekIndex * 7 + dayIndex;
                final dayNumber = cellIndex - firstDayWeekday + 1;

                DateTime? currentDate;
                bool isPrevMonth = false;
                bool isNextMonth = false;
                int displayDay = 0;

                if (cellIndex < firstDayWeekday) {
                  // Previous month days
                  final prevMonthLastDay = DateTime(
                    filterState.selectedDate.year,
                    filterState.selectedDate.month,
                    0,
                  );
                  final prevMonthDays = prevMonthLastDay.day;
                  displayDay = prevMonthDays - firstDayWeekday + cellIndex + 1;
                  currentDate = DateTime(
                    filterState.selectedDate.year,
                    filterState.selectedDate.month - 1,
                    displayDay,
                  );
                  isPrevMonth = true;
                } else if (dayNumber > daysInMonth) {
                  // Next month days
                  displayDay = dayNumber - daysInMonth;
                  currentDate = DateTime(
                    filterState.selectedDate.year,
                    filterState.selectedDate.month + 1,
                    displayDay,
                  );
                  isNextMonth = true;
                } else {
                  // Current month days
                  displayDay = dayNumber;
                  currentDate = DateTime(
                    filterState.selectedDate.year,
                    filterState.selectedDate.month,
                    dayNumber,
                  );
                }

                final isSelected =
                    currentDate.day == filterState.selectedDate.day &&
                    currentDate.month == filterState.selectedDate.month &&
                    currentDate.year == filterState.selectedDate.year;

                // Normalize date for comparison (year, month, day only)
                final normalizedDate = DateTime(
                  currentDate.year,
                  currentDate.month,
                  currentDate.day,
                );

                // Check if this date has events
                final hasEvents = calendarEvents.keys.any((eventDate) {
                  final normalizedEventDate = DateTime(
                    eventDate.year,
                    eventDate.month,
                    eventDate.day,
                  );
                  return normalizedEventDate.isAtSameMomentAs(normalizedDate);
                });

                return Expanded(
                  child: Container(
                    height: 50,
                    margin: const EdgeInsets.all(1),
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(eventFilterProvider.notifier)
                            .setSelectedDate(currentDate!);
                      },
                      child: Container(
                        width: double.infinity,
                        height: double.infinity,
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(
                                  0xFFE8F5E9,
                                ) // Light green background
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Date number
                            Text(
                              displayDay.toString(),
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: isSelected
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                                color: isSelected
                                    ? const Color(
                                        0xFF388E3C,
                                      ) // Dark green text when selected
                                    : (isPrevMonth || isNextMonth)
                                    ? const Color(
                                        0xFF9CA3AF,
                                      ) // Gray for prev/next month
                                    : const Color(
                                        0xFF1F2937,
                                      ), // Dark for current month
                              ),
                            ),
                            // Green dot indicator for dates with events
                            if (hasEvents && !isPrevMonth && !isNextMonth)
                              Positioned(
                                bottom: 8,
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF6B7F39), // Green dot
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSearchField() {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: GestureDetector(
        onTap: () {
          context.pushNamed(AppRouteNames.eventsSearch);
        },
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF6B7F39).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            child: Row(
              children: [
                const Icon(Icons.search, size: 20, color: Color(0xFF6B7F39)),
                const SizedBox(width: 12),
                Text(
                  l10n.translate('news_search_hint'),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: const Color(0xFF6B7280).withOpacity(0.7),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChips(WidgetRef ref, EventFilterState filterState) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        children: [
          _FilterChip(
            label: l10n.translate('events_filter_all'),
            isSelected: filterState.selectedFilter == null,
            onTap: () {
              ref.read(eventFilterProvider.notifier).setFilter(null);
            },
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: l10n.translate('events_filter_events'),
            isSelected: filterState.selectedFilter == EventType.event,
            onTap: () => ref
                .read(eventFilterProvider.notifier)
                .setFilter(EventType.event),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: l10n.translate('events_filter_meetings'),
            isSelected: filterState.selectedFilter == EventType.meeting,
            onTap: () => ref
                .read(eventFilterProvider.notifier)
                .setFilter(EventType.meeting),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsList(
    List<EventModel> events,
    EventFilterState filterState,
    List<EventModel> upcomingEvents,
  ) {
    final l10n = context.l10n;
    final localeTag = l10n.locale.toLanguageTag();
    final selectedDate = filterState.selectedDate;
    final isToday =
        selectedDate.day == DateTime.now().day &&
        selectedDate.month == DateTime.now().month &&
        selectedDate.year == DateTime.now().year;

    // No search filtering needed here - search is handled in dedicated screen
    List<EventModel> filteredEvents = events;
    List<EventModel> filteredUpcomingEvents = upcomingEvents;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Current Date Events heading
          Row(
            children: [
              Text(
                isToday
                    ? l10n.translate('events_today_title')
                    : DateFormat('MMM d', localeTag).format(selectedDate),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Current Date Events list
          if (filteredEvents.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Text(
                  l10n.translate('events_no_events_for_date'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredEvents.length,
              itemBuilder: (context, index) {
                return _EventCard(
                  event: filteredEvents[index],
                  isUpcoming: false,
                );
              },
            ),

          // Upcoming Events section - always show if there are upcoming events
          if (filteredUpcomingEvents.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              l10n.translate('events_upcoming_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: filteredUpcomingEvents.length,
              itemBuilder: (context, index) {
                return _EventCard(
                  event: filteredUpcomingEvents[index],
                  isUpcoming: true,
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  final String label;

  const _DayLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6B7280),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B7B3A) : const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: isSelected ? Colors.white : const Color(0xFF4B5563),
          ),
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventModel event;
  final bool isUpcoming;

  const _EventCard({required this.event, required this.isUpcoming});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Use the same card style for both regular and upcoming events
    return _buildCurrentDateEventCard(context, l10n);
  }

  Widget _buildCurrentDateEventCard(
    BuildContext context,
    AppLocalizations l10n,
  ) {
    final localeTag = l10n.locale.toLanguageTag();
    final dateTime = DateFormat(
      'd MMMM yyyy',
      localeTag,
    ).format(event.startDate);
    // Use actual start time if available, otherwise use default 14:00
    final timeString = event.startTimeString ?? '14:00';
    // Format time - handle both HH:mm and HH:mm:ss formats
    final formattedTime = _formatTimeString(timeString);
    final dateTimeText = '$dateTime AT $formattedTime';
    final imageUrl = ApiUrls.getMediaUrl(event.image);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailScreen(event: event),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border(
            bottom: BorderSide(
              color: const Color(0xFFE5E7EB).withOpacity(0.2),
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: imageUrl.isNotEmpty
                  ? Image.network(
                      imageUrl,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.event,
                            color: Color(0xFF6B7280),
                            size: 32,
                          ),
                        );
                      },
                    )
                  : Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.event,
                        color: Color(0xFF6B7280),
                        size: 32,
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Event details column
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Date At Time
                  Text(
                    dateTimeText.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF60A5FA), // Light blue color
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Event Title
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(
                        0xFF1F2937,
                      ), // Dark text for white background
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Location
                  Text(
                    event.location ?? l10n.translate('events_no_location'),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280), // Grey color
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // More options icon
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Icon(Icons.more_vert, size: 20, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method to format time string (HH:mm or HH:mm:ss) to HH:mm
  String _formatTimeString(String timeString) {
    if (timeString.isEmpty) return '14:00';

    // Handle HH:mm:ss format - extract just HH:mm
    if (timeString.contains(':')) {
      final parts = timeString.split(':');
      if (parts.length >= 2) {
        final hour = parts[0].padLeft(2, '0');
        final minute = parts[1].padLeft(2, '0');
        return '$hour:$minute';
      }
    }

    return timeString;
  }
}

// Error state widget (moved outside to fix scope issue)
class _ErrorStateWidget extends StatelessWidget {
  final BuildContext context;
  final WidgetRef ref;
  final Object error;

  const _ErrorStateWidget({
    required this.context,
    required this.ref,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Show snackbar with error message
    WidgetsBinding.instance.addPostFrameCallback((_) {
      String errorMessage;
      if (error is Exception) {
        errorMessage = error.cleanMessage;
      } else {
        errorMessage = error.toString();
      }
      SnackbarUtils.showError(context, message: errorMessage);
    });

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            Text(
              l10n.translate('events_error_title'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F2937),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error is Exception ? error.cleanMessage : error.toString(),
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Refresh the events provider
                ref.invalidate(eventsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: Text(l10n.translate('retry')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B7F39),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
