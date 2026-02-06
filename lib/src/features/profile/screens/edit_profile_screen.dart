import 'dart:io';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:udb_association/src/common/widgets/primary_button.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';
import 'package:udb_association/src/features/auth/models/user_model.dart';
import 'package:udb_association/src/features/profile/widgets/profile_header.dart';
import 'package:udb_association/src/features/profile/provider/profile_image_provider.dart';
import 'package:udb_association/utils/validators/form_validators.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

import '../../auth/provider/auth_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  GlobalKey<FormState> updateProfileKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController surnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController businessNameController = TextEditingController();
  TextEditingController shopDetailsController = TextEditingController();
  late String countryCode;
  String selectedCountryIso = 'PK'; // Track selected country ISO for validation
  bool _isUpdating = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    countryCode = '+92';
  }

  bool _hasPrefilledForm = false;

  @override
  void dispose() {
    firstNameController.dispose();
    surnameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    businessNameController.dispose();
    shopDetailsController.dispose();
    super.dispose();
  }

  void _prefillForm(User user) {
    print('📝 === PREFILL FORM DEBUG ===');
    print('User Phone: ${user.phone}');
    print('User Country Code: ${user.countryCode}');
    print('User Profile: ${user.profile}');
    print('Profile Phone: ${user.profile?.phone}');
    print('Profile Country Code: ${user.profile?.countryCode}');
    print('=== END PREFILL DEBUG ===\n');
    
    // Prefill first name and surname, or split name if they're not available
    if (user.firstName != null && user.firstName!.isNotEmpty) {
      firstNameController.text = user.firstName!;
    } else if (user.surname != null && user.surname!.isNotEmpty) {
      // If only surname is available, try to extract first name from name
      final nameParts = user.name.trim().split(' ');
      if (nameParts.length >= 2) {
        firstNameController.text = nameParts[0];
      }
    } else {
      // Split name into first name and surname
      final nameParts = user.name.trim().split(' ');
      if (nameParts.length >= 2) {
        firstNameController.text = nameParts[0];
        surnameController.text = nameParts.sublist(1).join(' ');
      } else if (nameParts.length == 1) {
        firstNameController.text = nameParts[0];
      }
    }
    
    if (user.surname != null && user.surname!.isNotEmpty) {
      surnameController.text = user.surname!;
    }
    
    emailController.text = user.email;
    phoneNumberController.text = user.phone ?? '';
    addressController.text = user.address ?? '';
    businessNameController.text = user.businessName ?? '';
    shopDetailsController.text = user.shopDetails ?? '';
    countryCode = user.countryCode ?? '+92';

    // Set the country ISO based on the country code
    selectedCountryIso = _getCountryIsoFromCode(countryCode);
  }

  /// Convert country code or ISO code to ISO country code
  String _getCountryIsoFromCode(String code) {
    // If it's already an ISO code (2-3 letters), return as is
    if (code.length <= 3 && !code.startsWith('+')) {
      return code.toUpperCase();
    }

    // If it's a country code (starts with +), convert to ISO
    switch (code) {
      case '+92':
        return 'PK'; // Pakistan
      case '+241':
        return 'GA'; // Gabon
      case '+1':
        return 'US'; // USA
      case '+44':
        return 'GB'; // United Kingdom
      case '+91':
        return 'IN'; // India
      case '+86':
        return 'CN'; // China
      case '+81':
        return 'JP'; // Japan
      case '+49':
        return 'DE'; // Germany
      case '+33':
        return 'FR'; // France
      case '+39':
        return 'IT'; // Italy
      case '+34':
        return 'ES'; // Spain
      case '+55':
        return 'BR'; // Brazil
      case '+61':
        return 'AU'; // Australia
      case '+7':
        return 'RU'; // Russia
      case '+20':
        return 'EG'; // Egypt
      case '+27':
        return 'ZA'; // South Africa
      case '+234':
        return 'NG'; // Nigeria
      case '+254':
        return 'KE'; // Kenya
      case '+966':
        return 'SA'; // Saudi Arabia
      case '+971':
        return 'AE'; // UAE
      default:
        return 'PK'; // Default to Pakistan
    }
  }

  Future<void> _pickImage(WidgetRef ref) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final selectedImage = File(image.path);
        ref.read(selectedProfileImageProvider.notifier).state = selectedImage;
        print('image path = ${selectedImage.path}');
      }
    } catch (e) {
      if (mounted) {
        SnackbarUtils.showError(
          context,
          message: context.l10n.translate(
            'edit_profile_pick_image_failed',
            params: {'error': e.cleanMessage},
          ),
        );
      }
    }
  }

  Future<void> _updateProfile(WidgetRef ref) async {
    final l10n = context.l10n;
    if (!updateProfileKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isUpdating = true;
    });

    try {
      final Map<String, dynamic> profileData = {
        'first_name': firstNameController.text.trim(),
        'email': emailController.text.trim(),
        'phone': phoneNumberController.text.trim(),
        'country_code':
            countryCode, // Always include country_code (required field)
        'address': addressController.text.trim(),
        'business_name': businessNameController.text.trim(),
        'shop_details': shopDetailsController.text.trim(),
      };

      // Add surname only if it's not empty (optional field)
      final surname = surnameController.text.trim();
      if (surname.isNotEmpty) {
        profileData['surname'] = surname;
      }

      // Ensure required fields are not empty
      if (profileData['first_name']!.isEmpty) {
        SnackbarUtils.showError(
          context,
          message: l10n.translate('profile_update_name_required'),
        );
        return;
      }
      
      // Surname is optional, so no validation needed

      if (profileData['phone']!.isEmpty) {
        SnackbarUtils.showError(
          context,
          message: l10n.translate('profile_update_phone_required'),
        );
        return;
      }

      // Check if we have a selected image
      final selectedImage = ref.read(selectedProfileImageProvider);

      // Don't remove any fields when updating with image - API requires all fields
      // Only remove empty fields for text-only updates
      if (selectedImage == null) {
        // Remove empty fields only for text-only updates
        profileData.removeWhere(
          (key, value) => value.isEmpty && key != 'country_code',
        );
      } else {
        // Add image if selected
        profileData['profile_image'] = selectedImage;
      }

      // Debug: Print the data being sent
      print('Profile data being sent: $profileData');
      print('Selected image: $selectedImage');
      print('Has image: ${selectedImage != null}');
      print('Form field values:');
      print('  First Name: "${firstNameController.text}"');
      print('  Surname: "${surnameController.text}"');
      print('  Email: "${emailController.text}"');
      print('  Phone: "${phoneNumberController.text}"');
      print('  Country Code: "$countryCode" (actual country code)');
      print(
        '  Selected Country ISO: "$selectedCountryIso" (for validation only)',
      );
      print('  Address: "${addressController.text}"');
      print('  Business Name: "${businessNameController.text}"');
      print('  Shop Details: "${shopDetailsController.text}"');

      await ref.read(updateProfileProvider(profileData).future);

      if (mounted) {
        // Clear the selected image after successful update
        ref.read(selectedProfileImageProvider.notifier).state = null;

        SnackbarUtils.showSuccess(
          context,
          message: l10n.translate('profile_update_success'),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error: $e');
      if (mounted) {
        SnackbarUtils.showError(
          context,
          message: l10n.translate(
            'profile_update_failed',
            params: {'error': e.cleanMessage},
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final selectedImage = ref.watch(selectedProfileImageProvider);
    final l10n = context.l10n;

    return Scaffold(
      body: profile.when(
        data: (user) {
          // Only prefill form once when user data is first loaded
          if (!_hasPrefilledForm) {
            _prefillForm(user);
            _hasPrefilledForm = true;
          }
          return _buildEditProfile(context, user, selectedImage);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(
          child: Text(
            l10n.translate('profile_error_load'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  Widget _buildEditProfile(
    BuildContext context,
    User user,
    File? selectedImage,
  ) {
    final l10n = context.l10n;
    return SingleChildScrollView(
      child: Column(
        spacing: 24,
        children: [
          ProfileHeader(
            showBackArrow: true,
            user: user,
            onImageTap: () => _pickImage(ref),
            selectedImage: selectedImage,
          ),

          // Form Section
          Padding(
            padding: EdgeInsets.all(16),
            child: Form(
              key: updateProfileKey,
              child: Column(
                children: [
                  // First Name
                  TextFormField(
                    controller: firstNameController,
                    decoration: InputDecoration(
                      hintText: l10n.translate('first_name'),
                      prefixIcon: const Icon(Icons.person),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) => AFormValidators.validateEmptyText(
                      value,
                      l10n.translate('first_name'),
                      l10n,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Surname (Optional)
                  TextFormField(
                    controller: surnameController,
                    decoration: InputDecoration(
                      hintText: '${l10n.translate('last_name')} (Optional)',
                      prefixIcon: const Icon(Icons.person_outline),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    // No validator - surname is optional
                  ),
                  SizedBox(height: 16),

                  // Email
                  TextFormField(
                    controller: emailController,
                    decoration: InputDecoration(
                      hintText: l10n.translate('profile_personal_email'),
                      prefixIcon: const Icon(Icons.mail),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) =>
                        AFormValidators.validateEmail(value, l10n),
                  ),
                  SizedBox(height: 16),

                  // Phone with Country Code
                  TextFormField(
                    controller: phoneNumberController,
                    decoration: InputDecoration(
                      hintText: l10n.translate('profile_personal_phone'),
                      prefixIcon: CountryCodePicker(
                        onChanged: (code) {
                          setState(() {
                            countryCode = code
                                .dialCode!; // Use dialCode for actual country code (+92)
                            selectedCountryIso = _getCountryIsoFromCode(
                              code.code!, // Use code for ISO (PK)
                            );
                          });
                        },
                        initialSelection: user.countryCode ?? '+92',
                        showCountryOnly: false,
                        showOnlyCountryWhenClosed: false,
                        alignLeft: false,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) => AFormValidators.validatePhoneNumber(
                      value,
                      l10n: l10n,
                      isoCode: selectedCountryIso,
                    ),
                  ),
                  SizedBox(height: 16),

                  // Address
                  TextFormField(
                    controller: addressController,
                    decoration: InputDecoration(
                      hintText: l10n.translate('profile_address_hint'),
                      prefixIcon: const Icon(Icons.location_on),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: 16),

                  // Business Name
                  if (user.role == 'vender')
                    Column(
                      children: [
                        TextFormField(
                          controller: businessNameController,
                          decoration: InputDecoration(
                            hintText: l10n.translate('profile_business_name'),
                            prefixIcon: const Icon(Icons.business),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),

                        // Shop Details
                        TextFormField(
                          controller: shopDetailsController,
                          decoration: InputDecoration(
                            hintText: l10n.translate('profile_shop_details'),
                            prefixIcon: const Icon(Icons.store),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ),
                  SizedBox(height: 32),

                  // Update Button
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      label: _isUpdating
                          ? l10n.translate('profile_update_in_progress')
                          : l10n.translate('profile_update_button'),
                      icon: _isUpdating ? null : Icons.check,
                      onPressed: _isUpdating
                          ? () {}
                          : () => _updateProfile(ref),
                    ),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
