import 'package:drip/src/drip_core/drip_core.dart';
import 'package:drip/src/drip_misc/drip_misc.dart';
import 'package:flutter/widgets.dart';

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

class _DripBuilderState<D extends Drip<DState>, DState> extends State<DripBuilder<D, DState>> {
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
    return StreamBuilder<DState>(
      initialData: _drip.state,
      stream: _drip.stateStream,
      builder: (_, snapshot) {
        return widget.builder(context, snapshot.requireData);
      },
    );
  }
}
