import 'package:drip/src/drip/base_drip.dart';
import 'package:drip/src/drip/drip_provider.dart';
import 'package:drip/src/drip/typedef.dart';
import 'package:flutter/material.dart';

class DripBuilder<D extends Drip<DState>, DState> extends StatefulWidget {
  /// default constructor
  const DripBuilder({
    super.key,
    this.streamListener = true,
    required this.builder,
    this.drip,
  });

  final bool streamListener;
  final DBuilder<DState> builder;
  final D? drip;

  @override
  State<DripBuilder<D, DState>> createState() => _DripBuilderState<D, DState>();
}

class _DripBuilderState<D extends Drip<DState>, DState>
    extends State<DripBuilder<D, DState>> {
  late D _drip;

  @override
  void initState() {
    super.initState();
    _drip = widget.drip ?? DripProvider.of<D>(context);
    // _previousState = _drip.initialState;
  }

  @override
  void didUpdateWidget(DripBuilder<D, DState> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drip != widget.drip) {
      _drip = widget.drip ?? DripProvider.of<D>(context);
      // _previousState = _drip.state;
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.streamListener
        ? StreamBuilder<DState>(
            initialData: _drip.state,
            stream: _drip.stateStream,
            builder: (_, snapshot) {
              return widget.builder(context, snapshot.requireData);
            },
          )
        : AnimatedBuilder(
            animation: _drip,
            builder: (_, __) => widget.builder(context, _drip.state),
          );
  }
}
