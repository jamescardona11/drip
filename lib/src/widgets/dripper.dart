import 'package:flutter/widgets.dart';

import '../drip_core/drip_core.dart';
import '../drip_misc/drip_misc.dart';

/// {@template dripper}
///
/// Dripper is a widget that rebuilds when the [Drip] state changes.
/// It is similar to BlocBuilder in bloc
/// The builder is called when the drip emits a new state
/// The new state can be the same as the previous one
///
/// {@endtemplate}
class Dripper<D extends Drip<DState>, DState> extends StatefulWidget {
  /// default constructor
  const Dripper({
    super.key,
    required this.builder,
    this.drip,
  });

  final DBuilder<DState> builder;
  final D? drip;

  @override
  State<Dripper<D, DState>> createState() => _DripperState<D, DState>();
}

class _DripperState<D extends Drip<DState>, DState> extends State<Dripper<D, DState>> {
  late D _drip;

  @override
  void initState() {
    super.initState();
    _drip = widget.drip ?? DripProvider.of<D>(context);
  }

  @override
  void didUpdateWidget(Dripper<D, DState> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drip != widget.drip) {
      _drip = widget.drip ?? DripProvider.of<D>(context);
      // _previousState = _drip.state;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DState>(
      initialData: _drip.state,
      stream: _drip.stateStream,
      builder: (_, snapshot) {
        return widget.builder(context, snapshot.requireData);
      },
    );
  }
}
