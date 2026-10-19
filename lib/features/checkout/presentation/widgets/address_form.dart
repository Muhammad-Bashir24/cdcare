import 'package:cdcare_address_demo/core/widgets/primary_button.dart';
import 'package:cdcare_address_demo/features/checkout/domain/models/delivery_address.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/controllers/address_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Available Nigerian states for selection.
const List<String> kNigerianStates = [
  'Abia',
  'Abuja (FCT)',
  'Adamawa',
  'Akwa Ibom',
  'Anambra',
  'Bauchi',
  'Bayelsa',
  'Benue',
  'Borno',
  'Cross River',
  'Delta',
  'Ebonyi',
  'Edo',
  'Ekiti',
  'Enugu',
  'Gombe',
  'Imo',
  'Jigawa',
  'Kaduna',
  'Kano',
  'Katsina',
  'Kebbi',
  'Kogi',
  'Kwara',
  'Lagos',
  'Nasarawa',
  'Niger',
  'Ogun',
  'Ondo',
  'Osun',
  'Oyo',
  'Plateau',
  'Rivers',
  'Sokoto',
  'Taraba',
  'Yobe',
  'Zamfara',
];

/// Form for capturing, validating, and submitting Nigerian delivery addresses.
class AddressForm extends ConsumerStatefulWidget {
  const AddressForm({super.key, this.initialAddress, this.onSubmitSuccess});

  final DeliveryAddress? initialAddress;
  final VoidCallback? onSubmitSuccess;

  static String? validateRecipientName(String? value) =>
      AddressValidator.validateRecipientName(value);

  static String? validatePhoneNumber(String? value) =>
      AddressValidator.validatePhoneNumber(value);

  static String? validateState(String? value) =>
      AddressValidator.validateState(value);

  static String? validateLga(String? value) =>
      AddressValidator.validateLga(value);

  static String? validateStreetAddress(String? value) =>
      AddressValidator.validateStreetAddress(value);

  @override
  ConsumerState<AddressForm> createState() => _AddressFormState();
}

/// Standalone validation logic for Nigerian delivery address forms.
class AddressValidator {
  AddressValidator._();

  static String? validateRecipientName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Recipient name is required';
    }
    if (value.trim().length < 3) {
      return 'Name must be at least 3 characters';
    }
    return null;
  }

  /// Validates a Nigerian phone number.
  /// Accepts formats:
  /// - 08012345678 (11 digits starting with 070, 080, 081, 090, 091, etc.)
  /// - +2348012345678 (country code + 10 digits)
  /// - 2348012345678
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    final cleaned = value.replaceAll(RegExp(r'\s+'), '');
    final phoneRegex = RegExp(r'^(?:\+?234|0)[789][01]\d{8}$');
    if (!phoneRegex.hasMatch(cleaned)) {
      return 'Enter a valid Nigerian phone number (e.g. 08012345678)';
    }
    return null;
  }

  static String? validateState(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a state';
    }
    return null;
  }

  static String? validateLga(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'LGA / City / Town is required';
    }
    if (value.trim().length < 2) {
      return 'Please enter a valid LGA or town';
    }
    return null;
  }

  static String? validateStreetAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Street address is required';
    }
    if (value.trim().length < 5) {
      return 'Please enter full street address with house number';
    }
    return null;
  }
}

class _AddressFormState extends ConsumerState<AddressForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _lgaController;
  late final TextEditingController _streetController;

  String? _selectedState;

  void initStateWarmup(DeliveryAddress? address) {
    _nameController = TextEditingController(text: address?.recipientName ?? '');
    _phoneController = TextEditingController(text: address?.phoneNumber ?? '');
    _lgaController = TextEditingController(
      text: address?.lga ?? address?.town ?? '',
    );
    _streetController = TextEditingController(
      text: address?.streetAddress ?? '',
    );
    _selectedState = address?.state;
    if (_selectedState != null && !kNigerianStates.contains(_selectedState)) {
      _selectedState = null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Prefer last attempted address if available, falling back to initialAddress
    final lastAttempt = ref
        .read(addressControllerProvider)
        .lastAttemptedAddress;
    initStateWarmup(lastAttempt ?? widget.initialAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _lgaController.dispose();
    _streetController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final address = DeliveryAddress(
      id:
          widget.initialAddress?.id ??
          'addr_${DateTime.now().millisecondsSinceEpoch}',
      recipientName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      state: _selectedState!,
      lga: _lgaController.text.trim(),
      town: _lgaController.text.trim(),
      streetAddress: _streetController.text.trim(),
    );

    ref.read(addressControllerProvider.notifier).submitAddress(address);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addressControllerProvider);
    final isSubmitting = state.isSubmitting;

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Recipient Full Name
          TextFormField(
            key: const Key('recipient_name_field'),
            controller: _nameController,
            enabled: !isSubmitting,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Recipient Full Name *',
              hintText: 'e.g. Muhammad Bashir',
              prefixIcon: Icon(Icons.person_outline_rounded, size: 20),
            ),
            validator: AddressValidator.validateRecipientName,
          ),
          const SizedBox(height: 16),

          // Phone Number
          TextFormField(
            key: const Key('phone_number_field'),
            controller: _phoneController,
            enabled: !isSubmitting,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'Nigerian Phone Number *',
              hintText: 'e.g. 08012345678 or +234...',
              prefixIcon: Icon(Icons.phone_outlined, size: 20),
              helperText: 'We will send delivery notifications to this number',
            ),
            validator: AddressValidator.validatePhoneNumber,
          ),
          const SizedBox(height: 16),

          // State Dropdown
          DropdownButtonFormField<String>(
            key: const Key('state_field'),
            initialValue: _selectedState,
            decoration: const InputDecoration(
              labelText: 'State *',
              hintText: 'Select delivery state',
              prefixIcon: Icon(Icons.map_outlined, size: 20),
            ),
            items: kNigerianStates.map((stateName) {
              return DropdownMenuItem<String>(
                value: stateName,
                child: Text(stateName),
              );
            }).toList(),
            onChanged: isSubmitting
                ? null
                : (val) {
                    setState(() {
                      _selectedState = val;
                    });
                  },
            validator: AddressValidator.validateState,
          ),
          const SizedBox(height: 16),

          // LGA / Town / City
          TextFormField(
            key: const Key('lga_field'),
            controller: _lgaController,
            enabled: !isSubmitting,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: const InputDecoration(
              labelText: 'LGA / Town / City *',
              hintText: 'e.g. Ikeja, Lekki, or Ibadan North',
              prefixIcon: Icon(Icons.location_city_outlined, size: 20),
            ),
            validator: AddressValidator.validateLga,
          ),
          const SizedBox(height: 16),

          // Detailed Street Address
          TextFormField(
            key: const Key('street_address_field'),
            controller: _streetController,
            enabled: !isSubmitting,
            maxLines: 2,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Detailed Street Address *',
              hintText:
                  'e.g. Flat 4B, Plot 15 Admiralty Way, off Lekki Phase 1',
              prefixIcon: Icon(Icons.home_outlined, size: 20),
              alignLabelWithHint: true,
            ),
            validator: AddressValidator.validateStreetAddress,
          ),
          const SizedBox(height: 24),

          // Save & Continue Button
          PrimaryButton(
            key: const Key('save_address_button'),
            label: isSubmitting ? 'Saving Address...' : 'Save & Continue',
            isLoading: isSubmitting,
            icon: const Icon(
              Icons.check_circle_outline,
              color: Colors.white,
              size: 20,
            ),
            onPressed: isSubmitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}
