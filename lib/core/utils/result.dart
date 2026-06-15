/// A lightweight functional result type used by the service layer so callers can
/// handle success and failure without exceptions leaking through the app.
sealed class Result<T> {
  const Result();

  /// Returns `true` when this is a [Success].
  bool get isSuccess => this is Success<T>;

  /// The value if successful, otherwise `null`.
  T? get valueOrNull => switch (this) {
        Success<T>(:final T value) => value,
        Failure<T>() => null,
      };

  /// Folds both branches into a single value.
  R when<R>({
    required R Function(T value) success,
    required R Function(String message, Object? error) failure,
  }) {
    return switch (this) {
      Success<T>(:final T value) => success(value),
      Failure<T>(:final String message, :final Object? error) =>
        failure(message, error),
    };
  }
}

/// Successful result carrying a [value].
final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

/// Failed result carrying a human-readable [message] and optional [error].
final class Failure<T> extends Result<T> {
  const Failure(this.message, [this.error]);
  final String message;
  final Object? error;
}
