part of 'drip.dart';

/// {@template _base_drip}
///
/// This class is the base class for Drip
/// Contains the basic methods and properties for a Drip
/// Define the eventController and stateController transformers
///
/// {@endtemplate}
abstract class _BaseDrip<DState> {
  _BaseDrip(this._initialState, [this._interceptors = const []]) {
    _state = _initialState;

    _stateController = StreamController<DState>.broadcast(onListen: () {
      // Add initialState to all new listeners
      _stateController.add(_initialState);
    });
    _eventControllerTransformer();
  }

  final DState _initialState;
  final List<BaseInterceptor<DState>> _interceptors;
  late DState _state;

  late final StreamController<DState> _stateController;
  final StreamController<DripEvent> _eventController = StreamController<DripEvent>();

  /// This method is used to transform a new DripEvent in new States
  Stream<DState> mutableStateOf(DripEvent event, DState state);

  /// This method is to change the current state into a new state
  /// This method start a new `DripAction` called [GenericStateChangeAction]
  /// Is similar to emit in bloc
  void leak(DState state);

  /// THis method should be called when you want to dispatch a new event
  /// The sate mutation when this method is called is handle for `mutableStateOf`
  void dispatch(DripEvent<DState> event);

  /// Method is called when an error is thrown
  void onError(Object err, StackTrace? stackTrace);

  /// Method is called when a new event is dispatched
  void onEvent(DripEvent<DState> event);

  /// Method is called when the state is changed
  void onState(DState state);

  bool get isClosed => _stateController.isClosed;

  /// Close the _stateController and _eventController
  /// Use this method when you want to close the drip
  @mustCallSuper
  void close() {
    _stateController.close();
    _eventController.close();
  }

  /// Return the current state
  DState get state => _state;

  /// Add the new state to _setState and _stateController
  // ?? is necessary avoid set a newState when the newState is the same that the current?
  void _setState(DState state) {
    _state = state;
    onState(state);
    // if (_state != state) {
    // }
  }

  /// Method that transform the event stream into a state stream using the interceptors and _switcher
  ///
  /// 1- `asyncExpand`: The event stream is expand to be able to end a event processing until start the next one
  /// 2- `fold`: Take all the interceptors and create a chain of function that will be called in order, Interceptor2(Interceptor1(Interceptor0(next)))
  ///     - `ActionExecutor`: Is the function that will be called in the chain, the function use a `await for()` to call all interceptors in the chain
  /// 3- `call(event, state)`: The chain of function is called with the event and the current state and return a stream of state
  /// 4- `switcher`: transform the interceptor result into a stream to call an Action or mutableStateOf
  ///     - `mutableStateOf`: is called when the event is not a DripAction
  /// 5- `forEach`: Add the new state to _setState and _stateController
  void _eventControllerTransformer() {
    _eventController.stream.asyncExpand((event) {
      final next = _interceptors
          .fold<Next<DState>>(
            (DripEvent event, DState state) => Stream<DState>.value(state),
            (Next<DState> previous, BaseInterceptor<DState> interceptor) =>
                (DripEvent event, DState state) => ActionExecutor(event, state, previous).call(interceptor),
          )
          .call(event, _state);

      return _switcher(next, (stateAfterInterceptors) {
        if (event is DripAction) {
          return event.call(stateAfterInterceptors).handleError(onError);
        } else {
          return mutableStateOf(event, stateAfterInterceptors).handleError(onError);
        }
      });
    }).forEach((nextState) {
      if (_stateController.isClosed) return;
      _setState(nextState);
      _stateController.add(nextState);
    });
  }

  /// Seems like a SwitchMap in RxDart
  Stream<R> _switcher<R, T>(Stream<T> str, Stream<R> Function(T) mapper) {
    return str.transform(StreamTransformer<T, R>.fromHandlers(
      handleData: (T value, EventSink<R> sink) async {
        await mapper(value).forEach(sink.add);
      },
    ));
  }
}
