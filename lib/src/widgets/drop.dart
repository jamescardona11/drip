import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

import '../drip_core/drip_core.dart';
import '../drip_misc/drip_misc.dart';
import '../widgets/drip_listener.dart';

/// {@template drop}
///
/// A widget that listens to a [Drip] and rebuilds when the [Drip] emits a new state.
/// That state is then passed to the [builder] function.
/// To avoid unnecessary rebuilds, the [builder] function is only called when the [selector] function returns a new value.
/// The [selector] function is called with the current state of the [Drip] and should return a value that is used to determine whether the [builder] function should be called.
///
/// {@endtemplate}

class DropWidget<D extends Drip<DState>, DState, SelectedState> extends StatefulWidget {
  /// default constructor
  const DropWidget({
    super.key,
    required this.builder,
    required this.selector,
  });

  final SBuilder<D, SelectedState> builder;
  final Selector<DState, SelectedState> selector;

  @override
  State<DropWidget<D, DState, SelectedState>> createState() => _DropWidgetState<D, DState, SelectedState>();
}

class _DropWidgetState<D extends Drip<DState>, DState, SelectedState> extends State<DropWidget<D, DState, SelectedState>> {
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
        if (selectedState is List && !listEquals(selectedState, _state as List)) {
          _update(selectedState);
        } else if (selectedState is Map && !mapEquals(selectedState, _state as Map)) {
          _update(selectedState);
        } else if (selectedState is! List && selectedState is! Map && _state != selectedState) {
          _update(selectedState);
        }
      },
      child: widget.builder(_drip, _state),
    );
  }

  void _update(SelectedState selectedState) {
    setState(() => _state = selectedState);
  }
}
