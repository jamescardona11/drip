// logger
// transformer

import '../drip_core/drip_core.dart';

abstract class BaseMiddleware<DState> {
  const BaseMiddleware();

  Future<DState> call(DripEvent event, DState state);

  bool canExecute(DState state) => defaultCanExecute(state);

  static bool defaultCanExecute<TState>(TState state) => true;
}

class SpecialPipetteEvent extends DripEvent {}

class Undo extends SpecialPipetteEvent {}

class Memento<DState> extends BaseMiddleware<DState> {
  Memento({
    this.historySize = 50,
  }) {
    history = _FixedLengthList(historySize);
  }

  final int historySize;

  late _FixedLengthList<DState> history;

  @override
  Future<DState> call(DripEvent event, DState state) async {
    print('Memento $event -- $state');
    if (event is Undo && history.isNotEmpty) {
      return history.removeLast();
      // return history.last;
    } else {
      history.add(state);
      return state;
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

  bool get isNotEmpty => _list.isNotEmpty;

  List<T> get list => _list;
}
