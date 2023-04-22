abstract class DripEvent {
  const DripEvent();
}

abstract class DripAction<DState> extends DripEvent {
  const DripAction();

  Stream<DState> call(DState state);
}

class GenericStateChangeAction<DState> extends DripAction<DState> {
  const GenericStateChangeAction(this.newState);

  final DState newState;

  // Stream<DState> generic() async* {
  //   yield newState;
  // }

  @override
  Stream<DState> call(DState state) async* {
    yield newState;
  }
}
