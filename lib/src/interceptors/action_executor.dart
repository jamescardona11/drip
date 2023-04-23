import '../drip_core/drip_core.dart';
import 'base_interceptors.dart';

/// {@template action_executor}
///
/// This class is used to execute the [BaseInterceptor]s
/// This class is used inside of the [_BaseDrip] class
/// This class call the next [BaseInterceptor] using a `await for` loop
///
/// {@endtemplate}
class ActionExecutor<DState> {
  const ActionExecutor(this.event, this.state, this.previousNext);

  final DripEvent event;
  final DState state;
  final Next<DState> previousNext;

  Stream<DState> call(
    BaseInterceptor<DState> middleware,
  ) async* {
    await for (final state in previousNext(event, state)) {
      yield* middleware.call(event, state);
    }
  }
}
