import 'dart:async';

import 'package:drip/src/drip/base_drip.dart';
import 'package:drip/src/drip/drip_provider.dart';
import 'package:drip/src/drip/typedef.dart';
import 'package:flutter/material.dart';

class DripListener<D extends Drip<DState>, DState> extends StatefulWidget {
  /// default constructor
  const DripListener({
    super.key,
    required this.listener,
    required this.child,
    this.drip,
  });

  final DListener<DState> listener;
  final Widget child;
  final D? drip;

  @override
  State<DripListener<D, DState>> createState() =>
      _DripListenerState<D, DState>();
}

class _DripListenerState<D extends Drip<DState>, DState>
    extends State<DripListener<D, DState>> {
  late StreamSubscription<DState> _subscription;
  late DState _previousState;
  late D _drip;

  @override
  void initState() {
    super.initState();
    _drip = widget.drip ?? DripProvider.of<D>(context);
    _previousState = _drip.initialState;
    _subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  @override
  void didUpdateWidget(DripListener<D, DState> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.drip != widget.drip) {
      _drip = widget.drip ?? DripProvider.of<D>(context);
      _previousState = _drip.initialState;

      _unsubscribe();
      _subscribe();
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
        widget.listener.call(context, state);
        _previousState = state;
      }
    });
  }

  void _unsubscribe() {
    _subscription.cancel();
  }
}
