import 'package:drip/src/drip_core/drip_core.dart';
import 'package:drip/src/drip_misc/drip_misc.dart';
import 'package:drip/src/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

class DripSelect<D extends Drip<DState>, DState, SelectedState> extends StatefulWidget {
  /// default constructor
  const DripSelect({
    super.key,
    required this.builder,
    required this.selector,
  });

  final SBuilder<SelectedState> builder;
  final Selector<DState, SelectedState> selector;

  @override
  State<DripSelect<D, DState, SelectedState>> createState() => _DripSelectState<D, DState, SelectedState>();
}

class _DripSelectState<D extends Drip<DState>, DState, SelectedState> extends State<DripSelect<D, DState, SelectedState>> {
  late D _drip;
  late SelectedState _state;

  @override
  void initState() {
    super.initState();
    _drip = DripProvider.of<D>(context);
    _state = widget.selector(_drip.state);
  }

  @override
  Widget build(BuildContext context) {
    return DripListener<D, DState>(
      listener: (context, state) {
        final selectedState = widget.selector(state);
        if (_state != selectedState) setState(() => _state = selectedState);
      },
      child: widget.builder(context, _state),
    );
  }
}
