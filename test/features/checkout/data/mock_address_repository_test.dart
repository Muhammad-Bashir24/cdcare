import 'package:cdcare_address_demo/core/errors/app_exception.dart';
import 'package:cdcare_address_demo/features/checkout/data/mock_address_repository.dart';
import 'package:cdcare_address_demo/features/checkout/domain/models/delivery_address.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const testAddress = DeliveryAddress(
    id: 'addr_101',
    recipientName: 'Muhammad Bashir',
    phoneNumber: '08012345678',
    state: 'Lagos',
    lga: 'Ikeja',
    town: 'Ikeja',
    streetAddress: '15 Allen Avenue, Ikeja',
  );

  group('MockAddressRepository', () {
    late MockAddressRepository repository;

    setUp(() {
      repository = MockAddressRepository(
        simulatedDelay: Duration.zero,
        simulatedTimeoutDelay: Duration.zero,
      );
    });

    test('saves address successfully when scenario is success', () async {
      repository.scenario = MockAddressScenario.success;

      await repository.saveDeliveryAddress(testAddress);

      final addresses = await repository.getDeliveryAddresses();
      expect(addresses.length, 1);
      expect(addresses.first, testAddress);
    });

    test(
      'throws NetworkAppException when scenario is networkFailure',
      () async {
        repository.scenario = MockAddressScenario.networkFailure;

        expect(
          () => repository.saveDeliveryAddress(testAddress),
          throwsA(isA<NetworkAppException>()),
        );
      },
    );

    test('throws ServerAppException when scenario is serverFailure', () async {
      repository.scenario = MockAddressScenario.serverFailure;

      expect(
        () => repository.saveDeliveryAddress(testAddress),
        throwsA(isA<ServerAppException>()),
      );
    });

    test('throws TimeoutAppException when scenario is timeout', () async {
      repository.scenario = MockAddressScenario.timeout;

      expect(
        () => repository.saveDeliveryAddress(testAddress),
        throwsA(isA<TimeoutAppException>()),
      );
    });

    test(
      'failOnceThenSucceed fails on first attempt and succeeds on second attempt',
      () async {
        repository.scenario = MockAddressScenario.failOnceThenSucceed;

        // First attempt: should throw transient failure
        expect(
          () => repository.saveDeliveryAddress(testAddress),
          throwsA(isA<NetworkAppException>()),
        );

        // Second attempt (retry): should succeed
        await repository.saveDeliveryAddress(testAddress);

        final addresses = await repository.getDeliveryAddresses();
        expect(addresses.length, 1);
        expect(addresses.first.id, testAddress.id);
      },
    );

    test('updates and deletes delivery addresses correctly', () async {
      repository.scenario = MockAddressScenario.success;
      await repository.saveDeliveryAddress(testAddress);

      final updated = testAddress.copyWith(
        recipientName: 'Muhammad B. Updated',
      );
      await repository.updateDeliveryAddress(updated);

      final fetched = await repository.getDeliveryAddressById(testAddress.id);
      expect(fetched.recipientName, 'Muhammad B. Updated');

      await repository.deleteDeliveryAddress(updated);
      final remaining = await repository.getDeliveryAddresses();
      expect(remaining.isEmpty, isTrue);
    });
  });
}
