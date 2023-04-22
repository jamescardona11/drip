abstract class DripEvent {
  const DripEvent();
}

abstract class DripAction<DState> extends DripEvent {
  const DripAction();

  Stream<DState> call(DState state);
}
