part of 'drip.dart';

abstract class _BaseDrip<DState> {
  _BaseDrip(this._initialState) {
    _state = _initialState;

    _stateController = StreamController<DState>.broadcast();
    _bindStateController();

    // I have the initialState in the DripBuilder
    // Add initialState in controller
    _stateController.add(_initialState);
    // print('initialState: ');
  }

  late final DState _initialState;
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

  DState get initialState => _initialState;

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

  void safeSubscription(StreamSubscription subscription) {
    _subscriptions.add(subscription);
  }

  void safeSubscriptions(List<StreamSubscription> subscriptions) {
    _subscriptions.addAll(subscriptions);
  }
}
