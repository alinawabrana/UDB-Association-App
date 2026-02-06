import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/location_model.dart';
import '../services/location_service.dart';
import '../../auth/provider/auth_providers.dart';

// Location Service Provider
final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

// Locations FutureProvider
final locationsProvider = FutureProvider<List<Location>>((ref) async {
  final service = ref.read(locationServiceProvider);
  final token = ref.watch(authTokenProvider);
  return await service.fetchLocations(token: token);
});

