/// Model representing a user from branch users API
class BranchUser {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? image;
  final String? role;
  final String? position;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isApproved;
  final String? emailVerifiedAt;
  final String? provider;
  final String? providerId;
  final String? firstName;
  final String? surname;
  final DateTime? dateOfBirth;
  final String? placeOfBirth;
  final String? nationality;
  final DateTime? dateOfFirstAccession;
  final String? placeOfResidence;
  final String? maritalStatus;
  final String? gender;
  final String? function;
  final String? direction;
  final MemberProfile? memberProfile;
  final ManagerProfile? managerProfile;
  final UserProfile? profile;

  const BranchUser({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.image,
    this.role,
    this.position,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.isApproved,
    this.emailVerifiedAt,
    this.provider,
    this.providerId,
    this.firstName,
    this.surname,
    this.dateOfBirth,
    this.placeOfBirth,
    this.nationality,
    this.dateOfFirstAccession,
    this.placeOfResidence,
    this.maritalStatus,
    this.gender,
    this.function,
    this.direction,
    this.memberProfile,
    this.managerProfile,
    this.profile,
  });

  /// Factory constructor to parse JSON from API
  factory BranchUser.fromJson(Map<String, dynamic> json) {
    // Construct name from first_name and surname if name is not present
    String name = json['name']?.toString()?.trim() ?? '';
    if (name.isEmpty) {
      final firstName = json['first_name']?.toString()?.trim() ?? '';
      final surname = json['surname']?.toString()?.trim() ?? '';
      if (firstName.isNotEmpty && surname.isNotEmpty) {
        name = '$firstName $surname';
      } else if (firstName.isNotEmpty) {
        name = firstName;
      } else if (surname.isNotEmpty) {
        name = surname;
      } else {
        // Fallback to email or user ID if no name available
        final email = json['email']?.toString()?.trim() ?? '';
        final userId = json['id']?.toString() ?? '';
        name = email.isNotEmpty ? email.split('@').first : 'User $userId';
      }
    }
    
    return BranchUser(
      id: json['id'] as int,
      name: name,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      image: json['image'] as String?,
      role: json['role'] as String?,
      position: json['position'] as String?,
      address: json['address'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
      isApproved: json['is_approved'] as bool?,
      emailVerifiedAt: json['email_verified_at'] as String?,
      provider: json['provider'] as String?,
      providerId: json['provider_id'] as String?,
      firstName: json['first_name'] as String?,
      surname: json['surname'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'].toString())
          : null,
      placeOfBirth: json['place_of_birth'] as String?,
      nationality: json['nationality'] as String?,
      dateOfFirstAccession: json['date_of_first_accession'] != null
          ? DateTime.parse(json['date_of_first_accession'].toString())
          : null,
      placeOfResidence: json['place_of_residence'] as String?,
      maritalStatus: json['marital_status'] as String?,
      gender: json['gender'] as String?,
      function: json['function'] as String?,
      direction: json['direction'] as String?,
      memberProfile: json['member_profile'] != null
          ? MemberProfile.fromJson(json['member_profile'])
          : null,
      managerProfile: json['manager_profile'] != null
          ? ManagerProfile.fromJson(json['manager_profile'])
          : null,
      profile: json['profile'] != null
          ? UserProfile.fromJson(json['profile'])
          : null,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'image': image,
      'role': role,
      'position': position,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_approved': isApproved,
      'email_verified_at': emailVerifiedAt,
      'provider': provider,
      'provider_id': providerId,
      'first_name': firstName,
      'surname': surname,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'place_of_birth': placeOfBirth,
      'nationality': nationality,
      'date_of_first_accession': dateOfFirstAccession?.toIso8601String(),
      'place_of_residence': placeOfResidence,
      'marital_status': maritalStatus,
      'gender': gender,
      'function': function,
      'direction': direction,
      'member_profile': memberProfile?.toJson(),
      'manager_profile': managerProfile?.toJson(),
      'profile': profile?.toJson(),
    };
  }

  /// Parse list from JSON response body
  static List<BranchUser> listFromJson(Map<String, dynamic> json) {
    if (json['data'] is List) {
      return (json['data'] as List)
          .map((e) => BranchUser.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    }
    throw const FormatException('Expected a JSON object with "data" array');
  }
}

/// Model for branch users response with counts
class BranchUsersResponse {
  final List<BranchUser> members;
  final List<BranchUser> managers;
  final int memberCount;
  final int managerCount;

  const BranchUsersResponse({
    required this.members,
    required this.managers,
    required this.memberCount,
    required this.managerCount,
  });

  factory BranchUsersResponse.fromUsers(List<BranchUser> users) {
    final members = users
        .where(
          (user) =>
              user.role?.toLowerCase() != 'manager' &&
              user.role?.toLowerCase() != 'admin',
        )
        .toList();
    final managers = users
        .where(
          (user) =>
              user.role?.toLowerCase() == 'manager' ||
              user.role?.toLowerCase() == 'admin',
        )
        .toList();

    return BranchUsersResponse(
      members: members,
      managers: managers,
      memberCount: members.length,
      managerCount: managers.length,
    );
  }
}

/// Model for member profile
class MemberProfile {
  final int id;
  final int userId;
  final String? phone;
  final String? address;
  final String? countryCode;
  final bool? isRedactor;
  final bool? subscriptionStatus;
  final int? branchId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? profileImage;
  final String? profileImageUrl;
  final Branch? branch;

  const MemberProfile({
    required this.id,
    required this.userId,
    this.phone,
    this.address,
    this.countryCode,
    this.isRedactor,
    this.subscriptionStatus,
    this.branchId,
    this.createdAt,
    this.updatedAt,
    this.profileImage,
    this.profileImageUrl,
    this.branch,
  });

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    return MemberProfile(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      countryCode: json['country_code'] as String?,
      isRedactor: json['is_redactor'] as bool?,
      subscriptionStatus: json['subscription_status'] as bool?,
      branchId: json['branch_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
      profileImage: json['profile_image'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'phone': phone,
      'address': address,
      'country_code': countryCode,
      'is_redactor': isRedactor,
      'subscription_status': subscriptionStatus,
      'branch_id': branchId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'profile_image': profileImage,
      'profile_image_url': profileImageUrl,
      'branch': branch?.toJson(),
    };
  }
}

/// Model for manager profile
class ManagerProfile {
  final int id;
  final int userId;
  final String? phone;
  final String? address;
  final String? countryCode;
  final int? branchId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? profileImage;
  final String? profileImageUrl;
  final Branch? branch;

  const ManagerProfile({
    required this.id,
    required this.userId,
    this.phone,
    this.address,
    this.countryCode,
    this.branchId,
    this.createdAt,
    this.updatedAt,
    this.profileImage,
    this.profileImageUrl,
    this.branch,
  });

  factory ManagerProfile.fromJson(Map<String, dynamic> json) {
    return ManagerProfile(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      countryCode: json['country_code'] as String?,
      branchId: json['branch_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
      profileImage: json['profile_image'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'phone': phone,
      'address': address,
      'country_code': countryCode,
      'branch_id': branchId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'profile_image': profileImage,
      'profile_image_url': profileImageUrl,
      'branch': branch?.toJson(),
    };
  }
}

/// Model for user profile (common profile)
class UserProfile {
  final int id;
  final int userId;
  final String? phone;
  final String? address;
  final String? countryCode;
  final bool? isRedactor;
  final bool? subscriptionStatus;
  final int? branchId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? profileImage;
  final String? profileImageUrl;
  final Branch? branch;

  const UserProfile({
    required this.id,
    required this.userId,
    this.phone,
    this.address,
    this.countryCode,
    this.isRedactor,
    this.subscriptionStatus,
    this.branchId,
    this.createdAt,
    this.updatedAt,
    this.profileImage,
    this.profileImageUrl,
    this.branch,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      countryCode: json['country_code'] as String?,
      isRedactor: json['is_redactor'] as bool?,
      subscriptionStatus: json['subscription_status'] as bool?,
      branchId: json['branch_id'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
      profileImage: json['profile_image'] as String?,
      profileImageUrl: json['profile_image_url'] as String?,
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'user_id': userId,
      'phone': phone,
      'address': address,
      'country_code': countryCode,
      'is_redactor': isRedactor,
      'subscription_status': subscriptionStatus,
      'branch_id': branchId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'profile_image': profileImage,
      'profile_image_url': profileImageUrl,
      'branch': branch?.toJson(),
    };
  }
}

/// Model for branch information
class Branch {
  final int id;
  final String name;
  final String? address;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? image;
  final String? phone;
  final String? email;
  final String? description;
  final String? country;
  final String? province;
  final String? department;

  const Branch({
    required this.id,
    required this.name,
    this.address,
    this.createdAt,
    this.updatedAt,
    this.image,
    this.phone,
    this.email,
    this.description,
    this.country,
    this.province,
    this.department,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      address: json['address'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'].toString())
          : null,
      image: json['image'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      description: json['description'] as String?,
      country: json['country'] as String?,
      province: json['province'] as String?,
      department: json['department'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'address': address,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'image': image,
      'phone': phone,
      'email': email,
      'description': description,
      'country': country,
      'province': province,
      'department': department,
    };
  }
}
