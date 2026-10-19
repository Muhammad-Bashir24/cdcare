import 'package:cdcare_address_demo/core/theme/app_theme.dart';
import 'package:cdcare_address_demo/core/widgets/primary_button.dart';
import 'package:cdcare_address_demo/features/checkout/domain/models/delivery_address.dart';
import 'package:cdcare_address_demo/features/checkout/domain/models/product.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/screens/checkout_screen.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/screens/product_screen.dart';
import 'package:flutter/material.dart';

/// Screen displaying the saved delivery address for confirmation
/// prior to final checkout summary.
class AddressConfirmationScreen extends StatelessWidget {
  const AddressConfirmationScreen({
    super.key,
    required this.address,
    this.product = kDefaultSampleProduct,
  });

  final DeliveryAddress address;
  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Address')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Progress indicator (Step 2)
              _buildStepIndicator(currentStep: 2),
              const SizedBox(height: 20),

              // Success confirmation banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.successContainer,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppTheme.successGreen.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: AppTheme.successGreen,
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Address Saved Successfully',
                            style: TextStyle(
                              color: AppTheme.successGreen,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Your delivery address is validated and saved.',
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontSize: 12.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Saved Address Details Card
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderGrey),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Delivery Destination',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextButton.icon(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.edit_outlined, size: 16),
                          label: const Text('Edit'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.accentBlue,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    _addressRow(
                      Icons.person_outline,
                      'Recipient',
                      address.recipientName,
                    ),
                    _addressRow(
                      Icons.phone_outlined,
                      'Contact',
                      address.phoneNumber,
                    ),
                    _addressRow(
                      Icons.location_on_outlined,
                      'Street',
                      address.streetAddress,
                    ),
                    _addressRow(
                      Icons.location_city_outlined,
                      'LGA / City',
                      address.lga,
                    ),
                    _addressRow(
                      Icons.map_outlined,
                      'State',
                      '${address.state} State, Nigeria',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Installment reminder
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.accentBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Item will be dispatched to this address as scheduled in your installment plan.',
                        style: TextStyle(
                          color: AppTheme.textPrimary.withValues(alpha: 0.9),
                          fontSize: 12.5,
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Continue to summary button
              PrimaryButton(
                key: const Key('continue_to_summary_button'),
                label: 'Continue to Checkout Summary',
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) =>
                          CheckoutScreen(product: product, address: address),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _addressRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.accentBlue),
          const SizedBox(width: 10),
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({required int currentStep}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.borderGrey),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StepBadge(1, 'Address', isDone: true),
          _StepDivider(isDone: true),
          _StepBadge(2, 'Confirm', isActive: true),
          _StepDivider(isDone: false),
          _StepBadge(3, 'Summary', isPending: true),
        ],
      ),
    );
  }
}

class _StepBadge extends StatelessWidget {
  const _StepBadge(
    this.step,
    this.label, {
    this.isActive = false,
    this.isDone = false,
    this.isPending = false,
  });

  final int step;
  final String label;
  final bool isActive;
  final bool isDone;
  final bool isPending;

  @override
  Widget build(BuildContext context) {
    final color = isActive
        ? AppTheme.accentBlue
        : isDone
        ? AppTheme.successGreen
        : AppTheme.textMuted;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: isActive
                ? AppTheme.accentBlue
                : (isDone ? AppTheme.successGreen : Colors.transparent),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
          ),
          alignment: Alignment.center,
          child: isDone
              ? const Icon(Icons.check, size: 14, color: Colors.white)
              : Text(
                  '$step',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isActive ? Colors.white : color,
                  ),
                ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
            color: isActive ? AppTheme.primaryNavy : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _StepDivider extends StatelessWidget {
  const _StepDivider({required this.isDone});

  final bool isDone;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: isDone ? AppTheme.successGreen : AppTheme.borderGrey,
      ),
    );
  }
}
