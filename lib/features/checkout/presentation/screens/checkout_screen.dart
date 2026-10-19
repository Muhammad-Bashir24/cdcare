import 'package:cdcare_address_demo/core/theme/app_theme.dart';
import 'package:cdcare_address_demo/core/widgets/primary_button.dart';
import 'package:cdcare_address_demo/features/checkout/domain/models/delivery_address.dart';
import 'package:cdcare_address_demo/features/checkout/domain/models/product.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/controllers/address_controller.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/screens/product_screen.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/widgets/order_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen presenting the final checkout summary, simulated payment schedule,
/// and verified delivery destination.
class CheckoutScreen extends ConsumerWidget {
  const CheckoutScreen({
    super.key,
    required this.product,
    required this.address,
  });

  final Product product;
  final DeliveryAddress address;

  String _formatNaira(double amount) {
    final rounded = amount.toInt();
    final parts = rounded.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
    return '₦$parts';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Summary')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step 3 progress
              _buildStepIndicator(currentStep: 3),
              const SizedBox(height: 16),

              // Product & Installment Plan Card
              OrderSummaryCard(product: product, compact: true),
              const SizedBox(height: 16),

              // Confirmed Delivery Destination Card
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
                    const Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: AppTheme.accentBlue,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Confirmed Delivery Address',
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Text(
                      address.recipientName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${address.streetAddress}, ${address.lga}, ${address.state} State',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tel: ${address.phoneNumber}',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Installment Breakdown Schedule
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
                    const Text(
                      'Simulated Installment Schedule',
                      style: TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(product.installmentDurationMonths, (
                      index,
                    ) {
                      final monthNumber = index + 1;
                      final isFirst = monthNumber == 1;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Month $monthNumber ${isFirst ? '(Initial Deposit)' : ''}',
                              style: TextStyle(
                                fontSize: 13,
                                color: isFirst
                                    ? AppTheme.primaryNavy
                                    : AppTheme.textSecondary,
                                fontWeight: isFirst
                                    ? FontWeight.w600
                                    : FontWeight.w400,
                              ),
                            ),
                            Text(
                              _formatNaira(product.installmentAmount),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isFirst
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isFirst
                                    ? AppTheme.accentBlue
                                    : AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Payable',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        Text(
                          _formatNaira(product.price),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primaryNavy,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Simulation notice banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.warningContainer.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.warningAmber.withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: AppTheme.warningAmber,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Simulated Checkout: No money will be deducted and no actual delivery will occur.',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Confirm button
              PrimaryButton(
                key: const Key('complete_simulated_order_button'),
                label: 'Complete Order (Simulated)',
                icon: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: () => _showOrderCompletedDialog(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderCompletedDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.task_alt_rounded,
              color: AppTheme.successGreen,
              size: 28,
            ),
            SizedBox(width: 10),
            Text(
              'Prototype Finished',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Address saved reliably and simulated checkout complete!',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            SizedBox(height: 8),
            Text(
              'The prototype demonstrated:\n'
              '• Validation of recipient name, phone, and Nigerian address\n'
              '• Explicit idle, submitting, success, and failure states\n'
              '• Duplicate submission prevention\n'
              '• Configurable request timeout & retry mechanics\n'
              '• Preserved form inputs upon recovery',
              style: TextStyle(
                fontSize: 12.5,
                height: 1.4,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              ref.read(addressControllerProvider.notifier).reset();
              Navigator.of(dialogContext).pop();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (context) => ProductScreen(product: product),
                ),
                (route) => false,
              );
            },
            child: const Text('Restart Demo'),
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
          _StepBadge(2, 'Confirm', isDone: true),
          _StepDivider(isDone: true),
          _StepBadge(3, 'Summary', isActive: true),
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
  });

  final int step;
  final String label;
  final bool isActive;
  final bool isDone;

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
