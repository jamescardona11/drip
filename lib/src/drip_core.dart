import 'dart:async';

import 'package:flutter/foundation.dart';

/// {@template drip}
///
/// Minimal Cubit-style state holder.
///
/// Subclass and call [leak] to publish a new state. Every [Drip] exposes a
/// broadcast [stateStream] so listeners outside the widget tree (tests,
/// other services) can consume updates.
///
/// {@endtemplate}
abstract class Drip<DState> {
  /// Creates a [Drip] seeded with [initialState].
  Drip(DState initialState) {
    _state = initialState;
    _controller = StreamController<DState>.broadcast(
      onListen: () {
        // Replay the current state to the first subscriber.
        _controller.add(_state);
      },
    );
  }

  late DState _state;
  late final StreamController<DState> _controller;

  /// Publishes [newState] as the next value of [state] and emits it on
  /// [stateStream].
  ///
  /// Calling [leak] after [close] is a no-op (a debug warning is printed).
  /// Intended to be invoked from inside the [Drip] subclass; subclasses
  /// should expose intent-revealing methods (e.g. `increment`, `addItem`)
  /// rather than letting callers leak arbitrary states.
  @protected
  void leak(DState newState) {
    if (_controller.isClosed) {
      debugPrint('Drip: leak() called after the drip was closed');
      return;
    }
    _state = newState;
    _controller.add(newState);
  }

  /// Closes the underlying stream controller. Once closed, [leak] becomes a
  /// no-op and existing subscribers receive `done`.
  void close() {
    _controller.close();
  }

  /// The current state.
  DState get state => _state;

  /// A broadcast stream of state updates. The first subscriber receives the
  /// current [state] immediately on subscription.
  Stream<DState> get stateStream => _controller.stream;
}
