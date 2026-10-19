import 'dart:async';

import 'package:cdcare_address_demo/core/errors/app_exception.dart';
import 'package:cdcare_address_demo/features/checkout/domain/models/delivery_address.dart';
import 'package:cdcare_address_demo/features/checkout/domain/repositories/address_repository.dart';

/// Available simulated failure scenarios for demonstration and testing.
enum MockAddressScenario {
  /// Simulates normal successful submission after a realistic delay.
  success,

  /// Simulates a slow server or sluggish network exceeding the client timeout.
  ///
  /// CRITICAL DISTRIBUTED SYSTEMS NOTE:
  /// A client-side timeout does not imply the server never saved the address;
  /// the packet might have reached the server, been committed to the database,
  /// and only the response was dropped or delayed.
  /// Production systems must use idempotency keys (e.g. `Idempotency-Key: <UUID>`)
  /// rather than blindly re-issuing mutating requests.
  timeout,

  /// Simulates immediate socket disconnect, DNS resolution failure, or offline state.
  networkFailure,

  /// Simulates a 500/503 HTTP internal server error.
  serverFailure,

  /// Simulates a transient error on the first attempt, followed by success on the next retry.
  failOnceThenSucceed,
}

/// A configurable mock implementation of [AddressRepository].
///
/// Enables seamless demonstration and unit testing of positive and negative
/// edge cases without contacting any external network or CDcare system.
class MockAddressRepository implements AddressRepository {
  MockAddressRepository({
    this.scenario = MockAddressScenario.success,
    this.simulatedDelay = const Duration(milliseconds: 650),
    this.simulatedTimeoutDelay = const Duration(seconds: 6),
  });

  /// The active scenario outcome.
  MockAddressScenario scenario;

  /// Artificial latency for non-timeout requests. Can be set to [Duration.zero] in unit tests.
  Duration simulatedDelay;

  /// Latency when simulating a timeout. Should exceed the client controller timeout.
  Duration simulatedTimeoutDelay;

  /// Internal count of failed attempts for [MockAddressScenario.failOnceThenSucceed].
  int failCount = 0;

  /// In-memory persistence for saved addresses.
  final List<DeliveryAddress> _addresses = [];

  List<DeliveryAddress> get savedAddresses => List.unmodifiable(_addresses);

  @override
  Future<List<DeliveryAddress>> getDeliveryAddresses() async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    return List.unmodifiable(_addresses);
  }

  @override
  Future<DeliveryAddress> getDeliveryAddressById(String id) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    return _addresses.firstWhere(
      (element) => element.id == id,
      orElse: () => throw ServerAppException('Address not found with id $id'),
    );
  }

  @override
  Future<void> saveDeliveryAddress(DeliveryAddress address) async {
    switch (scenario) {
      case MockAddressScenario.success:
        if (simulatedDelay > Duration.zero) {
          await Future<void>.delayed(simulatedDelay);
        }
        _upsert(address);
        break;

      case MockAddressScenario.timeout:
        // Delay beyond the client timeout duration to allow client-side timeout logic to trigger
        if (simulatedTimeoutDelay > Duration.zero) {
          await Future<void>.delayed(simulatedTimeoutDelay);
        }
        // If client timeout didn't abort (or wasn't configured), throw explicit TimeoutAppException
        throw const TimeoutAppException(
          'Simulated request timed out. The server did not respond within the allocated time window.',
        );

      case MockAddressScenario.networkFailure:
        if (simulatedDelay > Duration.zero) {
          await Future<void>.delayed(simulatedDelay);
        }
        throw const NetworkAppException(
          'Unable to reach address service due to a network error. Please check your data connection and retry.',
        );

      case MockAddressScenario.serverFailure:
        if (simulatedDelay > Duration.zero) {
          await Future<void>.delayed(simulatedDelay);
        }
        throw const ServerAppException(
          'Address service returned HTTP 500 (Internal Server Error). Please try again.',
        );

      case MockAddressScenario.failOnceThenSucceed:
        if (simulatedDelay > Duration.zero) {
          await Future<void>.delayed(simulatedDelay);
        }
        if (failCount == 0) {
          failCount++;
          throw const NetworkAppException(
            'Simulated transient failure on first attempt. Tap "Retry" to test recovery.',
          );
        } else {
          // Reset for future cycles and succeed
          failCount = 0;
          _upsert(address);
        }
        break;
    }
  }

  @override
  Future<void> updateDeliveryAddress(DeliveryAddress address) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    _upsert(address);
  }

  @override
  Future<void> deleteDeliveryAddress(DeliveryAddress address) async {
    if (simulatedDelay > Duration.zero) {
      await Future<void>.delayed(simulatedDelay);
    }
    _addresses.removeWhere((item) => item.id == address.id);
  }

  void _upsert(DeliveryAddress address) {
    final index = _addresses.indexWhere((element) => element.id == address.id);
    if (index >= 0) {
      _addresses[index] = address;
    } else {
      _addresses.add(address);
    }
  }

  /// Clears in-memory data and resets internal retry counters.
  void reset() {
    _addresses.clear();
    failCount = 0;
    scenario = MockAddressScenario.success;
  }
}
