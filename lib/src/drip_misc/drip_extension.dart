// ignore_for_file: unused_element

import 'package:drip/src/drip_core/drip_core.dart';
import 'package:flutter/material.dart';

import 'drip_provider.dart';

extension DripProviderX on BuildContext {
  D read<D extends Drip>() {
    return DripProvider.read<D>(this);
  }

  D watch<D extends Drip>() {
    return DripProvider.watch<D>(this);
  }

  void dispatch<D extends Drip>(
    DripEvent event,
  ) {
    return DripProvider.dispatch<D>(this, event);
  }
}
