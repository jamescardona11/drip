import 'package:flutter/widgets.dart';

import '../drip_core/drip_core.dart';
import '../drip_misc/drip_misc.dart';
import '../widgets/drip_listener.dart';
import '../widgets/widgets.dart';

class Dripping<D extends Drip<DState>, DState> extends StatefulWidget {
  /// default constructor
  const Dripping({
    super.key,
    required this.builder,
    required this.listener,
    this.streamListener = true,
  });

  final DBuilder<DState> builder;
  final DListener<DState> listener;
  final bool streamListener;

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
