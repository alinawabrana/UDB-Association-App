import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import 'package:udb_association/src/common/storage/token_storage.dart';

// AuthService Provider
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// Token State Provider
final authTokenProvider = StateProvider<String?>((ref) => null);

// Login FutureProvider
final loginProvider = FutureProvider.family<String?, (String, String)>((
  ref,
  credentials,
) async {
  final service = ref.read(authServiceProvider);
  final token = await service.login(credentials.$1, credentials.$2);
  ref.read(authTokenProvider.notifier).state = token;
  if (token != null) {
    await const TokenStorage().saveToken(token);
  }
  return token;
}, dependencies: [authServiceProvider]);

// Registration FutureProvider
final registerProvider = FutureProvider.family<void, Map<String, String>>((
  ref,
  form,
) async {
  final service = ref.read(authServiceProvider);
  await service.register(
    firstName: form["first_name"]!,
    surname: form["surname"]!,
    email: form["email"]!,
    password: form["password"]!,
    passwordConfirmation: form["password_confirmation"]!,
    phone: form["phone"]!,
    countryCode: form["country_code"]!,
    dateOfBirth: form["date_of_birth"],
    placeOfBirth: form["place_of_birth"],
    nationality: form["nationality"],
    dateOfFirstAccession: form["date_of_first_accession"],
    placeOfResidence: form["place_of_residence"],
    maritalStatus: form["marital_status"],
    gender: form["gender"],
    function: form["function"],
    direction: form["direction"],
  );
});

// Profile Provider
final profileProvider = FutureProvider<User>((ref) async {
  final service = ref.read(authServiceProvider);
  final token = ref.watch(authTokenProvider);
  if (token == null) throw Exception("Not logged in");

  print('🔍 === FETCHING USER PROFILE ===');
  final user = await service.fetchProfile(token);
  print('✅ Profile fetched successfully');
  print('User ID: ${user.id}');
  print('User Name: ${user.name}');
  print('User Email: ${user.email}');
  print('User Role: ${user.role}');
  print('User Branch ID: ${user.branchId}');
  print('User Profile: ${user.profile}');
  print('=== END PROFILE FETCH ===\n');

  return user;
});

// Update Profile Provider
final updateProfileProvider = FutureProvider.family<User, Map<String, dynamic>>(
  (ref, profileData) async {
    final service = ref.read(authServiceProvider);
    final token = ref.read(authTokenProvider);
    if (token == null) throw Exception("Not logged in");
    final updatedUser = await service.updateProfile(token, profileData);

    // Invalidate the profile provider to refresh the data
    ref.invalidate(profileProvider);

    return updatedUser;
  },
);

// 🔹 Google Sign-In StateNotifier
class GoogleSignInNotifier extends StateNotifier<AsyncValue<String?>> {
  GoogleSignInNotifier(this._authService) : super(const AsyncValue.data(null));

  final AuthService _authService;

  Future<String?> signIn() async {
    state = const AsyncValue.loading();
    try {
      final token = await _authService.loginWithGoogle();
      state = AsyncValue.data(token);
      return token; // Return the token directly
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      rethrow; // Re-throw the error so the widget can handle it
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

final googleSignInNotifierProvider =
    StateNotifierProvider<GoogleSignInNotifier, AsyncValue<String?>>((ref) {
      final authService = ref.read(authServiceProvider);
      return GoogleSignInNotifier(authService);
    });

// 🔹 Google Sign-In FutureProvider (deprecated - use notifier instead)
final googleLoginProvider = FutureProvider<String?>((ref) async {
  final service = ref.read(authServiceProvider);
  final token = await service.loginWithGoogle();
  if (token != null) {
    ref.read(authTokenProvider.notifier).state = token;
    await const TokenStorage().saveToken(token);
  }
  return token;
});
