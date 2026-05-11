import 'package:drip/drip.dart';
import 'package:flutter_test/flutter_test.dart';

class _UserDrip extends AsyncDrip<String> {
  _UserDrip(this._fakeFetch);
  final Future<String> Function() _fakeFetch;

  Future<void> load() => run(_fakeFetch);
}

void main() {
  group('AsyncState equality', () {
    test('AsyncIdle is equal to AsyncIdle of the same T', () {
      expect(const AsyncIdle<int>(), const AsyncIdle<int>());
      expect(
        const AsyncIdle<int>().hashCode,
        const AsyncIdle<int>().hashCode,
      );
    });

    test('AsyncLoading equality includes previous', () {
      expect(
        const AsyncLoading<int>(previous: 5),
        const AsyncLoading<int>(previous: 5),
      );
      expect(
        const AsyncLoading<int>(previous: 5) ==
            const AsyncLoading<int>(previous: 6),
        isFalse,
      );
    });

    test('AsyncData equality is by value', () {
      expect(const AsyncData<int>(42), const AsyncData<int>(42));
      expect(const AsyncData<int>(42) == const AsyncData<int>(43), isFalse);
    });

    test('AsyncError equality ignores stackTrace', () {
      final err = StateError('oops');
      final a = AsyncError<int>(err, StackTrace.current);
      final b = AsyncError<int>(err, StackTrace.current);
      expect(a, b);
    });

    test('dataOrNull returns value for AsyncData', () {
      expect(const AsyncData<int>(7).dataOrNull, 7);
    });

    test('dataOrNull returns previous for AsyncLoading', () {
      expect(const AsyncLoading<int>(previous: 3).dataOrNull, 3);
      expect(const AsyncLoading<int>().dataOrNull, isNull);
    });

    test('dataOrNull is null for AsyncIdle and AsyncError', () {
      expect(const AsyncIdle<int>().dataOrNull, isNull);
      expect(const AsyncError<int>('e').dataOrNull, isNull);
    });
  });

  group('AsyncDrip', () {
    test('starts in AsyncIdle', () {
      final drip = _UserDrip(() async => 'alice');
      addTearDown(drip.close);

      expect(drip.state, isA<AsyncIdle<String>>());
    });

    test('run() emits Loading then Data on success', () async {
      final drip = _UserDrip(() async => 'alice');
      addTearDown(drip.close);

      final emissions = <AsyncState<String>>[];
      final sub = drip.stateStream.listen(emissions.add);
      addTearDown(sub.cancel);

      // Flush the initial replay.
      await Future<void>.delayed(Duration.zero);

      await drip.load();
      // Allow the post-await leak() to flow through the listener.
      await Future<void>.delayed(Duration.zero);

      expect(emissions, [
        isA<AsyncIdle<String>>(),
        const AsyncLoading<String>(),
        const AsyncData<String>('alice'),
      ]);
    });

    test('run() emits Error on failure', () async {
      final exception = StateError('boom');
      final drip = _UserDrip(() async => throw exception);
      addTearDown(drip.close);

      await drip.load();

      expect(drip.state, isA<AsyncError<String>>());
      final err = drip.state as AsyncError<String>;
      expect(err.error, exception);
      expect(err.stackTrace, isNotNull);
    });

    test('a refresh after data carries previous through Loading', () async {
      var value = 'v1';
      final drip = _UserDrip(() async => value);
      addTearDown(drip.close);

      await drip.load();
      expect(drip.state, const AsyncData<String>('v1'));

      value = 'v2';
      final emissions = <AsyncState<String>>[];
      final sub = drip.stateStream.listen(emissions.add);
      addTearDown(sub.cancel);

      // Replay current state (v1) flushes first.
      await Future<void>.delayed(Duration.zero);
      emissions.clear();

      await drip.load();
      await Future<void>.delayed(Duration.zero);

      expect(emissions, [
        const AsyncLoading<String>(previous: 'v1'),
        const AsyncData<String>('v2'),
      ]);
    });

    test('reset() goes back to AsyncIdle', () async {
      final drip = _UserDrip(() async => 'x');
      addTearDown(drip.close);

      await drip.load();
      drip.reset();

      expect(drip.state, isA<AsyncIdle<String>>());
    });

    test('Dart 3 pattern matching is exhaustive', () {
      final cases = <AsyncState<int>>[
        const AsyncIdle<int>(),
        const AsyncLoading<int>(previous: 1),
        const AsyncData<int>(2),
        AsyncError<int>(StateError('e')),
      ];

      for (final c in cases) {
        final label = switch (c) {
          AsyncIdle<int>() => 'idle',
          AsyncLoading<int>() => 'loading',
          AsyncData<int>() => 'data',
          AsyncError<int>() => 'error',
        };
        expect(label, isIn(['idle', 'loading', 'data', 'error']));
      }
    });
  });
}
