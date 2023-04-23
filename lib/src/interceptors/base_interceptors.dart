import '../drip_core/drip_core.dart';

/// {@template base_interceptor}
///
/// Class to create Interceptors to transforms or intercept new [DripEvent]
/// The goal of this class is simple change or iterate the [DripEvent] and the [DState]
/// whit this changes the state can mutate before is call the method `mutableStateOf` or before call the [DripAction]
///
/// {@endtemplate}
abstract class BaseInterceptor<DState> {
  const BaseInterceptor();

  Stream<DState> call(
    DripEvent event,
    DState state,
  );
}

typedef Next<DState> = Stream<DState> Function(DripEvent event, DState state);
