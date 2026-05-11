import 'dart:async';

import 'package:drip/src/widgets/dropper.dart';
import 'package:flutter/widgets.dart';

import '../drip_core.dart';

/// A side-effect callback invoked when a [Drip] emits a new state.
///
/// The first parameter is the [Drip] instance (not a [BuildContext]).
typedef DListener<D extends Drip, DState> = void Function(D drip, DState state);

/// {@template dripping}
///
/// A listener-only widget: it subscribes to the [Drip]'s [Drip.stateStream]
/// and invokes [listener] on each distinct state, but does **not** rebuild
/// its [child] on state changes.
///
/// Useful for side effects (navigation, snackbars, analytics) where you do
/// not want to repaint the subtree.
///
/// {@endtemplate}
class Dripping<D extends Drip<DState>, DState> extends StatefulWidget {
  /// Creates a [Dripping] widget.
  const Dripping({
    super.key,
    required this.child,
    this.listener,
    this.drip,
  });

  /// Called on each new, distinct state. The subtree is not rebuilt.
  final DListener<D, DState>? listener;

  /// The subtree to display. It is rebuilt only when its parent rebuilds.
  final Widget child;

  /// An optional explicit [Drip]. When null, the drip is read from the
  /// nearest ancestor via [Dropper.of].
  final D? drip;

  @override
  State<Dripping<D, DState>> createState() => _DrippingState<D, DState>();
}

class _DrippingState<D extends Drip<DState>, DState>
    extends State<Dripping<D, DState>> {
  StreamSubscription<DState>? _subscription;
  DState? _previousState;
  late D _drip;

  @override
  void initState() {
    super.initState();
    _drip = widget.drip ?? Dropper.of<D>(context);

    if (widget.listener != null) {
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didUpdateWidget(Dripping<D, DState> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drip != widget.drip) {
      _drip = widget.drip ?? Dropper.of<D>(context);

      _unsubscribe();
      if (widget.listener != null) {
        _subscribe();
      }
    }
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  void _subscribe() {
    _subscription = _drip.stateStream.listen((state) {
      if (_previousState != state) {
        widget.listener!.call(_drip, state);
        _previousState = state;
      }
    });
  }

  void _unsubscribe() {
    _subscription?.cancel();
  }
}
