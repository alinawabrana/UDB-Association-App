import 'dart:async';
import 'dart:io';

typedef RetryWhen = bool Function(Object error);

Future<T> retry<T>(
  Future<T> Function() task, {
  int maxAttempts = 3,
  Duration initialDelay = const Duration(milliseconds: 400),
  double backoffFactor = 2.0,
  Duration? maxDelay,
  RetryWhen? shouldRetry,
}) async {
  assert(maxAttempts > 0, 'maxAttempts must be > 0');

  Duration delay = initialDelay;
  for (int attempt = 1; attempt <= maxAttempts; attempt++) {
    try {
      return await task();
    } catch (error) {
      final bool defaultRetryable =
          error is SocketException || error is TimeoutException;
      final bool retryable = shouldRetry != null
          ? shouldRetry(error)
          : defaultRetryable;

      final bool isLastAttempt = attempt == maxAttempts;
      if (!retryable || isLastAttempt) rethrow;

      // Exponential backoff with optional max cap
      final Duration capped = maxDelay != null && delay > maxDelay
          ? maxDelay
          : delay;
      await Future.delayed(capped);
      delay = Duration(
        milliseconds: (delay.inMilliseconds * backoffFactor).toInt(),
      );
    }
  }

  // Should never reach here
  // ignore: only_throw_errors
  throw Exception('Retry failed after $maxAttempts attempts');
}
