import 'package:drip/src/drip_core/drip_core.dart';
import 'package:drip/src/drip_misc/drip_misc.dart';
import 'package:drip/src/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

//consider usign RX for sent last state subscription
// test JUANQ solution
// see what happens if use change notifier in one side and stream in other

class DripConsumer<D extends Drip<DState>, DState> extends StatefulWidget {
  /// default constructor
  const DripConsumer({
    super.key,
    required this.builder,
    required this.listener,
    this.streamListener = true,
  });

  final DBuilder<DState> builder;
  final DListener<DState> listener;
  final bool streamListener;

  @override
  State<DripConsumer<D, DState>> createState() => _DripConsumerState<D, DState>();
}

class _DripConsumerState<D extends Drip<DState>, DState> extends State<DripConsumer<D, DState>> {
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
      child: DripBuilder<D, DState>(
        drip: _drip,
        builder: widget.builder,
      ),
    );
  }
}
