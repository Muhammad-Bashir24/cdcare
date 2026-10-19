import 'package:cdcare_address_demo/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CdcareAddressDemoApp boots and renders ProductScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const ProviderScope(child: CdcareAddressDemoApp()));

    // Verify app bar title
    expect(find.text('Checkout Prototype'), findsOneWidget);

    // Verify sample product name is shown
    expect(
      find.text('Samsung 55" Crystal 4K UHD Smart TV (AU7000)'),
      findsOneWidget,
    );

    // Verify Proceed to Delivery Address button exists
    final proceedButton = find.byKey(const Key('proceed_to_address_button'));
    expect(proceedButton, findsOneWidget);
  });
}
