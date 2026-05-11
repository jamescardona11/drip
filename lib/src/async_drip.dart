import 'drip_core.dart';

/// {@template async_state}
///
/// The state of an asynchronous computation owned by an [AsyncDrip].
///
/// Use Dart 3 pattern matching on the four cases:
///
/// ```dart
/// switch (state) {
///   AsyncIdle()                    => ...,
///   AsyncLoading(:final previous)  => ...,
///   AsyncData(:final value)        => ...,
///   AsyncError(:final error)       => ...,
/// }
/// ```
///
/// {@endtemplate}
sealed class AsyncState<T> {
  /// Subclasses initialise the case via `super()`; do not instantiate
  /// [AsyncState] directly.
  const AsyncState();

  /// Returns the last successful data value, or `null` if the current case
  /// is not [AsyncData]. For [AsyncLoading] this returns the [previous]
  /// data (if any).
  T? get dataOrNull => switch (this) {
        AsyncData<T>(:final value) => value,
        AsyncLoading<T>(:final previous) => previous,
        _ => null,
      };

  /// True when this is [AsyncLoading].
  bool get isLoading => this is AsyncLoading<T>;

  /// True when this is [AsyncData].
  bool get hasData => this is AsyncData<T>;

  /// True when this is [AsyncError].
  bool get hasError => this is AsyncError<T>;
}

/// The initial, untouched state of an [AsyncDrip].
final class AsyncIdle<T> extends AsyncState<T> {
  /// Creates an [AsyncIdle] case.
  const AsyncIdle();

  @override
  bool operator ==(Object other) => other is AsyncIdle<T>;

  @override
  int get hashCode => (AsyncIdle<T>).hashCode;

  @override
  String toString() => 'AsyncIdle<$T>()';
}

/// An asynchronous operation is in flight.
///
/// [previous] carries the last successful value (if any) so the UI can show
/// stale-while-revalidate placeholders without going back to a spinner.
final class AsyncLoading<T> extends AsyncState<T> {
  /// Creates an [AsyncLoading] case, optionally carrying the [previous]
  /// successful value.
  const AsyncLoading({this.previous});

  /// The last [AsyncData] value before this loading started, if any.
  final T? previous;

  @override
  bool operator ==(Object other) =>
      other is AsyncLoading<T> && other.previous == previous;

  @override
  int get hashCode => Object.hash(AsyncLoading<T>, previous);

  @override
  String toString() => 'AsyncLoading<$T>(previous: $previous)';
}

/// A successful result of an asynchronous operation.
final class AsyncData<T> extends AsyncState<T> {
  /// Creates an [AsyncData] case wrapping [value].
  const AsyncData(this.value);

  /// The successful value.
  final T value;

  @override
  bool operator ==(Object other) =>
      other is AsyncData<T> && other.value == value;

  @override
  int get hashCode => Object.hash(AsyncData<T>, value);

  @override
  String toString() => 'AsyncData<$T>($value)';
}

/// A failure case for an asynchronous operation.
///
/// Note: [stackTrace] is **not** part of equality, so two errors with the
/// same [error] object compare equal regardless of where they were thrown.
final class AsyncError<T> extends AsyncState<T> {
  /// Creates an [AsyncError] from an error object and optional stack trace.
  const AsyncError(this.error, [this.stackTrace]);

  /// The thrown error.
  final Object error;

  /// The stack trace captured at the throw site, if any.
  final StackTrace? stackTrace;

  @override
  bool operator ==(Object other) =>
      other is AsyncError<T> && other.error == error;

  @override
  int get hashCode => Object.hash(AsyncError<T>, error);

  @override
  String toString() => 'AsyncError<$T>($error)';
}

/// {@template async_drip}
///
/// A [Drip] specialised for asynchronous data: it owns an [AsyncState] of
/// `T` and provides [run] to execute a `Future<T>` while emitting the
/// expected `Loading -> Data | Error` sequence automatically.
///
/// Typical usage with Dart 3 pattern matching:
///
/// ```dart
/// class UserDrip extends AsyncDrip<User> {
///   UserDrip(this._api);
///   final UserApi _api;
///   Future<void> load(int id) => run(() => _api.fetchUser(id));
/// }
///
/// Dripper<UserDrip, AsyncState<User>>(
///   builder: (_, state) => switch (state) {
///     AsyncIdle()                   => const Text('Idle'),
///     AsyncLoading(:final previous) => previous == null
///         ? const CircularProgressIndicator()
///         : Text('Refreshing: ${previous.name}'),
///     AsyncData(:final value)       => Text(value.name),
///     AsyncError(:final error)      => Text('Error: $error'),
///   },
/// );
/// ```
///
/// Concurrent calls to [run] are not cancelled; if you trigger two
/// requests, both will eventually resolve and emit, with the last one to
/// finish winning the final state.
///
/// {@endtemplate}
class AsyncDrip<T> extends Drip<AsyncState<T>> {
  /// Creates an [AsyncDrip] starting in [AsyncIdle].
  AsyncDrip() : super(AsyncIdle<T>());

  /// Executes [task], emitting [AsyncLoading] (carrying the previous data
  /// if any) and then either [AsyncData] on success or [AsyncError] on
  /// failure.
  Future<void> run(Future<T> Function() task) async {
    leak(AsyncLoading<T>(previous: state.dataOrNull));
    try {
      final value = await task();
      leak(AsyncData<T>(value));
    } catch (error, stackTrace) {
      leak(AsyncError<T>(error, stackTrace));
    }
  }

  /// Resets the state back to [AsyncIdle], discarding any previous data
  /// or error.
  void reset() => leak(AsyncIdle<T>());
}
