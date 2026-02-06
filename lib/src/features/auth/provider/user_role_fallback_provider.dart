import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';

// Fallback role provider that works when API fails
final userRoleFallbackProvider =
    StateNotifierProvider<UserRoleFallbackNotifier, String?>((ref) {
      return UserRoleFallbackNotifier(ref);
    });

class UserRoleFallbackNotifier extends StateNotifier<String?> {
  final Ref ref;

  UserRoleFallbackNotifier(this.ref) : super(null) {
    _loadFallbackRole();
  }

  static const String _fallbackRoleKey = 'fallback_user_role';

  Future<void> _loadFallbackRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final role = prefs.getString(_fallbackRoleKey);
      if (role != null) {
        state = role;
      }
    } catch (e) {
      print('Error loading fallback user role: $e');
    }
  }

  Future<void> setFallbackRole(String role) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_fallbackRoleKey, role);
      state = role;
    } catch (e) {
      print('Error saving fallback user role: $e');
    }
  }

  Future<void> clearFallbackRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_fallbackRoleKey);
      state = null;
    } catch (e) {
      print('Error clearing fallback user role: $e');
    }
  }
}

// Combined provider that tries API first, then fallback
final effectiveUserRoleProvider = Provider<String?>((ref) {
  final profileAsync = ref.watch(profileProvider);
  final fallbackRole = ref.watch(userRoleFallbackProvider);

  return profileAsync.when(
    data: (user) {
      // API succeeded, use actual user role
      print('Using API role: ${user.role}');
      return user.role;
    },
    loading: () {
      // API loading, use fallback if available, otherwise null to show loader
      print('API loading, using fallback role: $fallbackRole');
      return fallbackRole; // Return null if no fallback set
    },
    error: (error, stack) {
      // API failed, use fallback if available, otherwise default to user
      print('API error, using fallback role: $fallbackRole');
      return fallbackRole ?? 'user'; // Default to user if API fails
    },
  );
});
