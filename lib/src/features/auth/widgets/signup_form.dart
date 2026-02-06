import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/common/widgets/primary_button.dart';
import 'package:udb_association/src/common/utils/snackbar_utils.dart';
import 'package:udb_association/src/features/auth/provider/auth_providers.dart';
import 'package:udb_association/utils/validators/form_validators.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';
import 'package:intl/intl.dart';

import '../provider/auth_tab_provider.dart';

class SignupForm extends ConsumerStatefulWidget {
  const SignupForm({super.key});

  @override
  ConsumerState<SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends ConsumerState<SignupForm> {
  final GlobalKey<FormState> signupFormKey = GlobalKey<FormState>();
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  
  // Optional fields controllers
  TextEditingController placeOfBirthController = TextEditingController();
  TextEditingController nationalityController = TextEditingController();
  TextEditingController placeOfResidenceController = TextEditingController();
  TextEditingController functionController = TextEditingController();
  TextEditingController directionController = TextEditingController();
  TextEditingController dateOfBirthDisplayController = TextEditingController();
  TextEditingController dateOfFirstAccessionDisplayController = TextEditingController();

  // State for date fields
  DateTime? selectedDateOfBirth;
  DateTime? selectedDateOfFirstAccession;

  // State for dropdown fields
  String? selectedMaritalStatus;
  String? selectedGender;

  // State for password visibility
  bool isPasswordObscured = true;
  bool isConfirmPasswordObscured = true;
  String selectedCountryCode = '+1';
  String selectedCountryIso = 'US';

  // State for registration process
  bool isRegistering = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final firstNameLabel = l10n.translate('first_name');
    final lastNameLabel = l10n.translate('last_name');
    final emailLabel = l10n.translate('email');
    final phoneLabel = l10n.translate('phone_number');
    final passwordLabel = l10n.translate('password');
    final confirmPasswordLabel = l10n.translate('confirm_password');

    return Form(
      key: signupFormKey,
      child: Column(
        children: [
          Row(
            children: [
              Flexible(
                child: TextFormField(
                  controller: firstNameController,
                  decoration: InputDecoration(
                    hintText: firstNameLabel,
                    prefixIcon: const Icon(Icons.person),
                  ),
                  validator: (value) => AFormValidators.validateEmptyText(
                    value,
                    firstNameLabel,
                    l10n,
                  ),
                ),
              ),
              SizedBox(width: 8),
              Flexible(
                child: TextFormField(
                  controller: lastNameController,
                  decoration: InputDecoration(
                    hintText: '$lastNameLabel (Optional)',
                    prefixIcon: const Icon(Icons.person),
                  ),
                  // No validator - surname is optional
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: emailLabel,
              prefixIcon: const Icon(Icons.mail),
            ),
            keyboardType: TextInputType.emailAddress,
            validator: (value) => AFormValidators.validateEmail(value, l10n),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: phoneNumberController,
            decoration: InputDecoration(
              hintText: phoneLabel,
              prefixIcon: CountryCodePicker(
                onChanged: (CountryCode countryCode) {
                  setState(() {
                    selectedCountryCode = countryCode.dialCode!;
                    selectedCountryIso = countryCode.code ?? 'US';
                  });
                },
                initialSelection: 'US',
                favorite: ['+1', 'US', '+44', 'GB'],
                showCountryOnly: false,
                showOnlyCountryWhenClosed: false,
                alignLeft: false,
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
          TextFormField(
            controller: addressController,
            decoration: InputDecoration(
              hintText: l10n.translate('address_optional'),
              prefixIcon: Icon(Icons.home),
            ),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDateOfBirth ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                locale: l10n.locale,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Color(0xFF6B7C32),
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                setState(() {
                  selectedDateOfBirth = pickedDate;
                  dateOfBirthDisplayController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                });
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: l10n.translate('date_of_birth_optional'),
                  prefixIcon: Icon(Icons.calendar_today),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                controller: dateOfBirthDisplayController,
              ),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: placeOfBirthController,
            decoration: InputDecoration(
              hintText: l10n.translate('place_of_birth_optional'),
              prefixIcon: Icon(Icons.location_on),
            ),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: nationalityController,
            decoration: InputDecoration(
              hintText: l10n.translate('nationality_optional'),
              prefixIcon: Icon(Icons.flag),
            ),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDateOfFirstAccession ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                locale: l10n.locale,
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: Color(0xFF6B7C32),
                        onPrimary: Colors.white,
                        onSurface: Colors.black,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (pickedDate != null) {
                setState(() {
                  selectedDateOfFirstAccession = pickedDate;
                  dateOfFirstAccessionDisplayController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                });
              }
            },
            child: AbsorbPointer(
              child: TextFormField(
                decoration: InputDecoration(
                  hintText: l10n.translate('date_of_first_accession_optional'),
                  prefixIcon: Icon(Icons.event),
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
                controller: dateOfFirstAccessionDisplayController,
              ),
            ),
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: placeOfResidenceController,
            decoration: InputDecoration(
              hintText: l10n.translate('place_of_residence_optional'),
              prefixIcon: Icon(Icons.home_work),
            ),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedMaritalStatus,
            decoration: InputDecoration(
              hintText: l10n.translate('marital_status_optional'),
              prefixIcon: Icon(Icons.favorite),
            ),
            items: [
              DropdownMenuItem(
                value: 'single', // English value for API
                child: Text(l10n.translate('single')),
              ),
              DropdownMenuItem(
                value: 'married', // English value for API
                child: Text(l10n.translate('married')),
              ),
              DropdownMenuItem(
                value: 'divorced', // English value for API
                child: Text(l10n.translate('divorced')),
              ),
              DropdownMenuItem(
                value: 'widowed', // English value for API
                child: Text(l10n.translate('widowed')),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedMaritalStatus = value;
              });
            },
          ),
          SizedBox(height: 16),
          DropdownButtonFormField<String>(
            value: selectedGender,
            decoration: InputDecoration(
              hintText: l10n.translate('gender_optional'),
              prefixIcon: Icon(Icons.person_outline),
            ),
            items: [
              DropdownMenuItem(
                value: 'male', // English value for API (lowercase for consistency)
                child: Text(l10n.translate('male')),
              ),
              DropdownMenuItem(
                value: 'female', // English value for API (lowercase for consistency)
                child: Text(l10n.translate('female')),
              ),
              DropdownMenuItem(
                value: 'other', // English value for API
                child: Text(l10n.translate('other')),
              ),
            ],
            onChanged: (value) {
              setState(() {
                selectedGender = value;
              });
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: functionController,
            decoration: InputDecoration(
              hintText: l10n.translate('function_optional'),
              prefixIcon: Icon(Icons.work_outline),
            ),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: directionController,
            decoration: InputDecoration(
              hintText: l10n.translate('direction_optional'),
              prefixIcon: Icon(Icons.directions),
            ),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: passwordController,
            obscureText: isPasswordObscured,
            decoration: InputDecoration(
              hintText: passwordLabel,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isPasswordObscured = !isPasswordObscured;
                  });
                },
                icon: Icon(
                  isPasswordObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            validator: (value) =>
                AFormValidators.validatePassword(value, l10n),
            onChanged: (value) {
              // Re-validate confirm password when password changes
              if (confirmPasswordController.text.isNotEmpty) {
                signupFormKey.currentState?.validate();
              }
            },
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: confirmPasswordController,
            obscureText: isConfirmPasswordObscured,
            decoration: InputDecoration(
              hintText: confirmPasswordLabel,
              prefixIcon: const Icon(Icons.lock),
              suffixIcon: IconButton(
                onPressed: () {
                  setState(() {
                    isConfirmPasswordObscured = !isConfirmPasswordObscured;
                  });
                },
                icon: Icon(
                  isConfirmPasswordObscured
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                ),
              ),
            ),
            validator: (value) {
              final confirmPassword = value ?? '';
              final password = passwordController.text;
              
              if (confirmPassword.isEmpty) {
                return l10n.translate('password_required');
              }
              
              if (password.isEmpty) {
                // If password is empty, don't validate confirm password yet
                return null;
              }
              
              // Compare both passwords as-is (without trimming) since password is sent as-is to API
              // Use exact string comparison
              if (password != confirmPassword) {
                return l10n.translate('confirm_password_mismatch');
              }
              
              return null;
            },
          ),
          SizedBox(height: 24),
          PrimaryButton(
            label: isRegistering
                ? l10n.translate('registering')
                : l10n.translate('register'),
            leading: isRegistering
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Icon(Icons.person_add_alt_1, size: 20, color: Colors.white),
            backgroundColor: const Color(0xFF6B7C32).withValues(alpha: 0.9),
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: <Color>[Color(0xFF6B7C32), Color(0xFF8FA055)],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0x1A000000), // #0000001A → black with 10% opacity
                offset: Offset(0, 10), // x=0, y=10
                blurRadius: 15, // blur
                spreadRadius: 0, // spread
              ),
              BoxShadow(
                color: Color(0x1A000000), // same semi-transparent black
                offset: Offset(0, 4), // x=0, y=4
                blurRadius: 6,
                spreadRadius: 0,
              ),
            ],
            foregroundColor: Colors.white,
            onPressed: isRegistering ? () {} : _handleRegistration,
          ),
        ],
      ),
    );
  }

  Future<void> _handleRegistration() async {
    if (!signupFormKey.currentState!.validate()) {
      return;
    }

    setState(() {
      isRegistering = true;
    });

    try {
      // Prepare form data with required fields
      final formData = <String, String>{
        "first_name": firstNameController.text.trim(),
        "email": emailController.text.trim(),
        "password": passwordController.text,
        "password_confirmation": confirmPasswordController.text,
        "phone": phoneNumberController.text.trim(),
        "country_code": selectedCountryCode,
      };

      // Add surname only if it's not empty (optional field)
      final surname = lastNameController.text.trim();
      if (surname.isNotEmpty) {
        formData["surname"] = surname;
      }

      // Add optional fields only if they have values
      if (selectedDateOfBirth != null) {
        formData["date_of_birth"] = DateFormat('yyyy-MM-dd').format(selectedDateOfBirth!);
      }

      final placeOfBirth = placeOfBirthController.text.trim();
      if (placeOfBirth.isNotEmpty) {
        formData["place_of_birth"] = placeOfBirth;
      }

      final nationality = nationalityController.text.trim();
      if (nationality.isNotEmpty) {
        formData["nationality"] = nationality;
      }

      if (selectedDateOfFirstAccession != null) {
        formData["date_of_first_accession"] = DateFormat('yyyy-MM-dd').format(selectedDateOfFirstAccession!);
      }

      final placeOfResidence = placeOfResidenceController.text.trim();
      if (placeOfResidence.isNotEmpty) {
        formData["place_of_residence"] = placeOfResidence;
      }

      if (selectedMaritalStatus != null && selectedMaritalStatus!.isNotEmpty) {
        formData["marital_status"] = selectedMaritalStatus!;
      }

      if (selectedGender != null && selectedGender!.isNotEmpty) {
        formData["gender"] = selectedGender!;
      }

      final function = functionController.text.trim();
      if (function.isNotEmpty) {
        formData["function"] = function;
      }

      final direction = directionController.text.trim();
      if (direction.isNotEmpty) {
        formData["direction"] = direction;
      }

      // Log form data being sent (mask password for security)
      final logData = Map<String, String>.from(formData);
      logData["password"] = "*" * (passwordController.text.length);
      print('📤 REGISTRATION FORM DATA:');
      print('═══════════════════════════════════════════');
      logData.forEach((key, value) {
        print('  $key: $value');
      });
      print('═══════════════════════════════════════════');
      print('🔐 Password length: ${passwordController.text.length} characters');
      print('🔐 Password (first char): ${passwordController.text.isNotEmpty ? passwordController.text[0] : "empty"}');
      print('🔐 Password (last char): ${passwordController.text.isNotEmpty ? passwordController.text[passwordController.text.length - 1] : "empty"}');

      // Trigger registration using the provider
      await ref.read(registerProvider(formData).future);

      // Show success message
      if (mounted) {
        SnackbarUtils.showSuccess(
          context,
          message: 'Registration successful! Please login to continue.',
        );

        // Navigate to login screen
        ref.read(authTabIndexProvider.notifier).state = 0;
      }
    } catch (e) {
      // Log the full error
      print('❌ REGISTRATION ERROR:');
      print('═══════════════════════════════════════════');
      print('Error type: ${e.runtimeType}');
      print('Error message: ${e.toString()}');
      print('Clean message: ${e.cleanMessage}');
      if (e is Exception) {
        print('Exception details: $e');
      }
      print('═══════════════════════════════════════════');
      
      // Show error message
      if (mounted) {
        SnackbarUtils.showError(
          context,
          message: 'Registration failed: ${e.cleanMessage}',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isRegistering = false;
        });
      }
    }
  }

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneNumberController.dispose();
    addressController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    placeOfBirthController.dispose();
    nationalityController.dispose();
    placeOfResidenceController.dispose();
    functionController.dispose();
    directionController.dispose();
    dateOfBirthDisplayController.dispose();
    dateOfFirstAccessionDisplayController.dispose();
    super.dispose();
  }
}
