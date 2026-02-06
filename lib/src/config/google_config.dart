class GoogleConfig {
  // TODO: Replace with your actual Google OAuth client ID
  // You can get this from Google Cloud Console > APIs & Services > Credentials
  //
  // For now, using a placeholder that won't cause initialization errors
  // Replace this with your actual Web client ID from Google Console
  static const String serverClientId =
      '763672698535-ev6l609kdbecvpnt7b7qdnfgnm5hkve1.apps.googleusercontent.com';

  // Scopes for Google Sign-In
  static const List<String> scopes = ['email', 'profile'];

  // Note: This placeholder client ID will allow the app to initialize
  // but Google Sign-In will fail at the authentication step until you
  // replace it with your actual client ID from Google Console
}
