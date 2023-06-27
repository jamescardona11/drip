import 'package:drip/src/widgets/dripping.dart';
import 'package:flutter/widgets.dart';

import '../drip_core.dart';
import '../drip_misc/drip_misc.dart';
import 'dropper.dart';

/// {@template dripper}
///
/// Dripper is a widget that rebuilds when the [Drip] state changes.
/// This class provide a builder and listener for a  [Drip]
/// The class is similar to Consumer in bloc
/// The builder is called when the drip emits a new state
/// The listener is called when the drip emits a new state different from the previous one
///
/// {@endtemplate}
class Dripper<D extends Drip<DState>, DState> extends StatefulWidget {
  const Dripper({
    super.key,
    this.create,
    required this.builder,
    this.listener,
  });

  final DBuilder<D, DState> builder;
  final D? create;
  final DListener<D, DState>? listener;

  @override
  State<Dripper<D, DState>> createState() => _DripperState<D, DState>();
}

class _DripperState<D extends Drip<DState>, DState> extends State<Dripper<D, DState>> {
  late D _drip;

  @override
  void initState() {
    super.initState();
    _drip = widget.create ?? Dropper.of<D>(context);
  }

  @override
  void didUpdateWidget(covariant Dripper<D, DState> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.create != widget.create) {
      _drip = widget.create ?? Dropper.of<D>(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = Dripping<D, DState>(
      listener: widget.listener,
      child: StreamBuilder<DState>(
        initialData: _drip.state,
        stream: _drip.stateStream,
        builder: (_, snapshot) {
          return widget.builder(_drip, snapshot.requireData);
        },
      ),
    );

    /// create a new drip using a dropper
    if (widget.create != null) {
      return Dropper<D>(
        create: widget.create!,
        child: stream,
      );
    }

    return stream;
  }
}
