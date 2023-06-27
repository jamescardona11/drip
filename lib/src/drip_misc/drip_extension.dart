// ignore_for_file: unused_element

import 'package:flutter/material.dart';

import '../drip_core.dart';
import '../widgets/dropper.dart';

/// {@template drip_extension}
///
/// Dropper extension help to access the [Drip] methods using the context
///
/// {@endtemplate}
extension DripProviderX on BuildContext {
  D read<D extends Drip>() {
    return Dropper.read<D>(this);
  }

  D watch<D extends Drip>() {
    return Dropper.watch<D>(this);
  }
}
