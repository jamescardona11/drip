import 'dart:async';

import 'drip_core.dart';

/// {@template computed_drip}
///
/// A [Drip] whose state is derived from one or more *source* drips.
///
/// Whenever any of the [sources] emits a new state, the [compute] callback
/// is invoked. The result is only re-emitted when it differs from the
/// current state (by `==`). Subscriptions to the sources are cancelled on
/// [close].
///
/// Inline (functional) style:
///
/// ```dart
/// final user = UserDrip();
/// final greeting = ComputedDrip<String>(
///   initial: '',
///   sources: [user],
///   compute: () => 'Hello ${user.state.name}',
/// );
/// ```
///
/// Subclass style (for richer behaviour or DI):
///
/// ```dart
/// class GreetingDrip extends ComputedDrip<String> {
///   GreetingDrip(this.user) : super(
///         initial: '',
///         sources: [user],
///         compute: () => 'Hello ${user.state.name}',
///       );
///   final UserDrip user;
/// }
/// ```
///
/// A [ComputedDrip] is itself a [Drip], so it can be a source for further
/// computed drips — composition is transitive.
///
/// {@endtemplate}
class ComputedDrip<S> extends Drip<S> {
  /// {@macro computed_drip}
  ComputedDrip({
    required S initial,
    required this.sources,
    required this.compute,
  }) : super(initial) {
    for (final source in sources) {
      _subscriptions.add(source.stateStream.listen((_) => _recompute()));
    }
    // Reconcile the initial value with the current sources so callers do
    // not need to construct a perfectly-correct `initial` argument when
    // the sources already hold non-default state.
    _recompute();
  }

  /// The drips this computed value depends on.
  final List<Drip<Object?>> sources;

  /// Re-evaluated whenever any of [sources] emits.
  final S Function() compute;

  final List<StreamSubscription<Object?>> _subscriptions = [];

  void _recompute() {
    final next = compute();
    if (next != state) {
      leak(next);
    }
  }

  @override
  void close() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    super.close();
  }
}
