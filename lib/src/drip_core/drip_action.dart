abstract class DripEvent {
  const DripEvent();

  @override
  String toString();
}

abstract class DripAction<DState> extends DripEvent {
  const DripAction();

  Stream<DState> call(DState state);
}
