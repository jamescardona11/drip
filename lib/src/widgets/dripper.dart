import 'package:drip/src/widgets/dripping.dart';
import 'package:flutter/widgets.dart';

import '../drip_core.dart';
import 'dropper.dart';

/// A builder that receives the [Drip] instance and its current state.
typedef DBuilder<D extends Drip<DState>, DState> = Widget Function(
  D drip,
  DState state,
);

/// {@template dripper}
///
/// A consumer widget that rebuilds whenever its [Drip] emits a new state,
/// and optionally fires a side-effect [listener].
///
/// Pass [create] to provide and own a [Drip] for the subtree without an
/// outer [DripProvider] / [Dropper]; otherwise the drip is read from
/// the nearest ancestor via [Dropper.of].
///
/// {@endtemplate}
class Dripper<D extends Drip<DState>, DState> extends StatefulWidget {
  /// Creates a [Dripper].
  const Dripper({
    super.key,
    this.create,
    required this.builder,
    this.listener,
  });

  /// Called on every state emission to produce the widget tree.
  final DBuilder<D, DState> builder;

  /// When non-null, the [Dripper] also acts as a provider for this drip.
  final D? create;

  /// Optional side-effect callback fired on each new state (no rebuild).
  final DListener<D, DState>? listener;

  @override
  State<Dripper<D, DState>> createState() => _DripperState<D, DState>();
}

class _DripperState<D extends Drip<DState>, DState>
    extends State<Dripper<D, DState>> {
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
      return DripProvider(
        create: (context) => widget.create!,
        child: stream,
      );
    }

    return stream;
  }
}
