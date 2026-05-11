import 'package:drip/src/drip_core.dart';
import 'package:drip/src/widgets/widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// A function that picks a slice of [DState] of type [T].
typedef Selector<DState, T> = T Function(DState state);

/// A builder that receives the [Drip] instance and the value picked by a
/// [Selector].
typedef SBuilder<D extends Drip<Object?>, SelectedState> = Widget Function(
  D drip,
  SelectedState data,
);

/// {@template drop_widget}
///
/// A consumer widget that rebuilds only when the value picked by [selector]
/// changes.
///
/// Equality is checked as follows:
/// - `List` values are compared with [listEquals]
/// - `Map` values are compared with [mapEquals]
/// - all other values are compared with `==`
///
/// {@endtemplate}

/// {@macro drop_widget}
class DropWidget<D extends Drip<DState>, DState, SelectedState>
    extends StatefulWidget {
  /// Creates a [DropWidget] driven by [selector] over the [Drip] of type [D].
  const DropWidget({
    super.key,
    required this.builder,
    required this.selector,
  });

  final SBuilder<D, SelectedState> builder;
  final Selector<DState, SelectedState> selector;

  @override
  State<DropWidget<D, DState, SelectedState>> createState() =>
      _DropWidgetState<D, DState, SelectedState>();
}

class _DropWidgetState<D extends Drip<DState>, DState, SelectedState>
    extends State<DropWidget<D, DState, SelectedState>> {
  late D _drip;
  late SelectedState _state;

  @override
  void initState() {
    super.initState();
    _drip = Dropper.of<D>(context);
    _state = widget.selector(_drip.state);
  }

  @override
  Widget build(BuildContext context) {
    return Dripping<D, DState>(
      listener: (_, state) {
        final selectedState = widget.selector(state);
        if (selectedState is List &&
            !listEquals(selectedState, _state as List)) {
          _update(selectedState);
        } else if (selectedState is Map &&
            !mapEquals(selectedState, _state as Map)) {
          _update(selectedState);
        } else if (selectedState is! List &&
            selectedState is! Map &&
            _state != selectedState) {
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
