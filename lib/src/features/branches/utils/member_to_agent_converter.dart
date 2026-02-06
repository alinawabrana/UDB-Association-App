import '../models/division_model.dart';
import '../providers/all_branch_members_provider.dart';
import '../../../../utils/constants/urls.dart';

/// Helper function to convert BranchMember to Agent for AgentDetailScreen
Agent convertMemberToAgent(BranchMember member) {
  final user = member.user;
  
  // Get phone from various profile types
  String? phone;
  if (user.memberProfile?.phone != null) {
    phone = user.memberProfile!.phone;
  } else if (user.managerProfile?.phone != null) {
    phone = user.managerProfile!.phone;
  } else if (user.profile?.phone != null) {
    phone = user.profile!.phone;
  } else {
    phone = user.phone;
  }
  
  // Get email
  final email = user.email;
  
  // Get profile image with proper URL construction - prioritize profile_image over profile_image_url
  String? profileImage;
  if (user.memberProfile?.profileImage != null) {
    profileImage = ApiUrls.getProfileImageUrl(user.memberProfile!.profileImage);
  } else if (user.memberProfile?.profileImageUrl != null) {
    profileImage = ApiUrls.getProfileImageUrl(user.memberProfile!.profileImageUrl);
  } else if (user.managerProfile?.profileImage != null) {
    profileImage = ApiUrls.getProfileImageUrl(user.managerProfile!.profileImage);
  } else if (user.managerProfile?.profileImageUrl != null) {
    profileImage = ApiUrls.getProfileImageUrl(user.managerProfile!.profileImageUrl);
  } else if (user.profile?.profileImage != null) {
    profileImage = ApiUrls.getProfileImageUrl(user.profile!.profileImage);
  } else if (user.profile?.profileImageUrl != null) {
    profileImage = ApiUrls.getProfileImageUrl(user.profile!.profileImageUrl);
  } else {
    profileImage = ApiUrls.getProfileImageUrl(user.image);
  }
  
  // Get display name safely
  String displayName = user.name;
  if (displayName.isEmpty) {
    final firstName = user.firstName ?? '';
    final surname = user.surname ?? '';
    if (firstName.isNotEmpty && surname.isNotEmpty) {
      displayName = '$firstName $surname';
    } else if (firstName.isNotEmpty) {
      displayName = firstName;
    } else if (surname.isNotEmpty) {
      displayName = surname;
    } else if (user.email != null && user.email!.isNotEmpty) {
      displayName = user.email!.split('@').first;
    } else {
      displayName = 'User ${user.id}';
    }
  }
  
  return Agent(
    id: user.id.toString(),
    name: displayName,
    title: user.position,
    role: user.role,
    department: member.branchDepartment,
    division: member.branchProvince,
    phone: phone,
    email: email,
    profileImage: profileImage,
    province: member.branchProvince,
    departement: member.branchDepartment,
    branchName: member.branchName,
    function: user.function,
    direction: user.direction,
  );
}

