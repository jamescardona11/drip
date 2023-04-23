import 'package:logger/logger.dart';

import '../drip_core/drip_core.dart';
import 'base_interceptors.dart';

/// {@template undo_action}
///
/// This class is used to undo the last state of the Drip
///
/// {@endtemplate}
class UndoMemory<DState> extends DripAction<DState> {
  @override
  Stream<DState> call(state) {
    return Stream.value(state);
  }
}

/// {@template drain_action}
///
/// This class is used to clean the history of the Drip
///
/// {@endtemplate}
class DrainMemory<DState> extends DripAction<DState> {
  @override
  Stream<DState> call(state) {
    return Stream.value(state);
  }
}

/// {@template memory_interceptor}
///
/// MemoryInterceptor is used to save the history of the Drip
/// This can be helpful to save the state in debug mode
///
///
/// {@endtemplate}
class MemoryInterceptor<DState> extends BaseInterceptor<DState> {
  MemoryInterceptor({
    this.historySize = 50,
  });

  /// The size of the history
  final int historySize;

  /// The history list of the Drip
  final List<DState> _history = [];

  @override
  Stream<DState> call(DripEvent event, DState state) async* {
    if (event is UndoMemory<DState> && _history.isNotEmpty) {
      yield _history.removeLast();
    } else if (event is DrainMemory<DState>) {
      _history.clear();
      yield state;
    } else {
      if (_history.length >= historySize) {
        _history.removeAt(0);
      }
      _history.add(state);
      yield state;
    }
  }

  /// Print the history of the Drip
  void print() {
    final logger = Logger();
    logger.d('MemoryInterceptor ** History **:');
    for (final state in _history) {
      logger.d('$state');
    }
  }
}
