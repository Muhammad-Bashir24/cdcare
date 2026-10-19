import 'package:cdcare_address_demo/core/theme/app_theme.dart';
import 'package:cdcare_address_demo/features/checkout/data/mock_address_repository.dart';
import 'package:cdcare_address_demo/features/checkout/domain/models/delivery_address.dart';
import 'package:cdcare_address_demo/features/checkout/domain/models/product.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/controllers/address_controller.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/screens/address_confirmation_screen.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/screens/product_screen.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/widgets/address_form.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/widgets/submission_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Screen allowing the user to input and submit delivery address.
/// Includes an interactive Demo Scenario Switcher for reviewers.
class AddressScreen extends ConsumerWidget {
  const AddressScreen({
    super.key,
    this.product = kDefaultSampleProduct,
    this.initialAddress,
  });

  final Product product;
  final DeliveryAddress? initialAddress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for successful address submission to trigger navigation
    ref.listen<AddressSubmissionState>(addressControllerProvider, (
      previous,
      next,
    ) {
      if (previous?.status != AddressSubmissionStatus.success &&
          next.isSuccess &&
          next.savedAddress != null) {
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (context) => AddressConfirmationScreen(
              product: product,
              address: next.savedAddress!,
            ),
          ),
        );
      }
    });

    final selectedScenario = ref.watch(scenarioProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Address'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            ref.read(addressControllerProvider.notifier).clearError();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Step Progress Tracker
              _buildStepIndicator(currentStep: 1),
              const SizedBox(height: 16),

              // Interactive Demo Scenario Controller
              _buildDemoScenarioCard(context, ref, selectedScenario),
              const SizedBox(height: 16),

              // Dynamic Submission Status Banner (submitting, error with retry)
              const SubmissionStatusView(),

              // Address Input Form
              AddressForm(initialAddress: initialAddress),
              const SizedBox(height: 24),
            ],
          ),
        ),
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _stepItem(
            1,
            'Address',
            isActive: currentStep == 1,
            isDone: currentStep > 1,
          ),
          _stepDivider(currentStep > 1),
          _stepItem(
            2,
            'Confirm',
            isActive: currentStep == 2,
            isDone: currentStep > 2,
          ),
          _stepDivider(currentStep > 2),
          _stepItem(
            3,
            'Summary',
            isActive: currentStep == 3,
            isDone: currentStep > 3,
          ),
        ],
      ),
    );
  }

  Widget _stepItem(
    int step,
    String label, {
    required bool isActive,
    required bool isDone,
  }) {
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

  Widget _stepDivider(bool completed) {
    return Expanded(
      child: Container(
        height: 1.5,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        color: completed ? AppTheme.successGreen : AppTheme.borderGrey,
      ),
    );
  }

  Widget _buildDemoScenarioCard(
    BuildContext context,
    WidgetRef ref,
    MockAddressScenario currentScenario,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.3)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune_rounded, size: 17, color: AppTheme.accentBlue),
              SizedBox(width: 6),
              Text(
                'Demo-Only: Mock Scenario Simulator',
                style: TextStyle(
                  color: AppTheme.primaryNavy,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Select a failure or timeout outcome to observe how the app responds and recovers:',
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11.5),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<MockAddressScenario>(
            key: const Key('demo_scenario_dropdown'),
            initialValue: currentScenario,
            isDense: true,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppTheme.borderGrey),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: const BorderSide(color: AppTheme.borderGrey),
              ),
            ),
            items: const [
              DropdownMenuItem(
                value: MockAddressScenario.success,
                child: Text(
                  '1. Success (Normal 650ms)',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              DropdownMenuItem(
                value: MockAddressScenario.timeout,
                child: Text(
                  '2. Client Timeout (Exceeds 5s)',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              DropdownMenuItem(
                value: MockAddressScenario.networkFailure,
                child: Text(
                  '3. Network Failure (Offline / DNS)',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              DropdownMenuItem(
                value: MockAddressScenario.serverFailure,
                child: Text(
                  '4. Server Failure (HTTP 500)',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              DropdownMenuItem(
                value: MockAddressScenario.failOnceThenSucceed,
                child: Text(
                  '5. Fail Once, Then Succeed (Retry Test)',
                  style: TextStyle(fontSize: 13),
                ),
              ),
            ],
            onChanged: (scenario) {
              if (scenario != null) {
                ref.read(scenarioProvider.notifier).selectScenario(scenario);
              }
            },
          ),
        ],
      ),
    );
  }
}
