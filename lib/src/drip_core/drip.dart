import 'dart:async';

import 'package:drip/drip.dart';
import 'package:flutter/foundation.dart';

part 'base_drip.dart';

abstract class Drip<DState> extends _BaseDrip<DState> {
  Drip(DState initialState) : super(initialState);

  @override
  Stream<DState> mutableStateOf(DripEvent event) async* {}

  @protected
  @override
  void emit(DState newState) {
    if (state == newState || _stateController.isClosed) {
      debugPrint('Drip: emit() called after was closed');
      return;
    }
    _setState(newState);
    dispatch(GenericStateChangeAction(newState));
  }

  @override
  void dispatch(DripEvent event) {
    try {
      onEvent(event);
      _eventController.add(event);
    } catch (err, stackTrace) {
      onError(err, stackTrace);
    }
  }

  @mustCallSuper
  @override
  void close() {
    super.close();
    _stateController.close();
    _eventController.close();
  }

  @override
  void onError(Object err, StackTrace? stackTrace) {}

  @override
  void onEvent(DripEvent event) {}

  Stream<DState> get stateStream => _stateController.stream;
}
