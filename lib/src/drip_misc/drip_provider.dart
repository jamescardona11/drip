import 'package:flutter/widgets.dart';

import '../drip_core/drip_core.dart';
import '../drip_misc/typedef.dart';

class DripProvider<D extends Drip> extends StatefulWidget {
  const DripProvider({
    Key? key,
    required this.create,
    required this.child,
  }) : super(key: key);

  final DCreate<D> create;
  final Widget child;

  @override
  State<DripProvider<D>> createState() => _DripProviderState<D>();

  static D of<D extends Drip>(BuildContext context, {bool listen = false}) {
    if (D == dynamic) {
      throw ProviderError();
    }

    final provider = listen
        ? context.dependOnInheritedWidgetOfExactType<_DripProviderIW<D>>()
        : (context.getElementForInheritedWidgetOfExactType<_DripProviderIW<D>>()?.widget as _DripProviderIW<D>?);

    if (provider == null) {
      throw ProviderError(D);
    }

    return provider.drip;
  }

  static D read<D extends Drip>(BuildContext context) {
    return of<D>(context);
  }

  static D watch<D extends Drip>(BuildContext context) {
    return of<D>(context, listen: true);
  }

  static void dispatch<D extends Drip>(
    BuildContext context,
    DripEvent event,
  ) {
    return of<D>(context).dispatch(event);
  }

  DripProvider<D> copyWith(Widget child) {
    return DripProvider<D>(
      key: key,
      create: create,
      child: child,
    );
  }
}

class _DripProviderState<D extends Drip> extends State<DripProvider<D>> {
  late D drip;

  @override
  void initState() {
    super.initState();
    drip = widget.create(context);
  }

  @override
  Widget build(BuildContext context) {
    return _DripProviderIW(
      drip: drip,
      child: widget.child,
    );
  }
}

class _DripProviderIW<D extends Drip> extends InheritedWidget {
  const _DripProviderIW({
    super.key,
    required super.child,
    required this.drip,
  }) : super();

  final D drip;

  @override
  bool updateShouldNotify(covariant _DripProviderIW<D> oldWidget) => drip != oldWidget.drip;
}

class ProviderError extends Error {
  /// The type of the class the user tried to retrieve
  final Type? type;

  /// Creates a [ProviderError]
  ProviderError([this.type]);

  @override
  String toString() {
    if (type == null) {
      return '''Error: please specify type instead of using dynamic when calling DripProvider.of<T>() or context.get<T>() method.''';
    }

    return '''Error: No Provider<$type> found. To fix, please try:
              * Wrapping your MaterialApp with the DripProvider<$type>.
              * Providing full type information to DripProvider<$type>, DripProvider.of<$type> and context.get<$type>() method.
          ''';
  }
}
