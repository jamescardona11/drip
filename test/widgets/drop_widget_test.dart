import 'package:drip/drip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Pair {
  const _Pair(this.a, this.b);
  final int a;
  final List<int> b;
}

class _PairDrip extends Drip<_Pair> {
  _PairDrip() : super(const _Pair(0, <int>[]));
  void setA(int v) => leak(_Pair(v, state.b));
  void setB(List<int> v) => leak(_Pair(state.a, v));
}

class _MapDrip extends Drip<Map<String, int>> {
  _MapDrip() : super(const <String, int>{'a': 1});
  void mutate(Map<String, int> next) => leak(next);
}

void main() {
  group('DropWidget — selector with memoization', () {
    testWidgets('rebuilds only when the selected primitive changes',
        (tester) async {
      final drip = _PairDrip();
      addTearDown(drip.close);
      var builds = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: DripProvider<_PairDrip>(
            create: (_) => drip,
            child: DropWidget<_PairDrip, _Pair, int>(
              selector: (state) => state.a,
              builder: (_, a) {
                builds += 1;
                return Text('a=$a');
              },
            ),
          ),
        ),
      );
      final initialBuilds = builds;

      // Mutate the *other* field — selector value unchanged.
      drip.setB([1, 2, 3]);
      await tester.pumpAndSettle();
      drip.setB([9, 9]);
      await tester.pumpAndSettle();

      expect(builds, initialBuilds,
          reason: 'selector returns same .a — must not rebuild');

      // Now mutate the selected field.
      drip.setA(42);
      await tester.pumpAndSettle();
      expect(find.text('a=42'), findsOneWidget);
      expect(builds, greaterThan(initialBuilds));
    });

    testWidgets('uses listEquals for List selectors', (tester) async {
      final drip = _PairDrip();
      addTearDown(drip.close);
      var builds = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: DripProvider<_PairDrip>(
            create: (_) => drip,
            child: DropWidget<_PairDrip, _Pair, List<int>>(
              selector: (state) => state.b,
              builder: (_, b) {
                builds += 1;
                return Text('len=${b.length}');
              },
            ),
          ),
        ),
      );
      final initialBuilds = builds;

      // Same content but different instance — listEquals should match.
      drip.setB(<int>[1, 2, 3]);
      await tester.pumpAndSettle();
      final afterFirst = builds;
      expect(afterFirst, greaterThan(initialBuilds));

      drip.setB(<int>[1, 2, 3]);
      await tester.pumpAndSettle();
      expect(builds, afterFirst,
          reason: 'same list content — listEquals=true, no rebuild');

      // Different content — must rebuild.
      drip.setB(<int>[1, 2]);
      await tester.pumpAndSettle();
      expect(builds, greaterThan(afterFirst));
    });

    testWidgets('uses mapEquals for Map selectors', (tester) async {
      final drip = _MapDrip();
      addTearDown(drip.close);
      var builds = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: DripProvider<_MapDrip>(
            create: (_) => drip,
            child: DropWidget<_MapDrip, Map<String, int>, Map<String, int>>(
              selector: (state) => state,
              builder: (_, m) {
                builds += 1;
                return Text('keys=${m.keys.length}');
              },
            ),
          ),
        ),
      );
      final initialBuilds = builds;

      // Same content, different instance.
      drip.mutate(<String, int>{'a': 1});
      await tester.pumpAndSettle();
      expect(builds, initialBuilds,
          reason: 'mapEquals=true on equal maps');

      drip.mutate(<String, int>{'a': 2});
      await tester.pumpAndSettle();
      expect(builds, greaterThan(initialBuilds));
    });
  });
}
