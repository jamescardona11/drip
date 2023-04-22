part of 'drip.dart';

abstract class _BaseDrip<DState> {
  _BaseDrip(this._initialState, [this._pipettes = const []]) {
    _state = _initialState;

    _stateController = StreamController<DState>.broadcast(onListen: () {
      print('msg');
      // Add initialState to all new listeners
      _stateController.add(_initialState);
    });
    _bindStateController();
  }

  final DState _initialState;
  final List<BaseMiddleware<DState>> _pipettes;
  late DState _state;

  late final StreamController<DState> _stateController;
  final StreamController<DripEvent> _eventController = StreamController<DripEvent>();
  final List<StreamSubscription> _subscriptions = List.from([], growable: true);

  Stream<DState> mutableStateOf(DripEvent event);

  void emit(DState newState);

  void dispatch(DripEvent event);

  void onError(Object err, StackTrace? stackTrace);

  void onEvent(DripEvent event);

  DState get state => _state;

  @mustCallSuper
  void close() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
  }

  void _setState(DState state) {
    if (_state != state) {
      _state = state;
    }
  }

  void _bindStateController() {
    // _eventController.stream.asyncExpand((event) {
    //   NextMiddleware<DState> next = (event, state) => Stream<DState>.empty();
    //   for (var pipette in _pipettes.reversed) {
    //     final NextMiddleware<DState> previousNext = next;
    //     next = (event, state) => pipette(event, state, previousNext);
    //   }

    //   return next(event, state).switchMap((valueAfterInterceptors) {
    //     if (event is DripAction<DState>) {
    //       return event.call(valueAfterInterceptors).handleError(onError);
    //     } else if (event is SpecialPipetteEvent) {
    //       return Stream.value(valueAfterInterceptors);
    //     } else {
    //       return mutableStateOf(event).handleError(onError);
    //     }
    //   });
    // }).forEach((DState nextState) {
    //   if (_stateController.isClosed) return;
    //   _setState(nextState);
    //   _stateController.add(nextState);
    // });

    _eventController.stream
        .asyncExpand((event) => _pipettes.reversed
                .fold<NextMiddleware<DState>>(
                  (DripEvent event, DState state) => Stream<DState>.empty(),
                  (NextMiddleware<DState> previous, BaseMiddleware<DState> pipette) =>
                      (DripEvent event, DState state) => pipette(event, state, previous),
                )
                .call(event, _state)
                .switchMap(
              (stateAfterPipettes) {
                if (event is DripAction<DState>) {
                  return event.call(stateAfterPipettes).handleError(onError);
                } else if (event is SpecialPipetteEvent) {
                  return Stream.value(stateAfterPipettes);
                } else {
                  return mutableStateOf(event).handleError(onError);
                }
              },
            ))
        .forEach((DState nextState) {
      if (_stateController.isClosed) return;
      _setState(nextState);
      _stateController.add(nextState);
    });
  }

  void safeSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  void safeSubscriptions(List<StreamSubscription> subscriptions) {
    _subscriptions.addAll(subscriptions);
  }
}
