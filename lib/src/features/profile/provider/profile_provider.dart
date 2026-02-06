import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/features/auth/models/user_model.dart';

class ProfileNotifier extends AsyncNotifier {
  late User profile;

  @override
  FutureOr build() {
    // This will be implemented when needed
    throw UnimplementedError();
  }
}

// Note: The actual profileProvider is defined in auth_providers.dart
// and fetches data from the API
