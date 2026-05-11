import 'package:drip/drip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _CounterDrip extends Drip<int> {
  _CounterDrip([super.initial = 0]);
  void inc() => leak(state + 1);
}

class _CountingChild extends StatefulWidget {
  const _CountingChild({super.key});
  @override
  State<_CountingChild> createState() => _CountingChildState();
}

class _CountingChildState extends State<_CountingChild> {
  int builds = 0;

  @override
  Widget build(BuildContext context) {
    builds += 1;
    return Text('builds=$builds');
  }
}

void main() {
  group('Dripping', () {
    testWidgets('fires the listener on each state change', (tester) async {
      final drip = _CounterDrip();
      addTearDown(drip.close);
      final received = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          home: DripProvider<_CounterDrip>(
            create: (_) => drip,
            child: Dripping<_CounterDrip, int>(
              listener: (_, state) => received.add(state),
              child: const SizedBox(),
            ),
          ),
        ),
      );

      drip.inc();
      drip.inc();
      await tester.pumpAndSettle();

      expect(received, containsAllInOrder(<int>[1, 2]));
    });

    testWidgets('does not rebuild its child on state changes', (tester) async {
      final drip = _CounterDrip();
      addTearDown(drip.close);
      final childKey = GlobalKey<_CountingChildState>();

      await tester.pumpWidget(
        MaterialApp(
          home: DripProvider<_CounterDrip>(
            create: (_) => drip,
            child: Dripping<_CounterDrip, int>(
              listener: (_, __) {},
              child: _CountingChild(key: childKey),
            ),
          ),
        ),
      );

      final buildsAfterMount = childKey.currentState!.builds;
      drip.inc();
      drip.inc();
      drip.inc();
      await tester.pumpAndSettle();

      expect(childKey.currentState!.builds, buildsAfterMount);
    });
  });
}
