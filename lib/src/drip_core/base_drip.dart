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
  final List<BaseMiddleware> _pipettes;
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
    _eventController.stream.asyncExpand((event) async* {
      await _executePipetteMiddleware(event);
      if (event is DripAction<DState>) {
        yield* event.call(state).handleError(onError);
      } else if (event is SpecialPipetteEvent) {
        yield* Stream.value(state);
      } else {
        yield* mutableStateOf(event).handleError(onError);
      }
    }).forEach((DState nextState) {
      if (_stateController.isClosed) return;
      _setState(nextState);
      _stateController.add(nextState);
    });
  }

  Future<void> _executePipetteMiddleware(DripEvent event) async {
    DState tState = state;
    for (var pipette in _pipettes) {
      tState = await pipette.call(event, tState);
    }

    _setState(tState);
  }

  void safeSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  void safeSubscriptions(List<StreamSubscription> subscriptions) {
    _subscriptions.addAll(subscriptions);
  }
}
