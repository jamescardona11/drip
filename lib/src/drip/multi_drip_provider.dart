import 'package:flutter/widgets.dart';

import 'drip_provider.dart';

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
