import 'package:flutter/widgets.dart';

import '../drip_core.dart';

/// {@template drip_provider}
///
/// Dropper is a [InheritedWidget] that provides the [Drip] to its children
/// The [Drip] is created using the [create] function
/// Children can access the [Drip] using the [Dropper.of] method or using BuildContext extension
///
/// {@endtemplate}

typedef DCreate<D extends Drip> = D Function(BuildContext context);

class Dropper<D extends Drip> extends StatelessWidget {
  const Dropper({
    Key? key,
    required this.create,
    this.child,
  }) : super(key: key);

  final D create;
  final Widget? child;

  static D of<D extends Drip>(BuildContext context, {bool listen = false}) {
    if (D == dynamic) {
      throw ProviderError();
    }

    final provider = listen
        ? context.dependOnInheritedWidgetOfExactType<_DropperIW<D>>()
        : (context.getElementForInheritedWidgetOfExactType<_DropperIW<D>>()?.widget as _DropperIW<D>?);

    if (provider == null) {
      throw ProviderError(D);
    }

    return provider.drip;
  }

  /// Method to access to the [Drip] using the context
  static D read<D extends Drip>(BuildContext context) {
    return of<D>(context);
  }

  /// Method to watch changes in the [Drip] using the context
  static D watch<D extends Drip>(BuildContext context) {
    return of<D>(context, listen: true);
  }

  @override
  Widget build(BuildContext context) {
    return _DropperIW(
      drip: create,
      child: child ?? const SizedBox(),
    );
  }

  Dropper<D> copyWith(Widget child) {
    return Dropper<D>(
      create: create,
      child: child,
    );
  }
}

class _DropperIW<D extends Drip> extends InheritedWidget {
  const _DropperIW({
    super.key,
    required super.child,
    required this.drip,
  }) : super();

  final D drip;

  @override
  bool updateShouldNotify(covariant _DropperIW<D> oldWidget) => drip != oldWidget.drip;
}

class ProviderError extends Error {
  /// The type of the class the user tried to retrieve
  final Type? type;

  /// Creates a [ProviderError]
  ProviderError([this.type]);

  @override
  String toString() {
    if (type == null) {
      return '''Error: please specify type instead of using dynamic when calling Dropper.of<T>() or context.get<T>() method.''';
    }

    return '''Error: No Dropper<$type> found. To fix, please try:
              * Wrapping your MaterialApp with the Dropper<$type>.
              * Providing full type information to Dropper<$type>, Dropper.of<$type> method.
          ''';
  }
}

/// {@template drip_extension}
///
/// Dropper extension help to access the [Drip] methods using the context
///
/// {@endtemplate}
extension DripProviderX on BuildContext {
  D read<D extends Drip>() {
    return Dropper.read<D>(this);
  }

  D watch<D extends Drip>() {
    return Dropper.watch<D>(this);
  }
}
