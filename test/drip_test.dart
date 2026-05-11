import 'package:drip/drip.dart';
import 'package:flutter_test/flutter_test.dart';

class _CounterDrip extends Drip<int> {
  _CounterDrip([super.initial = 0]);

  void inc() => leak(state + 1);
  void setTo(int v) => leak(v);
}

void main() {
  group('Drip<DState>', () {
    test('exposes the initial state', () {
      final drip = _CounterDrip(7);
      addTearDown(drip.close);

      expect(drip.state, 7);
    });

    test('leak() updates state synchronously', () {
      final drip = _CounterDrip();
      addTearDown(drip.close);

      drip.inc();
      drip.inc();
      drip.inc();

      expect(drip.state, 3);
    });

    test('first subscriber receives initial state', () async {
      final drip = _CounterDrip(42);
      addTearDown(drip.close);

      expect(drip.stateStream, emits(42));
    });

    test('leak() emits new state to active subscribers', () async {
      final drip = _CounterDrip();
      addTearDown(drip.close);

      expect(
        drip.stateStream,
        emitsInOrder(<int>[0, 1, 2, 3]),
      );

      // Allow the initial emission to flush before we leak.
      await Future<void>.delayed(Duration.zero);
      drip.inc();
      drip.inc();
      drip.inc();
    });

    test('stateStream is a broadcast stream', () async {
      final drip = _CounterDrip();
      addTearDown(drip.close);

      final emittedA = <int>[];
      final emittedB = <int>[];
      final subA = drip.stateStream.listen(emittedA.add);
      final subB = drip.stateStream.listen(emittedB.add);
      addTearDown(subA.cancel);
      addTearDown(subB.cancel);

      await Future<void>.delayed(Duration.zero);
      drip.setTo(5);
      await Future<void>.delayed(Duration.zero);

      expect(emittedA, contains(5));
      expect(emittedB, contains(5));
    });

    test('leak() after close() does not throw', () {
      final drip = _CounterDrip();
      drip.close();

      expect(drip.inc, returnsNormally);
    });

    test('close() makes the stream done', () async {
      final drip = _CounterDrip();
      drip.close();

      await expectLater(drip.stateStream, emitsDone);
    });
  });
}
