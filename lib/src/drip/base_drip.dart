import 'dart:async';

import 'package:flutter/widgets.dart';

import 'drip_events.dart';

abstract class Drip<DState> extends Listenable {
  // =

  Drip(this._initialState) {
    _state = _initialState;

    _stateController = StreamController<DState>.broadcast();
    _bindStateController();

    // I have the initialState in the DripBuilder
    // Add initialState in controller
    _stateController.add(_initialState);
    // print('initialState: ');
  }
  late final StreamController<DState> _stateController;
  final StreamController<DripEvent> _eventController = StreamController<DripEvent>();
  late final DState _initialState;
  late DState _state;

  Stream<DState> mutableStateOf(DripEvent event) async* {}

  void _setState(DState state) {
    if (_state != state) {
      _state = state;
    }
  }

  @protected
  void emit(DState newState) {
    if (state == newState || _stateController.isClosed) return;
    _setState(newState);
    // _stateController.add(newState);
    dispatch(GenericStateChangeAction(newState));
  }

  // @protected
  void dispatch(DripEvent event) {
    try {
      onEvent(event);
      _eventController.add(event);
    } catch (err, stackTrace) {
      onError(err, stackTrace);
    }
  }

  @mustCallSuper
  void close() {
    _stateController.close();
    _eventController.close();
  }

  void onError(Object err, StackTrace? stackTrace) {}

  void onEvent(DripEvent event) {}

  void _bindStateController() {
    _eventController.stream.asyncExpand((event) {
      if (event is DripAction<DState>) {
        return event.call(state).handleError(onError);
      } else {
        return mutableStateOf(event).handleError(onError);
      }
    }).forEach((DState nextState) {
      if (_stateController.isClosed) return;
      _setState(nextState);
      _stateController.add(nextState);
    });
  }

  DState get state => _state;
  DState get initialState => _initialState;
  Stream<DState> get stateStream => _stateController.stream;
}
