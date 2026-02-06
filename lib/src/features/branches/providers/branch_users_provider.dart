import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/branch_user_model.dart';
import '../services/branch_users_service.dart';
import '../../auth/provider/auth_providers.dart';

// Branch Users Service Provider
final branchUsersServiceProvider = Provider<BranchUsersService>(
  (ref) => BranchUsersService(),
);

// Branch Users FutureProvider
final branchUsersProvider = FutureProvider.family<List<BranchUser>, int>((
  ref,
  branchId,
) async {
  final service = ref.read(branchUsersServiceProvider);
  final token = ref.watch(authTokenProvider);
  return await service.fetchBranchUsers(branchId: branchId, token: token);
});

// Branch Users with Counts FutureProvider
final branchUsersWithCountsProvider =
    FutureProvider.family<BranchUsersResponse, int>((ref, branchId) async {
      final service = ref.read(branchUsersServiceProvider);
      final token = ref.watch(authTokenProvider);
      return await service.fetchBranchUsersWithCounts(
        branchId: branchId,
        token: token,
      );
    });
