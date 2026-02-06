import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to manage selected profile image state
final selectedProfileImageProvider = StateProvider<File?>((ref) => null);

// Provider to clear selected image (useful after successful upload)
final clearSelectedImageProvider = Provider<void Function()>((ref) {
  return () {
    ref.read(selectedProfileImageProvider.notifier).state = null;
  };
});
