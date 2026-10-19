import 'package:cdcare_address_demo/core/theme/app_theme.dart';
import 'package:cdcare_address_demo/core/widgets/primary_button.dart';
import 'package:cdcare_address_demo/features/checkout/domain/models/product.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/screens/address_screen.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/widgets/order_summary.dart';
import 'package:flutter/material.dart';

/// Default realistic sample electronics product on installment.
const Product kDefaultSampleProduct = Product(
  name: 'Samsung 55" Crystal 4K UHD Smart TV (AU7000)',
  price: 540000.0,
  installmentAmount: 90000.0,
  installmentDurationMonths: 6,
);

/// Landing screen presenting the sample product with its fictional installment plan.
class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key, this.product = kDefaultSampleProduct});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Checkout Prototype'),
        actions: [
          IconButton(
            tooltip: 'About Demo',
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showAboutDialog(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Disclaimer Notice
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.lightBlue,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.accentBlue.withValues(alpha: 0.25),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      size: 18,
                      color: AppTheme.primaryNavy,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Reliable Address Checkout Prototype (Simulated)',
                        style: TextStyle(
                          color: AppTheme.primaryNavy,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Product & Installment Summary Card
              OrderSummaryCard(product: product),
              const SizedBox(height: 16),

              // Product Key Specifications Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.borderGrey),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Product Highlights',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _specRow(
                      Icons.hd_outlined,
                      'Display',
                      '55-inch Ultra HD 4K (3840 x 2160)',
                    ),
                    _specRow(
                      Icons.smart_display_outlined,
                      'Smart Platform',
                      'Tizen OS with Netflix, YouTube, Prime',
                    ),
                    _specRow(
                      Icons.local_shipping_outlined,
                      'Delivery Guarantee',
                      'Doorstep delivery upon 50% payment',
                    ),
                    _specRow(
                      Icons.verified_outlined,
                      'Warranty',
                      '2-Year Official Manufacturer Warranty',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Prototype Context Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F4F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why this prototype?',
                      style: TextStyle(
                        color: AppTheme.primaryNavy,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Addresses an observed issue where address submission loaded indefinitely. This implementation introduces deterministic state machines, configurable timeouts, and graceful retry recovery.',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Proceed Button
              PrimaryButton(
                key: const Key('proceed_to_address_button'),
                label: 'Proceed to Delivery Address',
                icon: const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (context) => AddressScreen(product: product),
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

  Widget _specRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: AppTheme.accentBlue),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.textPrimary,
                ),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(
                    text: value,
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('CDcare-Inspired Prototype'),
        content: const Text(
          'This is an independent technical demonstration exploring reliable address submission and state handling in Flutter. It does not connect to CDcare servers and does not process real payments.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
