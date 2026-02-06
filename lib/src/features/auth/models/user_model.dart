class User {
  final String? id;
  final String name;
  final String? firstName;
  final String? surname;
  final String email;
  final String? role;
  final String? function;
  final bool? isApproved;
  final int? branchId; // User's branch ID
  final UserProfile? profile;
  final DateTime? createdAt; // Direct creation date from user object
  final DateTime? updatedAt; // Direct update date from user object
  // Private fields to store user-level phone and country_code if present
  final String? _userPhone;
  final String? _userCountryCode;

  const User({
    this.id,
    required this.name,
    this.firstName,
    this.surname,
    required this.email,
    this.role,
    this.function,
    this.isApproved,
    this.branchId,
    this.profile,
    this.createdAt,
    this.updatedAt,
    String? userPhone,
    String? userCountryCode,
  }) : _userPhone = userPhone,
       _userCountryCode = userCountryCode;

  // Convenience getters for backward compatibility
  // Check both user level and profile level for phone and country_code
  String? get phone {
    // First check if phone is at user level (new API structure)
    final userPhone = _userPhone;
    if (userPhone != null && userPhone.isNotEmpty) {
      return userPhone;
    }
    // Fallback to profile level (old API structure)
    return profile?.phone;
  }
  
  String? get countryCode {
    // First check if country_code is at user level (new API structure)
    final userCountryCode = _userCountryCode;
    if (userCountryCode != null && userCountryCode.isNotEmpty) {
      return userCountryCode;
    }
    // Fallback to profile level (old API structure)
    return profile?.countryCode;
  }
  String? get address => profile?.address;
  String? get profileImage => profile?.profileImage;
  String? get businessName => profile?.businessName;
  String? get shopDetails => profile?.shopDetails;
  DateTime? get userCreatedAt => createdAt ?? profile?.createdAt;
  DateTime? get userUpdatedAt => updatedAt ?? profile?.updatedAt;
  // Branch ID getter - can access from both User.branchId and User.profile.branchId
  int? get userBranchId => branchId ?? profile?.branchId;

  factory User.fromJson(Map<String, dynamic> json) {
    // Handle the new API response structure
    final userData = json['user'] ?? json;

    print('🔍 === PARSING USER FROM JSON ===');
    print('Raw JSON: $json');
    print('User Data: $userData');

    // Branch ID is located inside the profile object
    final profileData = userData['profile'];
    print('Profile Data: $profileData');
    print('branch_id value: ${profileData?['branch_id']}');
    print('branch_id type: ${profileData?['branch_id'].runtimeType}');

    final branchId = profileData?['branch_id'] as int?;
    print('Parsed branchId: $branchId');
    print('phone value: ${profileData?['phone']}');
    print('phone type: ${profileData?['phone'].runtimeType}');
    print('country_code value: ${profileData?['country_code']}');
    print('country_code type: ${profileData?['country_code'].runtimeType}');
    // Also check if phone is at user level
    print('userData phone: ${userData['phone']}');
    print('userData country_code: ${userData['country_code']}');

    // Construct name from first_name and surname if name is not present
    String name = userData['name']?.toString() ?? '';
    if (name.isEmpty) {
      final firstName = userData['first_name']?.toString() ?? '';
      final surname = userData['surname']?.toString() ?? '';
      if (firstName.isNotEmpty && surname.isNotEmpty) {
        name = '$firstName $surname';
      } else if (firstName.isNotEmpty) {
        name = firstName;
      } else if (surname.isNotEmpty) {
        name = surname;
      }
    }
    
    // Check if phone and country_code are at user level (new API structure)
    final userPhone = userData['phone']?.toString();
    final userCountryCode = userData['country_code']?.toString();
    
    print('User level phone: $userPhone');
    print('User level country_code: $userCountryCode');
    print('=== END USER PARSING ===\n');
    
    return User(
      id: userData['id']?.toString(),
      name: name,
      firstName: userData['first_name']?.toString(),
      surname: userData['surname']?.toString(),
      email: userData['email'] ?? '',
      role: userData['role']?.toString(),
      function: userData['function']?.toString(),
      isApproved: userData['is_approved'] as bool?,
      branchId: branchId,
      profile: userData['profile'] != null
          ? UserProfile.fromJson(userData['profile'])
          : null,
      createdAt: userData['created_at'] != null
          ? DateTime.parse(userData['created_at'])
          : null,
      updatedAt: userData['updated_at'] != null
          ? DateTime.parse(userData['updated_at'])
          : null,
      userPhone: userPhone,
      userCountryCode: userCountryCode,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'is_approved': isApproved,
      'branch_id': branchId,
      'profile': profile?.toJson(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class UserProfile {
  final String? id;
  final String? userId;
  final String? phone;
  final String? address;
  final String? countryCode;
  final String? businessName;
  final String? shopDetails;
  final String? profileImage;
  final int? branchId; // Branch ID is part of profile
  final bool? isRedactor;
  final bool? subscriptionStatus;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    this.id,
    this.userId,
    this.phone,
    this.address,
    this.countryCode,
    this.businessName,
    this.shopDetails,
    this.profileImage,
    this.branchId,
    this.isRedactor,
    this.subscriptionStatus,
    this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id']?.toString(),
      userId: json['user_id']?.toString(),
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      countryCode: json['country_code']?.toString(),
      businessName: json['business_name']?.toString(),
      shopDetails: json['shop_details']?.toString(),
      profileImage: json['profile_image']?.toString(),
      branchId: json['branch_id'] as int?,
      isRedactor: json['is_redactor'] as bool?,
      subscriptionStatus: json['subscription_status'] as bool?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'phone': phone,
      'address': address,
      'country_code': countryCode,
      'business_name': businessName,
      'shop_details': shopDetails,
      'profile_image': profileImage,
      'branch_id': branchId,
      'is_redactor': isRedactor,
      'subscription_status': subscriptionStatus,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
