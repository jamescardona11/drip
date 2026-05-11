// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:drip/drip.dart';

class DripCounter extends Drip<DripCounterState> {
  DripCounter() : super(DripCounterState());

  void freeze() {
    print('freeze');
    leak(state.copyWith(str: '${state.count}'));
  }

  void clear() {
    leak(state.copyWith(count: 0));
  }

  void increment() {
    leak(state.copyWith(count: state.count + 1));
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
