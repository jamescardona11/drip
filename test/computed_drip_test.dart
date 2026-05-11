import 'package:drip/drip.dart';
import 'package:flutter_test/flutter_test.dart';

class _CounterDrip extends Drip<int> {
  _CounterDrip([super.initial = 0]);
  void set(int v) => leak(v);
}

class _NameDrip extends Drip<String> {
  _NameDrip([super.initial = '']);
  void set(String v) => leak(v);
}

void main() {
  group('ComputedDrip', () {
    test('exposes initial value computed from current sources', () {
      final a = _CounterDrip(2);
      final b = _CounterDrip(3);
      addTearDown(a.close);
      addTearDown(b.close);

      final sum = ComputedDrip<int>(
        initial: 0,
        sources: [a, b],
        compute: () => a.state + b.state,
      );
      addTearDown(sum.close);

      expect(sum.state, 5);
    });

    test('recomputes when any source emits', () async {
      final a = _CounterDrip();
      final b = _CounterDrip();
      addTearDown(a.close);
      addTearDown(b.close);

      final sum = ComputedDrip<int>(
        initial: 0,
        sources: [a, b],
        compute: () => a.state + b.state,
      );
      addTearDown(sum.close);

      a.set(10);
      await Future<void>.delayed(Duration.zero);
      expect(sum.state, 10);

      b.set(5);
      await Future<void>.delayed(Duration.zero);
      expect(sum.state, 15);
    });

    test('does not re-emit when the computed value is equal', () async {
      final a = _CounterDrip(1);
      final b = _NameDrip('x');
      addTearDown(a.close);
      addTearDown(b.close);

      // Computed value depends only on a; mutating b should NOT emit.
      final mirror = ComputedDrip<int>(
        initial: 0,
        sources: [a, b],
        compute: () => a.state,
      );
      addTearDown(mirror.close);

      final emissions = <int>[];
      final sub = mirror.stateStream.listen(emissions.add);
      addTearDown(sub.cancel);

      await Future<void>.delayed(Duration.zero);
      // Initial replay
      expect(emissions, [1]);

      b.set('y'); // unrelated
      b.set('z');
      await Future<void>.delayed(Duration.zero);
      expect(emissions, [1], reason: 'b changes do not affect computed value');

      a.set(2);
      await Future<void>.delayed(Duration.zero);
      expect(emissions, [1, 2]);
    });

    test('can be a source for another ComputedDrip (composition)', () async {
      final a = _CounterDrip(1);
      addTearDown(a.close);

      final doubled = ComputedDrip<int>(
        initial: 0,
        sources: [a],
        compute: () => a.state * 2,
      );
      addTearDown(doubled.close);

      final plusOne = ComputedDrip<int>(
        initial: 0,
        sources: [doubled],
        compute: () => doubled.state + 1,
      );
      addTearDown(plusOne.close);

      expect(plusOne.state, 3); // (1*2)+1

      a.set(5);
      await Future<void>.delayed(Duration.zero);
      expect(doubled.state, 10);
      expect(plusOne.state, 11);
    });

    test('close() cancels source subscriptions', () async {
      final a = _CounterDrip();
      addTearDown(a.close);

      final mirror = ComputedDrip<int>(
        initial: 0,
        sources: [a],
        compute: () => a.state,
      );

      mirror.close();
      // Mutating the source after the computed is closed must not crash.
      expect(() => a.set(99), returnsNormally);
    });
  });
}
