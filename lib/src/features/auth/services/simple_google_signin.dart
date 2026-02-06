import 'package:google_sign_in/google_sign_in.dart';
import '../../../config/google_config.dart';

/// Simple Google Sign-In implementation for testing
class SimpleGoogleSignIn {
  static Future<String?> signIn() async {
    try {
      // Minimal initialization
      await GoogleSignIn.instance.initialize(
        serverClientId: GoogleConfig.serverClientId,
      );

      // Simple authentication
      final account = await GoogleSignIn.instance.authenticate();
      final auth = account.authentication;

      return auth.idToken;
    } catch (e) {
      // Return null on error
      return null;
    }
  }

  static Future<void> signOut() async {
    try {
      await GoogleSignIn.instance.signOut();
    } catch (e) {
      // Ignore errors
    }
  }
}
