# Drip

<p align="center">
<img src="https://github.com/jamescardona11/drip/blob/main/base_logo.png?raw=true" height="250" alt="Drip Package" />
</p>

**Minimalist Cubit-style state management for Flutter** — built on `Stream` + `InheritedWidget`. Drip is small on purpose: ~50 lines of core, three composable widgets, and a multi-provider out of the box.

## Why drip?

- **Tiny mental model.** Subclass `Drip<S>` and call `leak(newState)` to emit. That's it.
- **No code generation, no boilerplate.** Plain Dart classes; no events, no reducers, no Freezed required.
- **Stream-based.** Every `Drip` exposes a broadcast `stateStream` you can also consume outside the widget tree.
- **Multi-provider built in.** Compose several `Drip`s through `MultiProvider` (powered by `package:nested`).
- **Selector with memoization.** `DropWidget` rebuilds only when the value picked by your selector changes — supports `List`, `Map`, and primitive equality.

| | drip | Cubit (bloc) | Riverpod |
|---|---|---|---|
| Core lines of code | ~50 | thousands | thousands |
| Events / reducers | no | yes (events optional in Cubit) | no |
| Selector widget | built-in | `BlocSelector` | `ref.watch(provider.select)` |
| Code gen needed | never | optional | optional |
| Learning surface | one class, three widgets | many | many |

Drip is intentionally a small library, not a framework. If you need devtools, persistence, async value handling, or sophisticated dependency injection, reach for Riverpod or Bloc. If you want the simplest "state holder + stream" possible, Drip fits.

## Install

```yaml
dependencies:
  drip: ^0.1.0
```

```dart
import 'package:drip/drip.dart';
```

## Quickstart

### 1. Define your state holder

```dart
class CounterDrip extends Drip<int> {
  CounterDrip() : super(0);

  void increment() => leak(state + 1);
  void reset()     => leak(0);
}
```

### 2. Provide it to the widget tree

```dart
DripProvider<CounterDrip>(
  create: (_) => CounterDrip(),
  child: const CounterPage(),
)
```

### 3. Consume it

```dart
class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Dripper<CounterDrip, int>(
          builder: (drip, state) => Text('Counter: $state'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.read<CounterDrip>().increment(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

## The three consumer widgets

| Widget | Purpose | Rebuilds? |
|---|---|---|
| `Dripper<D, S>` | Builder + optional listener. Like `BlocConsumer`. | On every new state |
| `Dripping<D, S>` | Listener only (side effects). | Never — `child` is rebuilt by its parent |
| `DropWidget<D, S, T>` | Selector with memoization. | Only when `selector(state)` returns a new value |

```dart
// Selector — rebuild only when the .count field changes,
// even if other fields of CounterState are mutated.
DropWidget<CounterDrip, CounterState, int>(
  selector: (state) => state.count,
  builder: (drip, count) => Text('$count'),
)
```

## Accessing a Drip from `BuildContext`

```dart
final drip = context.read<CounterDrip>();   // no listening
final drip = context.watch<CounterDrip>();  // listen to updates
final drip = Dropper.of<CounterDrip>(context);
```

## Multi-provider

When several drips need to be available in the same subtree:

```dart
MultiProvider(
  children: [
    Dropper<UserDrip>(drip: UserDrip()),
    Dropper<CartDrip>(drip: CartDrip()),
    Dropper<ThemeDrip>(drip: ThemeDrip()),
  ],
  child: const MyApp(),
)
```

`MultiProvider` is a thin alias over `Nested` from [`package:nested`](https://pub.dev/packages/nested), so the children compose without indentation hell.

## Mental model

```
        ┌──────────────────────────────────────────────┐
        │ Drip<S>                                      │
        │   _state: S         leak(newState)           │
        │   _controller: StreamController<S>.broadcast │
        └──────────────────────────────────────────────┘
                          │ stateStream
                          ▼
        ┌─────────────────────────────────────────────┐
        │  Dropper<D>  (InheritedWidget provider)     │
        └─────────────────────────────────────────────┘
              │            │              │
           Dripper      Dripping      DropWidget
         (rebuild on  (side effect,  (rebuild on
          new state)   no rebuild)    selector change)
```

## Examples

- [Counter](https://github.com/jamescardona11/drip/tree/main/example/counter_app) — minimal `Drip<S>` with `Dripper` and `DropWidget`
- [Todo](https://github.com/jamescardona11/drip/tree/main/example/todo_app) — list management, multiple actions, custom state class

## Maintainers

- [James Cardona](https://github.com/jamescardona11)

Contributions welcome.

## License

MIT — see [LICENSE](./LICENSE).
