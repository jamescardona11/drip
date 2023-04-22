import 'package:flutter/foundation.dart';

import '../drip_core/drip_core.dart';

abstract class BaseMiddleware<DState> {
  const BaseMiddleware();

  Stream<DState> call(
    DripEvent event,
    DState state,
  );

  Stream<DState> actionExecutor(
    DripEvent event,
    DState state,
    NextMiddleware<DState> next,
  ) async* {
    await for (final state in next(event, state)) {
      yield state;
    }
  }
}

class ActionExecutor<DState> {
  const ActionExecutor(this.event, this.state, this.previousNext);

  final DripEvent event;
  final DState state;
  final NextMiddleware<DState> previousNext;

  Stream<DState> call(
    BaseMiddleware<DState> middleware,
  ) async* {
    await for (final state in previousNext(event, state)) {
      yield* middleware.call(event, state);
    }
  }
}

typedef NextMiddleware<DState> = Stream<DState> Function(DripEvent event, DState state);

class SpecialPipetteEvent extends DripEvent {}

class Undo extends SpecialPipetteEvent {}

class Drain extends SpecialPipetteEvent {}

class Memento<DState> extends BaseMiddleware<DState> {
  Memento({
    this.historySize = 50,
  }) {
    _history = _FixedLengthList(historySize);
  }

  final int historySize;
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

  void print() {
    debugPrint('History:');
    for (final state in _history.list) {
      debugPrint('$state');
    }
  }
}

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

class Logging<DState> extends BaseMiddleware<DState> {
  const Logging();

  @override
  Stream<DState> call(
    DripEvent event,
    DState state,
  ) async* {
    debugPrint('[$state] Starting');
    yield state;
    debugPrint('[$event] Finished after');
  }
}
