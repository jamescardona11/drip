import 'package:flutter/widgets.dart';

import '../drip_core/drip_core.dart';
import '../drip_misc/drip_misc.dart';
import '../widgets/drip_listener.dart';
import '../widgets/widgets.dart';

/// {@template dripping}
///
/// This class provide a builder and listener for a  [Drip]
/// The class is similar to Consumer in bloc
/// The builder is called when the drip emits a new state
/// The listener is called when the drip emits a new state different from the previous one
///
/// {@endtemplate}

class Dripping<D extends Drip<DState>, DState> extends StatefulWidget {
  /// default constructor
  const Dripping({
    super.key,
    required this.builder,
    required this.listener,
  });

  final DBuilder<D, DState> builder;
  final DListener<DState> listener;

  @override
  State<Dripping<D, DState>> createState() => _DrippingState<D, DState>();
}

class _DrippingState<D extends Drip<DState>, DState> extends State<Dripping<D, DState>> {
  late D _drip;

  @override
  void initState() {
    _drip = DripProvider.of<D>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DripListener<D, DState>(
      drip: _drip,
      listener: widget.listener,
      child: Dripper<D, DState>(
        drip: _drip,
        builder: widget.builder,
      ),
    );
  }
}
