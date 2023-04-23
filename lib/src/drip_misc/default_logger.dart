import 'package:logger/logger.dart';

import '../drip_core/drip_core.dart';

/// {@template default_logger}
///
/// This mixin is used to log the events and states of the Drip
///
/// {@endtemplate}
mixin DefaultLogger<DState> {
  final _logger = Logger();
  void onError(Object err, StackTrace? stackTrace) {
    _logger.e('=> Error in Drip', err, stackTrace);
  }

  void onEvent(DripEvent event) {
    _logger.d('=> New event $event');
  }

  void onState(DState state) {
    _logger.d('=> New state: $state');
  }
}
