import 'package:drip/drip.dart';
import 'package:flutter_test/flutter_test.dart';

class _CounterDrip extends Drip<int> {
  _CounterDrip([super.initial = 0]);
  void inc() => leak(state + 1);
}

class _RecordingObserver extends DripObserver {
  final created = <Drip<Object?>>[];
  final changes = <List<Object?>>[];
  final closed = <Drip<Object?>>[];

  @override
  void onCreate(Drip<Object?> drip) => created.add(drip);

  @override
  void onChange(Drip<Object?> drip, Object? previous, Object? next) {
    changes.add([previous, next]);
  }

  @override
  void onClose(Drip<Object?> drip) => closed.add(drip);
}

void main() {
  group('DripObserver', () {
    setUp(() {
      Drip.observer = const DripObserver();
    });

    tearDown(() {
      Drip.observer = const DripObserver();
    });

    test('default observer is a no-op (constructing does not throw)', () {
      expect(_CounterDrip.new, returnsNormally);
    });

    test('receives onCreate / onChange / onClose', () {
      final observer = _RecordingObserver();
      Drip.observer = observer;

      final drip = _CounterDrip();
      drip.inc();
      drip.inc();
      drip.close();

      expect(observer.created, hasLength(1));
      expect(observer.created.first, same(drip));

      expect(observer.changes, hasLength(2));
      expect(observer.changes[0], <Object?>[0, 1]);
      expect(observer.changes[1], <Object?>[1, 2]);

      expect(observer.closed, hasLength(1));
      expect(observer.closed.first, same(drip));
    });

    test('onChange is not fired after close()', () {
      final observer = _RecordingObserver();
      Drip.observer = observer;

      final drip = _CounterDrip();
      drip.close();
      drip.inc(); // no-op after close

      expect(observer.changes, isEmpty);
    });
  });
}
