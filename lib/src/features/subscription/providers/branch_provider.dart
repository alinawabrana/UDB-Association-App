import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/branch_model.dart';
import '../services/branch_service.dart';
import '../../auth/provider/auth_providers.dart';

// Branch Service Provider
final branchServiceProvider = Provider<BranchService>((ref) => BranchService());

// Branches FutureProvider
final branchesProvider = FutureProvider<List<Branch>>((ref) async {
  final service = ref.read(branchServiceProvider);
  final token = ref.watch(authTokenProvider);
  return await service.fetchBranches(token: token);
});
