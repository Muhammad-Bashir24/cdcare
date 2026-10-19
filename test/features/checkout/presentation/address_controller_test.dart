import 'package:cdcare_address_demo/core/errors/app_exception.dart';
import 'package:cdcare_address_demo/features/checkout/data/mock_address_repository.dart';
import 'package:cdcare_address_demo/features/checkout/domain/models/delivery_address.dart';
import 'package:cdcare_address_demo/features/checkout/presentation/controllers/address_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testAddress = DeliveryAddress(
    id: 'addr_201',
    recipientName: 'Muhammad Bashir',
    phoneNumber: '08012345678',
    state: 'Lagos',
    lga: 'Ikeja',
    town: 'Ikeja',
    streetAddress: 'Plot 4 Admiralty Way, Lekki',
  );

  group('AddressController Unit Tests', () {
    test('initial state is idle', () {
      final container = ProviderContainer(
        overrides: [
          addressRepositoryProvider.overrideWithValue(
            MockAddressRepository(simulatedDelay: Duration.zero),
          ),
        ],
      );
      addTearDown(container.dispose);

      final state = container.read(addressControllerProvider);
      expect(state.status, AddressSubmissionStatus.idle);
      expect(state.savedAddress, isNull);
      expect(state.lastAttemptedAddress, isNull);
      expect(state.errorMessage, isNull);
    });

    test(
      'successful submission updates state to success and sets savedAddress',
      () async {
        final repo = MockAddressRepository(
          scenario: MockAddressScenario.success,
          simulatedDelay: Duration.zero,
        );
        final container = ProviderContainer(
          overrides: [addressRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);

        final controller = container.read(addressControllerProvider.notifier);
        await controller.submitAddress(testAddress);

        final state = container.read(addressControllerProvider);
        expect(state.status, AddressSubmissionStatus.success);
        expect(state.savedAddress, testAddress);
        expect(state.lastAttemptedAddress, testAddress);
        expect(state.errorMessage, isNull);
      },
    );

    test(
      'prevents concurrent duplicate submissions while already submitting',
      () async {
        final repo = MockAddressRepository(
          scenario: MockAddressScenario.success,
          simulatedDelay: const Duration(milliseconds: 80),
        );
        final container = ProviderContainer(
          overrides: [addressRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);

        final controller = container.read(addressControllerProvider.notifier);

        // Trigger first submission (in flight)
        final firstSubmissionFuture = controller.submitAddress(testAddress);

        // Verify immediate state is submitting
        expect(container.read(addressControllerProvider).isSubmitting, isTrue);

        // Trigger second duplicate submission concurrently
        const duplicateAddress = DeliveryAddress(
          id: 'addr_999_duplicate',
          recipientName: 'Duplicate Attempt',
          phoneNumber: '08099999999',
          state: 'Ogun',
          lga: 'Abeokuta',
          town: 'Abeokuta',
          streetAddress: '99 Duplicate Lane',
        );
        await controller.submitAddress(duplicateAddress);

        // Wait for first submission to finish
        await firstSubmissionFuture;

        final state = container.read(addressControllerProvider);
        expect(state.status, AddressSubmissionStatus.success);
        // Ensure the second concurrent submission was ignored
        expect(state.savedAddress?.id, testAddress.id);
        expect(repo.savedAddresses.length, 1);
      },
    );

    test(
      'network failure transitions state to failure and preserves form address',
      () async {
        final repo = MockAddressRepository(
          scenario: MockAddressScenario.networkFailure,
          simulatedDelay: Duration.zero,
        );
        final container = ProviderContainer(
          overrides: [addressRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);

        final controller = container.read(addressControllerProvider.notifier);
        await controller.submitAddress(testAddress);

        final state = container.read(addressControllerProvider);
        expect(state.status, AddressSubmissionStatus.failure);
        expect(state.appException, isA<NetworkAppException>());
        expect(state.errorMessage, contains('network'));
        // Data preservation
        expect(state.lastAttemptedAddress, testAddress);
      },
    );

    test(
      'server failure transitions state to failure and preserves form address',
      () async {
        final repo = MockAddressRepository(
          scenario: MockAddressScenario.serverFailure,
          simulatedDelay: Duration.zero,
        );
        final container = ProviderContainer(
          overrides: [addressRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);

        final controller = container.read(addressControllerProvider.notifier);
        await controller.submitAddress(testAddress);

        final state = container.read(addressControllerProvider);
        expect(state.status, AddressSubmissionStatus.failure);
        expect(state.appException, isA<ServerAppException>());
        expect(state.errorMessage, contains('500'));
        expect(state.lastAttemptedAddress, testAddress);
      },
    );

    test('timeout triggers TimeoutAppException and failure state', () async {
      final repo = MockAddressRepository(
        scenario: MockAddressScenario.timeout,
        simulatedDelay: Duration.zero,
        simulatedTimeoutDelay: const Duration(milliseconds: 60),
      );
      final container = ProviderContainer(
        overrides: [
          addressRepositoryProvider.overrideWithValue(repo),
          // Set a short deterministic timeout of 20ms
          requestTimeoutProvider.overrideWithValue(
            const Duration(milliseconds: 20),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(addressControllerProvider.notifier);
      await controller.submitAddress(testAddress);

      final state = container.read(addressControllerProvider);
      expect(state.status, AddressSubmissionStatus.failure);
      expect(state.appException, isA<TimeoutAppException>());
      expect(state.errorMessage, contains('timed out'));
      expect(state.lastAttemptedAddress, testAddress);
    });

    test(
      'retry re-submits lastAttemptedAddress and recovers successfully',
      () async {
        final repo = MockAddressRepository(
          scenario: MockAddressScenario.failOnceThenSucceed,
          simulatedDelay: Duration.zero,
        );
        final container = ProviderContainer(
          overrides: [addressRepositoryProvider.overrideWithValue(repo)],
        );
        addTearDown(container.dispose);

        final controller = container.read(addressControllerProvider.notifier);

        // Initial attempt fails
        await controller.submitAddress(testAddress);
        expect(container.read(addressControllerProvider).isFailure, isTrue);
        expect(
          container.read(addressControllerProvider).lastAttemptedAddress,
          testAddress,
        );

        // Retry attempt succeeds
        await controller.retry();
        final recoveredState = container.read(addressControllerProvider);
        expect(recoveredState.isSuccess, isTrue);
        expect(recoveredState.savedAddress, testAddress);
      },
    );

    test('reset clears state back to idle', () async {
      final repo = MockAddressRepository(
        scenario: MockAddressScenario.success,
        simulatedDelay: Duration.zero,
      );
      final container = ProviderContainer(
        overrides: [addressRepositoryProvider.overrideWithValue(repo)],
      );
      addTearDown(container.dispose);

      final controller = container.read(addressControllerProvider.notifier);
      await controller.submitAddress(testAddress);
      expect(container.read(addressControllerProvider).isSuccess, isTrue);

      controller.reset();
      expect(container.read(addressControllerProvider).isIdle, isTrue);
      expect(container.read(addressControllerProvider).savedAddress, isNull);
    });
  });
}
