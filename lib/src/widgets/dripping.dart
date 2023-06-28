import 'dart:async';

import 'package:drip/src/widgets/dropper.dart';
import 'package:flutter/widgets.dart';

import '../drip_core.dart';

typedef DListener<D extends Drip, DState> = void Function(D drip, DState state);

class Dripping<D extends Drip<DState>, DState> extends StatefulWidget {
  const Dripping({
    super.key,
    required this.child,
    this.listener,
    this.drip,
  });

  final DListener<D, DState>? listener;
  final Widget child;
  final D? drip;

  @override
  State<Dripping<D, DState>> createState() => _DrippingState<D, DState>();
}

class _DrippingState<D extends Drip<DState>, DState> extends State<Dripping<D, DState>> {
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
