import 'dart:async';

import 'package:flutter/foundation.dart';

/// {@template drip}
///
/// This is the main class of the Drip package
/// This class implements the [_BaseDrip] and is used to create a new Drip
/// The Drip is used to manage the state of the application
///
/// {@endtemplate}
abstract class Drip<DState> {
  Drip(DState initialState) {
    _state = initialState;
    _controller = StreamController<DState>.broadcast(onListen: () {
      // Add initialState to all new listeners
      _controller.add(_state);
    });
  }

  late DState _state;

  // late final StreamController<DState> _stateController;
  late final StreamController<DState> _controller;

  /// This method is used to change the state of the Drip
  /// Is important to use this method inside of drip and not outside
  // ?? is necessary avoid leak a newState method when the newState is the same that the current?
  @protected
  void leak(DState state) {
    if (_controller.isClosed) {
      debugPrint('Drip: emit() called after was closed');
      return;
    }
    _setState(state);
    _controller.add(state);
  }

  void close() {
    _controller.close();
  }

  /// Add the new state to _setState and _stateController
  // ?? is necessary avoid set a newState when the newState is the same that the current?
  void _setState(DState state) {
    _state = state;
  }

  /// Return the current state
  DState get state => _state;

  Stream<DState> get stateStream => _controller.stream;
}
