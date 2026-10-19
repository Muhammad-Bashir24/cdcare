import 'dart:async';

import 'package:cdcare_address_demo/core/errors/app_exception.dart';
import 'package:cdcare_address_demo/features/checkout/data/mock_address_repository.dart';
import 'package:cdcare_address_demo/features/checkout/domain/models/delivery_address.dart';
import 'package:cdcare_address_demo/features/checkout/domain/repositories/address_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Explicit status flags for address submission.
enum AddressSubmissionStatus { idle, submitting, success, failure }

/// Immutable state representing the address submission lifecycle.
class AddressSubmissionState {
  const AddressSubmissionState({
    this.status = AddressSubmissionStatus.idle,
    this.errorMessage,
    this.savedAddress,
    this.lastAttemptedAddress,
    this.appException,
  });

  const AddressSubmissionState.idle()
    : status = AddressSubmissionStatus.idle,
      errorMessage = null,
      savedAddress = null,
      lastAttemptedAddress = null,
      appException = null;

  final AddressSubmissionStatus status;
  final String? errorMessage;
  final DeliveryAddress? savedAddress;
  final DeliveryAddress? lastAttemptedAddress;
  final AppException? appException;

  bool get isIdle => status == AddressSubmissionStatus.idle;
  bool get isSubmitting => status == AddressSubmissionStatus.submitting;
  bool get isSuccess => status == AddressSubmissionStatus.success;
  bool get isFailure => status == AddressSubmissionStatus.failure;

  AddressSubmissionState copyWith({
    AddressSubmissionStatus? status,
    String? errorMessage,
    DeliveryAddress? savedAddress,
    DeliveryAddress? lastAttemptedAddress,
    AppException? appException,
    bool clearError = false,
  }) {
    return AddressSubmissionState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      savedAddress: savedAddress ?? this.savedAddress,
      lastAttemptedAddress: lastAttemptedAddress ?? this.lastAttemptedAddress,
      appException: clearError ? null : (appException ?? this.appException),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AddressSubmissionState &&
          runtimeType == other.runtimeType &&
          status == other.status &&
          errorMessage == other.errorMessage &&
          savedAddress == other.savedAddress &&
          lastAttemptedAddress == other.lastAttemptedAddress &&
          appException == other.appException;

  @override
  int get hashCode => Object.hash(
    status,
    errorMessage,
    savedAddress,
    lastAttemptedAddress,
    appException,
  );
}

/// Provider for the mock repository instance.
final addressRepositoryProvider = Provider<AddressRepository>((ref) {
  final repo = MockAddressRepository();
  ref.onDispose(() {
    repo.reset();
  });
  return repo;
});

/// Configurable request timeout provider (prototype default: 5 seconds).
final requestTimeoutProvider = Provider<Duration>((ref) {
  return const Duration(seconds: 5);
});

/// Riverpod Notifier for managing the interactive demo scenario.
class ScenarioNotifier extends Notifier<MockAddressScenario> {
  @override
  MockAddressScenario build() => MockAddressScenario.success;

  void selectScenario(MockAddressScenario scenario) {
    state = scenario;
    final repo = ref.read(addressRepositoryProvider);
    if (repo is MockAddressRepository) {
      repo.scenario = scenario;
      repo.failCount = 0;
    }
  }
}

final scenarioProvider =
    NotifierProvider<ScenarioNotifier, MockAddressScenario>(
      ScenarioNotifier.new,
    );

/// Controller managing address submission lifecycle, validation errors,
/// concurrency deduplication, timeouts, and retries.
class AddressController extends Notifier<AddressSubmissionState> {
  @override
  AddressSubmissionState build() {
    return const AddressSubmissionState.idle();
  }

  /// Submits the given [address] to the repository.
  ///
  /// Concurrency Guard:
  /// Discards invocation if a submission is already in progress.
  Future<void> submitAddress(DeliveryAddress address) async {
    // Prevent duplicate concurrent submissions
    if (state.isSubmitting) {
      return;
    }

    final repository = ref.read(addressRepositoryProvider);
    final timeoutDuration = ref.read(requestTimeoutProvider);

    state = state.copyWith(
      status: AddressSubmissionStatus.submitting,
      lastAttemptedAddress: address,
      clearError: true,
    );

    try {
      final repoFuture = repository.saveDeliveryAddress(address);
      // Guard against late-arriving repository errors after client timeout has fired
      unawaited(repoFuture.catchError((Object _) {}));

      await repoFuture.timeout(
        timeoutDuration,
        onTimeout: () => throw const TimeoutAppException(
          'The address submission timed out. The server took longer than expected to respond.',
        ),
      );

      state = state.copyWith(
        status: AddressSubmissionStatus.success,
        savedAddress: address,
        lastAttemptedAddress: address,
        clearError: true,
      );
    } catch (error) {
      final AppException appException;
      if (error is AppException) {
        appException = error;
      } else if (error is TimeoutException) {
        appException = const TimeoutAppException();
      } else {
        appException = ServerAppException(error.toString());
      }

      state = state.copyWith(
        status: AddressSubmissionStatus.failure,
        errorMessage: appException.message,
        appException: appException,
        lastAttemptedAddress: address,
      );
    }
  }

  /// Retries submitting the last attempted address without losing input data.
  Future<void> retry() async {
    final lastAddress = state.lastAttemptedAddress;
    if (lastAddress != null) {
      await submitAddress(lastAddress);
    }
  }

  /// Clears any lingering errors while keeping form data intact.
  void clearError() {
    if (state.isFailure) {
      state = state.copyWith(
        status: AddressSubmissionStatus.idle,
        clearError: true,
      );
    }
  }

  /// Resets state completely.
  void reset() {
    state = const AddressSubmissionState.idle();
  }
}

/// Provider exposing [AddressController].
final addressControllerProvider =
    NotifierProvider<AddressController, AddressSubmissionState>(
      AddressController.new,
    );
