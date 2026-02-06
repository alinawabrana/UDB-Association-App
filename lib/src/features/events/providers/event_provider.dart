import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/features/events/models/event_model.dart';
import 'package:udb_association/src/features/events/services/event_service.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';

// Event filter state
class EventFilterState {
  final EventType? selectedFilter;
  final DateTime selectedDate;

  const EventFilterState({this.selectedFilter, required this.selectedDate});

  EventFilterState copyWith({
    EventType? selectedFilter,
    DateTime? selectedDate,
    bool clearFilter = false,
  }) {
    return EventFilterState(
      selectedFilter: clearFilter
          ? null
          : (selectedFilter ?? this.selectedFilter),
      selectedDate: selectedDate ?? this.selectedDate,
    );
  }
}

// Event filter provider
final eventFilterProvider =
    StateNotifierProvider<EventFilterNotifier, EventFilterState>((ref) {
      return EventFilterNotifier();
    });

class EventFilterNotifier extends StateNotifier<EventFilterState> {
  EventFilterNotifier() : super(EventFilterState(selectedDate: DateTime.now()));

  void setFilter(EventType? filter) {
    state = state.copyWith(selectedFilter: filter, clearFilter: filter == null);
  }

  void setSelectedDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }
}

// EventService Provider
final eventServiceProvider = Provider<EventService>((ref) => EventService());

// Events data provider - fetches from API
final eventsProvider = FutureProvider<List<EventModel>>((ref) async {
  final service = ref.read(eventServiceProvider);
  final token = ref.read(authTokenProvider);

  if (token == null) {
    throw Exception("Not logged in");
  }

  return await service.fetchEvents(token);
});

// Filtered events provider with scope-based filtering
final filteredEventsProvider = Provider<List<EventModel>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  final filterState = ref.watch(eventFilterProvider);
  final userProfileAsync = ref.watch(profileProvider);

  return eventsAsync.when(
    data: (events) {
      // Filter by user access (scope-based filtering)
      final accessibleEvents = _filterEventsByScope(
        events,
        userProfileAsync.value,
      );

      // Filter by date
      var filteredEvents = accessibleEvents.where((event) {
        final eventDate = DateTime(
          event.startDate.year,
          event.startDate.month,
          event.startDate.day,
        );
        final selectedDate = DateTime(
          filterState.selectedDate.year,
          filterState.selectedDate.month,
          filterState.selectedDate.day,
        );

        return eventDate.isAtSameMomentAs(selectedDate);
      }).toList();

      // Filter by type/category
      if (filterState.selectedFilter != null) {
        filteredEvents = filteredEvents
            .where((event) => event.eventType == filterState.selectedFilter)
            .toList();
      }

      return filteredEvents;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Upcoming events provider (events from tomorrow onwards)
final upcomingEventsProvider = Provider<List<EventModel>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  final userProfileAsync = ref.watch(profileProvider);

  return eventsAsync.when(
    data: (events) {
      // Filter by user access (scope-based filtering)
      final accessibleEvents = _filterEventsByScope(
        events,
        userProfileAsync.value,
      );

      // Get today's date (without time)
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      // Filter events that are after today
      final upcomingEvents = accessibleEvents.where((event) {
        final eventDate = DateTime(
          event.startDate.year,
          event.startDate.month,
          event.startDate.day,
        );
        return eventDate.isAfter(todayDate);
      }).toList();

      return upcomingEvents;
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// Helper function to filter events based on scope and user branch membership
List<EventModel> _filterEventsByScope(List<EventModel> events, dynamic user) {
  if (user == null) {
    print('❌ User is null, returning empty events list');
    return [];
  }

  // Check if user is a manager - managers see all events
  final userRole = user.role?.toLowerCase() ?? '';
  final isManager = userRole == 'manager';

  if (isManager) {
    print('🔍 === EVENT SCOPE FILTERING ===');
    print('User is MANAGER - showing ALL events');
    print('Total events: ${events.length}');
    print('=== END EVENT SCOPE FILTERING ===\n');
    return events; // Managers see all events
  }

  // Get user's branch ID
  final userBranchId = user.branchId;
  print('🔍 === EVENT SCOPE FILTERING ===');
  print('User Branch ID: $userBranchId');
  print('Total events to filter: ${events.length}');

  final filteredEvents = events.where((event) {
    print('\n📅 Event: ${event.title}');
    print('  - Scope: ${event.scope}');
    print('  - Target Branch ID: ${event.targetBranchId}');

    // If scope is global, show to everyone
    if (event.scope == 'global') {
      print('  ✅ Global event - SHOWING to everyone');
      return true;
    }

    // If scope is branch, only show to members of that branch
    if (event.scope == 'branch') {
      final shouldShow =
          userBranchId != null && userBranchId == event.targetBranchId;
      if (shouldShow) {
        print(
          '  ✅ Branch event - User is member of branch $userBranchId - SHOWING',
        );
      } else {
        print(
          '  ❌ Branch event - User branch ($userBranchId) != Event branch (${event.targetBranchId}) - HIDING',
        );
      }
      return shouldShow;
    }

    print('  ❌ Unknown scope - HIDING');
    return false;
  }).toList();

  print('\n📊 Filtered events count: ${filteredEvents.length}');
  print('=== END EVENT SCOPE FILTERING ===\n');

  return filteredEvents;
}

// Calendar events provider (for showing dots on calendar)
final calendarEventsProvider = Provider<Map<DateTime, List<EventModel>>>((ref) {
  final eventsAsync = ref.watch(eventsProvider);
  final userProfileAsync = ref.watch(profileProvider);
  final Map<DateTime, List<EventModel>> calendarEvents = {};

  return eventsAsync.when(
    data: (events) {
      // Filter by user access (scope-based filtering)
      final accessibleEvents = _filterEventsByScope(
        events,
        userProfileAsync.value,
      );

      for (final event in accessibleEvents) {
        final eventDate = DateTime(
          event.startDate.year,
          event.startDate.month,
          event.startDate.day,
        );
        if (calendarEvents.containsKey(eventDate)) {
          calendarEvents[eventDate]!.add(event);
        } else {
          calendarEvents[eventDate] = [event];
        }
      }

      return calendarEvents;
    },
    loading: () => calendarEvents,
    error: (_, __) => calendarEvents,
  );
});
