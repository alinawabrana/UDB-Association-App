import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/branch_user_model.dart';
import '../providers/branch_users_provider.dart';
import '../../subscription/providers/branch_provider.dart';
import '../../auth/provider/auth_providers.dart';

/// Model to combine BranchUser with Branch information
class BranchMember {
  final BranchUser user;
  final String branchName;
  final String? branchProvince;
  final String? branchDepartment;

  const BranchMember({
    required this.user,
    required this.branchName,
    this.branchProvince,
    this.branchDepartment,
  });
}

/// Provider to fetch all branch members (role = "member")
final allBranchMembersProvider = FutureProvider<List<BranchMember>>((ref) async {
  final branchService = ref.read(branchServiceProvider);
  final branchUsersService = ref.read(branchUsersServiceProvider);
  final token = ref.watch(authTokenProvider);

  // First, fetch all branches
  final branches = await branchService.fetchBranches(token: token);

  // Then, fetch users for each branch
  final List<BranchMember> allMembers = [];

  for (final branch in branches) {
    try {
      final users = await branchUsersService.fetchBranchUsers(
        branchId: branch.id,
        token: token,
      );

      // Filter users with role = "member"
      final members = users
          .where((user) => user.role?.toLowerCase() == 'member')
          .map((user) => BranchMember(
                user: user,
                branchName: branch.name,
                branchProvince: branch.province,
                branchDepartment: branch.department,
              ))
          .toList();

      allMembers.addAll(members);
    } catch (e) {
      // Continue with other branches if one fails
      print('Error fetching users for branch ${branch.id}: $e');
    }
  }

  return allMembers;
});

