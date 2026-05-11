import 'package:drip/drip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _CounterDrip extends Drip<int> {
  _CounterDrip([super.initial = 0]);
  void inc() => leak(state + 1);
}

Widget _wrap(Widget child) => MaterialApp(home: Material(child: child));

void main() {
  group('Dripper', () {
    testWidgets('builds with the current state', (tester) async {
      final drip = _CounterDrip(5);
      addTearDown(drip.close);

      await tester.pumpWidget(
        _wrap(
          DripProvider<_CounterDrip>(
            create: (_) => drip,
            child: Dripper<_CounterDrip, int>(
              builder: (_, state) => Text('count: $state'),
            ),
          ),
        ),
      );

      expect(find.text('count: 5'), findsOneWidget);
    });

    testWidgets('rebuilds on state change', (tester) async {
      final drip = _CounterDrip();
      addTearDown(drip.close);

      await tester.pumpWidget(
        _wrap(
          DripProvider<_CounterDrip>(
            create: (_) => drip,
            child: Dripper<_CounterDrip, int>(
              builder: (_, state) => Text('$state'),
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);

      drip.inc();
      await tester.pumpAndSettle();
      expect(find.text('1'), findsOneWidget);

      drip.inc();
      drip.inc();
      await tester.pumpAndSettle();
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('with create: provides the drip without external provider',
        (tester) async {
      final drip = _CounterDrip(7);
      addTearDown(drip.close);

      await tester.pumpWidget(
        _wrap(
          Dripper<_CounterDrip, int>(
            create: drip,
            builder: (_, state) => Text('$state'),
          ),
        ),
      );

      expect(find.text('7'), findsOneWidget);
    });

    testWidgets('listener fires on state change', (tester) async {
      final drip = _CounterDrip();
      addTearDown(drip.close);
      final seen = <int>[];

      await tester.pumpWidget(
        _wrap(
          DripProvider<_CounterDrip>(
            create: (_) => drip,
            child: Dripper<_CounterDrip, int>(
              listener: (_, state) => seen.add(state),
              builder: (_, state) => Text('$state'),
            ),
          ),
        ),
      );

      drip.inc();
      drip.inc();
      await tester.pumpAndSettle();

      expect(seen, contains(1));
      expect(seen, contains(2));
    });
  });
}
