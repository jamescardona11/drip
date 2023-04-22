import '../drip_core/drip_core.dart';

class GenericStateChangeAction<DState> extends DripAction<DState> {
  const GenericStateChangeAction(this.newState);

  final DState newState;

  @override
  Stream<DState> call(DState state) async* {
    yield newState;
  }
}
