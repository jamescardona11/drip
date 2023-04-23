// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:drip/drip.dart';

class DripCounter extends Drip<DripCounterState> {
  DripCounter()
      : super(DripCounterState(), interceptors: [
          MemoryInterceptor<DripCounterState>(historySize: 5),
        ]);

  void freeze() {
    print('freeze');
    leak(state.copyWith(str: '${state.count}'));
  }

  @override
  Stream<DripCounterState> mutableStateOf(event, state) async* {
    if (event is ClearEvent) {
      print('Clear');
      yield state.copyWith(count: 0);
    }
  }
}

class ClearEvent extends DripEvent<DripCounterState> {}

class IncrementCountAction extends DripAction<DripCounterState> {
  @override
  Stream<DripCounterState> call(DripCounterState state) async* {
    yield state.copyWith(count: state.count + 1);
  }
}

class DripCounterState {
  final int count;
  final String strNum;

  DripCounterState({
    this.count = 0,
    this.strNum = '0',
  });

  DripCounterState copyWith({
    int? count,
    String? str,
  }) {
    return DripCounterState(
      count: count ?? this.count,
      strNum: str ?? this.strNum,
    );
  }

  @override
  bool operator ==(covariant DripCounterState other) {
    if (identical(this, other)) return true;

    return other.count == count && other.strNum == strNum;
  }

  @override
  int get hashCode => count.hashCode ^ strNum.hashCode;

  @override
  String toString() => 'DripCounterState(count: $count, strNum: $strNum)';
}
