import 'package:logger/logger.dart';

import '../drip_core/drip_core.dart';
import 'base_interceptors.dart';

class Logging<DState> extends BaseInterceptor<DState> {
  Logging();
  final logger = Logger();

  @override
  Stream<DState> call(
    DripEvent event,
    DState state,
  ) async* {
    final stopwatch = Stopwatch()..start();
    logger.d('[$event] Starting');
    yield state;
    logger.d('[$event] State updated : $state \n Finished after ${stopwatch.elapsed}');
  }
}
