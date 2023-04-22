import '../drip_core/drip_core.dart';

abstract class BaseInterceptor<DState> {
  const BaseInterceptor();

  Stream<DState> call(
    DripEvent event,
    DState state,
  );
}

typedef Next<DState> = Stream<DState> Function(DripEvent event, DState state);
