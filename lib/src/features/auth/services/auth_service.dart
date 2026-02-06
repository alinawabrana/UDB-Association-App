import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../config/google_config.dart';
import '../../../../utils/network/retry.dart';

class AuthService {
  static const baseUrl = "https://udbconnect.com/api";
  static bool _isGoogleSignInInitialized = false;

  // Initialize Google Sign-In only once
  Future<void> _initializeGoogleSignIn() async {
    if (!_isGoogleSignInInitialized) {
      await signIn.initialize(serverClientId: GoogleConfig.serverClientId);
      _isGoogleSignInInitialized = true;
    }
  }

  final GoogleSignIn signIn = GoogleSignIn.instance;

  // GoogleSignIn is now a singleton, no need to instantiate

  Future<String?> login(String email, String password) async {
    final response = await retry(() async {
      return await http
          .post(
            Uri.parse("$baseUrl/login"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 20));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return data["token"];
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  Future<void> register({
    required String firstName,
    required String surname,
    required String email,
    required String password,
    required String passwordConfirmation,
    required String phone,
    required String countryCode,
    String? dateOfBirth,
    String? placeOfBirth,
    String? nationality,
    String? dateOfFirstAccession,
    String? placeOfResidence,
    String? maritalStatus,
    String? gender,
    String? function,
    String? direction,
  }) async {
    final requestBody = <String, dynamic>{
      "first_name": firstName,
      "surname": surname,
      "email": email,
      "password": password,
      "password_confirmation": passwordConfirmation,
      "phone": phone,
      "country_code": countryCode,
    };

    // Add optional fields only if they are provided
    if (dateOfBirth != null && dateOfBirth.isNotEmpty) {
      requestBody["date_of_birth"] = dateOfBirth;
    }
    if (placeOfBirth != null && placeOfBirth.isNotEmpty) {
      requestBody["place_of_birth"] = placeOfBirth;
    }
    if (nationality != null && nationality.isNotEmpty) {
      requestBody["nationality"] = nationality;
    }
    if (dateOfFirstAccession != null && dateOfFirstAccession.isNotEmpty) {
      requestBody["date_of_first_accession"] = dateOfFirstAccession;
    }
    if (placeOfResidence != null && placeOfResidence.isNotEmpty) {
      requestBody["place_of_residence"] = placeOfResidence;
    }
    if (maritalStatus != null && maritalStatus.isNotEmpty) {
      requestBody["marital_status"] = maritalStatus;
    }
    if (gender != null && gender.isNotEmpty) {
      requestBody["gender"] = gender;
    }
    if (function != null && function.isNotEmpty) {
      requestBody["function"] = function;
    }
    if (direction != null && direction.isNotEmpty) {
      requestBody["direction"] = direction;
    }

    // Log request body (mask password for security)
    final logBody = Map<String, dynamic>.from(requestBody);
    if (logBody.containsKey("password")) {
      final pwd = logBody["password"] as String;
      logBody["password"] = "*" * pwd.length;
    }
    if (logBody.containsKey("password_confirmation")) {
      final pwdConf = logBody["password_confirmation"] as String;
      logBody["password_confirmation"] = "*" * pwdConf.length;
    }
    print('🌐 API REQUEST:');
    print('═══════════════════════════════════════════');
    print('URL: $baseUrl/register');
    print('Method: POST');
    print('Headers: {Accept: application/json, Content-Type: application/json}');
    print('Body: ${jsonEncode(logBody)}');
    print('═══════════════════════════════════════════');

    final response = await retry(() async {
      return await http
          .post(
            Uri.parse("$baseUrl/register"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
            },
            body: jsonEncode(requestBody),
          )
          .timeout(const Duration(seconds: 25));
    });

    print('📥 API RESPONSE:');
    print('═══════════════════════════════════════════');
    print('Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('═══════════════════════════════════════════');

    if (response.statusCode < 200 || response.statusCode >= 300) {
      print('❌ API ERROR RESPONSE:');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');
      try {
        final errorJson = jsonDecode(response.body);
        print('Parsed Error JSON: $errorJson');
        if (errorJson is Map) {
          errorJson.forEach((key, value) {
            print('  $key: $value');
          });
        }
      } catch (e) {
        print('Could not parse error as JSON: $e');
      }
      throw Exception("Registration failed: ${response.body}");
    }
    
    print('✅ Registration successful!');
  }

  Future<User> fetchProfile(String token) async {
    final response = await retry(() async {
      return await http
          .get(
            Uri.parse("$baseUrl/user"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
          )
          .timeout(const Duration(seconds: 15));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception("Failed to fetch profile: ${response.body}");
    }
  }

  Future<User> updateProfile(
    String token,
    Map<String, dynamic> profileData,
  ) async {
    // Check if profile image is included (File object)
    final bool hasImage = profileData['profile_image'] is File;
    print('Has Image = $hasImage');

    if (hasImage) {
      // Step 1: Upload image first to get the filename
      final File imageFile = profileData['profile_image'] as File;
      final imageName = await _uploadProfileImage(token, imageFile);

      // Step 2: Remove the File object and add the image name
      profileData.remove('profile_image');
      profileData['profile_image'] = imageName;

      // Step 3: Use regular JSON request with the image name
      return await _updateProfileTextOnly(token, profileData);
    } else {
      // Use regular JSON request for text-only updates
      return await _updateProfileTextOnly(token, profileData);
    }
  }

  /// Upload profile image to separate endpoint and return the image filename
  Future<String> _uploadProfileImage(String token, File imageFile) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse("$baseUrl/profile/image"),
    );

    // Add headers
    request.headers.addAll({
      "Accept": "application/json",
      "Authorization": "Bearer $token",
    });

    // Add image file with field name 'profile_image'
    print('📤 Uploading image to: $baseUrl/profile/image');
    print('📁 Image path: ${imageFile.path}');
    request.files.add(
      await http.MultipartFile.fromPath('profile_image', imageFile.path),
    );

    // Send request
    var streamedResponse = await retry(() async {
      return await request.send().timeout(const Duration(seconds: 30));
    });
    var response = await http.Response.fromStream(streamedResponse);

    print('✅ Image upload response status: ${response.statusCode}');
    print('📄 Image upload response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      // Extract the image filename from the response
      // Assuming the API returns the filename in a field like 'image_name' or 'filename'
      // Adjust this based on your actual API response structure
      String imageName =
          data['image_name'] ?? data['filename'] ?? data['profile_image'] ?? '';

      // Remove 'profile/' prefix if it exists
      if (imageName.startsWith('profile/')) {
        imageName = imageName.substring(8); // Remove 'profile/' (8 characters)
      }

      print('✅ Image uploaded successfully: $imageName');
      return imageName;
    } else {
      throw Exception("Failed to upload profile image: ${response.body}");
    }
  }

  Future<User> _updateProfileTextOnly(
    String token,
    Map<String, dynamic> profileData,
  ) async {
    print('Text-only update data: $profileData');
    final response = await retry(() async {
      return await http
          .patch(
            Uri.parse("$baseUrl/user/profile"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/json",
              "Authorization": "Bearer $token",
            },
            body: jsonEncode(profileData),
          )
          .timeout(const Duration(seconds: 25));
    });

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception("Failed to update profile: ${response.body}");
    }
  }

  Future<String?> loginWithGoogle() async {
    try {
      // Initialize Google Sign-In only once
      await _initializeGoogleSignIn();

      // Check if platform supports authenticate
      if (!signIn.supportsAuthenticate()) {
        throw Exception("Google Sign-In not supported on this platform");
      }

      // Step 1: Google sign in - let Google handle everything
      final account = await signIn.authenticate();

      final auth = account.authentication;
      final idToken = auth.idToken;

      if (idToken == null) {
        throw Exception("Failed to get ID token from Google");
      }

      // Step 2: Send token to backend
      final response = await retry(() async {
        return await http
            .post(
              Uri.parse("$baseUrl/auth/google"),
              headers: {"Content-Type": "application/json"},
              body: jsonEncode({"token": idToken}),
            )
            .timeout(const Duration(seconds: 20));
      });

      if (response.statusCode >= 200 && response.statusCode < 300) {
        final data = jsonDecode(response.body);
        return data["token"]; // your app's auth token
      } else {
        throw Exception("Google login failed: ${response.body}");
      }
    } catch (e) {
      // Re-throw the original exception to preserve error details
      rethrow;
    }
  }
}
