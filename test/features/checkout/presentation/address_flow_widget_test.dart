import 'package:cdcare_address_demo/core/theme/app_theme.dart';
import 'package:cdcare_address_demo/features/checkout/data/mock_address_repository.dart';
import 'package:cdcare_address_demo/features/checkout/domain/models/product.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/controllers/address_controller.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/screens/address_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testProduct = Product(
    name: 'Samsung 55" Crystal UHD 4K Smart TV',
    price: 540000.0,
    installmentAmount: 90000.0,
    installmentDurationMonths: 6,
  );

  Widget createTestWidget({
    required MockAddressRepository repository,
    Duration requestTimeout = const Duration(seconds: 5),
  }) {
    return ProviderScope(
      overrides: [
        addressRepositoryProvider.overrideWithValue(repository),
        requestTimeoutProvider.overrideWithValue(requestTimeout),
      ],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        home: const AddressScreen(product: testProduct),
      ),
    );
  }

  group('AddressScreen & Flow Widget Tests', () {
    testWidgets('shows validation errors when submitting empty form', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = MockAddressRepository(simulatedDelay: Duration.zero);

      await tester.pumpWidget(createTestWidget(repository: repo));
      await tester.pumpAndSettle();

      // Tap Save & Continue with empty fields
      final submitButton = find.byKey(const Key('save_address_button'));
      expect(submitButton, findsOneWidget);
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // Check validation error texts
      expect(find.text('Recipient name is required'), findsOneWidget);
      expect(find.text('Phone number is required'), findsOneWidget);
      expect(find.text('Please select a state'), findsOneWidget);
      expect(find.text('LGA / City / Town is required'), findsOneWidget);
      expect(find.text('Street address is required'), findsOneWidget);
    });

    testWidgets(
      'submitting valid form shows loading state and disables button',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final repo = MockAddressRepository(
          scenario: MockAddressScenario.success,
          simulatedDelay: const Duration(milliseconds: 300),
        );

        await tester.pumpWidget(createTestWidget(repository: repo));
        await tester.pumpAndSettle();

        // Fill in valid details
        await tester.enterText(
          find.byKey(const Key('recipient_name_field')),
          'Muhammad Bashir',
        );
        await tester.enterText(
          find.byKey(const Key('phone_number_field')),
          '08012345678',
        );

        // Select State (Abuja FCT is near the top of the list)
        await tester.tap(find.byKey(const Key('state_field')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Abuja (FCT)').last);
        await tester.pumpAndSettle();

        // Fill LGA and Street
        await tester.enterText(find.byKey(const Key('lga_field')), 'Ikeja');
        await tester.enterText(
          find.byKey(const Key('street_address_field')),
          '10 Allen Avenue, Ikeja',
        );

        // Tap submit
        final submitButton = find.byKey(const Key('save_address_button'));
        await tester.ensureVisible(submitButton);
        await tester.tap(submitButton);
        await tester.pump(); // Start frame

        // Expect loading spinner in button and submitting message in status view
        expect(find.byType(CircularProgressIndicator), findsWidgets);
        expect(
          find.text('Saving delivery address securely...'),
          findsOneWidget,
        );

        // Verify submit button is disabled while submitting
        final elevatedButton = tester.widget<ElevatedButton>(
          find.descendant(
            of: submitButton,
            matching: find.byType(ElevatedButton),
          ),
        );
        expect(elevatedButton.onPressed, isNull);

        // Advance time for simulatedDelay to complete
        await tester.pump(const Duration(milliseconds: 350));
        await tester.pumpAndSettle();
      },
    );

    testWidgets(
      'network failure displays error banner, preserves form data, and retry recovers',
      (WidgetTester tester) async {
        tester.view.physicalSize = const Size(800, 1400);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final repo = MockAddressRepository(
          scenario: MockAddressScenario.failOnceThenSucceed,
          simulatedDelay: Duration.zero,
        );

        await tester.pumpWidget(createTestWidget(repository: repo));
        await tester.pumpAndSettle();

        // Enter data
        await tester.enterText(
          find.byKey(const Key('recipient_name_field')),
          'Muhammad Bashir',
        );
        await tester.enterText(
          find.byKey(const Key('phone_number_field')),
          '08012345678',
        );

        // Select State
        await tester.tap(find.byKey(const Key('state_field')));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Abuja (FCT)').last);
        await tester.pumpAndSettle();

        await tester.enterText(find.byKey(const Key('lga_field')), 'Ikeja');
        await tester.enterText(
          find.byKey(const Key('street_address_field')),
          '10 Allen Avenue, Ikeja',
        );

        // Submit first attempt (fails)
        final submitButton = find.byKey(const Key('save_address_button'));
        await tester.ensureVisible(submitButton);
        await tester.tap(submitButton);
        await tester.pumpAndSettle();

        // Error banner and retry button should be visible
        expect(find.text('Address Submission Failed'), findsOneWidget);
        expect(find.text('Retry Submission'), findsOneWidget);

        // Verify form data was preserved in the fields
        expect(find.text('Muhammad Bashir'), findsOneWidget);
        expect(find.text('08012345678'), findsOneWidget);
        expect(find.text('10 Allen Avenue, Ikeja'), findsOneWidget);

        // Tap Retry Submission (should succeed and navigate to confirmation screen)
        await tester.tap(find.text('Retry Submission'));
        await tester.pumpAndSettle();

        // Verify navigation to confirmation screen
        expect(find.text('Confirm Address'), findsOneWidget);
        expect(find.text('Address Saved Successfully'), findsOneWidget);
        expect(find.text('Muhammad Bashir'), findsOneWidget);
      },
    );

    testWidgets('complete end-to-end flow from address to checkout summary', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final repo = MockAddressRepository(
        scenario: MockAddressScenario.success,
        simulatedDelay: Duration.zero,
      );

      await tester.pumpWidget(createTestWidget(repository: repo));
      await tester.pumpAndSettle();

      // Fill in details
      await tester.enterText(
        find.byKey(const Key('recipient_name_field')),
        'Chidi Okafor',
      );
      await tester.enterText(
        find.byKey(const Key('phone_number_field')),
        '+2348031234567',
      );

      // Select State
      await tester.tap(find.byKey(const Key('state_field')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Abuja (FCT)').last);
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('lga_field')), 'Garki');
      await tester.enterText(
        find.byKey(const Key('street_address_field')),
        'Plot 25 Ahmadu Bello Way',
      );

      // Submit
      final submitButton = find.byKey(const Key('save_address_button'));
      await tester.ensureVisible(submitButton);
      await tester.tap(submitButton);
      await tester.pumpAndSettle();

      // AddressConfirmationScreen
      expect(find.text('Confirm Address'), findsOneWidget);
      expect(find.text('Chidi Okafor'), findsOneWidget);
      expect(find.text('Abuja (FCT) State, Nigeria'), findsOneWidget);

      // Tap Continue to Checkout Summary
      final continueButton = find.byKey(
        const Key('continue_to_summary_button'),
      );
      expect(continueButton, findsOneWidget);
      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      // CheckoutScreen
      expect(find.text('Checkout Summary'), findsOneWidget);
      expect(find.text('Confirmed Delivery Address'), findsOneWidget);
      expect(find.text('Simulated Installment Schedule'), findsOneWidget);

      // Tap Complete Order (Simulated)
      final completeButton = find.byKey(
        const Key('complete_simulated_order_button'),
      );
      expect(completeButton, findsOneWidget);
      await tester.ensureVisible(completeButton);
      await tester.tap(completeButton);
      await tester.pumpAndSettle();

      // Completion dialog
      expect(find.text('Prototype Finished'), findsOneWidget);
      expect(find.text('Restart Demo'), findsOneWidget);
    });
  });
}
