import 'package:logger/logger.dart';

import '../drip_core/drip_core.dart';
import 'base_interceptors.dart';

/// {@template undo_action}
///
/// This class is used to undo the last state of the Drip
///
/// {endtemplate}
class Undo extends DripAction {
  @override
  Stream call(state) {
    return Stream.value(state);
  }
}

/// {@template drain_action}
///
/// This class is used to clean the history of the Drip
///
/// {endtemplate}
class Drain extends DripAction {
  @override
  Stream call(state) {
    return Stream.value(state);
  }
}

/// {@template memory_interceptor}
///
/// MemoryInterceptor is used to save the history of the Drip
/// This can be helpful to save the state in debug mode
///
/// {endtemplate}
class MemoryInterceptor<DState> extends BaseInterceptor<DState> {
  MemoryInterceptor({
    this.historySize = 50,
  }) {
    _history = _FixedLengthList(historySize);
  }

  /// The size of the history
  final int historySize;

  /// The history list of the Drip
  late final _FixedLengthList<DState> _history;

  @override
  Stream<DState> call(DripEvent event, DState state) async* {
    if (event is Undo && _history.isNotEmpty) {
      yield _history.removeLast();
    } else if (event is Drain) {
      _history.clean();
      yield state;
    } else {
      _history.add(state);
      yield state;
    }
  }

  /// Print the history of the Drip
  void print() {
    final logger = Logger();
    logger.d('MemoryInterceptor ** History **:');
    for (final state in _history.list) {
      logger.d('$state');
    }
  }
}

/// Fixed length list implementation
/// This class is used to save the history of the Drip
/// This class is used inside of the [MemoryInterceptor] class

class _FixedLengthList<T> {
  _FixedLengthList(this.maxLength);

  final int maxLength;
  final List<T> _list = <T>[];

  void add(T element) {
    if (_list.length >= maxLength) {
      _list.removeAt(0);
    }
    _list.add(element);
  }

  T removeLast() => _list.removeLast();

  void clean() => _list.clear();

  bool get isNotEmpty => _list.isNotEmpty;

  List<T> get list => _list;
}
