import 'package:flutter/widgets.dart';
import 'package:nested/nested.dart';

import '../drip_core.dart';

/// A factory that builds a [Drip] given the current [BuildContext].
typedef DCreate<D> = D Function(BuildContext context);

/// {@template dropper}
///
/// Provides a [Drip] instance to the widget subtree via an
/// [InheritedWidget]. Descendants retrieve the drip with [Dropper.of],
/// [Dropper.read], [Dropper.watch], or the [BuildContext.read] /
/// [BuildContext.watch] extensions.
///
/// Use [Dropper] when you already own a [Drip] instance and want to
/// expose it eagerly. Use [DripProvider] when you want lazy creation
/// tied to the subtree lifecycle.
///
/// {@endtemplate}
class Dropper<D extends Drip<Object?>> extends SingleChildStatelessWidget {
  /// Creates a [Dropper] that exposes [drip] to its descendants.
  const Dropper({
    super.key,
    required this.drip,
    super.child,
  });

  /// The drip exposed to descendants.
  final D drip;

  /// Retrieves the [Drip] of type [D] from the nearest ancestor [Dropper].
  ///
  /// Throws [ProviderError] when no matching [Dropper] is found, or when
  /// [D] resolves to `dynamic`.
  ///
  /// When [listen] is true, the calling widget rebuilds whenever the
  /// provided drip *instance* changes (not on state emissions — for that
  /// use [Dripper] or [DropWidget]).
  static D of<D extends Drip<Object?>>(BuildContext context, {bool listen = false}) {
    if (D == dynamic) {
      throw ProviderError();
    }

    final provider = listen
        ? context.dependOnInheritedWidgetOfExactType<_DropperIW<D>>()
        : (context
            .getElementForInheritedWidgetOfExactType<_DropperIW<D>>()
            ?.widget as _DropperIW<D>?);

    if (provider == null) {
      throw ProviderError(D);
    }

    return provider.drip;
  }

  /// Method to access to the [Drip] using the context
  static D read<D extends Drip<Object?>>(BuildContext context) {
    return of<D>(context);
  }

  /// Method to watch changes in the [Drip] using the context
  static D watch<D extends Drip<Object?>>(BuildContext context) {
    return of<D>(context, listen: true);
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    return _DropperIW(
      drip: drip,
      child: child ?? const SizedBox(),
    );
  }
}

class _DropperIW<D extends Drip<Object?>> extends InheritedWidget {
  const _DropperIW({
    super.key,
    required super.child,
    required this.drip,
  }) : super();

  final D drip;

  @override
  bool updateShouldNotify(covariant _DropperIW<D> oldWidget) =>
      drip != oldWidget.drip;
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
  D read<D extends Drip<Object?>>() {
    return Dropper.read<D>(this);
  }

  D watch<D extends Drip<Object?>>() {
    return Dropper.watch<D>(this);
  }
}

/// {@template drip_provider_lazy}
///
/// A convenience provider that *lazily* creates a [Drip] via [create] and
/// exposes it to descendants the same way a [Dropper] does.
///
/// Use this when the drip's lifetime should be tied to this widget's
/// position in the tree (created on mount, disposed when removed).
///
/// {@endtemplate}
class DripProvider<D extends Drip<Object?>> extends StatelessWidget {
  /// Creates a [DripProvider].
  const DripProvider({
    super.key,
    required this.create,
    required this.child,
  });

  /// Factory invoked once to build the [Drip] instance.
  final DCreate<D> create;

  /// The subtree that receives the drip.
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      children: [
        Dropper<D>(drip: create(context)),
      ],
      child: child,
    );
  }
}

/// {@template multi_provider}
///
/// Composes several [Dropper] (or other [SingleChildStatelessWidget])
/// providers without nested indentation.
///
/// Backed by [`package:nested`](https://pub.dev/packages/nested).
///
/// {@endtemplate}
class MultiProvider extends Nested {
  /// Creates a [MultiProvider] that wraps [child] with the given [children].
  MultiProvider({
    super.key,
    required super.children,
    super.child,
  });
}
