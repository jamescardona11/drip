# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.1] - 2026-05-11

### Added
- `Drip.isClosed` getter — returns `true` after `close()` is called. Useful as a guard in code that may outlive a `Drip` (background tasks, observers) and in tests that want to assert teardown happened. The getter mirrors the `isClosed` that existed on `_BaseDrip` in 0.0.1; it was accidentally dropped in the refactor.

## [0.1.0] - 2026-05-11

### Changed
- API simplified to a Cubit-style surface. `Drip<S>` now exposes only `state`, `stateStream`, `leak(newState)`, and `close()`. No more event dispatch or interceptor pipeline.
- `Dropper<D>` is the new `InheritedWidget` provider. `DripProvider<D>` is kept as a convenience wrapper over `MultiProvider` with a single child.
- Tightened `analysis_options.yaml` with stricter lints (`avoid_print`, `require_trailing_commas`, `prefer_const_constructors`, `use_super_parameters`, `cancel_subscriptions`, `close_sinks`, etc.) and `strict-casts`.

### Added
- `MultiProvider`, backed by [`package:nested`](https://pub.dev/packages/nested), for composing multiple drips without nested indentation.
- `Dropper.of<D>` / `Dropper.read<D>` / `Dropper.watch<D>` and `BuildContext.read<D>()` / `BuildContext.watch<D>()` extension.
- `DropWidget<D, S, T>` — selector widget that rebuilds only when `selector(state)` returns a new value. Supports `List`, `Map`, and primitive equality out of the box.
- `Dripping<D, S>` — listener-only widget that does not rebuild its child on state changes.
- `DripObserver` — global hook with `onCreate` / `onChange(previous, next)` / `onClose` callbacks. Default is a no-op; install via `Drip.observer = MyObserver()` to plug in logging, analytics, or undo history.
- `ComputedDrip<S>` — a [`Drip`] whose value is derived from other drips. Automatically re-evaluates when any source emits; only re-emits on `!=`. Sources can themselves be `ComputedDrip`s, so composition is transitive. Closes its source subscriptions on `close()`. Fills the same niche as Riverpod's derived providers, with a single class and zero magic.
- `AsyncDrip<T>` and the sealed `AsyncState<T>` (`AsyncIdle` / `AsyncLoading` / `AsyncData` / `AsyncError`) for async data. `AsyncDrip.run(() => future)` emits `Loading -> Data | Error` automatically; `AsyncLoading.previous` keeps the last successful value for stale-while-revalidate UIs. Designed for Dart 3 exhaustive pattern matching with `switch`.
- `topics`, `repository`, and richer `description` in `pubspec.yaml` to improve pub.dev discoverability.
- GitHub Actions CI: format check, analyze, tests with coverage, and `pub publish --dry-run`. Matrix on Flutter `stable` + `beta`.

### Removed
- `DripEvent`, `DripAction` and the `dispatch` method (no event pipeline anymore).
- `BaseInterceptor`, `MemoryInterceptor`, `ActionExecutor` and the `interceptors` parameter on `Drip`'s constructor.
- `DefaultDripLoggerMixin` and the `logger` dependency.
- `DripListener` widget (use `Dripping` instead).
- `GenericStateChangeAction` (no longer needed without `dispatch`).

### Migration from 0.0.1

If you were using the previous (event/interceptor) API, the simplest upgrade path is:

```dart
// Before — 0.0.1
class CountAdded extends DripEvent<int> {}

class CounterDrip extends Drip<int> {
  CounterDrip() : super(0);

  @override
  Stream<int> mutableStateOf(DripEvent event, int state) async* {
    if (event is CountAdded) yield state + 1;
  }
}

// dispatch
CounterDrip().dispatch(CountAdded());
```

```dart
// After — 0.1.0
class CounterDrip extends Drip<int> {
  CounterDrip() : super(0);

  void increment() => leak(state + 1);
}

// call
CounterDrip().increment();
```

Interceptors no longer exist as a first-class concept. If you need cross-cutting behavior (logging, undo history, analytics), wrap calls inside your `Drip` subclass or compose state holders.

## [0.0.1] - 2024

### Added
- Initial release with builder/consumer widgets, interceptors, and dispatchable actions/events.
