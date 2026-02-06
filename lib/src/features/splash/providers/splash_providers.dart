import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/features/splash/models/splash_image.dart';
import 'package:udb_association/src/features/splash/services/splash_service.dart';

final splashServiceProvider = Provider<SplashService>((ref) {
  return SplashService();
});

final activeSplashImagesProvider = FutureProvider<List<SplashImage>>((
  ref,
) async {
  final service = ref.read(splashServiceProvider);
  return service.fetchActiveImages();
});
