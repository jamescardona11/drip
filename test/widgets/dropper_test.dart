import 'package:drip/drip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _CounterDrip extends Drip<int> {
  _CounterDrip([super.initial = 0]);
  void inc() => leak(state + 1);
}

class _OtherDrip extends Drip<String> {
  _OtherDrip([super.initial = 'hi']);
}

void main() {
  group('Dropper / DripProvider', () {
    testWidgets('Dropper.of throws ProviderError when not provided',
        (tester) async {
      late Object captured;
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              try {
                Dropper.of<_CounterDrip>(context);
              } catch (e) {
                captured = e;
              }
              return const SizedBox();
            },
          ),
        ),
      );

      expect(captured, isA<ProviderError>());
    });

    testWidgets('Dropper.of returns the provided drip', (tester) async {
      final drip = _CounterDrip(11);
      addTearDown(drip.close);
      _CounterDrip? resolved;

      await tester.pumpWidget(
        MaterialApp(
          home: Dropper<_CounterDrip>(
            drip: drip,
            child: Builder(
              builder: (context) {
                resolved = Dropper.of<_CounterDrip>(context);
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(resolved, same(drip));
      expect(resolved!.state, 11);
    });

    testWidgets('context.read<D>() returns the drip', (tester) async {
      final drip = _CounterDrip(3);
      addTearDown(drip.close);
      _CounterDrip? resolved;

      await tester.pumpWidget(
        MaterialApp(
          home: DripProvider<_CounterDrip>(
            create: (_) => drip,
            child: Builder(
              builder: (context) {
                resolved = context.read<_CounterDrip>();
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(resolved, same(drip));
    });

    testWidgets('DripProvider mounts the drip into the tree', (tester) async {
      final drip = _CounterDrip();
      addTearDown(drip.close);

      await tester.pumpWidget(
        MaterialApp(
          home: DripProvider<_CounterDrip>(
            create: (_) => drip,
            child: Builder(
              builder: (context) {
                final d = Dropper.of<_CounterDrip>(context);
                return Text('${d.state}', textDirection: TextDirection.ltr);
              },
            ),
          ),
        ),
      );

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('MultiProvider exposes multiple drips to descendants',
        (tester) async {
      final counter = _CounterDrip(9);
      final other = _OtherDrip('hello');
      addTearDown(counter.close);
      addTearDown(other.close);

      late int counterState;
      late String otherState;

      await tester.pumpWidget(
        MaterialApp(
          home: MultiProvider(
            children: [
              Dropper<_CounterDrip>(drip: counter),
              Dropper<_OtherDrip>(drip: other),
            ],
            child: Builder(
              builder: (context) {
                counterState = Dropper.of<_CounterDrip>(context).state;
                otherState = Dropper.of<_OtherDrip>(context).state;
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(counterState, 9);
      expect(otherState, 'hello');
    });

    testWidgets('Dropper.of<dynamic> throws ProviderError', (tester) async {
      final drip = _CounterDrip();
      addTearDown(drip.close);
      late Object captured;

      await tester.pumpWidget(
        MaterialApp(
          home: Dropper<_CounterDrip>(
            drip: drip,
            child: Builder(
              builder: (context) {
                try {
                  // ignore: avoid_dynamic_calls
                  Dropper.of(context);
                } catch (e) {
                  captured = e;
                }
                return const SizedBox();
              },
            ),
          ),
        ),
      );

      expect(captured, isA<ProviderError>());
    });
  });
}
