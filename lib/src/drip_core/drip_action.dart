/// {@template drip_action}
///
///  This abstract class is used to define a new [DrinEvent]
///  The Events are used to change the state of the [Drip]
///
/// {@endtemplate}
abstract class DripEvent {
  const DripEvent();

  @override
  String toString();
}

/// {@template drip_action}
///
/// This abstract class is used to define a new Actions
/// The Actions are used to change the state of the Drip
/// The Actions can live outside the Drip
///
/// {@endtemplate}

abstract class DripAction<DState> extends DripEvent {
  const DripAction();

  Stream<DState> call(DState state);
}
