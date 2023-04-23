import 'dart:async';

import 'package:drip/drip.dart';
import 'package:flutter/foundation.dart';

import '../drip_misc/generic_state_change_action.dart';
import '../interceptors/action_executor.dart';

part 'base_drip.dart';

/// {@template drip}
///
/// This is the main class of the Drip package
/// This class implements the [_BaseDrip] and is used to create a new Drip
/// The Drip is used to manage the state of the application
///
/// {@endtemplate}
abstract class Drip<DState> extends _BaseDrip<DState> {
  Drip(
    DState initialState, {
    List<BaseInterceptor<DState>> interceptors = const [],
  }) : super(initialState, interceptors);

  /// This method is used to change the state of the Drip
  /// This method is called when a new event is dispatched with new [DripEvent]
  @override
  Stream<DState> mutableStateOf(DripEvent event, DState state) async* {}

  /// This method is used to change the state of the Drip
  /// Is important to use this method inside of drip and not outside
  // ?? is necessary avoid leak a newState method when the newState is the same that the current?
  @protected
  @override
  void leak(DState newState) {
    if (_stateController.isClosed) {
      debugPrint('Drip: emit() called after was closed');
      return;
    }
    _setState(newState);
    dispatch(GenericStateChangeAction(newState));
  }

  /// This method is used to change the state of the Drip dispatching a new [DripEvent] or [DripAction]
  @override
  void dispatch(DripEvent<DState> event) {
    try {
      onEvent(event);
      _eventController.add(event);
    } catch (err, stackTrace) {
      onError(err, stackTrace);
    }
  }

  @override
  void onError(Object err, StackTrace? stackTrace) {}

  @override
  void onEvent(DripEvent<DState> event) {}

  @override
  void onState(DState state) {}

  Stream<DState> get stateStream => _stateController.stream;
}
