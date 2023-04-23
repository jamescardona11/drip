import '../drip_core/drip_core.dart';

/// {@template generic_state_change_action}
///
/// This class is used to change the state of the Drip
/// The goal of this class is create a new [DripAction] when method `leak` is called
/// This class is used inside of the [Drip] class
///
/// {@endtemplate}
class GenericStateChangeAction<DState> extends DripAction<DState> {
  const GenericStateChangeAction(this.newState);

  final DState newState;

  @override
  Stream<DState> call(DState state) async* {
    yield newState;
  }
}
