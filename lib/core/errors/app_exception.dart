/// Core application exception hierarchy for reliable error handling.
///
/// Designed to categorize errors cleanly so presentation layers can present
/// helpful, actionable feedback to users.
sealed class AppException implements Exception {
  const AppException(this.message, [this.cause]);

  final String message;
  final Object? cause;

  @override
  String toString() => message;
}

/// Thrown when a network failure occurs (e.g., DNS failure, offline socket, unreachable host).
class NetworkAppException extends AppException {
  const NetworkAppException([
    super.message =
        'Unable to connect to the server. Please check your internet connection and try again.',
    super.cause,
  ]);
}

/// Thrown when a request exceeds the configured client timeout duration.
///
/// NOTE: In distributed systems, a client-side timeout does not guarantee that
/// the server failed to receive or process the request. Production systems should
/// use idempotency keys before retrying mutating requests.
class TimeoutAppException extends AppException {
  const TimeoutAppException([
    super.message =
        'The address submission timed out. Please check your network and retry.',
    super.cause,
  ]);
}

/// Thrown when the remote server returns a 5xx error or internal failure.
class ServerAppException extends AppException {
  const ServerAppException([
    super.message =
        'A temporary server error occurred. Our team has been notified. Please try again.',
    super.cause,
  ]);
}

/// Thrown when client-side data validation fails before or during repository handling.
class ValidationAppException extends AppException {
  const ValidationAppException([
    super.message =
        'Please check the information entered and correct any errors.',
    super.cause,
  ]);
}
