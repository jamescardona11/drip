import 'package:flutter/widgets.dart';

import 'drip_provider.dart';

/// {@template drip_provider}
///
/// Similar to [DripProvider] but allows to provide multiple [Drip]
/// The [Drip] are created using the [create] function
///
/// {@endtemplate}
class MultiDripProvider extends StatelessWidget {
  const MultiDripProvider({
    Key? key,
    required this.providers,
    required this.child,
  }) : super(key: key);

  final List<DripProvider> providers;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return providers.reversed.fold(child, (p, e) => e.copyWith(p));
  }
}
