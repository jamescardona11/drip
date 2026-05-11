import 'drip_core.dart';

/// {@template drip_observer}
///
/// Global hook invoked for every [Drip] lifecycle event.
///
/// Useful for crosscutting concerns: logging, analytics, error reporting,
/// or recording state history for replay/undo. The default observer is a
/// no-op; install a custom subclass at startup:
///
/// ```dart
/// void main() {
///   Drip.observer = MyLoggingObserver();
///   runApp(const MyApp());
/// }
///
/// class MyLoggingObserver extends DripObserver {
///   @override
///   void onChange(Drip<Object?> drip, Object? previous, Object? next) {
///     print('${drip.runtimeType}: $previous -> $next');
///   }
/// }
/// ```
///
/// Override only the callbacks you need; unimplemented methods do nothing.
///
/// {@endtemplate}
class DripObserver {
  /// Creates a [DripObserver] with no-op defaults.
  const DripObserver();

  /// Called once when a [Drip] is constructed.
  void onCreate(Drip<Object?> drip) {}

  /// Called for every state mutation via [Drip.leak].
  ///
  /// [previous] is the state before the mutation, [next] is the state that
  /// was just published.
  void onChange(Drip<Object?> drip, Object? previous, Object? next) {}

  /// Called when [Drip.close] is invoked, before the underlying stream
  /// controller is actually closed.
  void onClose(Drip<Object?> drip) {}
}
