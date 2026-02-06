import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:udb_association/src/features/subscription/providers/billing_form_provider.dart';
import 'package:udb_association/utils/validators/form_validators.dart';
import 'package:udb_association/src/common/localization/app_localizations.dart';

class BillingInformationForm extends ConsumerStatefulWidget {
  const BillingInformationForm({super.key});

  @override
  ConsumerState<BillingInformationForm> createState() =>
      _BillingInformationFormState();
}

class _BillingInformationFormState
    extends ConsumerState<BillingInformationForm> {
  late TextEditingController _billingAddressController;
  late TextEditingController _customerEmailController;
  late TextEditingController _customerNameController;
  late TextEditingController _phoneController;
  late TextEditingController _businessNameController;
  late TextEditingController _shopTaglineController;
  late TextEditingController _shopDetailController;

  bool _hasInitialized = false;

  @override
  void initState() {
    super.initState();
    _billingAddressController = TextEditingController();
    _customerEmailController = TextEditingController();
    _customerNameController = TextEditingController();
    _phoneController = TextEditingController();
    _businessNameController = TextEditingController();
    _shopTaglineController = TextEditingController();
    _shopDetailController = TextEditingController();
  }

  @override
  void dispose() {
    _billingAddressController.dispose();
    _customerEmailController.dispose();
    _customerNameController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _shopTaglineController.dispose();
    _shopDetailController.dispose();
    super.dispose();
  }

  void _initializeControllers(BillingFormState formState) {
    if (!_hasInitialized) {
      _billingAddressController.text = formState.billingAddress;
      _customerEmailController.text = formState.customerEmail;
      _customerNameController.text = formState.customerName;
      _phoneController.text = formState.phone;
      _businessNameController.text = formState.businessName;
      _shopTaglineController.text = formState.shopTagline;
      _shopDetailController.text = formState.shopDetail;
      _hasInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final formState = ref.watch(billingFormProvider);
    final formController = ref.read(billingFormProvider.notifier);

    // Initialize controllers only once when form state has data
    if (!_hasInitialized &&
        (formState.customerEmail.isNotEmpty ||
            formState.customerName.isNotEmpty)) {
      _initializeControllers(formState);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Billing Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF111827),
            ),
          ),
          const SizedBox(height: 16),

          // Same as user checkbox
          Row(
            children: [
              Checkbox(
                value: formState.isSameAsUser,
                onChanged: (value) {
                  formController.toggleSameAsUser(value ?? false);
                  // Reset initialization flag when checkbox changes
                  _hasInitialized = false;
                },
                visualDensity: VisualDensity.compact,
              ),
              const Expanded(
                child: Text(
                  'Use same information as user profile',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF374151),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Customer Name
          _buildFormField(
            label: 'Customer Name',
            controller: _customerNameController,
            onChanged: formController.updateCustomerName,
            validator: (value) =>
                AFormValidators.validateEmptyText(
              value,
              'Customer Name',
              l10n,
            ),
            enabled: !formState.isSameAsUser,
          ),
          const SizedBox(height: 16),

          // Customer Email
          _buildFormField(
            label: 'Customer Email',
            controller: _customerEmailController,
            onChanged: formController.updateCustomerEmail,
            validator: (value) =>
                AFormValidators.validateEmail(value, l10n),
            keyboardType: TextInputType.emailAddress,
            enabled: !formState.isSameAsUser,
          ),
          const SizedBox(height: 16),

          // Phone (Required)
          _buildFormField(
            label: 'Phone (Required)',
            controller: _phoneController,
            onChanged: formController.updatePhone,
            validator: (value) =>
                AFormValidators.validatePhoneNumber(
              value,
              l10n: l10n,
              isoCode: 'PK',
            ),
            keyboardType: TextInputType.phone,
            enabled: !formState.isSameAsUser,
          ),
          const SizedBox(height: 16),

          // Business Name (Required)
          _buildFormField(
            label: 'Business Name (Required)',
            controller: _businessNameController,
            onChanged: formController.updateBusinessName,
            validator: (value) =>
                AFormValidators.validateEmptyText(
              value,
              'Business Name',
              l10n,
            ),
            enabled: !formState.isSameAsUser,
          ),
          const SizedBox(height: 16),

          // Shop Tagline
          _buildFormField(
            label: 'Shop Tagline',
            controller: _shopTaglineController,
            onChanged: formController.updateShopTagline,
            enabled: !formState.isSameAsUser,
          ),
          const SizedBox(height: 16),

          // Shop Detail
          _buildFormField(
            label: 'Shop Detail',
            controller: _shopDetailController,
            onChanged: formController.updateShopDetail,
            maxLines: 3,
            enabled: !formState.isSameAsUser,
          ),
          const SizedBox(height: 16),

          // Address (Optional)
          _buildFormField(
            label: 'Address',
            controller: _billingAddressController,
            onChanged: formController.updateAddress,
            maxLines: 3,
            enabled: !formState.isSameAsUser,
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required Function(String) onChanged,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          validator: validator,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6B7C32), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
